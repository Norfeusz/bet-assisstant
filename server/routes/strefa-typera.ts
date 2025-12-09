import express from 'express'
import * as path from 'path'
import * as fs from 'fs'
import { PrismaClient } from '@prisma/client'
import { calculateBetStatistics } from '../utils/bet-statistics'
import { TablesBackup } from '../utils/backup-tables'

const router = express.Router()
const prisma = new PrismaClient()
const tablesBackup = new TablesBackup()

// Google Sheets configuration
const SPREADSHEET_ID = process.env.GOOGLE_SHEETS_ID || ''
const SHEET_NAME = 'Bet Builder'

console.log('[Strefa Typera] GOOGLE_SHEETS_ID from env:', process.env.GOOGLE_SHEETS_ID)
console.log('[Strefa Typera] SPREADSHEET_ID:', SPREADSHEET_ID)

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

interface AddMatchRequest {
	homeTeam: string
	awayTeam: string
	league?: string
	date?: string
	betType?: string
	betOption?: string
	assumption?: string
	odds?: number
	superbetLink?: string
	flashscoreLink?: string
}

// NEW ENDPOINT: Add match with comprehensive statistics (Step 2 format)
router.post('/strefa-typera/add-match-v2', async (req, res) => {
	try {
		console.log('[Strefa Typera V2] Request received:', req.body)
		
		const { homeTeam, awayTeam, league, date, betType, betOption, odds, superbetLink, flashscoreLink } = req.body as AddMatchRequest

		if (!homeTeam || !awayTeam || !betType || !betOption || !odds) {
			console.log('[Strefa Typera V2] Missing required fields')
			return res.status(400).json({ error: 'All fields are required' })
		}

		if (!SPREADSHEET_ID) {
			console.log('[Strefa Typera V2] GOOGLE_SHEETS_ID not configured')
			return res.status(500).json({ error: 'GOOGLE_SHEETS_ID not configured in .env' })
		}

		// Format date to YYYY-MM-DD
		const formattedDate = date ? new Date(date).toISOString().split('T')[0] : ''
		
		console.log('[Strefa Typera V2] Fetching match data from database...')
		// Get match data from database to retrieve standing, country, league, match_id
		const match = await prisma.matches.findFirst({
			where: {
				home_team: homeTeam,
				away_team: awayTeam,
				match_date: date ? new Date(date) : undefined,
			},
			select: {
				id: true,
				country: true,
				league: true,
				standing_home: true,
				standing_away: true,
			}
		})

		if (!match) {
			console.log('[Strefa Typera V2] Match not found in database')
			return res.status(404).json({ error: 'Match not found in database' })
		}

		console.log('[Strefa Typera V2] Calculating statistics for 5, 10, and 15 matches...')
		
		// Calculate statistics for all combinations: 5/10/15 matches × overall/ha
		const stats5Overall = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'overall', league, 5)
		const stats5Ha = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'ha', league, 5)
		const stats10Overall = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'overall', league, 10)
		const stats10Ha = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'ha', league, 10)
		const stats15Overall = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'overall', league, 15)
		const stats15Ha = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'ha', league, 15)
		
		console.log('[Strefa Typera V2] Statistics calculated')

		// Helper function to format percentage
		const formatPercent = (value: number | string) => {
			return typeof value === 'string' ? value : `${value}%`
		}

		// Calculate column E (szanse) - average of valid values from H:O
		// Only count numeric values, ignore "za mało danych"
		// Minimum 4 values required
		const percentages = [
			stats5Overall.homePercentage,
			stats5Overall.awayPercentage,
			stats5Ha.homePercentage,
			stats5Ha.awayPercentage,
			stats10Overall.homePercentage,
			stats10Overall.awayPercentage,
			stats10Ha.homePercentage,
			stats10Ha.awayPercentage,
		]

		// Filter only numeric values
		const validPercentages = percentages.filter(p => typeof p === 'number') as number[]
		
		let szanse: string
		if (validPercentages.length < 4) {
			// Not enough data - need at least 4 values
			szanse = 'za mało danych'
		} else {
			// Calculate average from valid values
			const sum = validPercentages.reduce((acc, val) => acc + val, 0)
			const average = sum / validPercentages.length
			szanse = average.toFixed(1).replace('.', ',') + '%'
		}

		// Prepare single row with all columns A-AG
		const row = [
			homeTeam,                              // A - home_team
			awayTeam,                              // B - away_team
			betType,                               // C - zakład
			betOption,                             // D - typ
			szanse,                                // E - szanse (calculated or "za mało danych")
			odds || '',                            // F - kurs
			'',                                    // G - moc bet (calculated in sheet: =E*F)
			formatPercent(stats5Overall.homePercentage),   // H - 5 H % (o)
			formatPercent(stats5Overall.awayPercentage),   // I - 5 A % (o)
			formatPercent(stats5Ha.homePercentage),        // J - 5 H % (H/A)
			formatPercent(stats5Ha.awayPercentage),        // K - 5 A % (H/A)
			formatPercent(stats10Overall.homePercentage),  // L - 10 H % (o)
			formatPercent(stats10Overall.awayPercentage),  // M - 10 A % (o)
			formatPercent(stats10Ha.homePercentage),       // N - 10 H % (H/A)
			formatPercent(stats10Ha.awayPercentage),       // O - 10 A % (H/A)
			formatPercent(stats15Overall.homePercentage),  // P - 15 H % (o)
			formatPercent(stats15Overall.awayPercentage),  // Q - 15 A % (o)
			formatPercent(stats15Ha.homePercentage),       // R - 15 H % (H/A)
			formatPercent(stats15Ha.awayPercentage),       // S - 15 A % (H/A)
			'',                                    // T - Kupon (r)
			'',                                    // U - Wszedł (r)
			'',                                    // V - Wynik H (r)
			'',                                    // W - Wynik A (r)
			match.standing_home || '',             // X - home_standing
			match.standing_away || '',             // Y - away_standing
			'',                                    // Z - Komentarz (r)
			match.country,                         // AA - Kraj
			match.league,                          // AB - Liga
			formattedDate,                         // AC - Data meczu
			match.id,                              // AD - ID Meczu
			'',                                    // AE - ID Kuponu (r)
			superbetLink || '',                    // AF - Superbet link
			flashscoreLink || '',                  // AG - Flashscore link
		]

		console.log('[Strefa Typera V2] Getting Google Sheets client...')
		// Get Google Sheets client
		const sheets = await getGoogleSheetsClient()
		console.log('[Strefa Typera V2] Client ready, appending row...')

		// Append row to sheet (A to AG to include all columns)
		await sheets.spreadsheets.values.append({
			spreadsheetId: SPREADSHEET_ID,
			range: `${SHEET_NAME}!A:AG`,
			valueInputOption: 'USER_ENTERED',
			requestBody: {
				values: [row],
			},
		})
		
		console.log('[Strefa Typera V2] Row appended successfully')

		res.json({
			success: true,
			message: `Added 1 row to Google Sheets with comprehensive statistics`,
			rowsAdded: 1,
			homeTeam,
			awayTeam,
			betType,
			betOption,
			odds,
			szanse: szanse, // can be string "za mało danych" or number like "45.5"
			matchId: match.id,
			statistics: {
				stats5Overall,
				stats5Ha,
				stats10Overall,
				stats10Ha,
				stats15Overall,
				stats15Ha,
			}
		})
	} catch (error: any) {
		console.error('[Strefa Typera V2] Error:', error)
		res.status(500).json({ error: error.message || 'Internal server error' })
	}
})

