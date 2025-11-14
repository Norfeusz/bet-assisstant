/**
 * Web Server for League Configuration
 */

import express from 'express'
import * as dotenv from 'dotenv'
import { ApiFootballClient } from '../src/services/api-football-client'
import { LeagueSelector, LeagueConfig } from '../src/services/league-selector'
import { ImportStateManager } from '../src/utils/import-state'
import { setShouldStopImport, getShouldStopImport } from '../src/utils/import-control'
import { LeaguePresetManager } from '../src/utils/league-presets'
import importJobsRouter from './routes/import-jobs'

dotenv.config()

const app = express()
const PORT = process.env.PORT || 3000

app.use(express.json())

// Import jobs routes
app.use('/api', importJobsRouter)

// Initialize services
const apiKey = process.env.API_FOOTBALL_KEY!

if (!apiKey) {
	console.error('❌ ERROR: API_FOOTBALL_KEY is not set in .env file')
	process.exit(1)
}

const client = new ApiFootballClient(apiKey)
const selector = new LeagueSelector(client)
const stateManager = new ImportStateManager()
const presetManager = new LeaguePresetManager()

// API Endpoints

// Get config (for background import dialog)
app.get('/api/config', (req, res) => {
	const leagues = selector.getAllLeagues()
	res.json({ leagues })
})

// Get all configured leagues
app.get('/api/leagues/configured', (req, res) => {
	const leagues = selector.getAllLeagues()
	res.json(leagues)
})

// Get available countries
app.get('/api/countries', async (req, res) => {
	try {
		const countries = [
			{ code: 'PL', name: 'Poland', flag: '🇵🇱' },
			{ code: 'GB', name: 'England', flag: '🏴󐁧󐁢󐁥󐁮󐁧󐁿' },
			{ code: 'DE', name: 'Germany', flag: '🇩🇪' },
			{ code: 'ES', name: 'Spain', flag: '🇪🇸' },
			{ code: 'IT', name: 'Italy', flag: '🇮🇹' },
			{ code: 'FR', name: 'France', flag: '🇫🇷' },
			{ code: 'NL', name: 'Netherlands', flag: '🇳🇱' },
			{ code: 'BE', name: 'Belgium', flag: '🇧🇪' },
			{ code: 'PT', name: 'Portugal', flag: '🇵🇹' },
			{ code: 'TR', name: 'Turkey', flag: '🇹🇷' },
			{ code: 'GR', name: 'Greece', flag: '🇬🇷' },
			{ code: 'NO', name: 'Norway', flag: '🇳🇴' },
			{ code: 'SE', name: 'Sweden', flag: '🇸🇪' },
			{ code: 'DK', name: 'Denmark', flag: '🇩🇰' },
			{ code: 'BR', name: 'Brazil', flag: '🇧🇷' },
			{ code: 'AR', name: 'Argentina', flag: '🇦🇷' },
			{ code: 'US', name: 'USA', flag: '🇺🇸' },
			{ code: 'MX', name: 'Mexico', flag: '🇲🇽' },
			{ code: 'AT', name: 'Austria', flag: '🇦🇹' },
			{ code: 'HR', name: 'Croatia', flag: '🇭🇷' },
			{ code: 'CY', name: 'Cyprus', flag: '🇨🇾' },
			{ code: 'BO', name: 'Bolivia', flag: '🇧🇴' },
			{ code: 'FI', name: 'Finland', flag: '🇫🇮' },
			{ code: 'BF', name: 'Burkina-Faso', flag: '🇧🇫' },
			{ code: 'BG', name: 'Bulgaria', flag: '🇧🇬' },
			{ code: 'EG', name: 'Egypt', flag: '🇪🇬' },
			{ code: 'PE', name: 'Peru', flag: '🇵🇪' },
			{ code: 'CZ', name: 'Czech-Republic', flag: '🇨🇿' },
			{ code: 'SK', name: 'Slovakia', flag: '🇸🇰' },
			{ code: 'RS', name: 'Serbia', flag: '🇷🇸' },
			{ code: 'CH', name: 'Switzerland', flag: '🇨🇭' },
			{ code: 'EC', name: 'Ecuador', flag: '🇪🇨' },
			{ code: 'DO', name: 'Dominican-Republic', flag: '🇩🇴' },
			{ code: 'ID', name: 'Indonesia', flag: '🇮🇩' },
			{ code: 'JM', name: 'Jamaica', flag: '🇯🇲' },
			{ code: 'QA', name: 'Qatar', flag: '🇶🇦' },
			{ code: 'KZ', name: 'Kazakhstan', flag: '🇰🇿' },
			{ code: 'AZ', name: 'Azerbaijan', flag: '🇦🇿' },
			{ code: 'CO', name: 'Colombia', flag: '🇨🇴' },
			{ code: 'KR', name: 'South-Korea', flag: '🇰🇷' },
			{ code: 'MK', name: 'Macedonia', flag: '🇲🇰' },
			{ code: 'MA', name: 'Morocco', flag: '🇲🇦' },
			{ code: 'MZ', name: 'Mozambique', flag: '🇲🇿' },
			{ code: 'NG', name: 'Nigeria', flag: '🇳🇬' },
			{ code: 'PY', name: 'Paraguay', flag: '🇵🇾' },
			{ code: 'RO', name: 'Romania', flag: '🇷🇴' },
			{ code: 'SI', name: 'Slovenia', flag: '🇸🇮' },
			{ code: 'SG', name: 'Singapore', flag: '🇸🇬' },
			{ code: 'SCO', name: 'Scotland', flag: '🏴󐁧󐁢󐁳󐁣󐁴󐁿' },
			{ code: 'TH', name: 'Thailand', flag: '🇹🇭' },
			{ code: 'TN', name: 'Tunisia', flag: '🇹🇳' },
			{ code: 'UA', name: 'Ukraine', flag: '🇺🇦' },
			{ code: 'UY', name: 'Uruguay', flag: '🇺🇾' },
			{ code: 'HU', name: 'Hungary', flag: '🇭🇺' },
			{ code: 'VN', name: 'Vietnam', flag: '🇻🇳' },
		]
		res.json(countries)
	} catch (error: any) {
		res.status(500).json({ error: error.message })
	}
})

