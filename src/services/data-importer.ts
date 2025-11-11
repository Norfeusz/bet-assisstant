/**
 * Data Importer - Import fresh match data from API Football
 * Strategy: Start from recent dates (Nov 3, 2025) and go backwards
 */

import { ApiFootballClient } from './api-football-client'
import { LeagueSelector, LeagueConfig } from './league-selector'
import { prisma } from '../db'
import {
	FixtureResponse,
	FixtureStatisticsResponse,
	OddsResponse,
	StandingsResponse,
} from '../types/api-football.types'
import { ImportStateManager, ImportState } from '../utils/import-state'
import { getShouldStopImport } from '../utils/import-control'

export interface ImportProgress {
	totalMatches: number
	importedMatches: number
	failedMatches: number
	currentDate: string
	leagues: {
		[leagueId: number]: {
			name: string
			imported: number
			failed: number
		}
	}
}

export class DataImporter {
	private apiClient: ApiFootballClient
	private leagueSelector: LeagueSelector
	private progress: ImportProgress
	private stateManager: ImportStateManager
	private standingsCache: Map<string, StandingsResponse> // Cache: "leagueId-season" -> standings

	constructor(apiClient: ApiFootballClient, leagueSelector: LeagueSelector) {
		this.apiClient = apiClient
		this.leagueSelector = leagueSelector
		this.stateManager = new ImportStateManager()
		this.standingsCache = new Map()
		this.progress = {
			totalMatches: 0,
			importedMatches: 0,
			failedMatches: 0,
			currentDate: '',
			leagues: {},
		}
	}

	/**
	 * Import matches for a specific date range (with resume support)
	 */
	async importDateRange(
		fromDate: string,
		toDate: string,
		resume: boolean = false,
		autoRetry: boolean = false
	): Promise<void> {
		const enabledLeagues = this.leagueSelector.getEnabledLeagues()

		if (enabledLeagues.length === 0) {
			throw new Error('No leagues enabled. Run league selector initialization first.')
		}

		let startLeagueIndex = 0

		// Check for resume
		if (resume) {
			const savedState = this.stateManager.getIncompleteImport()
			if (savedState) {
				console.log('\n🔄 Resuming previous import...')
				console.log(`📅 Original range: ${savedState.startDate} to ${savedState.endDate}`)
				console.log(`✅ Already imported: ${savedState.matchesImported} matches\n`)

				fromDate = savedState.startDate
				toDate = savedState.endDate
				startLeagueIndex = savedState.currentLeagueIndex
				this.progress.importedMatches = savedState.matchesImported
			}
		}

		// Initialize state
		const state: ImportState = {
			startDate: fromDate,
			endDate: toDate,
			currentDate: fromDate,
			leagueIds: enabledLeagues.map(l => l.id),
			currentLeagueIndex: startLeagueIndex,
			matchesImported: this.progress.importedMatches,
			startedAt: resume
				? this.stateManager.loadState()?.startedAt || new Date().toISOString()
				: new Date().toISOString(),
			lastUpdated: new Date().toISOString(),
			status: 'in-progress',
		}
		this.stateManager.saveState(state)

		console.log(`\n=== Importing matches from ${fromDate} to ${toDate} ===`)
		console.log(`Leagues to process: ${enabledLeagues.length}`)
		if (autoRetry) {
			console.log(`🔄 Auto-retry: ENABLED (will wait 1 hour after rate limit)`)
		}

		try {
			// Process each league starting from startLeagueIndex
			for (let i = startLeagueIndex; i < enabledLeagues.length; i++) {
				const league = enabledLeagues[i]

				// Check if user requested stop
				if (getShouldStopImport()) {
					console.log('\n⏸️  Import stopped by user')
					console.log(`✅ Imported ${this.progress.importedMatches} matches so far`)
					this.stateManager.markPaused('Stopped by user')
					return
				}

				try {
					await this.importLeagueMatches(league, fromDate, toDate)

					// Update state after each league
					state.currentLeagueIndex = i
					state.matchesImported = this.progress.importedMatches
					this.stateManager.saveState(state)

					// Show progress
					this.displayProgress()

					// Small delay between leagues to respect rate limits
					await this.sleep(1000)
				} catch (error: any) {
					if (error.message?.includes('rate limit') || error.message?.includes('429')) {
						console.log('\n⏸️  Rate limit reached.')
						console.log(`✅ Imported ${this.progress.importedMatches} matches so far`)

						if (autoRetry) {
							console.log(`\n⏰ Auto-retry enabled. Waiting 1 hour before continuing...`)

							// Save current state as paused before waiting
							const currentState = this.stateManager.loadState()
							if (currentState) {
								currentState.status = 'paused'
								currentState.error = 'Rate limit - waiting for auto-retry'
								this.stateManager.saveState(currentState)
							}

							// Wait 1 hour
							await this.waitWithCountdown(3600) // 3600 seconds = 1 hour

							console.log(`\n🔄 Resuming import...`)

							// Update state to in-progress before resuming
							if (currentState) {
								currentState.status = 'in-progress'
								currentState.error = undefined
								this.stateManager.saveState(currentState)
							}

							// Recursive call to continue from current position
							return await this.importDateRange(fromDate, toDate, true, autoRetry)
						} else {
							console.log(`\n💡 To resume later, run: npm run import:resume`)
							this.stateManager.markPaused('Rate limit reached')
							return
						}
					}
					throw error
				}
			}

			console.log('\n=== Import Complete ===')
			this.displayFinalSummary()
			this.stateManager.markCompleted()
		} catch (error) {
			console.error('\n❌ Import failed:', error)
			this.stateManager.markPaused(error instanceof Error ? error.message : 'Unknown error')
			throw error
		}
	}