// OLD ENDPOINT (kept for backwards compatibility, will be deprecated)
// Add match with full bet analysis (bet type, options, statistics, odds)
router.post('/strefa-typera/add-match-full', async (req, res) => {
	try {
		console.log('[Strefa Typera] Request received:', req.body)
		
		const { homeTeam, awayTeam, league, date, betType, betOption, odds, superbetLink, flashscoreLink } = req.body as AddMatchRequest

		if (!homeTeam || !awayTeam || !betType || !betOption || !odds) {
			console.log('[Strefa Typera] Missing required fields')
			return res.status(400).json({ error: 'All fields are required' })
		}

		if (!SPREADSHEET_ID) {
			console.log('[Strefa Typera] GOOGLE_SHEETS_ID not configured')
			return res.status(500).json({ error: 'GOOGLE_SHEETS_ID not configured in .env' })
		}

		// Format date to YYYY-MM-DD
		const formattedDate = date ? new Date(date).toISOString().split('T')[0] : ''
		
		console.log('[Strefa Typera] Fetching match data from database...')
		// Get match data from database to retrieve standing, country, league, match_id
		const match = await prisma.matches.findFirst({
			where: {
				home_team: homeTeam,
				away_team: awayTeam,
				match_date: date ? new Date(date) : undefined,
			},
			select: {
				id: true,
				country: true,
				league: true,
				standing_home: true,
				standing_away: true,
			}
		})

		if (!match) {
			console.log('[Strefa Typera] Match not found in database')
			return res.status(404).json({ error: 'Match not found in database' })
		}

		console.log('[Strefa Typera] Calculating statistics for 5, 10, and 15 matches...')
		
		// Calculate statistics for all combinations: 5/10/15 matches × overall/ha
		const stats5Overall = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'overall', league, 5)
		const stats5Ha = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'ha', league, 5)
		const stats10Overall = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'overall', league, 10)
		const stats10Ha = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'ha', league, 10)
		const stats15Overall = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'overall', league, 15)
		const stats15Ha = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'ha', league, 15)
		
		console.log('[Strefa Typera] Statistics calculated')

		// Helper function to format percentage
		const formatPercent = (value: number | string) => {
			return typeof value === 'string' ? value : `${value}%`
		}

		// Calculate column E (szanse) - average of valid values from H:O
		// Only count numeric values, ignore "za mało danych"
		// Minimum 4 values required
		const percentages = [
			stats5Overall.homePercentage,
			stats5Overall.awayPercentage,
			stats5Ha.homePercentage,
			stats5Ha.awayPercentage,
			stats10Overall.homePercentage,
			stats10Overall.awayPercentage,
			stats10Ha.homePercentage,
			stats10Ha.awayPercentage,
		]

		// Filter only numeric values
		const validPercentages = percentages.filter(p => typeof p === 'number') as number[]
		
		let szanse: string
		if (validPercentages.length < 4) {
			// Not enough data - need at least 4 values
			szanse = 'za mało danych'
		} else {
			// Calculate average from valid values
			const sum = validPercentages.reduce((acc, val) => acc + val, 0)
			const average = sum / validPercentages.length
			szanse = average.toFixed(1).replace('.', ',') + '%'
		}

		// Prepare single row with all columns A-AG (Step 7 format)
		const row = [
			homeTeam,                              // A - home_team
			awayTeam,                              // B - away_team
			betType,                               // C - zakład
			betOption,                             // D - typ
			szanse,                                // E - szanse (calculated or "za mało danych")
			odds || '',                            // F - kurs
			'',                                    // G - moc bet (calculated in sheet: =E*F)
			formatPercent(stats5Overall.homePercentage),   // H - 5 H % (o)
			formatPercent(stats5Overall.awayPercentage),   // I - 5 A % (o)
			formatPercent(stats5Ha.homePercentage),        // J - 5 H % (H/A)
			formatPercent(stats5Ha.awayPercentage),        // K - 5 A % (H/A)
			formatPercent(stats10Overall.homePercentage),  // L - 10 H % (o)
			formatPercent(stats10Overall.awayPercentage),  // M - 10 A % (o)
			formatPercent(stats10Ha.homePercentage),       // N - 10 H % (H/A)
			formatPercent(stats10Ha.awayPercentage),       // O - 10 A % (H/A)
			formatPercent(stats15Overall.homePercentage),  // P - 15 H % (o)
			formatPercent(stats15Overall.awayPercentage),  // Q - 15 A % (o)
			formatPercent(stats15Ha.homePercentage),       // R - 15 H % (H/A)
			formatPercent(stats15Ha.awayPercentage),       // S - 15 A % (H/A)
			'',                                    // T - Kupon (r)
			'',                                    // U - Wszedł (r)
			'',                                    // V - Wynik H (r)
			'',                                    // W - Wynik A (r)
			match.standing_home || '',             // X - home_standing
			match.standing_away || '',             // Y - away_standing
			'',                                    // Z - Komentarz (r)
			match.country,                         // AA - Kraj
			match.league,                          // AB - Liga
			formattedDate,                         // AC - Data meczu
			match.id,                              // AD - ID Meczu
			'',                                    // AE - ID Kuponu (r)
			superbetLink || '',                    // AF - Superbet link
			flashscoreLink || '',                  // AG - Flashscore link
		]

		console.log('[Strefa Typera] Getting Google Sheets client...')
		// Get Google Sheets client
		const sheets = await getGoogleSheetsClient()
		console.log('[Strefa Typera] Client ready, appending row...')

		// Append row to sheet (A to AG to include all columns)
		await sheets.spreadsheets.values.append({
			spreadsheetId: SPREADSHEET_ID,
			range: `${SHEET_NAME}!A:AG`,
			valueInputOption: 'USER_ENTERED',
			requestBody: {
				values: [row],
			},
		})
		
		console.log('[Strefa Typera] Row appended successfully')

		res.json({
			success: true,
			message: `Added 1 row to Google Sheets with comprehensive statistics`,
			rowsAdded: 1,
			homeTeam,
			awayTeam,
			betType,
			betOption,
			odds,
			szanse: szanse,
			matchId: match.id,
			statistics: {
				stats5Overall,
				stats5Ha,
				stats10Overall,
				stats10Ha,
				stats15Overall,
				stats15Ha,
			}
		})
	} catch (error: any) {
		console.error('[Strefa Typera] Error:', error)
		res.status(500).json({ error: error.message || 'Internal server error' })
	}
})