// Get leagues for a country
app.get('/api/countries/:country/leagues', async (req, res) => {
	try {
		const { country } = req.params
		const currentYear = new Date().getFullYear()

		console.log(`📥 Fetching leagues for country: ${country}, season: ${currentYear}`)

		const response = await client.getLeagues({
			season: currentYear,
			country: country,
		})

		console.log(`✅ Received ${response.response.length} leagues from API`)

		const leagues = (response.response as any).map((item: any) => ({
			id: item.league.id,
			name: item.league.name,
			type: item.league.type,
			logo: item.league.logo,
			country: item.country.name,
		}))

		console.log(`📤 Sending ${leagues.length} leagues to client`)
		res.json(leagues)
	} catch (error: any) {
		console.error(`❌ Error fetching leagues for ${req.params.country}:`, error.message)
		res.status(500).json({ error: error.message })
	}
})

// Add league
app.post('/api/leagues', (req, res) => {
	try {
		const config: LeagueConfig = req.body
		selector.addLeague(config)
		res.json({ success: true, message: 'League added' })
	} catch (error: any) {
		res.status(500).json({ error: error.message })
	}
})

// Remove league
app.delete('/api/leagues/:id', (req, res) => {
	try {
		const id = parseInt(req.params.id)
		selector.removeLeague(id)
		res.json({ success: true, message: 'League removed' })
	} catch (error: any) {
		res.status(500).json({ error: error.message })
	}
})

// Toggle league
app.patch('/api/leagues/:id/toggle', (req, res) => {
	try {
		const id = parseInt(req.params.id)
		const { enabled } = req.body
		selector.toggleLeague(id, enabled)
		res.json({ success: true, message: 'League toggled' })
	} catch (error: any) {
		res.status(500).json({ error: error.message })
	}
})

// Auto-select recommended leagues
app.post('/api/leagues/auto-select', async (req, res) => {
	try {
		await selector.initializeRecommended()
		const leagues = selector.getAllLeagues()
		res.json({ success: true, leagues })
	} catch (error: any) {
		res.status(500).json({ error: error.message })
	}
})