	/**
	 * Import matches for a single league in date range
	 */
	private async importLeagueMatches(league: LeagueConfig, fromDate: string, toDate: string): Promise<void> {
		console.log(`\nProcessing: ${league.name} (${league.country})`)

		// Initialize league stats first (before any potential errors)
		if (!this.progress.leagues[league.id]) {
			this.progress.leagues[league.id] = {
				name: league.name,
				imported: 0,
				failed: 0,
			}
		}

		try {
			// Get current season (2025 for Nov 2025)
			const currentYear = new Date().getFullYear()

			// Fetch fixtures for this league in date range
			const fixtures = await this.apiClient.getLeagueFixtures(league.id, currentYear, { from: fromDate, to: toDate })

			console.log(`  Found ${fixtures.length} matches`)

			if (fixtures.length === 0) {
				return
			}

			// OPTIMIZATION: Pre-fetch all finished matches from database for this date range
			// This avoids individual SELECT queries for each match (saves DB calls)
			const fixtureIds = fixtures.map(f => f.fixture.id)
			const finishedMatchesInDb = await prisma.$queryRawUnsafe<Array<{ fixture_id: number }>>(
				`SELECT fixture_id 
			FROM matches 
			WHERE fixture_id = ANY($1::int[])
			AND is_finished = 'yes'`,
				fixtureIds
			)
			const finishedFixtureIds = new Set(finishedMatchesInDb.map(m => m.fixture_id)) // Process each fixture
			for (const fixture of fixtures) {
				await this.importSingleMatch(fixture, league, finishedFixtureIds)
			}
		} catch (error) {
			console.error(`  Error processing league ${league.name}:`, error)
			this.progress.leagues[league.id].failed++
		}
	}

	/**
	 * Get team standings (positions) from league table with caching
	 */
	private async getTeamStandings(
		leagueId: number,
		season: number,
		homeTeam: string,
		awayTeam: string
	): Promise<{ homeStanding: number | null; awayStanding: number | null }> {
		try {
			const cacheKey = `${leagueId}-${season}`

			// Check cache first
			if (!this.standingsCache.has(cacheKey)) {
				// Fetch standings from API
				console.log(`  📊 Fetching standings for league ${leagueId} season ${season}...`)
				const standingsResponse = await this.apiClient.getStandings({
					league: leagueId,
					season: season,
				})

				if (standingsResponse.response.length > 0) {
					this.standingsCache.set(cacheKey, standingsResponse.response[0])
				} else {
					console.warn(`  ⚠️  No standings found for league ${leagueId}`)
					return { homeStanding: null, awayStanding: null }
				}
			}

			// Get standings from cache
			const standings = this.standingsCache.get(cacheKey)
			if (!standings || !standings.league.standings[0]) {
				return { homeStanding: null, awayStanding: null }
			}

			// Find team positions
			const table = standings.league.standings[0]
			const homeStanding = table.find(s => s.team.name === homeTeam)?.rank || null
			const awayStanding = table.find(s => s.team.name === awayTeam)?.rank || null

			return { homeStanding, awayStanding }
		} catch (error) {
			console.warn(`  ⚠️  Could not fetch standings:`, error)
			return { homeStanding: null, awayStanding: null }
		}
	}