// KROK 3: Backfill function to update "Typy" sheet with missing data
router.post('/strefa-typera/backfill-typy', async (req, res) => {
	try {
		console.log('[Strefa Typera Backfill] Starting backfill process for "Typy" sheet...')
		
		if (!SPREADSHEET_ID) {
			console.log('[Strefa Typera Backfill] GOOGLE_SHEETS_ID not configured')
			return res.status(500).json({ error: 'GOOGLE_SHEETS_ID not configured in .env' })
		}

		const sheets = await getGoogleSheetsClient()
		const sheetName = 'Typy'
		
		console.log('[Strefa Typera Backfill] Fetching all rows from "Typy" sheet...')
		
		// Get all rows from "Typy" sheet (A to AG to include superbet and flashscore links)
		const response = await sheets.spreadsheets.values.get({
			spreadsheetId: SPREADSHEET_ID,
			range: `${sheetName}!A:AG`,
		})

		const rows = response.data.values || []
		
		if (rows.length <= 1) {
			console.log('[Strefa Typera Backfill] No data rows found (only header or empty)')
			return res.json({ success: true, message: 'No data rows to backfill', rowsUpdated: 0 })
		}

		console.log(`[Strefa Typera Backfill] Found ${rows.length - 1} data rows`)
		
		const updates: any[] = []
		let rowsUpdated = 0
		let rowsSkipped = 0
		let rowsNotFound = 0

		// Skip header row (index 0), process data rows starting from index 1
		for (let i = 1; i < rows.length; i++) {
			const row = rows[i]
			const rowNumber = i + 1 // Sheet row number (1-indexed)
			
			// Extract existing data
			const homeTeam = row[0] || ''  // A
			const awayTeam = row[1] || ''  // B
			const betType = row[2] || ''   // C
			const betOption = row[3] || '' // D
			const dateStr = row[28] || ''  // AC - Data meczu
			
			if (!homeTeam || !awayTeam || !betType || !betOption) {
				console.log(`[Strefa Typera Backfill] Row ${rowNumber}: Missing required fields, skipping`)
				rowsSkipped++
				continue
			}

			// Skip only if already has date filled (backfill will update/fill date from database)
			// Links (AF, AG) are preserved from sheet as they don't exist in matches table
			const hasDate = row[28] && row[28] !== ''
			if (hasDate) {
				console.log(`[Strefa Typera Backfill] Row ${rowNumber}: Already has date, skipping`)
				rowsSkipped++
				continue
			}

			console.log(`[Strefa Typera Backfill] Processing row ${rowNumber}: ${homeTeam} vs ${awayTeam}`)

			// Parse date
			let matchDate: Date | undefined
			if (dateStr) {
				matchDate = new Date(dateStr)
				if (isNaN(matchDate.getTime())) {
					console.log(`[Strefa Typera Backfill] Row ${rowNumber}: Invalid date format (${dateStr}), skipping`)
					rowsSkipped++
					continue
				}
				console.log(`[Strefa Typera Backfill] Row ${rowNumber}: Parsed date: ${matchDate.toISOString()}`)
			}

			// Find match in database
			console.log(`[Strefa Typera Backfill] Row ${rowNumber}: Searching for match - Home: "${homeTeam}", Away: "${awayTeam}", Date: ${matchDate ? matchDate.toISOString() : 'undefined'}`)
			const match = await prisma.matches.findFirst({
				where: {
					home_team: homeTeam,
					away_team: awayTeam,
					match_date: matchDate,
				},
				select: {
					id: true,
					country: true,
					league: true,
					standing_home: true,
					standing_away: true,
					match_date: true,
				}
			})

			if (!match) {
				console.log(`[Strefa Typera Backfill] Row ${rowNumber}: Match not found in database - trying without date filter...`)
				
				// Try without date to see if team names match
				const matchWithoutDate = await prisma.matches.findFirst({
					where: {
						home_team: homeTeam,
						away_team: awayTeam,
					},
					select: {
						id: true,
						match_date: true,
						home_team: true,
						away_team: true,
					}
				})
				
				if (matchWithoutDate) {
					console.log(`[Strefa Typera Backfill] Row ${rowNumber}: Found match with different date: ${matchWithoutDate.match_date?.toISOString()} (expected: ${matchDate?.toISOString()})`)
				} else {
					console.log(`[Strefa Typera Backfill] Row ${rowNumber}: No match found even without date filter - team names don't match`)
				}
				
				rowsNotFound++
				continue
			}

			console.log(`[Strefa Typera Backfill] Row ${rowNumber}: Match found (ID: ${match.id}), calculating statistics...`)

			// Calculate statistics for all combinations
			const stats5Overall = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'overall', match.league, 5)
			const stats5Ha = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'ha', match.league, 5)
			const stats10Overall = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'overall', match.league, 10)
			const stats10Ha = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'ha', match.league, 10)
			const stats15Overall = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'overall', match.league, 15)
			const stats15Ha = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'ha', match.league, 15)

			// Helper function to format percentage
			const formatPercent = (value: number | string) => {
				return typeof value === 'string' ? value : `${value}%`
			}

			// Calculate column E (szanse) - only from valid values, minimum 4 required
			const percentages = [
				stats5Overall.homePercentage,
				stats5Overall.awayPercentage,
				stats5Ha.homePercentage,
				stats5Ha.awayPercentage,
				stats10Overall.homePercentage,
				stats10Overall.awayPercentage,
				stats10Ha.homePercentage,
				stats10Ha.awayPercentage,
			]
			
			// Filter only numeric values
			const validPercentages = percentages.filter(p => typeof p === 'number') as number[]
			
			let szanse: string
			if (validPercentages.length < 4) {
				// Not enough data - need at least 4 values
				szanse = 'za mało danych'
			} else {
				// Calculate average from valid values
				const sum = validPercentages.reduce((acc, val) => acc + val, 0)
				const average = sum / validPercentages.length
				szanse = average.toFixed(1).replace('.', ',') + '%'
			}

			// Prepare update data for specific columns
			// We'll update: E, H-S, X, Y, AA, AB, AC, AD, AF, AG
			const updateData = {
				range: `${sheetName}!E${rowNumber}:AG${rowNumber}`,
				values: [[
					szanse,                                // E - szanse (calculated or "za mało danych")
					row[5] || '',                          // F - kurs (keep existing)
					row[6] || '',                          // G - moc bet (keep existing)
					formatPercent(stats5Overall.homePercentage),   // H
					formatPercent(stats5Overall.awayPercentage),   // I
					formatPercent(stats5Ha.homePercentage),        // J
					formatPercent(stats5Ha.awayPercentage),        // K
					formatPercent(stats10Overall.homePercentage),  // L
					formatPercent(stats10Overall.awayPercentage),  // M
					formatPercent(stats10Ha.homePercentage),       // N
					formatPercent(stats10Ha.awayPercentage),       // O
					formatPercent(stats15Overall.homePercentage),  // P
					formatPercent(stats15Overall.awayPercentage),  // Q
					formatPercent(stats15Ha.homePercentage),       // R
					formatPercent(stats15Ha.awayPercentage),       // S
					row[19] || '',                         // T - Kupon (keep existing)
					row[20] || '',                         // U - Wszedł (keep existing)
					row[21] || '',                         // V - Wynik H (keep existing)
					row[22] || '',                         // W - Wynik A (keep existing)
					match.standing_home || '',             // X
					match.standing_away || '',             // Y
					row[25] || '',                         // Z - Komentarz (keep existing)
					match.country,                         // AA
					match.league,                          // AB
					match.match_date ? match.match_date.toISOString().split('T')[0] : '', // AC - Data
					match.id,                              // AD - Match ID
					row[30] || '',                         // AE - ID Kuponu (keep existing)
					row[31] || '',                         // AF - Superbet link (keep existing)
					row[32] || '',                         // AG - Flashscore link (keep existing)
				]]
			}

			updates.push(updateData)
			rowsUpdated++
			
			console.log(`[Strefa Typera Backfill] Row ${rowNumber}: Prepared update`)
		}

		if (updates.length === 0) {
			console.log('[Strefa Typera Backfill] No rows to update')
			return res.json({
				success: true,
				message: 'No rows needed updating',
				rowsUpdated: 0,
				rowsSkipped,
				rowsNotFound,
			})
		}

		console.log(`[Strefa Typera Backfill] Applying ${updates.length} updates to sheet...`)

		// Apply all updates using batchUpdate
		const batchUpdateData = updates.map(u => ({
			range: u.range,
			values: u.values,
		}))

		await sheets.spreadsheets.values.batchUpdate({
			spreadsheetId: SPREADSHEET_ID,
			requestBody: {
				valueInputOption: 'USER_ENTERED',
				data: batchUpdateData,
			},
		})

		console.log(`[Strefa Typera Backfill] Backfill completed successfully!`)

		res.json({
			success: true,
			message: `Backfill completed: ${rowsUpdated} rows updated`,
			rowsUpdated,
			rowsSkipped,
			rowsNotFound,
			totalRows: rows.length - 1,
		})
	} catch (error: any) {
		console.error('[Strefa Typera Backfill] Error:', error)
		res.status(500).json({ error: error.message || 'Internal server error' })
	}
})

