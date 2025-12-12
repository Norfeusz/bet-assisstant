import express from 'express'
import { PrismaClient } from '@prisma/client'
import * as path from 'path'
import * as fs from 'fs'

const router = express.Router()
const prisma = new PrismaClient()

// Google Sheets configuration
const SPREADSHEET_ID = process.env.GOOGLE_SHEETS_ID || ''

// Load bet conditions configuration
const BET_CONDITIONS_PATH = path.join(process.cwd(), 'config', 'bet-conditions.json')
let betConditionsConfig: any = null

function loadBetConditions() {
	if (!betConditionsConfig) {
		if (!fs.existsSync(BET_CONDITIONS_PATH)) {
			throw new Error('config/bet-conditions.json not found')
		}
		betConditionsConfig = JSON.parse(fs.readFileSync(BET_CONDITIONS_PATH, 'utf-8'))
	}
	return betConditionsConfig
}

async function getGoogleSheetsClient() {
	const { google } = await import('googleapis')
	const credentialsPath = path.join(process.cwd(), 'config', 'google-sheets-config.json')
	
	if (!fs.existsSync(credentialsPath)) {
		throw new Error('config/google-sheets-config.json not found. Please create it based on config/google-sheets-config.json.example')
	}
	
	const credentials = JSON.parse(fs.readFileSync(credentialsPath, 'utf-8'))
	
	const auth = new google.auth.GoogleAuth({
		credentials,
		scopes: ['https://www.googleapis.com/auth/spreadsheets'],
	})
	
	const authClient = await auth.getClient()
	return google.sheets({ version: 'v4', auth: authClient })
}

interface BetVerificationResult {
	matchId: number
	homeGoals: number | null
	awayGoals: number | null
	homeCorners: number | null
	awayCorners: number | null
	homeOffsides: number | null
	awayOffsides: number | null
	isFinished: boolean
	verified: boolean
	result?: 'tak' | 'nie'
}

/**
 * Verify bet condition based on bet type and actual match results using config file
 */
function verifyBetCondition(
	betType: string,
	betOption: string,
	homeGoals: number | null,
	awayGoals: number | null,
	homeCorners: number | null,
	awayCorners: number | null,
	homeOffsides: number | null,
	awayOffsides: number | null
): 'tak' | 'nie' | null {
	// Load configuration
	const config = loadBetConditions()
	
	// Find matching condition in config
	let condition = config.betConditions.find((c: any) => {
		// Match by betType and optionally betOption
		if (c.betType !== betType) {
			// Check aliases
			if (!c.aliases || !c.aliases.includes(betType)) {
				return false
			}
		}
		// If condition has specific betOption, it must match
		if (c.betOption && c.betOption.toLowerCase() !== betOption.toLowerCase()) {
			return false
		}
		return true
	})
	
	if (!condition) {
		console.warn(`No configuration found for bet type: ${betType}`)
		return null
	}
	
	// Check if required data is available
	if (homeGoals === null || awayGoals === null) {
		return null
	}
	
	// Parse threshold from betOption if needed
	const threshold = parseFloat(betOption)
	
	// Evaluate condition using Function constructor (safer than eval)
	try {
		const conditionFn = new Function(
			'homeGoals',
			'awayGoals',
			'homeCorners',
			'awayCorners',
			'homeOffsides',
			'awayOffsides',
			'threshold',
			`return ${condition.condition};`
		)
		
		const result = conditionFn(
			homeGoals,
			awayGoals,
			homeCorners,
			awayCorners,
			homeOffsides,
			awayOffsides,
			threshold
		)
		
		return result ? 'tak' : 'nie'
	} catch (error) {
		console.error(`Error evaluating condition for ${betType}:`, error)
		return null
	}
}

/**
 * Get result columns based on bet type using config file
 */
function getResultColumns(betType: string): { homeResult: string; awayResult: string } {
	const config = loadBetConditions()
	
	// Find matching condition
	const condition = config.betConditions.find((c: any) => 
		c.betType === betType || (c.aliases && c.aliases.includes(betType))
	)
	
	if (!condition) {
		// Default to goals
		return { homeResult: 'home_goals', awayResult: 'away_goals' }
	}
	
	return {
		homeResult: condition.homeResult,
		awayResult: condition.awayResult
	}
}

/**
 * GET /api/verify-bets
 * Verify bets in both "Typy" and "Kupony" sheets
 */
