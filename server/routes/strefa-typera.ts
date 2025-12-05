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
	betType?: string
	betOption?: string
	assumption?: string
	odds?: number
}

// Add match with full bet analysis (bet type, options, statistics, odds)
router.post('/strefa-typera/add-match-full', async (req, res) => {
	try {
		console.log('[Strefa Typera] Request received:', req.body)
		
		const { homeTeam, awayTeam, league, betType, betOption, odds } = req.body as AddMatchRequest

		if (!homeTeam || !awayTeam || !betType || !betOption || !odds) {
			console.log('[Strefa Typera] Missing required fields')
			return res.status(400).json({ error: 'All fields are required' })
		}

		if (!SPREADSHEET_ID) {
			console.log('[Strefa Typera] GOOGLE_SHEETS_ID not configured')
			return res.status(500).json({ error: 'GOOGLE_SHEETS_ID not configured in .env' })
		}

		console.log('[Strefa Typera] Calculating statistics...')
		// Calculate statistics for both assumptions
		const overallStats = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'overall', league)
		const haStats = await calculateBetStatistics(homeTeam, awayTeam, betType, betOption, 'ha', league)
		console.log('[Strefa Typera] Statistics calculated')

		// Prepare rows
		const rows = [
			[
				homeTeam,
				awayTeam,
				betType,
				betOption,
				'ogółem',
				`${overallStats.homePercentage}%`,
				`${overallStats.awayPercentage}%`,
				'',
				odds
			],
			[
				homeTeam,
				awayTeam,
				betType,
				betOption,
				'H/A',
				`${haStats.homePercentage}%`,
				`${haStats.awayPercentage}%`,
				'',
				odds
			]
		]

		console.log('[Strefa Typera] Getting Google Sheets client...')
		// Get Google Sheets client
		const sheets = await getGoogleSheetsClient()
		console.log('[Strefa Typera] Client ready, appending rows...')

		// Append rows to sheet
		await sheets.spreadsheets.values.append({
			spreadsheetId: SPREADSHEET_ID,
			range: `${SHEET_NAME}!A:I`,
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

export default router