// Backfill function for "Bet Builder" sheet
router.post('/strefa-typera/backfill-bet-builder', async (req, res) => {
	try {
		console.log('[Strefa Typera Backfill BB] Starting backfill process for "Bet Builder" sheet...')
		
		if (!SPREADSHEET_ID) {
			console.log('[Strefa Typera Backfill BB] GOOGLE_SHEETS_ID not configured')
			return res.status(500).json({ error: 'GOOGLE_SHEETS_ID not configured in .env' })
		}

		const sheets = await getGoogleSheetsClient()
		const sheetName = 'Bet Builder'
		
		console.log('[Strefa Typera Backfill BB] Fetching all rows from "Bet Builder" sheet...')
		
		// Get all rows from "Bet Builder" sheet (A to AG to include superbet and flashscore links)
		const response = await sheets.spreadsheets.values.get({
			spreadsheetId: SPREADSHEET_ID,
			range: `${sheetName}!A:AG`,
		})

		const rows = response.data.values || []
		
		if (rows.length <= 1) {
			console.log('[Strefa Typera Backfill BB] No data rows found (only header or empty)')
			return res.json({ success: true, message: 'No data rows to backfill', rowsUpdated: 0 })
		}

		console.log(`[Strefa Typera Backfill BB] Found ${rows.length - 1} data rows`)
		
		const updates: any[] = []
		let rowsUpdated = 0
		let rowsSkipped = 0
		let rowsNotFound = 0

		// Skip header row (index 0), process data rows starting from index 1
		for (let i = 1; i < rows.length; i++) {
			const row = rows[i]
			const rowNumber = i + 1 // Sheet row number (1-indexed)
			
			// Extract existing data
			const homeTeam = row[0] || ''  // A
			const awayTeam = row[1] || ''  // B
			const betType = row[2] || ''   // C
			const betOption = row[3] || '' // D
			const dateStr = row[28] || ''  // AC - Data meczu
			
			if (!homeTeam || !awayTeam || !betType || !betOption) {
				console.log(`[Strefa Typera Backfill BB] Row ${rowNumber}: Missing required fields, skipping`)
				rowsSkipped++
				continue
			}

			// Skip only if already has date filled (backfill will update/fill date from database)
			// Links (AF, AG) are preserved from sheet as they don't exist in matches table
			const hasDate = row[28] && row[28] !== ''
			if (hasDate) {
				console.log(`[Strefa Typera Backfill BB] Row ${rowNumber}: Already has date, skipping`)
				rowsSkipped++
				continue
			}

			console.log(`[Strefa Typera Backfill BB] Processing row ${rowNumber}: ${homeTeam} vs ${awayTeam}`)

			// Parse date
			let matchDate: Date | undefined
			if (dateStr) {
				matchDate = new Date(dateStr)
				if (isNaN(matchDate.getTime())) {
					console.log(`[Strefa Typera Backfill BB] Row ${rowNumber}: Invalid date format (${dateStr}), skipping`)
					rowsSkipped++
					continue
				}
				console.log(`[Strefa Typera Backfill BB] Row ${rowNumber}: Parsed date: ${matchDate.toISOString()}`)
			}

			// Find match in database
			console.log(`[Strefa Typera Backfill BB] Row ${rowNumber}: Searching for match - Home: "${homeTeam}", Away: "${awayTeam}", Date: ${matchDate ? matchDate.toISOString() : 'undefined'}`)
			const match = await prisma.matches.findFirst({
				where: {
					home_team: homeTeam,
					away_team: awayTeam,
					match_date: matchDate,
				},
				select: {
					id: true,
					country: true,
					league: true,
					standing_home: true,
					standing_away: true,
					match_date: true,
				}
			})

			if (!match) {
				console.log(`[Strefa Typera Backfill BB] Row ${rowNumber}: Match not found in database - trying without date filter...`)
				
				// Try without date to see if team names match
				const matchWithoutDate = await prisma.matches.findFirst({
					where: {
						home_team: homeTeam,
						away_team: awayTeam,
					},
					select: {
						id: true,
						match_date: true,
						home_team: true,
						away_team: true,
					}
				})
				
				if (matchWithoutDate) {
					console.log(`[Strefa Typera Backfill BB] Row ${rowNumber}: Found match with different date: ${matchWithoutDate.match_date?.toISOString()} (expected: ${matchDate?.toISOString()})`)
				} else {
					console.log(`[Strefa Typera Backfill BB] Row ${rowNumber}: No match found even without date filter - team names don't match`)
				}
				
				rowsNotFound++
				continue
			}

			console.log(`[Strefa Typera Backfill BB] Row ${rowNumber}: Match found (ID: ${match.id}), calculating statistics...`)

			// Calculate statistics for all combinations
			const stats5Overall = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'overall', match.league, 5)
			const stats5Ha = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'ha', match.league, 5)
			const stats10Overall = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'overall', match.league, 10)
			const stats10Ha = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'ha', match.league, 10)
			const stats15Overall = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'overall', match.league, 15)
			const stats15Ha = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'ha', match.league, 15)

			// Helper function to format percentage
			const formatPercent = (value: number | string) => {
				return typeof value === 'string' ? value : `${value}%`
			}

			// Calculate column E (szanse) - only from valid values, minimum 4 required
			const percentages = [
				stats5Overall.homePercentage,
				stats5Overall.awayPercentage,
				stats5Ha.homePercentage,
				stats5Ha.awayPercentage,
				stats10Overall.homePercentage,
				stats10Overall.awayPercentage,
				stats10Ha.homePercentage,
				stats10Ha.awayPercentage,
			]
			
			// Filter only numeric values
			const validPercentages = percentages.filter(p => typeof p === 'number') as number[]
			
			let szanse: string
			if (validPercentages.length < 4) {
				// Not enough data - need at least 4 values
				szanse = 'za mało danych'
			} else {
				// Calculate average from valid values
				const sum = validPercentages.reduce((acc, val) => acc + val, 0)
				const average = sum / validPercentages.length
				szanse = average.toFixed(1).replace('.', ',') + '%'
			}

			// Prepare update data for specific columns
			// We'll update: E, H-S, X, Y, AA, AB, AC, AD, AF, AG
			const updateData = {
				range: `${sheetName}!E${rowNumber}:AG${rowNumber}`,
				values: [[
					szanse,                                // E - szanse (calculated or "za mało danych")
					row[5] || '',                          // F - kurs (keep existing)
					row[6] || '',                          // G - moc bet (keep existing)
					formatPercent(stats5Overall.homePercentage),   // H
					formatPercent(stats5Overall.awayPercentage),   // I
					formatPercent(stats5Ha.homePercentage),        // J
					formatPercent(stats5Ha.awayPercentage),        // K
					formatPercent(stats10Overall.homePercentage),  // L
					formatPercent(stats10Overall.awayPercentage),  // M
					formatPercent(stats10Ha.homePercentage),       // N
					formatPercent(stats10Ha.awayPercentage),       // O
					formatPercent(stats15Overall.homePercentage),  // P
					formatPercent(stats15Overall.awayPercentage),  // Q
					formatPercent(stats15Ha.homePercentage),       // R
					formatPercent(stats15Ha.awayPercentage),       // S
					row[19] || '',                         // T - Kupon (keep existing)
					row[20] || '',                         // U - Wszedł (keep existing)
					row[21] || '',                         // V - Wynik H (keep existing)
					row[22] || '',                         // W - Wynik A (keep existing)
					match.standing_home || '',             // X
					match.standing_away || '',             // Y
					row[25] || '',                         // Z - Komentarz (keep existing)
					match.country,                         // AA
					match.league,                          // AB
					match.match_date ? match.match_date.toISOString().split('T')[0] : '', // AC - Data
					match.id,                              // AD - Match ID
					row[30] || '',                         // AE - ID Kuponu (keep existing)
					row[31] || '',                         // AF - Superbet link (keep existing)
					row[32] || '',                         // AG - Flashscore link (keep existing)
				]]
			}

			updates.push(updateData)
			rowsUpdated++
			
			console.log(`[Strefa Typera Backfill BB] Row ${rowNumber}: Prepared update`)
		}

		if (updates.length === 0) {
			console.log('[Strefa Typera Backfill BB] No rows to update')
			return res.json({
				success: true,
				message: 'No rows needed updating',
				rowsUpdated: 0,
				rowsSkipped,
				rowsNotFound,
			})
		}

		console.log(`[Strefa Typera Backfill BB] Applying ${updates.length} updates to sheet...`)

		// Apply all updates using batchUpdate
		const batchUpdateData = updates.map(u => ({
			range: u.range,
			values: u.values,
		}))

		await sheets.spreadsheets.values.batchUpdate({
			spreadsheetId: SPREADSHEET_ID,
			requestBody: {
				valueInputOption: 'USER_ENTERED',
				data: batchUpdateData,
			},
		})

		console.log(`[Strefa Typera Backfill BB] Backfill completed successfully!`)

		res.json({
			success: true,
			message: `Backfill completed: ${rowsUpdated} rows updated`,
			rowsUpdated,
			rowsSkipped,
			rowsNotFound,
			totalRows: rows.length - 1,
		})
	} catch (error: any) {
		console.error('[Strefa Typera Backfill BB] Error:', error)
		res.status(500).json({ error: error.message || 'Internal server error' })
	}
})