router.post('/verify-bets', async (req, res) => {
	try {
		console.log('🔍 Starting bet verification...')

		// Get Google Sheets client
		const sheets = await getGoogleSheetsClient()

		// Process both sheets
		const sheetsToProcess = ['Typy', 'Kupony']
		let totalVerified = 0
		let totalUpdated = 0

		for (const sheetName of sheetsToProcess) {
			console.log(`\n📊 Processing sheet: ${sheetName}`)

			// Get all rows from sheet (columns A to AE - up to match_id)
			const range = `${sheetName}!A2:AE`
			const response = await sheets.spreadsheets.values.get({
				spreadsheetId: SPREADSHEET_ID,
				range,
			})

			const rows = response.data.values || []
			console.log(`Found ${rows.length} rows in ${sheetName}`)
			
			if (rows.length > 0) {
				console.log(`Sample first row columns: U=${rows[0][20]}, V=${rows[0][21]}, W=${rows[0][22]}, AD=${rows[0][29]}`)
			}

			const updates: any[] = []

			for (let i = 0; i < rows.length; i++) {
				const row = rows[i]
				const rowIndex = i + 2 // +2 because sheet starts at row 2 (row 1 is header)

				// Column U (index 20) = Wszedł?, Column V (index 21) = Wynik H, Column W (index 22) = Wynik A
				const entered = row[20] // Column U - Wszedł?
				const resultH = row[21] // Column V - Wynik H
				const resultA = row[22] // Column W - Wynik A
				const matchId = row[29] // Column AD - ID Meczu (index 29)

				// Skip if no match ID
				if (!matchId) {
					continue
				}

				// Skip if already has results (both columns filled with non-empty values)
				const hasResultH = resultH && String(resultH).trim() !== '' && String(resultH).trim() !== '-'
				const hasResultA = resultA && String(resultA).trim() !== '' && String(resultA).trim() !== '-'
				
				if (hasResultH && hasResultA) {
					continue
				}

				console.log(`🔍 Checking match ID: ${matchId}, Row: ${rowIndex}`)

				// Get match data from database by id (not fixture_id)
				const match = await prisma.matches.findUnique({
					where: {
						id: parseInt(matchId, 10),
					},
					select: {
						home_team: true,
						away_team: true,
						home_goals: true,
						away_goals: true,
						home_corners: true,
						away_corners: true,
						home_offsides: true,
						away_offsides: true,
						is_finished: true,
					},
				})

				if (!match) {
					console.log(`❌ Match ${matchId} not found in database`)
					continue
				}

				console.log(`✅ Found match: ${match.home_team} vs ${match.away_team}, finished: ${match.is_finished}`)

				// Skip if match not finished
				if (match.is_finished !== 'yes') {
					console.log(`⏳ Match ${matchId} not finished yet`)
					continue
				}

				totalVerified++

				// Get bet type and option from row
				const betType = row[2] // Column C - zakład
				const betOption = row[3] // Column D - typ

				// Verify bet condition
				const result = verifyBetCondition(
					betType,
					betOption,
					match.home_goals,
					match.away_goals,
					match.home_corners,
					match.away_corners,
					match.home_offsides,
					match.away_offsides
				)

				if (result === null) {
					console.log(`⚠️ Cannot verify match ${matchId} - missing data or unknown bet type`)
					continue
				}

				// Get result columns based on bet type from config
				const resultColumns = getResultColumns(betType)
				let homeResult: string | number = '-'
				let awayResult: string | number = '-'

				// Map database fields to values
				if (resultColumns.homeResult !== '-') {
					const field = resultColumns.homeResult as keyof typeof match
					homeResult = match[field] ?? '-'
				}
				if (resultColumns.awayResult !== '-') {
					const field = resultColumns.awayResult as keyof typeof match
					awayResult = match[field] ?? '-'
				}

				// Add update for this row
				updates.push({
					range: `${sheetName}!U${rowIndex}:W${rowIndex}`,
					values: [[result, homeResult, awayResult]],
				})

				totalUpdated++
				console.log(`✅ Match ${matchId}: ${result} (${homeResult} - ${awayResult})`)
			}

			// Batch update all rows in this sheet
			if (updates.length > 0) {
				await sheets.spreadsheets.values.batchUpdate({
					spreadsheetId: SPREADSHEET_ID,
					requestBody: {
						valueInputOption: 'RAW',
						data: updates,
					},
				})
				console.log(`✅ Updated ${updates.length} rows in ${sheetName}`)
			} else {
				console.log(`ℹ️ No updates needed for ${sheetName}`)
			}
		}

		res.json({
			success: true,
			message: `Verified ${totalVerified} matches, updated ${totalUpdated} bets`,
			totalVerified,
			totalUpdated,
		})
	} catch (error) {
		console.error('❌ Error verifying bets:', error)
		res.status(500).json({
			success: false,
			error: error instanceof Error ? error.message : 'Unknown error',
		})
	}
})

export default router