// Get API rate limit stats
app.get('/api/rate-limit', (req, res) => {
	try {
		const stats = client.getRateLimitStats()

		// Calculate time until next hour reset (for hourly limit)
		const now = new Date()
		const nextHour = new Date(now)
		nextHour.setHours(now.getHours() + 1, 0, 0, 0)
		const msUntilNextHour = nextHour.getTime() - now.getTime()
		const minutesUntilReset = Math.floor(msUntilNextHour / 60000)

		// Calculate time until midnight (for daily limit)
		const midnight = new Date(now)
		midnight.setHours(24, 0, 0, 0)
		const msUntilMidnight = midnight.getTime() - now.getTime()
		const hoursUntilMidnight = Math.floor(msUntilMidnight / 3600000)
		const minutesUntilMidnight = Math.floor((msUntilMidnight % 3600000) / 60000)

		res.json({
			...stats,
			nextHourlyReset: {
				minutes: minutesUntilReset,
				timestamp: nextHour.toISOString(),
			},
			nextDailyReset: {
				hours: hoursUntilMidnight,
				minutes: minutesUntilMidnight,
				timestamp: midnight.toISOString(),
			},
		})
	} catch (error: any) {
		res.status(500).json({ error: error.message })
	}
})

// Admin: reset rate limit counters (useful to recover quickly from exhausted counters)
app.post('/api/admin/reset-rate-limit', (req, res) => {
	try {
		client.resetRateLimit()
		res.json({ success: true, message: 'Rate limit counters reset' })
	} catch (error: any) {
		res.status(500).json({ success: false, error: error.message })
	}
})

// Get summary
app.get('/api/leagues/summary', (req, res) => {
	try {
		const all = selector.getAllLeagues()
		const enabled = selector.getEnabledLeagues()

		const byCountry = all.reduce((acc, league) => {
			if (!acc[league.country]) {
				acc[league.country] = { total: 0, enabled: 0 }
			}
			acc[league.country].total++
			if (league.enabled) {
				acc[league.country].enabled++
			}
			return acc
		}, {} as Record<string, { total: number; enabled: number }>)

		res.json({
			total: all.length,
			enabled: enabled.length,
			disabled: all.length - enabled.length,
			byCountry,
		})
	} catch (error: any) {
		res.status(500).json({ error: error.message })
	}
})

// Import matches
app.post('/api/import', async (req, res) => {
	try {
		const { startDate, endDate, resume } = req.body

		if (!resume && (!startDate || !endDate)) {
			return res.status(400).json({ error: 'Start and end dates are required' })
		}

		// Reset stop flag
		setShouldStopImport(false)

		// Import will run in background
		res.json({
			success: true,
			message: resume ? 'Import resumed' : 'Import started',
			dateRange: resume ? null : { startDate, endDate },
		})

		// Run import asynchronously
		const { DataImporter } = await import('../src/services/data-importer')
		const importer = new DataImporter(client, selector)

		if (resume) {
			console.log(`\n🔄 Resuming import...`)
			const savedState = stateManager.getIncompleteImport()
			if (savedState) {
				await importer.importDateRange(savedState.startDate, savedState.endDate, true, true) // autoRetry: true
			}
		} else {
			console.log(`\n📥 Starting import from ${startDate} to ${endDate}...`)
			await importer.importDateRange(startDate, endDate, false, true) // autoRetry: true
		}

		if (getShouldStopImport()) {
			console.log(`⏸️  Import paused by user\n`)
		} else {
			console.log(`✅ Import completed!\n`)
		}
	} catch (error: any) {
		console.error('Import error:', error)
	}
})

// Stop import (pause)
app.post('/api/import/stop', (req, res) => {
	setShouldStopImport(true)
	console.log('\n⏸️  Stop requested - import will pause after current league...\n')
	res.json({ success: true, message: 'Import will stop after current league' })
})

// Cancel import completely
app.post('/api/import/cancel', (req, res) => {
	setShouldStopImport(true)
	stateManager.clearState()
	console.log('\n❌ Import cancelled and state cleared\n')
	res.json({ success: true, message: 'Import cancelled' })
})

// Get import status
app.get('/api/import/status', (req, res) => {
	try {
		const savedState = stateManager.getIncompleteImport()

		if (!savedState) {
			return res.json({ hasIncomplete: false })
		}

		const progress = stateManager.getProgress()

		res.json({
			hasIncomplete: true,
			state: savedState,
			progress,
		})
	} catch (error: any) {
		res.status(500).json({ error: error.message })
	}
})

// ===== LEAGUE PRESETS =====

// Get all saved presets
app.get('/api/presets', (req, res) => {
	try {
		const presets = presetManager.getAllPresets()
		res.json(presets)
	} catch (error: any) {
		res.status(500).json({ error: error.message })
	}
})