// KROK 18: Accept types - copy from Bet Builder to Typy and save to database
router.post('/strefa-typera/accept-types', async (req, res) => {
	try {
		console.log('[Strefa Typera Accept Types] Starting to copy from Bet Builder to Typy...')

		if (!SPREADSHEET_ID) {
			console.log('[Strefa Typera Accept Types] GOOGLE_SHEETS_ID not configured')
			return res.status(500).json({ error: 'GOOGLE_SHEETS_ID not configured in .env' })
		}

		const sheets = await getGoogleSheetsClient()

		// Get all rows from "Bet Builder" sheet
		console.log('[Strefa Typera Accept Types] Fetching rows from Bet Builder...')
		const betBuilderResponse = await sheets.spreadsheets.values.get({
			spreadsheetId: SPREADSHEET_ID,
			range: 'Bet Builder!A:AG',
		})

		const betBuilderRows = betBuilderResponse.data.values || []

		if (betBuilderRows.length <= 1) {
			console.log('[Strefa Typera Accept Types] No data rows in Bet Builder (only header or empty)')
			return res.json({ success: true, message: 'No rows to copy', rowsCopied: 0 })
		}

		// Skip header (first row), get all data rows
		const dataRows = betBuilderRows.slice(1)
		console.log(`[Strefa Typera Accept Types] Found ${dataRows.length} rows to copy`)

		if (dataRows.length === 0) {
			return res.json({ success: true, message: 'No data rows to copy', rowsCopied: 0 })
		}

		// Append all data rows to "Typy" sheet
		console.log('[Strefa Typera Accept Types] Appending rows to Typy sheet...')
		await sheets.spreadsheets.values.append({
			spreadsheetId: SPREADSHEET_ID,
			range: 'Typy!A:AG',
			valueInputOption: 'USER_ENTERED',
			requestBody: {
				values: dataRows,
			},
		})

		console.log(`[Strefa Typera Accept Types] Successfully copied ${dataRows.length} rows to Typy`)

		// KROK 24: Save to database
		console.log('[Strefa Typera Accept Types] Saving to database...')
		let dbInserted = 0
		for (const row of dataRows) {
			try {
				await prisma.bets.create({
					data: {
						home_team: row[0] || '',
						away_team: row[1] || '',
						bet_type: row[2] || '',
						bet_option: row[3] || '',
						szanse: row[4] || null,
						odds: row[5] ? parseFloat(row[5]) : null,
						moc_bet: row[6] ? parseFloat(row[6]) : null,
						stat_5_h_overall: row[7] || null,
						stat_5_a_overall: row[8] || null,
						stat_5_h_ha: row[9] || null,
						stat_5_a_ha: row[10] || null,
						stat_10_h_overall: row[11] || null,
						stat_10_a_overall: row[12] || null,
						stat_10_h_ha: row[13] || null,
						stat_10_a_ha: row[14] || null,
						stat_15_h_overall: row[15] || null,
						stat_15_a_overall: row[16] || null,
						stat_15_h_ha: row[17] || null,
						stat_15_a_ha: row[18] || null,
						entered: row[19] || null,
						result_home: row[20] ? parseInt(row[20]) : null,
						result_away: row[21] ? parseInt(row[21]) : null,
						standing_home: row[22] ? parseInt(row[22]) : null,
						standing_away: row[23] ? parseInt(row[23]) : null,
						comment: row[24] || null,
						country: row[25] || null,
						league: row[26] || null,
						superbet_link: row[27] || null,
						match_date: row[28] && !isNaN(Date.parse(row[28])) ? new Date(row[28]) : null,
						match_id: row[29] ? parseInt(row[29]) : null,
						flashscore_link: row[32] || null,
					}
				})
				dbInserted++
			} catch (err: any) {
				console.error(`[Strefa Typera Accept Types] Error inserting to DB:`, err.message)
			}
		}
		console.log(`[Strefa Typera Accept Types] Inserted ${dbInserted} rows to database`)

		// KROK 25: Create backup after saving
		console.log('[Strefa Typera Accept Types] Creating backup...')
		const backupResult = await tablesBackup.backupTables()
		if (!backupResult.success) {
			console.warn('[Strefa Typera Accept Types] Backup failed but continuing:', backupResult.error)
		}

		res.json({
			success: true,
			message: `Copied ${dataRows.length} rows from Bet Builder to Typy`,
			rowsCopied: dataRows.length,
			dbInserted,
			backupCreated: backupResult.success,
		})
	} catch (error: any) {
		console.error('[Strefa Typera Accept Types] Error:', error)
		res.status(500).json({ error: error.message || 'Internal server error' })
	}
})