	/**
	 * Import a single match with statistics and odds (optimized to save API tokens)
	 */
	private async importSingleMatch(
		fixture: FixtureResponse,
		league: LeagueConfig,
		finishedFixtureIds?: Set<number>
	): Promise<void> {
		const fixtureId = fixture.fixture.id
		const homeTeam = fixture.teams.home.name
		const awayTeam = fixture.teams.away.name
		const isFinished = ['FT', 'AET', 'PEN'].includes(fixture.fixture.status.short)

		try {
			// OPTIMIZATION: Quick check using pre-fetched cache
			if (finishedFixtureIds && finishedFixtureIds.has(fixtureId)) {
				console.log(`  ⏭️  ${homeTeam} vs ${awayTeam} - already finished in database`)
				return
			}

			// OPTIMIZATION: Check if match exists BEFORE fetching statistics/odds from API
			// Only needed if we don't have the cache
			const existingMatches = finishedFixtureIds
				? []
				: await prisma.$queryRaw<
						Array<{
							is_finished: string | null
							home_odds: number | null
							draw_odds: number | null
							away_odds: number | null
						}>
				  >`
				SELECT is_finished, home_odds, draw_odds, away_odds
				FROM matches
				WHERE fixture_id = ${fixtureId}
				LIMIT 1
			`
			const existingMatch = existingMatches.length > 0 ? existingMatches[0] : null

			// CASE 1: Match finished in DB → SKIP (saves 2 API tokens!)
			if (existingMatch && existingMatch.is_finished === 'yes') {
				console.log(`  ⏭️  ${homeTeam} vs ${awayTeam} - already finished in database`)
				return
			}

			// CASE 2: Match not finished in DB, new data also not finished → Only fetch ODDS
			if (existingMatch && existingMatch.is_finished === 'no' && !isFinished) {
				let odds: OddsResponse[] = []

				try {
					const oddsResponse = await this.apiClient.getOdds({
						fixture: fixtureId,
					})
					odds = oddsResponse.response
				} catch (error) {
					console.warn(`    Could not fetch odds for fixture ${fixtureId}`)
				}

				// Extract and compare odds
				let homeOdds: number | null = null
				let drawOdds: number | null = null
				let awayOdds: number | null = null

				if (odds.length > 0) {
					const oddsData = odds[0]
					const matchWinnerBet = oddsData.bookmakers[0]?.bets.find(b => b.name === 'Match Winner')
					if (matchWinnerBet) {
						homeOdds = parseFloat(matchWinnerBet.values.find(v => v.value === 'Home')?.odd || '0') || null
						drawOdds = parseFloat(matchWinnerBet.values.find(v => v.value === 'Draw')?.odd || '0') || null
						awayOdds = parseFloat(matchWinnerBet.values.find(v => v.value === 'Away')?.odd || '0') || null
					}
				}

				const oddsChanged =
					existingMatch.home_odds !== homeOdds ||
					existingMatch.draw_odds !== drawOdds ||
					existingMatch.away_odds !== awayOdds

				if (oddsChanged) {
					await prisma.$executeRawUnsafe(
						`
						UPDATE matches
						SET home_odds = $1, draw_odds = $2, away_odds = $3
						WHERE fixture_id = $4
					`,
						homeOdds,
						drawOdds,
						awayOdds,
						fixtureId
					)
					console.log(`  🔄 ${homeTeam} vs ${awayTeam} - odds updated`)
				} else {
					console.log(`  ⏭️  ${homeTeam} vs ${awayTeam} - no changes`)
				}
				return
			}

			// CASE 3 & 4: Fetch full data (new match OR match became finished)
			let statistics: FixtureStatisticsResponse[] = []
			let odds: OddsResponse[] = []

			try {
				const statsResponse = await this.apiClient.getFixtureStatistics({
					fixture: fixtureId,
				})
				statistics = statsResponse.response
			} catch (error) {
				console.warn(`    Could not fetch statistics for fixture ${fixtureId}`)
			}

			try {
				const oddsResponse = await this.apiClient.getOdds({
					fixture: fixtureId,
				})
				odds = oddsResponse.response
			} catch (error) {
				console.warn(`    Could not fetch odds for fixture ${fixtureId}`)
			}

			// Save or update to database
			await this.saveMatchToDatabase(fixture, statistics, odds, league, existingMatch)

			if (existingMatch) {
				console.log(`  ✅ ${homeTeam} vs ${awayTeam} - finished, statistics updated`)
			} else {
				console.log(`  ✅ ${homeTeam} vs ${awayTeam} - imported`)
			}

			this.progress.importedMatches++
			this.progress.totalMatches++
			this.progress.leagues[league.id].imported++
		} catch (error) {
			console.error(`  ❌ Failed to import match ${fixtureId}:`, error)
			this.progress.failedMatches++
			this.progress.totalMatches++
			this.progress.leagues[league.id].failed++
		}
	}