// Save a new preset
app.post('/api/presets', (req, res) => {
	try {
		const { name, description, leagueIds } = req.body

		if (!name || !leagueIds || !Array.isArray(leagueIds)) {
			return res.status(400).json({ error: 'Name and leagueIds array are required' })
		}

		const preset = presetManager.savePreset(name, leagueIds, description)
		res.json({ success: true, preset })
	} catch (error: any) {
		res.status(500).json({ error: error.message })
	}
})

// Delete a preset
app.delete('/api/presets/:name', (req, res) => {
	try {
		const { name } = req.params
		const success = presetManager.deletePreset(decodeURIComponent(name))

		if (success) {
			res.json({ success: true })
		} else {
			res.status(404).json({ error: 'Preset not found' })
		}
	} catch (error: any) {
		res.status(500).json({ error: error.message })
	}
})

// Load a preset (apply to league configuration)
app.post('/api/presets/:name/load', async (req, res) => {
	try {
		const { name } = req.params
		const preset = presetManager.getPreset(decodeURIComponent(name))

		if (!preset) {
			return res.status(404).json({ error: 'Preset not found' })
		}

		console.log(`📂 Loading preset "${name}" with ${preset.leagueIds.length} leagues`)

		// Disable all leagues first
		const allLeagues = selector.getAllLeagues()
		allLeagues.forEach(league => {
			selector.toggleLeague(league.id, false)
		})

		console.log(`🔄 Disabled ${allLeagues.length} existing leagues`)

		// Fetch league details from API for leagues not in config
		const currentYear = new Date().getFullYear()
		let addedCount = 0
		let enabledCount = 0

		for (const leagueId of preset.leagueIds) {
			// Check if league already exists
			const existingLeague = selector.getAllLeagues().find(l => l.id === leagueId)

			if (existingLeague) {
				// Just enable it
				selector.toggleLeague(leagueId, true)
				enabledCount++
				console.log(`✅ Enabled existing league: ${existingLeague.name}`)
			} else {
				// Fetch from API and add
				try {
					const response = await client.getLeagues({
						season: currentYear,
						id: leagueId,
					})

					if (response.response.length > 0) {
						const item = response.response[0] as any
						const leagueConfig: LeagueConfig = {
							id: item.league.id,
							name: item.league.name,
							country: item.country.name,
							type: item.league.type,
							priority: 3,
							enabled: true,
						}
						selector.addLeague(leagueConfig)
						addedCount++
						console.log(`➕ Added new league: ${leagueConfig.name}`)
					} else {
						console.warn(`⚠️  League ID ${leagueId} not found in API`)
					}
				} catch (error: any) {
					console.error(`❌ Error fetching league ${leagueId}:`, error.message)
				}
			}
		}

		console.log(`✅ Preset loaded: ${enabledCount} enabled, ${addedCount} added`)

		res.json({
			success: true,
			preset,
			stats: {
				enabled: enabledCount,
				added: addedCount,
				total: preset.leagueIds.length,
			},
		})
	} catch (error: any) {
		console.error(`❌ Error loading preset:`, error.message)
		res.status(500).json({ error: error.message })
	}
})

// =====================================
// DATABASE QUERY ENDPOINTS
// =====================================

// Get distinct countries from database
app.get('/api/database/countries', async (req, res) => {
	try {
		const { PrismaClient } = await import('@prisma/client')
		const prisma = new PrismaClient()

		const countries = await prisma.$queryRaw<Array<{ country: string }>>`
			SELECT DISTINCT country
			FROM matches
		ORDER BY country
	`

		const countryNames = countries.map((c: any) => c.country)

		await prisma.$disconnect()

		console.log('📊 Loaded', countryNames.length, 'countries from database')
		res.json(countryNames)
	} catch (error: any) {
		console.error('Error loading countries from database:', error)
		res.status(500).json({ error: error.message })
	}
})

// Get distinct leagues (optionally filtered by country)
app.get('/api/database/leagues', async (req, res) => {
	try {
		const country = req.query.country as string

		const { PrismaClient } = await import('@prisma/client')
		const prisma = new PrismaClient()

		let leagues: Array<{ league: string }>

		if (country) {
			leagues = await prisma.$queryRaw<Array<{ league: string }>>`
				SELECT DISTINCT league
				FROM matches
				WHERE country = ${country}
				ORDER BY league
			`
		} else {
			leagues = await prisma.$queryRaw<Array<{ league: string }>>`
				SELECT DISTINCT league
				FROM matches
				ORDER BY league
			`
		}

		const leagueNames = leagues.map(l => l.league)

		await prisma.$disconnect()

		console.log('📊 Loaded', leagueNames.length, 'leagues' + (country ? ` for ${country}` : ''))
		res.json(leagueNames)
	} catch (error: any) {
		console.error('Error loading leagues from database:', error)
		res.status(500).json({ error: error.message })
	}
})