// KROK 19: Fix missing match IDs for specific matches
router.post('/strefa-typera/fix-missing-ids', async (req, res) => {
	try {
		console.log('[Strefa Typera Fix IDs] Fixing missing match IDs...')

		if (!SPREADSHEET_ID) {
			throw new Error('GOOGLE_SHEETS_ID environment variable not set')
		}

		const sheets = await getGoogleSheetsClient()
		const sheetName = req.body.sheetName || 'Typy'

		// Fetch all rows
		const response = await sheets.spreadsheets.values.get({
			spreadsheetId: SPREADSHEET_ID,
			range: `${sheetName}!A:AD`,
		})

		const rows = response.data.values || []

		if (rows.length <= 1) {
			return res.json({ success: true, message: 'No data rows found', fixed: 0 })
		}

		// Specific matches to fix
		const matchesToFix = [
			{ home: 'FC Eindhoven', away: 'Jong PSV U21', id: 17061 },
			{ home: 'Lechia Gdansk', away: 'Gornik Zabrze', id: 16635 },
			{ home: 'Tychy 71', away: 'Polonia Warszawa', id: 16644 },
		]

		const updates: any[] = []
		let fixedCount = 0

		// Process each row
		for (let i = 1; i < rows.length; i++) {
			const row = rows[i]
			const rowNumber = i + 1
			const homeTeam = row[0] || ''
			const awayTeam = row[1] || ''
			const existingId = row[29] || '' // AD column

			// Skip if ID already exists
			if (existingId && existingId.trim() !== '') {
				continue
			}

			// Check if this row matches any of the specific matches
			for (const match of matchesToFix) {
				if (homeTeam.includes(match.home) && awayTeam.includes(match.away)) {
					console.log(`[Strefa Typera Fix IDs] Found match at row ${rowNumber}: ${homeTeam} - ${awayTeam}, setting ID to ${match.id}`)
					updates.push({
						range: `${sheetName}!AD${rowNumber}`,
						values: [[match.id]]
					})
					fixedCount++
					break
				}
			}
		}

		if (updates.length === 0) {
			return res.json({ success: true, message: 'No IDs to fix', fixed: 0 })
		}

		// Apply updates
		await sheets.spreadsheets.values.batchUpdate({
			spreadsheetId: SPREADSHEET_ID,
			requestBody: {
				data: updates,
				valueInputOption: 'USER_ENTERED',
			},
		})

		console.log(`[Strefa Typera Fix IDs] Fixed ${fixedCount} match IDs`)

		res.json({
			success: true,
			message: `Fixed ${fixedCount} match IDs`,
			fixed: fixedCount,
		})
	} catch (error: any) {
		console.error('[Strefa Typera Fix IDs] Error:', error)
		res.status(500).json({ error: error.message || 'Internal server error' })
	}
})

