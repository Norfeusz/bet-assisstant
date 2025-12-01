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
	private leagueOddsAvailability: Map<number, boolean> // Cache: leagueId -> has odds

	constructor(apiClient: ApiFootballClient, leagueSelector: LeagueSelector) {
		this.apiClient = apiClient
		this.leagueSelector = leagueSelector
		this.stateManager = new ImportStateManager()
		this.standingsCache = new Map()
		this.leagueOddsAvailability = new Map()
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
	 * Update results for unfinished matches in date range
	 */
	async updateResults(
		fromDate: string,
		toDate: string,
		resume: boolean = false
	): Promise<void> {
		const enabledLeagues = this.leagueSelector.getEnabledLeagues()

		if (enabledLeagues.length === 0) {
			throw new Error('No leagues enabled. Run league selector initialization first.')
		}

		console.log(`\n=== Updating match results from ${fromDate} to ${toDate} ===`)
		console.log(`Leagues to process: ${enabledLeagues.length}`)

		try {
			for (const league of enabledLeagues) {
				// Check if user requested stop
				if (getShouldStopImport()) {
					console.log('\n⏸️  Update stopped by user')
					console.log(`✅ Updated ${this.progress.importedMatches} matches so far`)
					return
				}

				try {
					await this.updateLeagueResults(league, fromDate, toDate)
					this.displayProgress()
					await this.sleep(1000)
				} catch (error: any) {
					console.error(`  Error updating league ${league.name}:`, error)
					if (error.message?.includes('rate limit') || error.message?.includes('429')) {
						console.log('\n⏸️  Rate limit reached.')
						throw error
					}
				}
			}

			console.log('\n✅ Results update completed!')
			console.log(`Updated: ${this.progress.importedMatches} matches`)
		} catch (error) {
			console.error('Error during results update:', error)
			throw error
		}
	}

	/**
	 * Update results for a single league
	 */
	private async updateLeagueResults(league: LeagueConfig, fromDate: string, toDate: string): Promise<void> {
		console.log(`\nUpdating results: ${league.name} (${league.country})`)

		if (!this.progress.leagues[league.id]) {
			this.progress.leagues[league.id] = {
				name: league.name,
				imported: 0,
				failed: 0,
			}
		}

		try {
			const currentYear = new Date().getFullYear()
			
			console.log(`  🔍 Fetching finished fixtures: league=${league.id}, season=${currentYear}, from=${fromDate}, to=${toDate}`)

			// Fetch fixtures from API
			const fixtures = await this.apiClient.getLeagueFixtures(league.id, currentYear, { from: fromDate, to: toDate })
			
			console.log(`  ✅ API returned ${fixtures.length} fixtures for ${league.name}`)

			if (fixtures.length === 0) {
				return
			}

			// Filter only finished fixtures
			const finishedFixtures = fixtures.filter(f => ['FT', 'AET', 'PEN'].includes(f.fixture.status.short))
			console.log(`  📊 Found ${finishedFixtures.length} finished fixtures`)

			// Process each finished fixture
			for (const fixture of finishedFixtures) {
				await this.updateSingleMatchResult(fixture, league)
			}
		} catch (error) {
			console.error(`  Error updating league ${league.name}:`, error)
			this.progress.leagues[league.id].failed++
			throw error
		}
	}

	/**
	 * Update a single match result if it exists in database and is unfinished
	 */
	private async updateSingleMatchResult(fixture: FixtureResponse, league: LeagueConfig): Promise<void> {
		const fixtureId = fixture.fixture.id
		const homeTeam = fixture.teams.home.name
		const awayTeam = fixture.teams.away.name

		try {
			// Check if match exists and is unfinished
			const existingMatch = await prisma.matches.findUnique({
				where: { fixture_id: fixtureId },
				select: { fixture_id: true, is_finished: true }
			})

			if (!existingMatch) {
				// Match doesn't exist in database - skip
				return
			}

			if (existingMatch.is_finished === 'yes') {
				// Already updated - skip
				return
			}

		console.log(`  🔄 Updating: ${homeTeam} vs ${awayTeam}`)

		// Fetch statistics and odds
		let statistics: FixtureStatisticsResponse[] = []
		let odds: OddsResponse[] = []

		try {
			const statsResponse = await this.apiClient.getFixtureStatistics({ fixture: fixtureId })
			statistics = statsResponse.response
			await this.sleep(334) // Rate limit: ~3 requests/sec
		} catch (error) {
			console.warn(`  ⚠️  Could not fetch statistics for fixture ${fixtureId}`)
		}

		// Check if odds are available for this league (cache result)
		let shouldFetchOdds = true
		if (this.leagueOddsAvailability.has(league.id)) {
			shouldFetchOdds = this.leagueOddsAvailability.get(league.id)!
		}

		if (shouldFetchOdds) {
			try {
				const oddsResponse = await this.apiClient.getOdds({ fixture: fixtureId })
				odds = oddsResponse.response
				await this.sleep(334)

				// Cache result: if no odds returned, don't fetch for other matches in this league
				if (odds.length === 0 && !this.leagueOddsAvailability.has(league.id)) {
					console.log(`  ℹ️  No odds available for league ${league.name}, skipping odds for remaining matches`)
					this.leagueOddsAvailability.set(league.id, false)
				} else if (odds.length > 0) {
					this.leagueOddsAvailability.set(league.id, true)
				}
			} catch (error) {
				console.warn(`  ⚠️  Could not fetch odds for fixture ${fixtureId}`)
			}
		}			// Update match in database using saveMatchToDatabase
			await this.saveMatchToDatabase(fixture, statistics, odds, league, {
				is_finished: existingMatch.is_finished,
				home_odds: null,
				draw_odds: null,
				away_odds: null
			})

			this.progress.importedMatches++
			this.progress.leagues[league.id].imported++
			console.log(`  ✅ Updated: ${homeTeam} vs ${awayTeam}`)
		} catch (error: any) {
			console.error(`  ❌ Error updating ${homeTeam} vs ${awayTeam}:`, error.message)
			this.progress.failedMatches++
			this.progress.leagues[league.id].failed++
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

			console.log(`  🔍 Fetching fixtures: league=${league.id}, season=${currentYear}, from=${fromDate}, to=${toDate}`)

			// Fetch fixtures for this league in date range
			const fixtures = await this.apiClient.getLeagueFixtures(league.id, currentYear, { from: fromDate, to: toDate })

			console.log(`  ✅ API returned ${fixtures.length} fixtures for ${league.name}`)

			if (fixtures.length === 0) {
				return
			}

			// Process each fixture (no pre-checking for duplicates)
			// Database will handle duplicates via unique constraint on fixture_id
			for (const fixture of fixtures) {
				await this.importSingleMatch(fixture, league)
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
	 * Import a single match with statistics and odds (optimized - no duplicate checking)
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
			// Check if match already exists in database BEFORE making API calls
			const existingMatch = await prisma.matches.findUnique({
				where: { fixture_id: fixtureId },
				select: { fixture_id: true }
			})

			if (existingMatch) {
				console.log(`  ⏭️  ${homeTeam} vs ${awayTeam} - already exists (skipped)`)
				return
			}
			
		// Fetch full data (statistics + odds)
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

		// Check if odds are available for this league (cache result)
		let shouldFetchOdds = true
		if (this.leagueOddsAvailability.has(league.id)) {
			shouldFetchOdds = this.leagueOddsAvailability.get(league.id)!
		}

		if (shouldFetchOdds) {
			try {
				const oddsResponse = await this.apiClient.getOdds({
					fixture: fixtureId,
				})
				odds = oddsResponse.response

				// Cache result: if no odds returned, don't fetch for other matches in this league
				if (odds.length === 0 && !this.leagueOddsAvailability.has(league.id)) {
					console.log(`  ℹ️  No odds available for league ${league.name}, skipping odds for remaining matches`)
					this.leagueOddsAvailability.set(league.id, false)
				} else if (odds.length > 0) {
					this.leagueOddsAvailability.set(league.id, true)
				}
			} catch (error) {
				console.warn(`    Could not fetch odds for fixture ${fixtureId}`)
				// On error, assume odds might be available for other matches
			}
		}			// Save to database using UPSERT (INSERT ... ON CONFLICT DO UPDATE)
			// Database will handle duplicates automatically via unique constraint on fixture_id
			await this.saveMatchToDatabase(fixture, statistics, odds, league, null)

			console.log(`  ✅ ${homeTeam} vs ${awayTeam} - saved to database`)

			this.progress.importedMatches++
			this.progress.totalMatches++
			this.progress.leagues[league.id].imported++
		} catch (error: any) {
			// Ignore duplicate key errors (means match was already imported)
			if (error.code === '23505' || error.message?.includes('duplicate key')) {
				console.log(`  ⏭️  ${homeTeam} vs ${awayTeam} - already exists (skipped)`)
				return
			}
			
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

		// Get team standings ONLY for matches from November 1, 2025 onwards
		let homeStanding: number | null = null
		let awayStanding: number | null = null

		const standingsCutoffDate = new Date('2025-11-01')
		if (matchDate >= standingsCutoffDate) {
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

		// UPSERT: Insert new match or update if already exists (using unique constraint on fixture_id)
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
				$1, $2, $3, $4, $5, $6, $7::match_result_enum, $8, $9, $10, $11, $12,
				$13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26,
				$27, $28, $29, $30, $31, $32, $33, $34, $35, $36
			)
			ON CONFLICT (fixture_id) DO UPDATE SET
				match_date = EXCLUDED.match_date,
				result = EXCLUDED.result,
				home_goals = EXCLUDED.home_goals,
				away_goals = EXCLUDED.away_goals,
				home_goals_ht = EXCLUDED.home_goals_ht,
				away_goals_ht = EXCLUDED.away_goals_ht,
				result_ht = EXCLUDED.result_ht,
				home_xg = EXCLUDED.home_xg,
				away_xg = EXCLUDED.away_xg,
				home_shots = EXCLUDED.home_shots,
				home_shots_on_target = EXCLUDED.home_shots_on_target,
				away_shots = EXCLUDED.away_shots,
				away_shots_on_target = EXCLUDED.away_shots_on_target,
				home_corners = EXCLUDED.home_corners,
				away_corners = EXCLUDED.away_corners,
				home_offsides = EXCLUDED.home_offsides,
				away_offsides = EXCLUDED.away_offsides,
				home_y_cards = EXCLUDED.home_y_cards,
				away_y_cards = EXCLUDED.away_y_cards,
				home_r_cards = EXCLUDED.home_r_cards,
				away_r_cards = EXCLUDED.away_r_cards,
				home_possession = EXCLUDED.home_possession,
				away_possession = EXCLUDED.away_possession,
				home_fouls = EXCLUDED.home_fouls,
				away_fouls = EXCLUDED.away_fouls,
				home_odds = COALESCE(EXCLUDED.home_odds, matches.home_odds),
				draw_odds = COALESCE(EXCLUDED.draw_odds, matches.draw_odds),
				away_odds = COALESCE(EXCLUDED.away_odds, matches.away_odds),
				standing_home = COALESCE(EXCLUDED.standing_home, matches.standing_home),
				standing_away = COALESCE(EXCLUDED.standing_away, matches.standing_away),
				is_finished = EXCLUDED.is_finished
		`,
			fixtureId,
			matchDate,
			league.country,
			league.name,
			homeTeam,
			awayTeam,
			matchResult,
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