// Get distinct teams (optionally filtered by country and/or league)
app.get('/api/database/teams', async (req, res) => {
	try {
		const country = req.query.country as string
		const league = req.query.league as string

		const { PrismaClient } = await import('@prisma/client')
		const prisma = new PrismaClient()

		let teams: Array<{ team: string }>

		if (country && league) {
			// Both country and league
			teams = await prisma.$queryRaw<Array<{ team: string }>>`
				SELECT DISTINCT team FROM (
					SELECT home_team as team FROM matches WHERE country = ${country} AND league = ${league}
					UNION
					SELECT away_team as team FROM matches WHERE country = ${country} AND league = ${league}
				) AS all_teams
				ORDER BY team
			`
		} else if (country) {
			// Only country
			teams = await prisma.$queryRaw<Array<{ team: string }>>`
				SELECT DISTINCT team FROM (
					SELECT home_team as team FROM matches WHERE country = ${country}
					UNION
					SELECT away_team as team FROM matches WHERE country = ${country}
				) AS all_teams
				ORDER BY team
			`
		} else if (league) {
			// Only league
			teams = await prisma.$queryRaw<Array<{ team: string }>>`
				SELECT DISTINCT team FROM (
					SELECT home_team as team FROM matches WHERE league = ${league}
					UNION
					SELECT away_team as team FROM matches WHERE league = ${league}
				) AS all_teams
				ORDER BY team
			`
		} else {
			// No filters - all teams
			teams = await prisma.$queryRaw<Array<{ team: string }>>`
				SELECT DISTINCT team FROM (
					SELECT home_team as team FROM matches
					UNION
					SELECT away_team as team FROM matches
				) AS all_teams
				ORDER BY team
			`
		}

		const teamNames = teams.map(t => t.team)

		await prisma.$disconnect()

		const filterDesc = [country, league].filter(Boolean).join(', ') || 'all'
		console.log('📊 Loaded', teamNames.length, 'teams for', filterDesc)
		res.json(teamNames)
	} catch (error: any) {
		console.error('Error loading teams from database:', error)
		res.status(500).json({ error: error.message })
	}
})