// Get matches from Bet Builder for coupon creation
router.get('/strefa-typera/bet-builder-matches', async (req, res) => {
	try {
		console.log('[Strefa Typera Get BB Matches] Fetching matches from Bet Builder sheet...')
		
		if (!SPREADSHEET_ID) {
			throw new Error('GOOGLE_SHEETS_ID environment variable not set')
		}

		const sheets = await getGoogleSheetsClient()

		// Fetch all rows from Bet Builder
		const response = await sheets.spreadsheets.values.get({
			spreadsheetId: SPREADSHEET_ID,
			range: 'Bet Builder!A:AG',
		})

		const rows = response.data.values || []
		console.log(`[Strefa Typera Get BB Matches] Found ${rows.length} rows`)

		if (rows.length <= 1) {
			return res.json({ matches: [] })
		}

		// Convert rows to match objects (skip header)
		const matches = []
		for (let i = 1; i < rows.length; i++) {
			const row = rows[i]
			matches.push({
				rowIndex: i,
				homeTeam: row[0] || '',
				awayTeam: row[1] || '',
				betType: row[2] || '',
				betOption: row[3] || '',
				szanse: row[4] || '',
				odds: row[5] || '',
			})
		}

		console.log(`[Strefa Typera Get BB Matches] Returning ${matches.length} matches`)
		res.json({ matches })

	} catch (error: any) {
		console.error('[Strefa Typera Get BB Matches] Error:', error)
		res.status(500).json({ error: error.message || 'Internal server error' })
	}
})

// KROK 21: Create coupon from selected matches
router.post('/strefa-typera/create-coupon', async (req, res) => {
	try {
		console.log('[Strefa Typera Create Coupon] Request received:', req.body)

		const { matchIndices, stake, potentialWin } = req.body

		if (!Array.isArray(matchIndices) || matchIndices.length === 0) {
			return res.status(400).json({ error: 'No matches selected' })
		}

		if (!stake || !potentialWin) {
			return res.status(400).json({ error: 'Stake and potential win are required' })
		}

		if (!SPREADSHEET_ID) {
			throw new Error('GOOGLE_SHEETS_ID environment variable not set')
		}

		const sheets = await getGoogleSheetsClient()

		// Fetch Bet Builder rows
		const bbResponse = await sheets.spreadsheets.values.get({
			spreadsheetId: SPREADSHEET_ID,
			range: 'Bet Builder!A:AG',
		})

		const bbRows = bbResponse.data.values || []
		if (bbRows.length <= 1) {
			return res.status(400).json({ error: 'No data in Bet Builder sheet' })
		}

		// Fetch existing coupons to generate new coupon ID
		const kuponyResponse = await sheets.spreadsheets.values.get({
			spreadsheetId: SPREADSHEET_ID,
			range: 'Kupony!AE:AE',
		})

		const kuponyIds = kuponyResponse.data.values || []

		let maxId = 0
		// Find highest existing coupon ID (K0001, K0002, etc.)
		for (const row of kuponyIds) {
			const idStr = row[0] || ''
			if (idStr.startsWith('K')) {
				const num = parseInt(idStr.substring(1))
				if (!isNaN(num) && num > maxId) {
					maxId = num
				}
			}
		}

		const newCouponId = `K${String(maxId + 1).padStart(4, '0')}`
		console.log(`[Strefa Typera Create Coupon] Generated coupon ID: ${newCouponId}`)

		// Collect selected rows and add coupon data
		const rowsToAdd: any[] = []

		for (const index of matchIndices) {
			const rowIndex = index + 1 // +1 because we skip header
			if (rowIndex >= bbRows.length) {
				continue
			}

			const sourceRow = bbRows[rowIndex]

			// Copy all 33 columns (A-AG) and add coupon data
			const newRow = [...sourceRow]

			// Ensure array has at least 35 elements (up to column AI)
			while (newRow.length < 35) {
				newRow.push('')
			}

			// AE (index 30) - Coupon ID
			newRow[30] = newCouponId

			// AH (index 33) - Stake
			newRow[33] = stake

			// AI (index 34) - Potential Win
			newRow[34] = potentialWin

			rowsToAdd.push(newRow)
		}

		console.log(`[Strefa Typera Create Coupon] Adding ${rowsToAdd.length} rows to Kupony sheet`)

		// Append rows to Kupony sheet
		await sheets.spreadsheets.values.append({
			spreadsheetId: SPREADSHEET_ID,
			range: 'Kupony!A:AI',
			valueInputOption: 'USER_ENTERED',
			requestBody: {
				values: rowsToAdd,
			},
		})

		console.log(`[Strefa Typera Create Coupon] Successfully created coupon ${newCouponId}`)

		// KROK 24: Save to database
		console.log('[Strefa Typera Create Coupon] Saving to database...')
		let dbInserted = 0
		for (const row of rowsToAdd) {
			try {
				await prisma.coupons.create({
					data: {
						home_team: row[0] || '',
						away_team: row[1] || '',
						bet_type: row[2] || '',
						bet_option: row[3] || '',
						szanse: row[4] || null,
						odds: row[5] ? parseFloat(row[5]) : null,
						moc_bet: row[6] ? parseFloat(row[6]) : null,
						stat_5_h_overall: row[7] || null,
						stat_5_a_overall: row[8] || null,
						stat_5_h_ha: row[9] || null,
						stat_5_a_ha: row[10] || null,
						stat_10_h_overall: row[11] || null,
						stat_10_a_overall: row[12] || null,
						stat_10_h_ha: row[13] || null,
						stat_10_a_ha: row[14] || null,
						stat_15_h_overall: row[15] || null,
						stat_15_a_overall: row[16] || null,
						stat_15_h_ha: row[17] || null,
						stat_15_a_ha: row[18] || null,
						entered: row[19] || null,
						result_home: row[20] ? parseInt(row[20]) : null,
						result_away: row[21] ? parseInt(row[21]) : null,
						standing_home: row[22] ? parseInt(row[22]) : null,
						standing_away: row[23] ? parseInt(row[23]) : null,
						comment: row[24] || null,
						country: row[25] || null,
						league: row[26] || null,
						superbet_link: row[27] || null,
						match_date: row[28] && !isNaN(Date.parse(row[28])) ? new Date(row[28]) : null,
						match_id: row[29] ? parseInt(row[29]) : null,
						coupon_id: row[30] || null,
						flashscore_link: row[32] || null,
						stake: row[33] ? parseFloat(row[33]) : null,
						potential_win: row[34] ? parseFloat(row[34]) : null,
					}
				})
				dbInserted++
			} catch (err: any) {
				console.error(`[Strefa Typera Create Coupon] Error inserting to DB:`, err.message)
			}
		}
		console.log(`[Strefa Typera Create Coupon] Inserted ${dbInserted} rows to database`)

		// KROK 25: Create backup after saving
		console.log('[Strefa Typera Create Coupon] Creating backup...')
		const backupResult = await tablesBackup.backupTables()
		if (!backupResult.success) {
			console.warn('[Strefa Typera Create Coupon] Backup failed but continuing:', backupResult.error)
		}

		res.json({
			success: true,
			couponId: newCouponId,
			rowsAdded: rowsToAdd.length,
			dbInserted,
			backupCreated: backupResult.success,
		})

	} catch (error: any) {
		console.error('[Strefa Typera Create Coupon] Error:', error)
		res.status(500).json({ error: error.message || 'Internal server error' })
	}
})