	/**
	 * Map API data to database schema and save (with update logic)
	 */
	private async saveMatchToDatabase(
		fixture: FixtureResponse,
		statistics: FixtureStatisticsResponse[],
		odds: OddsResponse[],
		league: LeagueConfig,
		existingMatch: {
			is_finished: string | null
			home_odds: number | null
			draw_odds: number | null
			away_odds: number | null
		} | null
	): Promise<void> {
		const fixtureId = fixture.fixture.id

		// Extract basic match info
		const matchDate = new Date(fixture.fixture.date)
		const homeTeam = fixture.teams.home.name
		const awayTeam = fixture.teams.away.name
		const homeScore = fixture.goals.home ?? 0
		const awayScore = fixture.goals.away ?? 0

		// Determine if match is finished (FT = Full Time, AET = After Extra Time, PEN = Penalties)
		const isFinished = ['FT', 'AET', 'PEN'].includes(fixture.fixture.status.short) ? 'yes' : 'no'

		// Get team standings ONLY for finished matches
		let homeStanding: number | null = null
		let awayStanding: number | null = null

		if (isFinished === 'yes') {
			const season = new Date(fixture.fixture.date).getFullYear()
			const standings = await this.getTeamStandings(league.id, season, homeTeam, awayTeam)
			homeStanding = standings.homeStanding
			awayStanding = standings.awayStanding
		}

		// Half-time scores
		const homeScoreHT = fixture.score.halftime.home ?? 0
		const awayScoreHT = fixture.score.halftime.away ?? 0

		// Determine match result
		let matchResult: 'h-win' | 'draw' | 'a-win'
		if (homeScore > awayScore) {
			matchResult = 'h-win'
		} else if (homeScore < awayScore) {
			matchResult = 'a-win'
		} else {
			matchResult = 'draw'
		}

		// Determine half-time result
		let resultHT: string
		if (homeScoreHT > awayScoreHT) {
			resultHT = 'h-win'
		} else if (homeScoreHT < awayScoreHT) {
			resultHT = 'a-win'
		} else {
			resultHT = 'draw'
		}

		// Extract statistics
		const homeStats = statistics.find(s => s.team.id === fixture.teams.home.id)
		const awayStats = statistics.find(s => s.team.id === fixture.teams.away.id)

		// Check if we have real statistics data (Ball Possession is a good indicator)
		const hasRealStats =
			homeStats?.statistics.some(s => s.type === 'Ball Possession' && s.value !== null) ||
			awayStats?.statistics.some(s => s.type === 'Ball Possession' && s.value !== null)

		const getStatValue = (
			stats: FixtureStatisticsResponse | undefined,
			type: string,
			defaultValue?: number | null
		): number | null => {
			if (!stats) return defaultValue !== undefined ? defaultValue : hasRealStats ? 0 : null

			const stat = stats.statistics.find(s => s.type === type)
			if (!stat || stat.value === null) {
				// If defaultValue explicitly provided, use it
				if (defaultValue !== undefined) return defaultValue
				// Otherwise: if we have real stats → missing value = 0, else = null
				return hasRealStats ? 0 : null
			}

			// Handle percentage strings like "65%"
			if (typeof stat.value === 'string' && stat.value.includes('%')) {
				return parseInt(stat.value)
			}

			return typeof stat.value === 'number' ? stat.value : parseInt(stat.value)
		}

		// Helper for xG - try multiple field names and handle decimal strings
		const getXGValue = (stats: FixtureStatisticsResponse | undefined): number | null => {
			if (!stats) return null

			// Try different possible field names
			const possibleNames = ['expected_goals', 'Expected Goals', 'xG', 'Expected goals']

			for (const name of possibleNames) {
				const stat = stats.statistics.find(s => s.type === name)
				if (stat && stat.value !== null) {
					// Ensure we preserve decimal precision
					let value: number
					if (typeof stat.value === 'string') {
						value = parseFloat(stat.value)
					} else if (typeof stat.value === 'number') {
						value = stat.value
					} else {
						continue
					}

					// Validate and return with full precision
					if (!isNaN(value) && value >= 0) {
						// Round to 2 decimal places to match database precision
						return Math.round(value * 100) / 100
					}
				}
			}

			return null
		} // Extract betting odds (pre-match, 1X2)
		let homeOdds: number | null = null
		let drawOdds: number | null = null
		let awayOdds: number | null = null

		if (odds.length > 0) {
			const oddsData = odds[0] // Take first bookmaker
			const matchWinnerBet = oddsData.bookmakers[0]?.bets.find(b => b.name === 'Match Winner')

			if (matchWinnerBet) {
				homeOdds = parseFloat(matchWinnerBet.values.find(v => v.value === 'Home')?.odd || '0') || null
				drawOdds = parseFloat(matchWinnerBet.values.find(v => v.value === 'Draw')?.odd || '0') || null
				awayOdds = parseFloat(matchWinnerBet.values.find(v => v.value === 'Away')?.odd || '0') || null
			}
		}

		// CASE 3: Match exists with is_finished = "no", new match "yes" → UPDATE ALL EXCEPT ODDS
		if (existingMatch && existingMatch.is_finished === 'no' && isFinished === 'yes') {
			await prisma.$executeRawUnsafe(
				`
				UPDATE matches
				SET 
					home_goals = $1,
					away_goals = $2,
					result = $3::match_result_enum,
					home_goals_ht = $4,
					away_goals_ht = $5,
					result_ht = $6,
					home_xg = $7,
					away_xg = $8,
					home_shots = $9,
					home_shots_on_target = $10,
					away_shots = $11,
					away_shots_on_target = $12,
					home_corners = $13,
					away_corners = $14,
					home_offsides = $15,
					away_offsides = $16,
					home_y_cards = $17,
					away_y_cards = $18,
					home_r_cards = $19,
					away_r_cards = $20,
					home_possession = $21,
					away_possession = $22,
					home_fouls = $23,
					away_fouls = $24,
					standing_home = COALESCE($25, standing_home),
					standing_away = COALESCE($26, standing_away),
					is_finished = $27
				WHERE fixture_id = $28
			`,
				homeScore,
				awayScore,
				matchResult === 'h-win' ? 'h-win' : matchResult === 'a-win' ? 'a-win' : 'draw',
				homeScoreHT,
				awayScoreHT,
				resultHT,
				getXGValue(homeStats),
				getXGValue(awayStats),
				getStatValue(homeStats, 'Total Shots'),
				getStatValue(homeStats, 'Shots on Goal'),
				getStatValue(awayStats, 'Total Shots'),
				getStatValue(awayStats, 'Shots on Goal'),
				getStatValue(homeStats, 'Corner Kicks'),
				getStatValue(awayStats, 'Corner Kicks'),
				getStatValue(homeStats, 'Offsides'),
				getStatValue(awayStats, 'Offsides'),
				getStatValue(homeStats, 'Yellow Cards'),
				getStatValue(awayStats, 'Yellow Cards'),
				getStatValue(homeStats, 'Red Cards'),
				getStatValue(awayStats, 'Red Cards'),
				getStatValue(homeStats, 'Ball Possession'),
				getStatValue(awayStats, 'Ball Possession'),
				getStatValue(homeStats, 'Fouls'),
				getStatValue(awayStats, 'Fouls'),
				homeStanding,
				awayStanding,
				isFinished,
				fixtureId
			)
			console.log(`  ✅ ${homeTeam} vs ${awayTeam} - finished, statistics updated`)
			return
		}

		// CASE 4: Match doesn't exist → INSERT NEW
		await prisma.$executeRawUnsafe(
			`
			INSERT INTO matches (
				fixture_id,
				match_date,
				country,
				league,
				home_team,
				away_team,
				result,
				home_goals,
				away_goals,
				home_goals_ht,
				away_goals_ht,
				result_ht,
				home_xg,
				away_xg,
				home_shots,
				home_shots_on_target,
				away_shots,
				away_shots_on_target,
				home_corners,
				away_corners,
				home_offsides,
				away_offsides,
				home_y_cards,
				away_y_cards,
				home_r_cards,
				away_r_cards,
				home_possession,
				away_possession,
				home_fouls,
				away_fouls,
				home_odds,
				draw_odds,
				away_odds,
				standing_home,
				standing_away,
				is_finished
			) VALUES (
				$1, $2, $3, $4, $5, $6, $7::match_result_enum, $8, $9, $10,
				$11, $12, $13, $14, $15, $16, $17, $18, $19, $20,
				$21, $22, $23, $24, $25, $26, $27, $28, $29, $30,
				$31, $32, $33, $34, $35, $36
			)
		`,
			fixtureId,
			matchDate,
			league.country,
			league.name,
			homeTeam,
			awayTeam,
			matchResult === 'h-win' ? 'h-win' : matchResult === 'a-win' ? 'a-win' : 'draw',
			homeScore,
			awayScore,
			homeScoreHT,
			awayScoreHT,
			resultHT,
			getXGValue(homeStats),
			getXGValue(awayStats),
			getStatValue(homeStats, 'Total Shots'),
			getStatValue(homeStats, 'Shots on Goal'),
			getStatValue(awayStats, 'Total Shots'),
			getStatValue(awayStats, 'Shots on Goal'),
			getStatValue(homeStats, 'Corner Kicks'),
			getStatValue(awayStats, 'Corner Kicks'),
			getStatValue(homeStats, 'Offsides'),
			getStatValue(awayStats, 'Offsides'),
			getStatValue(homeStats, 'Yellow Cards'),
			getStatValue(awayStats, 'Yellow Cards'),
			getStatValue(homeStats, 'Red Cards'),
			getStatValue(awayStats, 'Red Cards'),
			getStatValue(homeStats, 'Ball Possession'),
			getStatValue(awayStats, 'Ball Possession'),
			getStatValue(homeStats, 'Fouls'),
			getStatValue(awayStats, 'Fouls'),
			homeOdds,
			drawOdds,
			awayOdds,
			homeStanding,
			awayStanding,
			isFinished
		)
	}

