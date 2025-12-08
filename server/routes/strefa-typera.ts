import express from 'express'
import * as path from 'path'
import * as fs from 'fs'
import { PrismaClient } from '@prisma/client'
import { calculateBetStatistics } from '../utils/bet-statistics'

const router = express.Router()
const prisma = new PrismaClient()

// Google Sheets configuration
const SPREADSHEET_ID = process.env.GOOGLE_SHEETS_ID || ''
const SHEET_NAME = 'Bet Builder'

console.log('[Strefa Typera] GOOGLE_SHEETS_ID from env:', process.env.GOOGLE_SHEETS_ID)
console.log('[Strefa Typera] SPREADSHEET_ID:', SPREADSHEET_ID)

async function getGoogleSheetsClient() {
	const { google } = await import('googleapis')
	const credentialsPath = path.join(process.cwd(), 'google-sheets-config.json')
	
	if (!fs.existsSync(credentialsPath)) {
		throw new Error('google-sheets-config.json not found. Please create it based on google-sheets-config.json.example')
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
}

// NEW ENDPOINT: Add match with comprehensive statistics (Step 2 format)
router.post('/strefa-typera/add-match-v2', async (req, res) => {
	try {
		console.log('[Strefa Typera V2] Request received:', req.body)
		
		const { homeTeam, awayTeam, league, date, betType, betOption, odds } = req.body as AddMatchRequest

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
			szanse = average.toFixed(1)
		}

		// Prepare single row with all columns A-AE
		const row = [
			homeTeam,                              // A - home_team
			awayTeam,                              // B - away_team
			betType,                               // C - zakład
			betOption,                             // D - typ
			szanse,                                // E - szanse (calculated or "za mało danych")
			'',                                    // F - kurs (r - filled manually)
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
		]

		console.log('[Strefa Typera V2] Getting Google Sheets client...')
		// Get Google Sheets client
		const sheets = await getGoogleSheetsClient()
		console.log('[Strefa Typera V2] Client ready, appending row...')

		// Append row to sheet
		await sheets.spreadsheets.values.append({
			spreadsheetId: SPREADSHEET_ID,
			range: `${SHEET_NAME}!A:AE`,
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
		
		const { homeTeam, awayTeam, league, date, betType, betOption, odds } = req.body as AddMatchRequest

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
		
		console.log('[Strefa Typera] Calculating statistics...')
		// Calculate statistics for both assumptions
		const overallStats = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'overall', league)
		const haStats = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'ha', league)
		console.log('[Strefa Typera] Statistics calculated')

		// Helper function to format percentage
		const formatPercent = (value: number | string) => {
			return typeof value === 'string' ? value : `${value}%`
		}

		// Prepare rows
		const rows = [
			[
				homeTeam,
				awayTeam,
				betType,
				betOption,
				'ogółem',
				formatPercent(overallStats.homePercentage),
				formatPercent(overallStats.awayPercentage),
				'',
				odds,
				'', // J
				'', // K
				'', // L
				'', // M
				formattedDate // N - Data meczu (YYYY-MM-DD format)
			],
			[
				homeTeam,
				awayTeam,
				betType,
				betOption,
				'H/A',
				formatPercent(haStats.homePercentage),
				formatPercent(haStats.awayPercentage),
				'',
				odds,
				'', // J
				'', // K
				'', // L
				'', // M
				formattedDate // N - Data meczu (YYYY-MM-DD format)
			]
		]

		console.log('[Strefa Typera] Getting Google Sheets client...')
		// Get Google Sheets client
		const sheets = await getGoogleSheetsClient()
		console.log('[Strefa Typera] Client ready, appending rows...')

		// Append rows to sheet
		await sheets.spreadsheets.values.append({
			spreadsheetId: SPREADSHEET_ID,
			range: `${SHEET_NAME}!A:N`,
			valueInputOption: 'USER_ENTERED',
			requestBody: {
				values: rows,
			},
		})
		
		console.log('[Strefa Typera] Rows appended successfully')

		res.json({
			success: true,
			message: `Added 2 rows to Google Sheets`,
			rowsAdded: 2,
			homeTeam,
			awayTeam,
			betType,
			betOption,
			odds,
			overallStats,
			haStats,
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
		
		// Get all rows from "Typy" sheet
		const response = await sheets.spreadsheets.values.get({
			spreadsheetId: SPREADSHEET_ID,
			range: `${sheetName}!A:AE`,
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

			// Check if already has data in columns to fill
			const hasData = row[4] || row[7] || row[23] || row[26] // E, H, X, AA
			if (hasData && row[4] !== '' && row[7] !== '' && row[23] !== '' && row[26] !== '') {
				console.log(`[Strefa Typera Backfill] Row ${rowNumber}: Already has data, skipping`)
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
				szanse = average.toFixed(1)
			}

			// Prepare update data for specific columns
			// We'll update: E, H-S, X, Y, AA, AB, AD
			const updateData = {
				range: `${sheetName}!E${rowNumber}:AE${rowNumber}`,
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
					row[28] || '',                         // AC - Data (keep existing)
					match.id,                              // AD
					row[30] || '',                         // AE - ID Kuponu (keep existing)
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
		
		// Get all rows from "Bet Builder" sheet
		const response = await sheets.spreadsheets.values.get({
			spreadsheetId: SPREADSHEET_ID,
			range: `${sheetName}!A:AE`,
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

			// Check if already has data in columns to fill
			const hasData = row[4] || row[7] || row[23] || row[26] // E, H, X, AA
			if (hasData && row[4] !== '' && row[7] !== '' && row[23] !== '' && row[26] !== '') {
				console.log(`[Strefa Typera Backfill BB] Row ${rowNumber}: Already has data, skipping`)
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
				szanse = average.toFixed(1)
			}

			// Prepare update data for specific columns
			// We'll update: E, H-S, X, Y, AA, AB, AD
			const updateData = {
				range: `${sheetName}!E${rowNumber}:AE${rowNumber}`,
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
					row[28] || '',                         // AC - Data (keep existing)
					match.id,                              // AD
					row[30] || '',                         // AE - ID Kuponu (keep existing)
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

export default router