// KROK 23: Migrate data from Google Sheets to database (one-time)
router.post('/strefa-typera/migrate-sheets-to-db', async (req, res) => {
	try {
		console.log('[Strefa Typera Migrate] Starting migration from sheets to database...')

		if (!SPREADSHEET_ID) {
			throw new Error('GOOGLE_SHEETS_ID environment variable not set')
		}

		const sheets = await getGoogleSheetsClient()

		// Migrate Typy sheet to bets table
		console.log('[Strefa Typera Migrate] Fetching data from Typy sheet...')
		const typyResponse = await sheets.spreadsheets.values.get({
			spreadsheetId: SPREADSHEET_ID,
			range: 'Typy!A:AG',
		})

		const typyRows = typyResponse.data.values || []
		let betsInserted = 0

		if (typyRows.length > 1) {
			for (let i = 1; i < typyRows.length; i++) {
				const row = typyRows[i]

				if (!row[0] || !row[1]) continue // Skip if no teams

				try {
					await prisma.bets.create({
						data: {
							home_team: row[0] || '',
							away_team: row[1] || '',
							bet_type: row[2] || '',
							bet_option: row[3] || '',
							szanse: row[4] || null,
							odds: row[5] ? parseFloat(row[5]) : null,
							moc_bet: row[6] ? parseFloat(row[6]) : null,
							stat_5_h_overall: row[7] || null,
							stat_5_a_overall: row[8] || null,
							stat_5_h_ha: row[9] || null,
							stat_5_a_ha: row[10] || null,
							stat_10_h_overall: row[11] || null,
							stat_10_a_overall: row[12] || null,
							stat_10_h_ha: row[13] || null,
							stat_10_a_ha: row[14] || null,
							stat_15_h_overall: row[15] || null,
							stat_15_a_overall: row[16] || null,
							stat_15_h_ha: row[17] || null,
							stat_15_a_ha: row[18] || null,
							entered: row[19] || null,
							result_home: row[20] ? parseInt(row[20]) : null,
							result_away: row[21] ? parseInt(row[21]) : null,
							standing_home: row[22] ? parseInt(row[22]) : null,
							standing_away: row[23] ? parseInt(row[23]) : null,
							comment: row[24] || null,
							country: row[25] || null,
							league: row[26] || null,
							superbet_link: row[27] || null,
							match_date: row[28] && !isNaN(Date.parse(row[28])) ? new Date(row[28]) : null,
							match_id: row[29] ? parseInt(row[29]) : null,
							flashscore_link: row[32] || null,
						}
					})
					betsInserted++
				} catch (err: any) {
					console.error(`[Strefa Typera Migrate] Error inserting bet row ${i}:`, err.message)
				}
			}
		}

		// Migrate Kupony sheet to coupons table
		console.log('[Strefa Typera Migrate] Fetching data from Kupony sheet...')
		const kuponyResponse = await sheets.spreadsheets.values.get({
			spreadsheetId: SPREADSHEET_ID,
			range: 'Kupony!A:AI',
		})

		const kuponyRows = kuponyResponse.data.values || []
		let couponsInserted = 0

		if (kuponyRows.length > 1) {
			for (let i = 1; i < kuponyRows.length; i++) {
				const row = kuponyRows[i]

				if (!row[0] || !row[1]) continue // Skip if no teams

				try {
					await prisma.coupons.create({
						data: {
							home_team: row[0] || '',
							away_team: row[1] || '',
							bet_type: row[2] || '',
							bet_option: row[3] || '',
							szanse: row[4] || null,
							odds: row[5] ? parseFloat(row[5]) : null,
							moc_bet: row[6] ? parseFloat(row[6]) : null,
							stat_5_h_overall: row[7] || null,
							stat_5_a_overall: row[8] || null,
							stat_5_h_ha: row[9] || null,
							stat_5_a_ha: row[10] || null,
							stat_10_h_overall: row[11] || null,
							stat_10_a_overall: row[12] || null,
							stat_10_h_ha: row[13] || null,
							stat_10_a_ha: row[14] || null,
							stat_15_h_overall: row[15] || null,
							stat_15_a_overall: row[16] || null,
							stat_15_h_ha: row[17] || null,
							stat_15_a_ha: row[18] || null,
							entered: row[19] || null,
							result_home: row[20] ? parseInt(row[20]) : null,
							result_away: row[21] ? parseInt(row[21]) : null,
							standing_home: row[22] ? parseInt(row[22]) : null,
							standing_away: row[23] ? parseInt(row[23]) : null,
							comment: row[24] || null,
							country: row[25] || null,
							league: row[26] || null,
							superbet_link: row[27] || null,
							match_date: row[28] && !isNaN(Date.parse(row[28])) ? new Date(row[28]) : null,
							match_id: row[29] ? parseInt(row[29]) : null,
							coupon_id: row[30] || null,
							flashscore_link: row[32] || null,
							stake: row[33] ? parseFloat(row[33]) : null,
							potential_win: row[34] ? parseFloat(row[34]) : null,
						}
					})
					couponsInserted++
				} catch (err: any) {
					console.error(`[Strefa Typera Migrate] Error inserting coupon row ${i}:`, err.message)
				}
			}
		}

		console.log(`[Strefa Typera Migrate] Migration completed: ${betsInserted} bets, ${couponsInserted} coupons`)

		res.json({
			success: true,
			message: `Migration completed`,
			betsInserted,
			couponsInserted,
		})

	} catch (error: any) {
		console.error('[Strefa Typera Migrate] Error:', error)
		res.status(500).json({ error: error.message || 'Internal server error' })
	}
})

export default router