	/**
	 * Display current progress
	 */
	private displayProgress(): void {
		const stats = this.apiClient.getRateLimitStats()
		console.log(`\nProgress: ${this.progress.importedMatches} imported, ${this.progress.failedMatches} failed`)
		console.log(`Rate limit: ${stats.dailyRequests}/${stats.dailyLimit} daily, ${stats.dailyRemaining} remaining`)
	}

	/**
	 * Display final summary
	 */
	private displayFinalSummary(): void {
		console.log('\n📊 Final Summary:')
		console.log(`Total matches processed: ${this.progress.totalMatches}`)
		console.log(`✅ Successfully imported: ${this.progress.importedMatches}`)
		console.log(`❌ Failed: ${this.progress.failedMatches}`)

		console.log('\nBy League:')
		Object.values(this.progress.leagues)
			.sort((a, b) => b.imported - a.imported)
			.forEach(league => {
				console.log(`  ${league.name}: ${league.imported} imported, ${league.failed} failed`)
			})

		const stats = this.apiClient.getRateLimitStats()
		console.log(`\n⚡ API Usage: ${stats.dailyRequests}/${stats.dailyLimit} (${stats.dailyRemaining} remaining)`)
	}

	/**
	 * Wait with countdown display
	 */
	private async waitWithCountdown(seconds: number): Promise<void> {
		const endTime = Date.now() + seconds * 1000

		while (Date.now() < endTime) {
			const remaining = Math.floor((endTime - Date.now()) / 1000)
			const minutes = Math.floor(remaining / 60)
			const secs = remaining % 60

			// Clear line and write countdown
			process.stdout.write(`\r⏳ Waiting: ${minutes}m ${secs}s remaining...`)

			await this.sleep(1000)
		}

		process.stdout.write('\r✅ Wait complete!                    \n')
	}

	/**
	 * Helper: Sleep for milliseconds
	 */
	private sleep(ms: number): Promise<void> {
		return new Promise(resolve => setTimeout(resolve, ms))
	}

	/**
	 * Get import progress
	 */
	getProgress(): ImportProgress {
		return this.progress
	}

	/**
	 * Get current rate limit information from API client
	 */
	getRateLimitInfo(): { remaining: number; limit: number } {
		const stats = this.apiClient.getRateLimitStats()
		return {
			remaining: stats.hourlyRemaining,
			limit: stats.hourlyLimit,
		}
	}
}