// Get matches with filters
app.get('/api/database/matches', async (req, res) => {
	try {
		const country = req.query.country as string
		const league = req.query.league as string
		const team = req.query.team as string
		const dateFrom = req.query.date_from as string
		const dateTo = req.query.date_to as string
		const isFinished = req.query.is_finished as string
		const sort = req.query.sort as string
		const limit = req.query.limit ? parseInt(req.query.limit as string) : 100

		console.log('🔍 API /api/database/matches called with params:', {
			country,
			league,
			team,
			dateFrom,
			dateTo,
			isFinished,
			sort,
			limit,
		})

		const { PrismaClient } = await import('@prisma/client')
		const prisma = new PrismaClient()

		// Build WHERE conditions
		const conditions: string[] = []
		const params: any[] = []

		if (country) {
			conditions.push(`country = $${params.length + 1}`)
			params.push(country)
		}
		if (league) {
			conditions.push(`league = $${params.length + 1}`)
			params.push(league)
		}
		if (team) {
			conditions.push(`(home_team = $${params.length + 1} OR away_team = $${params.length + 1})`)
			params.push(team)
		}
		if (dateFrom) {
			conditions.push(`match_date >= $${params.length + 1}::date`)
			params.push(dateFrom)
		}
		if (dateTo) {
			conditions.push(`match_date <= $${params.length + 1}::date`)
			params.push(dateTo)
		}
		if (isFinished !== undefined) {
			const finished = isFinished === 'yes' || isFinished === 'true' ? 'yes' : 'no'
			conditions.push(`is_finished = $${params.length + 1}`)
			params.push(finished)
			console.log(`   ✓ is_finished filter: "${isFinished}" → ${finished}`)
		}

		const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : ''

		console.log('   SQL WHERE clause:', whereClause)
		console.log('   SQL params:', params) // Determine sort order
		let orderBy = 'ORDER BY match_date DESC'
		if (sort === 'date_asc') {
			orderBy = 'ORDER BY match_date ASC'
		} else if (sort === 'date_desc') {
			orderBy = 'ORDER BY match_date DESC'
		}

		// Query matches
		const matches = await prisma.$queryRawUnsafe(
			`
			SELECT 
				id, match_date, country, league,
				home_team, away_team,
				home_goals, away_goals,
				home_goals_ht, away_goals_ht,
				result, is_finished,
				home_corners, away_corners,
				home_offsides, away_offsides,
				home_shots, away_shots,
				home_shots_on_target, away_shots_on_target,
				home_xg, away_xg,
				home_possession, away_possession
			FROM matches
			${whereClause}
			${orderBy}
			LIMIT ${limit}
		`,
			...params
		)

		await prisma.$disconnect()

		// Convert BigInt to Number for JSON serialization
		const serializedMatches = (matches as any[]).map(match => ({
			...match,
			id: Number(match.id),
			home_goals: match.home_goals !== null ? Number(match.home_goals) : null,
			away_goals: match.away_goals !== null ? Number(match.away_goals) : null,
			home_goals_ht: match.home_goals_ht !== null ? Number(match.home_goals_ht) : null,
			away_goals_ht: match.away_goals_ht !== null ? Number(match.away_goals_ht) : null,
			home_corners: match.home_corners !== null ? Number(match.home_corners) : null,
			away_corners: match.away_corners !== null ? Number(match.away_corners) : null,
			home_offsides: match.home_offsides !== null ? Number(match.home_offsides) : null,
			away_offsides: match.away_offsides !== null ? Number(match.away_offsides) : null,
			home_shots: match.home_shots !== null ? Number(match.home_shots) : null,
			away_shots: match.away_shots !== null ? Number(match.away_shots) : null,
			home_shots_on_target: match.home_shots_on_target !== null ? Number(match.home_shots_on_target) : null,
			away_shots_on_target: match.away_shots_on_target !== null ? Number(match.away_shots_on_target) : null,
			home_xg: match.home_xg !== null ? parseFloat(match.home_xg) : null,
			away_xg: match.away_xg !== null ? parseFloat(match.away_xg) : null,
			home_possession: match.home_possession !== null ? Number(match.home_possession) : null,
			away_possession: match.away_possession !== null ? Number(match.away_possession) : null,
		}))

		console.log('📊 Found', serializedMatches.length, 'matches with filters:', {
			country,
			league,
			team,
			dateFrom,
			dateTo,
			isFinished,
			sort,
			limit,
		})
		if (serializedMatches.length > 0) {
			console.log('📊 Sample match (serialized):', serializedMatches[0])
		}
		res.json(serializedMatches)
	} catch (error: any) {
		console.error('Error loading matches from database:', error)
		res.status(500).json({ error: error.message })
	}
})

// Reset all standings to NULL
app.post('/api/database/reset-standings', async (req, res) => {
	try {
		const { PrismaClient } = await import('@prisma/client')
		const prisma = new PrismaClient()

		const result = await prisma.$executeRaw`
			UPDATE matches 
			SET standing_home = NULL, standing_away = NULL
		`

		await prisma.$disconnect()

		console.log(`✅ Reset standings: ${result} records updated`)
		res.json({
			success: true,
			recordsUpdated: Number(result),
			message: 'All standings reset to NULL',
		})
	} catch (error: any) {
		console.error('Error resetting standings:', error)
		res.status(500).json({ error: error.message })
	}
})

// Global error handler
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
	console.error('❌ Server Error:', err)
	console.error('   Request:', req.method, req.url)
	console.error('   Body:', req.body)
	res.status(500).json({ error: err.message || 'Internal Server Error' })
})

// Serve static files AFTER all API routes
app.use(express.static('public'))

// Start server
app.listen(PORT, () => {
	console.log(`\n🌐 League Configuration Web Interface`)
	console.log(`\n   Server running on port: ${PORT}`)
	console.log(`   Environment: ${process.env.NODE_ENV || 'development'}`)
	if (process.env.RAILWAY_ENVIRONMENT) {
		console.log(`   Railway Environment: ${process.env.RAILWAY_ENVIRONMENT}`)
	} else {
		console.log(`\n   Open in browser: http://localhost:${PORT}`)
	}
	console.log(`\n   Press Ctrl+C to stop\n`)
})
