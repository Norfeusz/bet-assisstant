/**
 * Bet Finder Module
 * Functions for finding and analyzing matches based on various criteria
 */

import { showToast } from './utils/helpers.js'
import { state } from './config/state.js'
import { isCancelled } from './search-queue.js'

/**
 * Validate date range from bet finder form
 * @returns {Object|null} { dateFrom, dateTo } or null if invalid
 */
function validateDateRange() {
	const dateFrom = document.getElementById('bet-finder-date-from').value
	const dateTo = document.getElementById('bet-finder-date-to').value

	if (!dateFrom || !dateTo) {
		showToast('Wybierz zakres dat', 'error')
		return null
	}

	if (new Date(dateFrom) > new Date(dateTo)) {
		showToast('Data "od" nie może być późniejsza niż "do"', 'error')
		return null
	}

	return { dateFrom, dateTo }
}

/**
 * Calculate goal statistics for a team
 * @param {Array} matches - Team's historical matches
 * @param {string} teamName - Team name
 * @returns {Object} Goal statistics
 */
function calculateGoalStats(matches, teamName) {
	let totalGoalsScored = 0
	let totalGoalsConceded = 0
	let matchCount = 0
	const matchDetails = []

	matches.forEach(match => {
		const isHome = match.home_team === teamName
		const goalsScored = isHome ? match.home_goals : match.away_goals
		const goalsConceded = isHome ? match.away_goals : match.home_goals

		totalGoalsScored += goalsScored || 0
		totalGoalsConceded += goalsConceded || 0
		matchCount++

		matchDetails.push({
			date: match.match_date,
			homeTeam: match.home_team,
			awayTeam: match.away_team,
			homeGoals: match.home_goals,
			awayGoals: match.away_goals,
			totalGoals: (match.home_goals || 0) + (match.away_goals || 0),
			isHome: isHome,
			standing_home: match.standing_home,
			standing_away: match.standing_away,
		})
	})

	const totalGoals = totalGoalsScored + totalGoalsConceded
	const avgGoals = matchCount > 0 ? (totalGoals / matchCount).toFixed(2) : 0

	return {
		totalGoalsScored,
		totalGoalsConceded,
		totalGoals,
		matchCount,
		avgGoals: parseFloat(avgGoals),
		matches: matchDetails,
	}
}

/**
 * Calculate corner statistics for a team
 * @param {Array} matches - Team's historical matches
 * @param {string} teamName - Team name
 * @returns {Object} Corner statistics
 */
function calculateCornerStats(matches, teamName) {
	let totalCorners = 0
	let cornersMatchCount = 0
	let matchCount = 0
	const matchDetails = []

	matches.forEach(match => {
		matchCount++

		const isHome = match.home_team === teamName

		// Only count matches with corner data
		if (match.home_corners != null && match.away_corners != null) {
			const teamCorners = isHome ? match.home_corners : match.away_corners
			const opponentCorners = isHome ? match.away_corners : match.home_corners
			const totalMatchCorners = match.home_corners + match.away_corners

			totalCorners += teamCorners
			cornersMatchCount++

			matchDetails.push({
				date: match.match_date,
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeGoals: match.home_goals,
				awayGoals: match.away_goals,
				homeCorners: match.home_corners,
				awayCorners: match.away_corners,
				totalCorners: totalMatchCorners,
				teamCorners: teamCorners,
				isHome: isHome,
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			})
		}
	})

	return {
		totalCorners,
		cornersMatchCount,
		matchCount,
		avgCorners: cornersMatchCount > 0 ? parseFloat((totalCorners / cornersMatchCount).toFixed(2)) : 0,
		matches: matchDetails,
	}
}

/**
 * Calculate offsides statistics for a team
 * @param {Array} matches - Team's historical matches
 * @param {string} teamName - Team name
 * @returns {Object} Offsides statistics
 */
function calculateOffsidesStats(matches, teamName) {
	let totalOffsides = 0
	let offsidesMatchCount = 0
	let matchCount = 0
	const matchDetails = []

	matches.forEach(match => {
		matchCount++

		const isHome = match.home_team === teamName

		// Only count matches with offsides data
		if (match.home_offsides != null && match.away_offsides != null) {
			const teamOffsides = isHome ? match.home_offsides : match.away_offsides
			const opponentOffsides = isHome ? match.away_offsides : match.home_offsides
			const totalMatchOffsides = match.home_offsides + match.away_offsides

			totalOffsides += teamOffsides
			offsidesMatchCount++

			matchDetails.push({
				date: match.match_date,
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeGoals: match.home_goals,
				awayGoals: match.away_goals,
				homeOffsides: match.home_offsides,
				awayOffsides: match.away_offsides,
				totalOffsides: totalMatchOffsides,
				teamOffsides: teamOffsides,
				isHome: isHome,
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			})
		}
	})

	return {
		totalOffsides,
		offsidesMatchCount,
		matchCount,
		avgOffsides: offsidesMatchCount > 0 ? parseFloat((totalOffsides / offsidesMatchCount).toFixed(2)) : 0,
		matches: matchDetails,
	}
}

/**
 * Calculate corner advantage statistics (corners for and against)
 * @param {Array} matches - Team's historical matches
 * @param {string} teamName - Team name
 * @returns {Object} Corner advantage statistics
 */
function calculateCornerAdvantageStats(matches, teamName) {
	let totalCornersFor = 0 // Corners executed by team
	let totalCornersAgainst = 0 // Corners executed by opponents
	let cornersMatchCount = 0
	let matchCount = 0
	const matchDetails = []

	matches.forEach(match => {
		matchCount++

		const isHome = match.home_team === teamName

		// Only count matches with corner data
		if (match.home_corners != null && match.away_corners != null) {
			const teamCorners = isHome ? match.home_corners : match.away_corners
			const opponentCorners = isHome ? match.away_corners : match.home_corners

			totalCornersFor += teamCorners
			totalCornersAgainst += opponentCorners
			cornersMatchCount++

			matchDetails.push({
				date: match.match_date,
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeGoals: match.home_goals,
				awayGoals: match.away_goals,
				homeCorners: match.home_corners,
				awayCorners: match.away_corners,
				teamCornersFor: teamCorners,
				teamCornersAgainst: opponentCorners,
				isHome: isHome,
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			})
		}
	})

	return {
		totalCornersFor,
		totalCornersAgainst,
		cornersMatchCount,
		matchCount,
		avgCornersFor: cornersMatchCount > 0 ? parseFloat((totalCornersFor / cornersMatchCount).toFixed(2)) : 0,
		avgCornersAgainst: cornersMatchCount > 0 ? parseFloat((totalCornersAgainst / cornersMatchCount).toFixed(2)) : 0,
		matches: matchDetails,
	}
}

/**
 * Calculate total match corners statistics (sum of both teams)
 * @param {Array} matches - Team's historical matches
 * @param {string} teamName - Team name
 * @returns {Object} Total match corners statistics
 */
function calculateTotalMatchCornersStats(matches, teamName) {
	let totalMatchCorners = 0
	let cornersMatchCount = 0
	let matchCount = 0
	const matchDetails = []

	matches.forEach(match => {
		matchCount++

		const isHome = match.home_team === teamName

		// Only count matches with corner data
		if (match.home_corners != null && match.away_corners != null) {
			const matchCornersSum = match.home_corners + match.away_corners
			totalMatchCorners += matchCornersSum
			cornersMatchCount++

			matchDetails.push({
				date: match.match_date,
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeGoals: match.home_goals,
				awayGoals: match.away_goals,
				homeCorners: match.home_corners,
				awayCorners: match.away_corners,
				totalCorners: matchCornersSum,
				isHome: isHome,
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			})
		}
	})

	return {
		totalMatchCorners,
		cornersMatchCount,
		matchCount,
		avgMatchCorners: cornersMatchCount > 0 ? parseFloat((totalMatchCorners / cornersMatchCount).toFixed(2)) : 0,
		matches: matchDetails,
	}
}

/**
 * Calculate total match offsides statistics (sum of both teams)
 * @param {Array} matches - Team's historical matches
 * @param {string} teamName - Team name
 * @returns {Object} Offsides statistics
 */
function calculateTotalMatchOffsidesStats(matches, teamName) {
	let totalMatchOffsides = 0
	let offsidesMatchCount = 0
	let matchCount = 0
	const matchDetails = []

	matches.forEach(match => {
		matchCount++

		const isHome = match.home_team === teamName

		// Only count matches with offsides data
		if (match.home_offsides != null && match.away_offsides != null) {
			const matchOffsidesSum = match.home_offsides + match.away_offsides
			totalMatchOffsides += matchOffsidesSum
			offsidesMatchCount++

			matchDetails.push({
				date: match.match_date,
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeGoals: match.home_goals,
				awayGoals: match.away_goals,
				homeOffsides: match.home_offsides,
				awayOffsides: match.away_offsides,
				totalOffsides: matchOffsidesSum,
				isHome: isHome,
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			})
		}
	})

	return {
		totalMatchOffsides,
		offsidesMatchCount,
		matchCount,
		avgMatchOffsides: offsidesMatchCount > 0 ? parseFloat((totalMatchOffsides / offsidesMatchCount).toFixed(2)) : 0,
		matches: matchDetails,
	}
}

/**
 * Calculate handicap statistics for a team
 * @param {Array} matches - Team's historical matches
 * @param {string} teamName - Team name
 * @returns {Object} Handicap statistics
 */
function calculateHandicapStats(matches, teamName) {
	let winsBy2Plus = 0
	let lossesby2Plus = 0
	let matchCount = 0
	const matchDetails = []

	matches.forEach(match => {
		const isHome = match.home_team === teamName
		const goalsScored = isHome ? match.home_goals : match.away_goals
		const goalsConceded = isHome ? match.away_goals : match.home_goals
		const goalDifference = goalsScored - goalsConceded

		matchCount++

		// Check if win/loss by 2+ goals
		if (goalDifference >= 2) {
			winsBy2Plus++
		}
		if (goalDifference <= -2) {
			lossesby2Plus++
		}

		matchDetails.push({
			date: match.match_date,
			homeTeam: match.home_team,
			awayTeam: match.away_team,
			homeGoals: match.home_goals,
			awayGoals: match.away_goals,
			goalDifference: Math.abs(goalDifference),
			isWinBy2Plus: goalDifference >= 2,
			isLossBy2Plus: goalDifference <= -2,
			isHome: isHome,
			standing_home: match.standing_home,
			standing_away: match.standing_away,
		})
	})

	return {
		winsBy2Plus,
		lossesby2Plus,
		matchCount,
		matches: matchDetails,
	}
}

/**
 * Calculate win/loss statistics for a team
 * @param {Array} matches - Team's historical matches
 * @param {string} teamName - Team name
 * @returns {Object} Win/Loss statistics
 */
function calculateWinLossStats(matches, teamName) {
	let wins = 0
	let losses = 0
	let draws = 0
	let matchCount = 0
	const matchDetails = []

	matches.forEach(match => {
		const isHome = match.home_team === teamName
		const goalsScored = isHome ? match.home_goals : match.away_goals
		const goalsConceded = isHome ? match.away_goals : match.home_goals

		matchCount++

		// Determine result
		if (goalsScored > goalsConceded) {
			wins++
		} else if (goalsScored < goalsConceded) {
			losses++
		} else {
			draws++
		}

		matchDetails.push({
			date: match.match_date,
			homeTeam: match.home_team,
			awayTeam: match.away_team,
			homeGoals: match.home_goals,
			awayGoals: match.away_goals,
			result: goalsScored > goalsConceded ? 'W' : goalsScored < goalsConceded ? 'L' : 'D',
			isHome: isHome,
			standing_home: match.standing_home,
			standing_away: match.standing_away,
		})
	})

	return {
		wins,
		losses,
		draws,
		matchCount,
		winPercent: matchCount > 0 ? parseFloat(((wins / matchCount) * 100).toFixed(1)) : 0,
		lossPercent: matchCount > 0 ? parseFloat(((losses / matchCount) * 100).toFixed(1)) : 0,
		drawPercent: matchCount > 0 ? parseFloat(((draws / matchCount) * 100).toFixed(1)) : 0,
		matches: matchDetails,
	}
}

/**
 * Calculate home win statistics (only home matches)
 * @param {Array} matches - Team's historical matches
 * @param {string} teamName - Team name
 * @returns {Object} Home win statistics
 */
function calculateHomeWinStats(matches, teamName) {
	let homeWins = 0
	let homeDraws = 0
	let homeLosses = 0
	let homeMatchCount = 0
	const matchDetails = []

	matches.forEach(match => {
		const isHome = match.home_team === teamName
		
		// Only count home matches
		if (isHome) {
			const goalsScored = match.home_goals
			const goalsConceded = match.away_goals

			homeMatchCount++

			// Determine result
			if (goalsScored > goalsConceded) {
				homeWins++
			} else if (goalsScored < goalsConceded) {
				homeLosses++
			} else {
				homeDraws++
			}

			matchDetails.push({
				date: match.match_date,
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeGoals: match.home_goals,
				awayGoals: match.away_goals,
				result: goalsScored > goalsConceded ? 'W' : goalsScored < goalsConceded ? 'L' : 'D',
				isHome: true,
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			})
		}
	})

	return {
		homeWins,
		homeDraws,
		homeLosses,
		homeMatchCount,
		homeWinPercent: homeMatchCount > 0 ? parseFloat(((homeWins / homeMatchCount) * 100).toFixed(1)) : 0,
		homeDrawPercent: homeMatchCount > 0 ? parseFloat(((homeDraws / homeMatchCount) * 100).toFixed(1)) : 0,
		homeLossPercent: homeMatchCount > 0 ? parseFloat(((homeLosses / homeMatchCount) * 100).toFixed(1)) : 0,
		matches: matchDetails,
	}
}

/**
 * Calculate away win statistics (only away matches)
 * @param {Array} matches - Team's historical matches
 * @param {string} teamName - Team name
 * @returns {Object} Away win statistics
 */
function calculateAwayWinStats(matches, teamName) {
	let awayWins = 0
	let awayDraws = 0
	let awayLosses = 0
	let awayMatchCount = 0
	const matchDetails = []

	matches.forEach(match => {
		const isHome = match.home_team === teamName
		
		// Only count away matches
		if (!isHome) {
			const goalsScored = match.away_goals
			const goalsConceded = match.home_goals

			awayMatchCount++

			// Determine result
			if (goalsScored > goalsConceded) {
				awayWins++
			} else if (goalsScored < goalsConceded) {
				awayLosses++
			} else {
				awayDraws++
			}

			matchDetails.push({
				date: match.match_date,
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeGoals: match.home_goals,
				awayGoals: match.away_goals,
				result: goalsScored > goalsConceded ? 'W' : goalsScored < goalsConceded ? 'L' : 'D',
				isHome: false,
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			})
		}
	})

	return {
		awayWins,
		awayDraws,
		awayLosses,
		awayMatchCount,
		awayWinPercent: awayMatchCount > 0 ? parseFloat(((awayWins / awayMatchCount) * 100).toFixed(1)) : 0,
		awayDrawPercent: awayMatchCount > 0 ? parseFloat(((awayDraws / awayMatchCount) * 100).toFixed(1)) : 0,
		awayLossPercent: awayMatchCount > 0 ? parseFloat(((awayLosses / awayMatchCount) * 100).toFixed(1)) : 0,
		matches: matchDetails,
	}
}

/**
 * Calculate BTS (Both Teams to Score) statistics
 * @param {Array} matches - Team's historical matches
 * @param {string} teamName - Team name
 * @returns {Object} BTS statistics
 */
function calculateBTSStats(matches, teamName) {
	let btsCount = 0 // Matches where both teams scored
	let noBtsCount = 0 // Matches where at least one team didn't score
	let matchCount = 0
	const matchDetails = []

	matches.forEach(match => {
		const isHome = match.home_team === teamName
		const homeGoals = match.home_goals || 0
		const awayGoals = match.away_goals || 0
		
		// Check if both teams scored
		const isBTS = homeGoals > 0 && awayGoals > 0

		if (isBTS) {
			btsCount++
		} else {
			noBtsCount++
		}
		matchCount++

		matchDetails.push({
			date: match.match_date,
			homeTeam: match.home_team,
			awayTeam: match.away_team,
			homeGoals: homeGoals,
			awayGoals: awayGoals,
			isBTS: isBTS,
			isHome: isHome,
			standing_home: match.standing_home,
			standing_away: match.standing_away,
		})
	})

	return {
		btsCount,
		noBtsCount,
		matchCount,
		btsPercent: matchCount > 0 ? parseFloat(((btsCount / matchCount) * 100).toFixed(1)) : 0,
		matches: matchDetails,
	}
}

/**
 * Generic function to find and analyze matches based on various criteria
 * @param {Object} config - Configuration object
 * @returns {Promise<void>}
 */
async function findMatches(config) {
	const {
		searchMessage,
		calculateStats,
		calculateHomeStats, // Optional: separate function for home team
		calculateAwayStats, // Optional: separate function for away team
		processMatch,
		sortMatches,
		showModal,
		noMatchesMessage,
		minMatches = 5,
		validateTeamStats = null,
	} = config

	console.log('🔍 findMatches called with config:', {
		searchMessage,
		minMatches,
		hasValidateTeamStats: !!validateTeamStats,
	})

	const dates = validateDateRange()
	if (!dates) {
		console.log('❌ Date validation failed')
		return
	}

	const { dateFrom, dateTo } = dates
	console.log(`📅 Date range: ${dateFrom} to ${dateTo}`)
	showToast(searchMessage, 'info')

	try {
		// Fetch upcoming matches
		const url = `/api/database/matches?date_from=${dateFrom}&date_to=${dateTo}&is_finished=no&limit=10000`
		console.log(`🌐 Fetching upcoming matches: ${url}`)
		const upcomingResponse = await fetch(url)

		if (!upcomingResponse.ok) {
			const errorData = await upcomingResponse.json()
			console.error('API Error:', errorData)
			showToast(`Błąd serwera: ${errorData.error || 'Nieznany błąd'}`, 'error')
			return
		}

		const upcomingMatches = await upcomingResponse.json()

		if (!Array.isArray(upcomingMatches)) {
			console.error('Invalid response format:', upcomingMatches)
			showToast('Błąd: Nieprawidłowy format odpowiedzi z serwera', 'error')
			return
		}

		// Check for cancellation
		if (isCancelled()) {
			console.log('🚫 Search cancelled by user')
			showToast('Wyszukiwanie anulowane', 'warning')
			return
		}

		if (upcomingMatches.length === 0) {
			showToast('Nie znaleziono nadchodzących meczów w wybranym zakresie', 'warning')
			return
		}

		showToast(`Znaleziono ${upcomingMatches.length} nadchodzących meczów. Analizuję...`, 'info')

		// Cache for team histories to avoid duplicate fetches
		const historyCache = new Map()

		// Helper function to get or fetch team history
		const getTeamHistory = async (team, league) => {
			const cacheKey = `${team}|${league}`
			if (historyCache.has(cacheKey)) {
				return historyCache.get(cacheKey)
			}

			// Fetch finished matches
			const history = await fetch(
				`/api/database/matches?team=${encodeURIComponent(team)}&league=${encodeURIComponent(
					league
				)}&is_finished=yes&sort=date_desc${state.selectedMatchCount ? `&limit=${state.selectedMatchCount}` : ''}`
			).then(res => res.json())

			// Also fetch first future match with standings (from Nov 1, 2025 onwards) to fill gaps for old matches
			const futureWithStanding = await fetch(
				`/api/database/matches?team=${encodeURIComponent(team)}&league=${encodeURIComponent(
					league
				)}&date_from=2025-11-01&sort=date_asc&limit=1`
			).then(res => res.json())

			// Combine: finished matches + first future match with standing
			const combined = [...history, ...futureWithStanding]

			historyCache.set(cacheKey, combined)
			return combined
		}

		// Calculate statistics for each match
		const matchStats = []
		let processedCount = 0
		let skippedCount = 0

		console.log(`🔍 Analyzing ${upcomingMatches.length} upcoming matches...`)
		console.log(`📊 Using match count limit: ${state.selectedMatchCount || 'all'}`)

		for (const match of upcomingMatches) {
			// Check for cancellation
			if (isCancelled()) {
				console.log('🚫 Search cancelled by user')
				showToast('Wyszukiwanie anulowane', 'warning')
				return
			}

			const homeTeam = match.home_team
			const awayTeam = match.away_team
			const league = match.league

			console.log(`\n📌 Processing: ${homeTeam} vs ${awayTeam} (${league})`)

			// Fetch historical matches for both teams IN PARALLEL (with caching)
			const [homeHistory, awayHistory] = await Promise.all([
				getTeamHistory(homeTeam, league),
				getTeamHistory(awayTeam, league),
			])

			console.log(`  ├─ ${homeTeam}: ${homeHistory.length} historical matches`)
			console.log(`  └─ ${awayTeam}: ${awayHistory.length} historical matches`)

			// Calculate team statistics
			// Use separate functions if provided, otherwise use the same calculateStats for both
			const homeStatsFunc = calculateHomeStats || calculateStats
			const awayStatsFunc = calculateAwayStats || calculateStats
			const homeStats = homeStatsFunc(homeHistory, homeTeam)
			const awayStats = awayStatsFunc(awayHistory, awayTeam)

			console.log(`  ├─ ${homeTeam} stats: ${homeStats.matchCount} matches analyzed`)
			console.log(`  └─ ${awayTeam} stats: ${awayStats.matchCount} matches analyzed`)

			// Skip if either team has less than minimum matches
			if (homeStats.matchCount < minMatches || awayStats.matchCount < minMatches) {
				console.log(`  ❌ Skipped: Not enough matches (min: ${minMatches})`)
				skippedCount++
				continue
			}

			// Optional custom validation
			if (validateTeamStats && !validateTeamStats(homeStats, awayStats)) {
				console.log(`  ❌ Skipped: Custom validation failed`)
				skippedCount++
				continue
			}

			// Process match data
			const matchData = processMatch(match, homeStats, awayStats)
			matchStats.push(matchData)
			processedCount++
			console.log(`  ✅ Added to results`)
		}

		console.log(`\n📊 Analysis complete:`)
		console.log(`  ✅ Processed: ${processedCount} matches`)
		console.log(`  ❌ Skipped: ${skippedCount} matches`)
		console.log(`  📋 Total valid: ${matchStats.length} matches`)

		// Check if we have any valid matches
		if (matchStats.length === 0) {
			showToast(noMatchesMessage, 'warning')
			return
		}

		// Sort matches and take top 10
		matchStats.sort(sortMatches)
		const top10 = matchStats.slice(0, 10)

		// Show results in modal
		showModal(top10, dateFrom, dateTo)
	} catch (error) {
		console.error('Error finding matches:', error)
		showToast('Błąd podczas wyszukiwania', 'error')
	}
}

/**
 * Find matches with most goals
 */
export async function findMostGoals() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze...',
		calculateStats: calculateGoalStats,
		processMatch: (match, homeStats, awayStats) => {
			const totalGoals = homeStats.totalGoals + awayStats.totalGoals
			const totalMatches = homeStats.matchCount + awayStats.matchCount
			const averageGoals = totalMatches > 0 ? (totalGoals / totalMatches).toFixed(2) : 0

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				totalGoals,
				averageGoals: parseFloat(averageGoals),
				searchType: 'most-goals',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => b.averageGoals - a.averageGoals,
		showModal: showMostGoalsModal,
		noMatchesMessage:
			'Nie znaleziono meczów spełniających kryteria (obie drużyny muszą mieć min. 5 zakończonych meczów)',
		minMatches: 5,
	})
}

/**
 * Find matches with least goals
 */
export async function findLeastGoals() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze...',
		calculateStats: calculateGoalStats,
		processMatch: (match, homeStats, awayStats) => {
			const totalGoals = homeStats.totalGoals + awayStats.totalGoals
			const totalMatches = homeStats.matchCount + awayStats.matchCount
			const averageGoals = totalMatches > 0 ? (totalGoals / totalMatches).toFixed(2) : 0

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				totalGoals,
				averageGoals: parseFloat(averageGoals),
				searchType: 'least-goals',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => a.averageGoals - b.averageGoals, // ASCENDING for least goals
		showModal: showLeastGoalsModal,
		noMatchesMessage:
			'Nie znaleziono meczów spełniających kryteria (obie drużyny muszą mieć min. 5 zakończonych meczów)',
		minMatches: 5,
	})
}

/**
 * Find matches for handicap 1.5
 */
export async function findHandicap15() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze dla Handicap 1.5...',
		calculateStats: calculateHandicapStats,
		processMatch: (match, homeStats, awayStats) => {
			// Calculate percentages
			const homeWinBy2Plus = homeStats.matchCount > 0 ? (homeStats.winsBy2Plus / homeStats.matchCount) * 100 : 0
			const homeLoseBy2Plus = homeStats.matchCount > 0 ? (homeStats.lossesby2Plus / homeStats.matchCount) * 100 : 0
			const awayWinBy2Plus = awayStats.matchCount > 0 ? (awayStats.winsBy2Plus / awayStats.matchCount) * 100 : 0
			const awayLoseBy2Plus = awayStats.matchCount > 0 ? (awayStats.lossesby2Plus / awayStats.matchCount) * 100 : 0

			// Calculate handicap scores in both directions
			const homeHandicapScore = homeWinBy2Plus + awayLoseBy2Plus
			const awayHandicapScore = awayWinBy2Plus + homeLoseBy2Plus

			// Take the higher handicap score
			const handicapScore = Math.max(homeHandicapScore, awayHandicapScore)
			const handicapType = homeHandicapScore > awayHandicapScore ? 'home' : 'away'
			const strongTeam = handicapType === 'home' ? match.home_team : match.away_team
			const weakTeam = handicapType === 'home' ? match.away_team : match.home_team
			const strongTeamWins = handicapType === 'home' ? homeStats.winsBy2Plus : awayStats.winsBy2Plus
			const strongTeamWinsPct = handicapType === 'home' ? homeWinBy2Plus : awayWinBy2Plus
			const weakTeamLosses = handicapType === 'home' ? awayStats.lossesby2Plus : homeStats.lossesby2Plus
			const weakTeamLossesPct = handicapType === 'home' ? awayLoseBy2Plus : homeLoseBy2Plus

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				handicapScore: parseFloat(handicapScore.toFixed(1)),
				handicapType,
				strongTeam,
				weakTeam,
				strongTeamWins,
				strongTeamWinsPct: parseFloat(strongTeamWinsPct.toFixed(1)),
				weakTeamLosses,
				weakTeamLossesPct: parseFloat(weakTeamLossesPct.toFixed(1)),
			}
		},
		sortMatches: (a, b) => b.handicapScore - a.handicapScore,
		showModal: showHandicap15Modal,
		noMatchesMessage:
			'Nie znaleziono meczów spełniających kryteria (obie drużyny muszą mieć min. 5 zakończonych meczów)',
		minMatches: 5,
	})
}

/**
 * Find matches with most corners
 */
export async function findMostCorners() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z największą liczbą rożnych...',
		calculateStats: calculateCornerStats,
		processMatch: (match, homeStats, awayStats) => {
			// Calculate average corners
			const homeAvgCorners = homeStats.totalCorners / homeStats.cornersMatchCount
			const awayAvgCorners = awayStats.totalCorners / awayStats.cornersMatchCount
			const combinedAvgCorners = homeAvgCorners + awayAvgCorners

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				homeAvgCorners: parseFloat(homeAvgCorners.toFixed(2)),
				awayAvgCorners: parseFloat(awayAvgCorners.toFixed(2)),
				averageCorners: parseFloat(combinedAvgCorners.toFixed(2)),
				searchType: 'most-corners',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => b.averageCorners - a.averageCorners,
		showModal: showMostCornersModal,
		noMatchesMessage:
			'Nie znaleziono meczów z danymi o rzutach rożnych (obie drużyny muszą mieć min. 5 zakończonych meczów z dostępnymi statystykami)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => homeStats.cornersMatchCount >= 5 && awayStats.cornersMatchCount >= 5,
	})
}

/**
 * Find matches with least corners
 */
export async function findLeastCorners() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z najmniejszą liczbą rożnych...',
		calculateStats: calculateCornerStats,
		processMatch: (match, homeStats, awayStats) => {
			// Calculate average corners
			const homeAvgCorners = homeStats.totalCorners / homeStats.cornersMatchCount
			const awayAvgCorners = awayStats.totalCorners / awayStats.cornersMatchCount
			const combinedAvgCorners = homeAvgCorners + awayAvgCorners

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				homeAvgCorners: parseFloat(homeAvgCorners.toFixed(2)),
				awayAvgCorners: parseFloat(awayAvgCorners.toFixed(2)),
				averageCorners: parseFloat(combinedAvgCorners.toFixed(2)),
				searchType: 'least-corners',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => a.averageCorners - b.averageCorners, // ASCENDING for least corners
		showModal: showLeastCornersModal,
		noMatchesMessage:
			'Nie znaleziono meczów z danymi o rzutach rożnych (obie drużyny muszą mieć min. 5 zakończonych meczów z dostępnymi statystykami)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => homeStats.cornersMatchCount >= 5 && awayStats.cornersMatchCount >= 5,
	})
}

/**
 * Find matches with most BTS (Both Teams to Score)
 */
export async function findMostBTS() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z największym prawdopodobieństwem BTS...',
		calculateStats: calculateBTSStats,
		processMatch: (match, homeStats, awayStats) => {
			// Calculate combined BTS percentage (average of both teams)
			const combinedBTSPercent = (homeStats.btsPercent + awayStats.btsPercent) / 2

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				homeBTSPercent: parseFloat(homeStats.btsPercent.toFixed(1)),
				awayBTSPercent: parseFloat(awayStats.btsPercent.toFixed(1)),
				combinedBTSPercent: parseFloat(combinedBTSPercent.toFixed(1)),
				searchType: 'most-bts',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => b.combinedBTSPercent - a.combinedBTSPercent,
		showModal: showMostBTSModal,
		noMatchesMessage:
			'Nie znaleziono meczów spełniających kryteria (obie drużyny muszą mieć min. 5 zakończonych meczów)',
		minMatches: 5,
	})
}

/**
 * Find matches with least BTS (No Both Teams to Score)
 */
export async function findNoBTS() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z najmniejszym prawdopodobieństwem BTS...',
		calculateStats: calculateBTSStats,
		processMatch: (match, homeStats, awayStats) => {
			// Calculate combined no-BTS percentage (average of both teams)
			const homeNoBTSPercent = (homeStats.noBtsCount / homeStats.matchCount) * 100
			const awayNoBTSPercent = (awayStats.noBtsCount / awayStats.matchCount) * 100
			const combinedNoBTSPercent = (homeNoBTSPercent + awayNoBTSPercent) / 2

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				homeNoBTSPercent: parseFloat(homeNoBTSPercent.toFixed(1)),
				awayNoBTSPercent: parseFloat(awayNoBTSPercent.toFixed(1)),
				combinedNoBTSPercent: parseFloat(combinedNoBTSPercent.toFixed(1)),
				searchType: 'no-bts',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => b.combinedNoBTSPercent - a.combinedNoBTSPercent,
		showModal: showNoBTSModal,
		noMatchesMessage:
			'Nie znaleziono meczów spełniających kryteria (obie drużyny muszą mieć min. 5 zakończonych meczów)',
		minMatches: 5,
	})
}

/**
 * Find matches where home team has highest home win percentage
 */
export async function findHomeWins() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z najczęstszymi wygranymi gospodarzy...',
		calculateHomeStats: calculateHomeWinStats, // Home team: only home matches
		calculateAwayStats: calculateWinLossStats, // Away team: all matches
		processMatch: (match, homeStats, awayStats) => {
			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				homeWinPercent: parseFloat(homeStats.homeWinPercent.toFixed(1)),
				searchType: 'home-wins',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => b.homeWinPercent - a.homeWinPercent,
		showModal: showHomeWinsModal,
		noMatchesMessage:
			'Nie znaleziono meczów spełniających kryteria (gospodarz musi mieć min. 5 zakończonych meczów u siebie)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => homeStats.homeMatchCount >= 5,
	})
}

/**
 * Find matches where away team has highest away win percentage
 */
export async function findAwayWins() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z najczęstszymi wygranymi gości...',
		calculateHomeStats: calculateWinLossStats, // Home team: all matches
		calculateAwayStats: calculateAwayWinStats, // Away team: only away matches
		processMatch: (match, homeStats, awayStats) => {
			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				awayWinPercent: parseFloat(awayStats.awayWinPercent.toFixed(1)),
				searchType: 'away-wins',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => b.awayWinPercent - a.awayWinPercent,
		showModal: showAwayWinsModal,
		noMatchesMessage:
			'Nie znaleziono meczów spełniających kryteria (gość musi mieć min. 5 zakończonych meczów na wyjeździe)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => awayStats.awayMatchCount >= 5,
	})
}

/**
 * Find matches where home team has highest home loss percentage
 */
export async function findHomeLosses() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z najczęstszymi porażkami gospodarzy...',
		calculateHomeStats: calculateHomeWinStats, // Home team: only home matches
		calculateAwayStats: calculateWinLossStats, // Away team: all matches
		processMatch: (match, homeStats, awayStats) => {
			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				homeLossPercent: parseFloat(homeStats.homeLossPercent.toFixed(1)),
				searchType: 'home-losses',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => b.homeLossPercent - a.homeLossPercent,
		showModal: showHomeLossesModal,
		noMatchesMessage:
			'Nie znaleziono meczów spełniających kryteria (gospodarz musi mieć min. 5 zakończonych meczów u siebie)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => homeStats.homeMatchCount >= 5,
	})
}

/**
 * Find matches where away team has highest away loss percentage
 */
export async function findAwayLosses() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z najczęstszymi porażkami gości...',
		calculateHomeStats: calculateWinLossStats, // Home team: all matches
		calculateAwayStats: calculateAwayWinStats, // Away team: only away matches
		processMatch: (match, homeStats, awayStats) => {
			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				awayLossPercent: parseFloat(awayStats.awayLossPercent.toFixed(1)),
				searchType: 'away-losses',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => b.awayLossPercent - a.awayLossPercent,
		showModal: showAwayLossesModal,
		noMatchesMessage:
			'Nie znaleziono meczów spełniających kryteria (gość musi mieć min. 5 zakończonych meczów na wyjeździe)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => awayStats.awayMatchCount >= 5,
	})
}

/**
 * Find matches where home team wins often at home AND away team loses often away
 */
export async function findHomeAdvantage() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z przewagą gospodarzy...',
		calculateHomeStats: calculateHomeWinStats, // Home team: only home matches
		calculateAwayStats: calculateAwayWinStats, // Away team: only away matches
		processMatch: (match, homeStats, awayStats) => {
			// Combine home win % and away loss %
			const homeWinPercent = homeStats.homeWinPercent || 0
			const awayLossPercent = awayStats.awayLossPercent || 0
			const advantageScore = (homeWinPercent + awayLossPercent) / 2

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				homeWinPercent: parseFloat(homeWinPercent.toFixed(1)),
				awayLossPercent: parseFloat(awayLossPercent.toFixed(1)),
				advantageScore: parseFloat(advantageScore.toFixed(1)),
				searchType: 'home-advantage',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => b.advantageScore - a.advantageScore,
		showModal: showHomeAdvantageModal,
		noMatchesMessage:
			'Nie znaleziono meczów spełniających kryteria (obie drużyny muszą mieć min. 5 zakończonych meczów)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => 
			(homeStats.homeMatchCount >= 5) && (awayStats.awayMatchCount >= 5),
	})
}

/**
 * Find matches where away team wins often away AND home team loses often at home
 */
export async function findAwayAdvantage() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z przewagą gości...',
		calculateHomeStats: calculateHomeWinStats, // Home team: only home matches
		calculateAwayStats: calculateAwayWinStats, // Away team: only away matches
		processMatch: (match, homeStats, awayStats) => {
			// Combine away win % and home loss %
			const awayWinPercent = awayStats.awayWinPercent || 0
			const homeLossPercent = homeStats.homeLossPercent || 0
			const advantageScore = (awayWinPercent + homeLossPercent) / 2

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				awayWinPercent: parseFloat(awayWinPercent.toFixed(1)),
				homeLossPercent: parseFloat(homeLossPercent.toFixed(1)),
				advantageScore: parseFloat(advantageScore.toFixed(1)),
				searchType: 'away-advantage',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => b.advantageScore - a.advantageScore,
		showModal: showAwayAdvantageModal,
		noMatchesMessage:
			'Nie znaleziono meczów spełniających kryteria (obie drużyny muszą mieć min. 5 zakończonych meczów)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => 
			(homeStats.homeMatchCount >= 5) && (awayStats.awayMatchCount >= 5),
	})
}

/**
 * Find matches with most offsides (single team)
 */
export async function findMostOffsides() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z największą liczbą spalonych...',
		calculateStats: calculateOffsidesStats,
		processMatch: (match, homeStats, awayStats) => {
			// Calculate average offsides
			const homeAvgOffsides = homeStats.totalOffsides / homeStats.offsidesMatchCount
			const awayAvgOffsides = awayStats.totalOffsides / awayStats.offsidesMatchCount
			const combinedAvgOffsides = homeAvgOffsides + awayAvgOffsides

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				homeAvgOffsides: parseFloat(homeAvgOffsides.toFixed(2)),
				awayAvgOffsides: parseFloat(awayAvgOffsides.toFixed(2)),
				averageOffsides: parseFloat(combinedAvgOffsides.toFixed(2)),
				searchType: 'most-offsides',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => b.averageOffsides - a.averageOffsides,
		showModal: showMostOffsidesModal,
		noMatchesMessage:
			'Nie znaleziono meczów z danymi o spalonych (obie drużyny muszą mieć min. 5 zakończonych meczów z dostępnymi statystykami)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => homeStats.offsidesMatchCount >= 5 && awayStats.offsidesMatchCount >= 5,
	})
}

/**
 * Find matches with least offsides (single team)
 */
export async function findLeastOffsides() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z najmniejszą liczbą spalonych...',
		calculateStats: calculateOffsidesStats,
		processMatch: (match, homeStats, awayStats) => {
			// Calculate average offsides
			const homeAvgOffsides = homeStats.totalOffsides / homeStats.offsidesMatchCount
			const awayAvgOffsides = awayStats.totalOffsides / awayStats.offsidesMatchCount
			const combinedAvgOffsides = homeAvgOffsides + awayAvgOffsides

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				homeAvgOffsides: parseFloat(homeAvgOffsides.toFixed(2)),
				awayAvgOffsides: parseFloat(awayAvgOffsides.toFixed(2)),
				averageOffsides: parseFloat(combinedAvgOffsides.toFixed(2)),
				searchType: 'least-offsides',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => a.averageOffsides - b.averageOffsides, // ASCENDING for least offsides
		showModal: showLeastOffsidesModal,
		noMatchesMessage:
			'Nie znaleziono meczów z danymi o spalonych (obie drużyny muszą mieć min. 5 zakończonych meczów z dostępnymi statystykami)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => homeStats.offsidesMatchCount >= 5 && awayStats.offsidesMatchCount >= 5,
	})
}

/**
 * Find matches with goal advantage
 */
export async function findGoalAdvantage() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z przewagą...',
		calculateStats: calculateGoalStats,
		processMatch: (match, homeStats, awayStats) => {
			// Calculate averages for both teams
			const homeScoredAvg = homeStats.matchCount > 0 ? homeStats.totalGoalsScored / homeStats.matchCount : 0
			const homeConcededAvg = homeStats.matchCount > 0 ? homeStats.totalGoalsConceded / homeStats.matchCount : 0
			const awayScoredAvg = awayStats.matchCount > 0 ? awayStats.totalGoalsScored / awayStats.matchCount : 0
			const awayConcededAvg = awayStats.matchCount > 0 ? awayStats.totalGoalsConceded / awayStats.matchCount : 0

			// Calculate advantage in both directions
			const homeAdvantageScore = homeScoredAvg + awayConcededAvg
			const awayAdvantageScore = awayScoredAvg + homeConcededAvg

			// Take the higher advantage
			const advantageScore = Math.max(homeAdvantageScore, awayAdvantageScore)
			const advantageType = homeAdvantageScore > awayAdvantageScore ? 'home' : 'away'
			const strongTeam = advantageType === 'home' ? match.home_team : match.away_team
			const weakTeam = advantageType === 'home' ? match.away_team : match.home_team
			const strongTeamScored = advantageType === 'home' ? homeScoredAvg : awayScoredAvg
			const weakTeamConceded = advantageType === 'home' ? awayConcededAvg : homeConcededAvg

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				advantageScore: parseFloat(advantageScore.toFixed(2)),
				advantageType,
				strongTeam,
				weakTeam,
				strongTeamScored: parseFloat(strongTeamScored.toFixed(2)),
				weakTeamConceded: parseFloat(weakTeamConceded.toFixed(2)),
			}
		},
		sortMatches: (a, b) => b.advantageScore - a.advantageScore,
		showModal: showGoalAdvantageModal,
		noMatchesMessage:
			'Nie znaleziono meczów spełniających kryteria (obie drużyny muszą mieć min. 5 zakończonych meczów)',
		minMatches: 5,
	})
}

/**
 * Find matches where one team has highest win percentage and other has highest loss percentage
 */
export async function findWinnerVsLoser() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z kontrastem form (wygrywający vs przegrywający)...',
		calculateStats: calculateWinLossStats,
		processMatch: (match, homeStats, awayStats) => {
			// Calculate form contrast score - the bigger the difference, the better
			// Option 1: Home team is strong (high win%), Away team is weak (high loss%)
			const homeWinAwayLoss = homeStats.winPercent + awayStats.lossPercent

			// Option 2: Away team is strong (high win%), Home team is weak (high loss%)
			const awayWinHomeLoss = awayStats.winPercent + homeStats.lossPercent

			// Use the higher contrast score
			const contrastScore = Math.max(homeWinAwayLoss, awayWinHomeLoss)

			// Determine which team is strong and which is weak
			let strongTeam, weakTeam, strongTeamWinPercent, weakTeamLossPercent
			if (homeWinAwayLoss > awayWinHomeLoss) {
				strongTeam = match.home_team
				weakTeam = match.away_team
				strongTeamWinPercent = homeStats.winPercent
				weakTeamLossPercent = awayStats.lossPercent
			} else {
				strongTeam = match.away_team
				weakTeam = match.home_team
				strongTeamWinPercent = awayStats.winPercent
				weakTeamLossPercent = homeStats.lossPercent
			}

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				contrastScore: parseFloat(contrastScore.toFixed(1)),
				strongTeam,
				weakTeam,
				strongTeamWinPercent: parseFloat(strongTeamWinPercent.toFixed(1)),
				weakTeamLossPercent: parseFloat(weakTeamLossPercent.toFixed(1)),
				searchType: 'winner-vs-loser',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => b.contrastScore - a.contrastScore,
		showModal: showWinnerVsLoserModal,
		noMatchesMessage:
			'Nie znaleziono meczów spełniających kryteria (obie drużyny muszą mieć min. 5 zakończonych meczów)',
		minMatches: 5,
	})
}

/**
 * Find matches with most total corners (sum of both teams)
 */
export async function findMostTotalCorners() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z największą sumą rożnych...',
		calculateStats: calculateTotalMatchCornersStats,
		processMatch: (match, homeStats, awayStats) => {
			const averageTotalCorners = parseFloat(((homeStats.avgMatchCorners + awayStats.avgMatchCorners) / 2).toFixed(2))

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				averageTotalCorners,
				searchType: 'total-corners',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => b.averageTotalCorners - a.averageTotalCorners,
		showModal: showMostTotalCornersModal,
		noMatchesMessage:
			'Nie znaleziono meczów z danymi o rzutach rożnych (obie drużyny muszą mieć min. 5 zakończonych meczów z dostępnymi statystykami)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => homeStats.cornersMatchCount >= 5 && awayStats.cornersMatchCount >= 5,
	})
}

/**
 * Find matches with least total corners (sum of both teams)
 */
export async function findLeastTotalCorners() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z najmniejszą sumą rożnych...',
		calculateStats: calculateTotalMatchCornersStats,
		processMatch: (match, homeStats, awayStats) => {
			const averageTotalCorners = parseFloat(((homeStats.avgMatchCorners + awayStats.avgMatchCorners) / 2).toFixed(2))

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				averageTotalCorners,
				searchType: 'total-corners-least',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => a.averageTotalCorners - b.averageTotalCorners,
		showModal: showLeastTotalCornersModal,
		noMatchesMessage:
			'Nie znaleziono meczów z danymi o rzutach rożnych (obie drużyny muszą mieć min. 5 zakończonych meczów z dostępnymi statystykami)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => homeStats.cornersMatchCount >= 5 && awayStats.cornersMatchCount >= 5,
	})
}

/**
 * Find matches with corner advantage (one team executes many corners, other concedes many)
 */
export async function findCornerAdvantage() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z przewagą rożnych...',
		calculateStats: calculateCornerAdvantageStats,
		processMatch: (match, homeStats, awayStats) => {
			// Calculate advantage scores:
			// Option 1: Home executes many + Away concedes many
			const homeAdvantageScore = homeStats.avgCornersFor + awayStats.avgCornersAgainst

			// Option 2: Away executes many + Home concedes many
			const awayAdvantageScore = awayStats.avgCornersFor + homeStats.avgCornersAgainst

			// Use the higher advantage
			const advantageScore = Math.max(homeAdvantageScore, awayAdvantageScore)

			// Determine which team has advantage
			let strongTeam, weakTeam, strongTeamCornersFor, weakTeamCornersAgainst
			if (homeAdvantageScore > awayAdvantageScore) {
				strongTeam = match.home_team
				weakTeam = match.away_team
				strongTeamCornersFor = homeStats.avgCornersFor
				weakTeamCornersAgainst = awayStats.avgCornersAgainst
			} else {
				strongTeam = match.away_team
				weakTeam = match.home_team
				strongTeamCornersFor = awayStats.avgCornersFor
				weakTeamCornersAgainst = homeStats.avgCornersAgainst
			}

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				advantageScore: parseFloat(advantageScore.toFixed(2)),
				strongTeam,
				weakTeam,
				strongTeamCornersFor: parseFloat(strongTeamCornersFor.toFixed(2)),
				weakTeamCornersAgainst: parseFloat(weakTeamCornersAgainst.toFixed(2)),
				searchType: 'corner-advantage',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => b.advantageScore - a.advantageScore,
		showModal: showCornerAdvantageModal,
		noMatchesMessage:
			'Nie znaleziono meczów z danymi o rzutach rożnych (obie drużyny muszą mieć min. 5 zakończonych meczów z dostępnymi statystykami)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => homeStats.cornersMatchCount >= 5 && awayStats.cornersMatchCount >= 5,
	})
}

/**
 * Find matches with most total offsides (sum of both teams)
 */
export async function findMostTotalOffsides() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z największą sumą spalonych...',
		calculateStats: calculateTotalMatchOffsidesStats,
		processMatch: (match, homeStats, awayStats) => {
			const averageTotalOffsides = parseFloat(
				((homeStats.avgMatchOffsides + awayStats.avgMatchOffsides) / 2).toFixed(2)
			)

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				averageTotalOffsides,
				searchType: 'total-offsides',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => b.averageTotalOffsides - a.averageTotalOffsides,
		showModal: showMostTotalOffsidesModal,
		noMatchesMessage:
			'Nie znaleziono meczów z danymi o spalonych (obie drużyny muszą mieć min. 5 zakończonych meczów z dostępnymi statystykami)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => homeStats.offsidesMatchCount >= 5 && awayStats.offsidesMatchCount >= 5,
	})
}

/**
 * Find matches with least total offsides (sum of both teams)
 */
export async function findLeastTotalOffsides() {
	await findMatches({
		searchMessage: 'Wyszukuję mecze z najmniejszą sumą spalonych...',
		calculateStats: calculateTotalMatchOffsidesStats,
		processMatch: (match, homeStats, awayStats) => {
			const averageTotalOffsides = parseFloat(
				((homeStats.avgMatchOffsides + awayStats.avgMatchOffsides) / 2).toFixed(2)
			)

			return {
				date: match.match_date,
				league: match.league,
				country: match.country || '',
				homeTeam: match.home_team,
				awayTeam: match.away_team,
				homeStats,
				awayStats,
				averageTotalOffsides,
				searchType: 'total-offsides-least',
				standing_home: match.standing_home,
				standing_away: match.standing_away,
			}
		},
		sortMatches: (a, b) => a.averageTotalOffsides - b.averageTotalOffsides,
		showModal: showLeastTotalOffsidesModal,
		noMatchesMessage:
			'Nie znaleziono meczów z danymi o spalonych (obie drużyny muszą mieć min. 5 zakończonych meczów z dostępnymi statystykami)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => homeStats.offsidesMatchCount >= 5 && awayStats.offsidesMatchCount >= 5,
	})
}

// ==========================================
// MODAL DISPLAY FUNCTIONS
// ==========================================

// Store modal data globally
let currentModalResults = null
let currentModalType = null

// Store full modal data for each modal by ID
const modalDataStore = new Map()

// Getters for modal data
export function getCurrentModalData() {
	return {
		results: currentModalResults,
		modalType: currentModalType,
	}
}

export function getModalData(modalId) {
	return modalDataStore.get(modalId)
}

export function storeModalData(modalId, data) {
	modalDataStore.set(modalId, data)
}

// Map of modalType to show function for restoration
export const modalTypeToShowFunction = {
	'most-goals': (data) => showMostGoalsModal(data.results, data.dateFrom, data.dateTo),
	'least-goals': (data) => showLeastGoalsModal(data.results, data.dateFrom, data.dateTo),
	'most-corners': (data) => showMostCornersModal(data.results, data.dateFrom, data.dateTo),
	'least-corners': (data) => showLeastCornersModal(data.results, data.dateFrom, data.dateTo),
	'handicap-15': (data) => showHandicap15Modal(data.results, data.dateFrom, data.dateTo),
	'goal-advantage': (data) => showGoalAdvantageModal(data.results, data.dateFrom, data.dateTo),
	'winner-vs-loser': (data) => showWinnerVsLoserModal(data.results, data.dateFrom, data.dateTo),
	'most-total-corners': (data) => showMostTotalCornersModal(data.results, data.dateFrom, data.dateTo),
	'least-total-corners': (data) => showLeastTotalCornersModal(data.results, data.dateFrom, data.dateTo),
	'corner-advantage': (data) => showCornerAdvantageModal(data.results, data.dateFrom, data.dateTo),
	'most-total-offsides': (data) => showMostTotalOffsidesModal(data.results, data.dateFrom, data.dateTo),
	'least-total-offsides': (data) => showLeastTotalOffsidesModal(data.results, data.dateFrom, data.dateTo),
	'most-offsides': (data) => showMostOffsidesModal(data.results, data.dateFrom, data.dateTo),
	'least-offsides': (data) => showLeastOffsidesModal(data.results, data.dateFrom, data.dateTo),
	'most-bts': (data) => showMostBTSModal(data.results, data.dateFrom, data.dateTo),
	'no-bts': (data) => showNoBTSModal(data.results, data.dateFrom, data.dateTo),
	'home-wins': (data) => showHomeWinsModal(data.results, data.dateFrom, data.dateTo),
	'away-wins': (data) => showAwayWinsModal(data.results, data.dateFrom, data.dateTo),
	'home-losses': (data) => showHomeLossesModal(data.results, data.dateFrom, data.dateTo),
	'away-losses': (data) => showAwayLossesModal(data.results, data.dateFrom, data.dateTo),
	'home-advantage': (data) => showHomeAdvantageModal(data.results, data.dateFrom, data.dateTo),
	'away-advantage': (data) => showAwayAdvantageModal(data.results, data.dateFrom, data.dateTo),
}

// Export show functions for modal restoration
export {
	showMostGoalsModal,
	showLeastGoalsModal,
	showMostCornersModal,
	showLeastCornersModal,
	showHandicap15Modal,
	showGoalAdvantageModal,
	showWinnerVsLoserModal,
	showMostTotalCornersModal,
	showLeastTotalCornersModal,
	showCornerAdvantageModal,
	showMostTotalOffsidesModal,
	showLeastTotalOffsidesModal,
	showMostOffsidesModal,
	showLeastOffsidesModal,
	showMostBTSModal,
	showNoBTSModal,
	showHomeWinsModal,
	showAwayWinsModal,
	showHomeLossesModal,
	showAwayLossesModal,
	showHomeAdvantageModal,
	showAwayAdvantageModal,
}

// Helper function to get team standing from stats (uses most recent match)
// Helper function to get team standing from stats
// Returns an object with standing and isApproximate flag
function getTeamStanding(teamStats, teamName, matchDate, currentMatchStanding = null) {
	// If current match has standing, use it (exact match)
	if (currentMatchStanding !== null && currentMatchStanding !== undefined) {
		return { standing: currentMatchStanding, isApproximate: false }
	}
	
	if (!teamStats || !teamStats.matches || teamStats.matches.length === 0) {
		return null
	}
	
	const targetDate = new Date(matchDate)
	const standingCutoffDate = new Date('2025-11-01') // Standings start from this date
	
	// Sort matches by date (ascending)
	const sortedMatches = [...teamStats.matches].sort((a, b) => {
		return new Date(a.date) - new Date(b.date)
	})
	
	// Find exact match for this date or the closest future match with standing
	let exactMatch = null
	let closestFutureMatch = null
	
	for (const match of sortedMatches) {
		const matchDateObj = new Date(match.date)
		const standing = match.homeTeam === teamName ? match.standing_home : match.standing_away
		
		if (!standing) continue // Skip matches without standing
		
		// Check if this is exact date match
		if (matchDateObj.toDateString() === targetDate.toDateString()) {
			exactMatch = { standing, isApproximate: false }
			break
		}
		
		// If match is in the future (or after cutoff date for old matches), save as closest
		if (matchDateObj > targetDate || (targetDate < standingCutoffDate && matchDateObj >= standingCutoffDate)) {
			if (!closestFutureMatch) {
				closestFutureMatch = { standing, isApproximate: true }
			}
		}
	}
	
	return exactMatch || closestFutureMatch || null
}

// Helper function to format team name with standing position
export function formatTeamWithStanding(teamName, standing, matchDate) {
	if (!standing) {
		return teamName
	}
	
	// Check if standing is approximate (from future match)
	const isApproximate = standing.isApproximate || false
	const standingValue = standing.standing || standing
	
	// Gray out if approximate OR before November 2025
	const cutoffDate = new Date('2025-11-01')
	const date = new Date(matchDate)
	const isBeforeCutoff = date < cutoffDate
	
	const standingColor = (isApproximate || isBeforeCutoff) ? '#999' : '#000'
	return `${teamName} <span style="color: ${standingColor};">(${standingValue})</span>`
}

// Helper function to generate "Add to Watched" button
function generateAddButton(result, searchType) {
	const resultData = JSON.stringify(result).replace(/"/g, '&quot;').replace(/'/g, "\\'")
	return `<button class="btn-small" onclick='window.addToWatchedMatches(JSON.parse("${resultData}"), "${searchType}")'>⭐ Dodaj</button>`
}

// Generic function to create TOP 10 modal structure
export function createTop10Modal(config) {
	const {
		results,
		dateFrom,
		dateTo,
		modalType,
		title,
		icon,
		description,
		headerGradient = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
		descriptionGradient = 'linear-gradient(135deg, #fef3c7 0%, #fcd34d 100%)',
		descriptionBorder = '#f59e0b',
		descriptionTextColor = '#78350f',
		maxWidth = '1200px',
		tableHeaders,
		renderTableRow,
		matchCountField = 'matchCount', // default for goals, can be 'cornersMatchCount' for corners
	} = config

	if (results.length === 0) {
		showToast('Brak wyników do wyświetlenia', 'warning')
		return
	}

	// Store results for minimize/restore
	currentModalResults = results
	currentModalType = modalType

	// Generate unique modal ID
	const modalId = `${modalType}-${Date.now()}`

	// Store full modal configuration for this modal (without functions)
	modalDataStore.set(modalId, {
		results,
		dateFrom,
		dateTo,
		modalType,
		title,
		// Don't store renderTableRow or matchCountField - they will be recreated by show function
	})

	// Calculate total analyzed matches
	const totalMatchesAnalyzed = results.reduce((sum, r) => {
		const homeCount = r.homeStats[matchCountField] || r.homeStats.matchCount || 0
		const awayCount = r.awayStats[matchCountField] || r.awayStats.matchCount || 0
		return sum + homeCount + awayCount
	}, 0)

	const formattedDateFrom = new Date(dateFrom).toLocaleDateString('pl-PL')
	const formattedDateTo = new Date(dateTo).toLocaleDateString('pl-PL')

	let modalHTML = `
        <div class="modal-backdrop" onclick="window.minimizeModal()" style="z-index: 9999;"></div>
        <div class="modal-dialog" style="max-width: ${maxWidth}; z-index: 10000;">
            <div class="modal-header" style="background: ${headerGradient};">
                <div>
                    <h2>${icon} ${title}</h2>
                    <div style="font-size: 13px; opacity: 0.9; margin-top: 5px;">
                        📅 ${formattedDateFrom} - ${formattedDateTo} | 📊 Analizowano ${totalMatchesAnalyzed} meczów
                    </div>
                </div>
                <div style="display: flex; gap: 10px;">
                    <button class="modal-minimize" onclick="window.minimizeModal()" title="Minimalizuj">−</button>
                    <button class="modal-close" onclick="window.closeModal()">×</button>
                </div>
            </div>
            <div class="modal-body">
                <div style="background: ${descriptionGradient}; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid ${descriptionBorder};">
                    <p style="margin: 0; color: ${descriptionTextColor}; font-size: 14px; line-height: 1.6;">
                        <strong>ℹ️ O czym jest ten modal:</strong><br>
                        ${description}
                    </p>
                </div>
                <table class="results-table">
                    <thead>
                        <tr>
                            ${tableHeaders}
                        </tr>
                    </thead>
                    <tbody>
    `

	results.forEach((result, index) => {
		modalHTML += renderTableRow(result, index)
	})

	modalHTML += `
                    </tbody>
                </table>
            </div>
        </div>
    `

	// If there's an existing modal, minimize it instead of removing it
	const existingModal = document.getElementById('bet-finder-modal')
	if (existingModal) {
		// Call the minimize function from app.js
		if (window.minimizeModal) {
			window.minimizeModal()
		} else {
			existingModal.remove() // Fallback if minimizeModal not available
		}
	}

	// Create and show modal
	const modalContainer = document.createElement('div')
	modalContainer.id = 'bet-finder-modal'
	modalContainer.dataset.modalId = modalId // Store modalId on the element
	modalContainer.innerHTML = modalHTML
	document.body.appendChild(modalContainer)
}

function showMostGoalsModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'most-goals',
		title: 'TOP 10 - Norf to gej',
		icon: '⚽',
		description:
			'Znajduje mecze gdzie obie drużyny mają najwyższą średnią bramek w ostatnich meczach. Im wyższa łączna średnia, tym większe prawdopodobieństwo bramkowego spotkania.',
		headerGradient: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
		descriptionGradient: 'linear-gradient(135deg, #fef3c7 0%, #fcd34d 100%)',
		descriptionBorder: '#f59e0b',
		descriptionTextColor: '#78350f',
		maxWidth: '1200px',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Statystyki gospodarzy</th>
            <th>Goście</th>
            <th>Statystyki gości</th>
            <th>Łączna średnia</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.totalGoalsScored}:${result.homeStats.totalGoalsConceded} (śr. ${result.homeStats.avgGoals})`
			const awayStatsText = `${result.awayStats.totalGoalsScored}:${result.awayStats.totalGoalsConceded} (śr. ${result.awayStats.avgGoals})`
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')
			
			// Get standings from current match or team history
			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)

return `
                <tr>
                    <td style="font-weight: 700; color: #667eea;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${formatTeamWithStanding(result.homeTeam, homeStanding, result.date)}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${formatTeamWithStanding(result.awayTeam, awayStanding, result.date)}
                        </a>
                    </td>
                    <td>${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #f5576c; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.averageGoals}
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Najwięcej bramek")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showLeastGoalsModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'least-goals',
		title: 'TOP 10 - Najmniej bramek',
		icon: '🔒',
		description: 'Znajduje mecze gdzie obie drużyny mają najniższą średnią bramek. Idealny typ zakładu: Under 2.5.',
		headerGradient: 'linear-gradient(135deg, #3b82f6 0%, #1e40af 100%)',
		descriptionGradient: 'linear-gradient(135deg, #dbeafe 0%, #93c5fd 100%)',
		descriptionBorder: '#3b82f6',
		descriptionTextColor: '#1e3a8a',
		maxWidth: '1200px',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Statystyki gospodarzy</th>
            <th>Goście</th>
            <th>Statystyki gości</th>
            <th>Łączna średnia</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.totalGoalsScored}:${result.homeStats.totalGoalsConceded} (śr. ${result.homeStats.avgGoals})`
			const awayStatsText = `${result.awayStats.totalGoalsScored}:${result.awayStats.totalGoalsConceded} (śr. ${result.awayStats.avgGoals})`
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')
			
			// Get standings from current match or team history
			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)

return `
                <tr>
                    <td style="font-weight: 700; color: #3b82f6;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${formatTeamWithStanding(result.homeTeam, homeStanding, result.date)}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${formatTeamWithStanding(result.awayTeam, awayStanding, result.date)}
                        </a>
                    </td>
                    <td>${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #3b82f6; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.averageGoals}
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Najmniej bramek")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showHandicap15Modal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'handicap-15',
		title: 'TOP 10 - Handicap 1.5',
		icon: '📈',
		description:
			'Znajduje mecze gdzie jedna drużyna wygrywa znacznie częściej (różnica > 1.5 bramki). Idealny typ zakładu: Handicap azjatycki.',
		headerGradient: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
		descriptionGradient: 'linear-gradient(135deg, #d1fae5 0%, #6ee7b7 100%)',
		descriptionBorder: '#10b981',
		descriptionTextColor: '#064e3b',
		maxWidth: '1400px',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Wygrane/Przegrane 2+</th>
            <th>Goście</th>
            <th>Wygrane/Przegrane 2+</th>
            <th>Wynik handicap</th>
            <th>Silniejszy</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.winsBy2Plus}W / ${result.homeStats.lossesby2Plus}L (${result.homeStats.matchCount} meczów)`
			const awayStatsText = `${result.awayStats.winsBy2Plus}W / ${result.awayStats.lossesby2Plus}L (${result.awayStats.matchCount} meczów)`
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')
			
			// Get standings from current match or team history
			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)

// Highlight strong team
			const homeTeamStyle = result.strongTeam === result.homeTeam 
				? 'color: #10b981; font-weight: 700;' 
				: 'color: #ef4444; font-weight: 600;'
			const awayTeamStyle = result.strongTeam === result.awayTeam 
				? 'color: #10b981; font-weight: 700;' 
				: 'color: #ef4444; font-weight: 600;'

			return `
                <tr>
                    <td style="font-weight: 700; color: #10b981;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="${homeTeamStyle}">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${formatTeamWithStanding(result.homeTeam, homeStanding, result.date)}
                        </a>
                    </td>
                    <td style="font-size: 13px;">${homeStatsText}</td>
                    <td style="${awayTeamStyle}">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${formatTeamWithStanding(result.awayTeam, awayStanding, result.date)}
                        </a>
                    </td>
                    <td style="font-size: 13px;">${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #10b981; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.handicapScore}
                    </td>
                    <td style="font-weight: 700; font-size: 14px; color: #10b981;">
                        ${result.strongTeam}
                        <br><span style="font-size: 11px; color: #6b7280;">
                            wygrane 2+: ${result.strongTeamWinsPct}% | ${result.weakTeam} przegrane 2+: ${result.weakTeamLossesPct}%
                        </span>
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Handicap 1.5")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showMostCornersModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'most-corners',
		title: 'TOP 10 - Najwięcej rzutów rożnych',
		icon: '🚩',
		description:
			'Znajduje mecze gdzie obie drużyny mają najwyższą średnią rzutów rożnych. Idealny typ zakładu: Over na rożne.',
		headerGradient: 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)',
		descriptionGradient: 'linear-gradient(135deg, #fef3c7 0%, #fcd34d 100%)',
		descriptionBorder: '#f59e0b',
		descriptionTextColor: '#78350f',
		maxWidth: '1200px',
		matchCountField: 'cornersMatchCount',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Statystyki gospodarzy</th>
            <th>Goście</th>
            <th>Statystyki gości</th>
            <th>Łączna średnia</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.totalCorners || 0} (śr. ${result.homeStats.avgCorners || 0})`
			const awayStatsText = `${result.awayStats.totalCorners || 0} (śr. ${result.awayStats.avgCorners || 0})`
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #f59e0b;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td>${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #f59e0b; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.averageCorners}
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Najwięcej rożnych")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showMostBTSModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'most-bts',
		title: 'TOP 10 - Najwięcej BTS (Both Teams to Score)',
		icon: '⚽',
		description:
			'Znajduje mecze gdzie obie drużyny mają najwyższy procent meczów z bramkami po obu stronach. Idealny typ zakładu: BTS (Both Teams to Score).',
		headerGradient: 'linear-gradient(135deg, #06b6d4 0%, #0891b2 100%)',
		descriptionGradient: 'linear-gradient(135deg, #cffafe 0%, #67e8f9 100%)',
		descriptionBorder: '#06b6d4',
		descriptionTextColor: '#164e63',
		maxWidth: '1200px',
		matchCountField: 'matchCount',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>BTS gospodarzy</th>
            <th>Goście</th>
            <th>BTS gości</th>
            <th>Łączny BTS %</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.btsCount}/${result.homeStats.matchCount} (${result.homeBTSPercent}%)`
			const awayStatsText = `${result.awayStats.btsCount}/${result.awayStats.matchCount} (${result.awayBTSPercent}%)`
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #06b6d4;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td>${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #06b6d4; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.combinedBTSPercent}%
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Najwięcej BTS")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showNoBTSModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'no-bts',
		title: 'TOP 10 - Bez BTS (No Both Teams to Score)',
		icon: '🛡️',
		description:
			'Znajduje mecze gdzie drużyny mają najwyższy procent meczów BEZ bramek po obu stronach (max jedna drużyna strzela). Idealny typ zakładu: No BTS.',
		headerGradient: 'linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%)',
		descriptionGradient: 'linear-gradient(135deg, #ede9fe 0%, #c4b5fd 100%)',
		descriptionBorder: '#8b5cf6',
		descriptionTextColor: '#5b21b6',
		maxWidth: '1200px',
		matchCountField: 'matchCount',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Bez BTS gospodarzy</th>
            <th>Goście</th>
            <th>Bez BTS gości</th>
            <th>Łączny Bez BTS %</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.noBtsCount}/${result.homeStats.matchCount} (${result.homeNoBTSPercent}%)`
			const awayStatsText = `${result.awayStats.noBtsCount}/${result.awayStats.matchCount} (${result.awayNoBTSPercent}%)`
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #8b5cf6;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td>${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #8b5cf6; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.combinedNoBTSPercent}%
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Bez BTS")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showHomeWinsModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'home-wins',
		title: 'TOP 10 - Zwycięstwa gospodarzy',
		icon: '🏠',
		description:
			'Znajduje mecze gdzie gospodarze najczęściej wygrywają w swoich meczach domowych. Idealny typ zakładu: Wygrana gospodarzy (1).',
		headerGradient: 'linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%)',
		descriptionGradient: 'linear-gradient(135deg, #dbeafe 0%, #93c5fd 100%)',
		descriptionBorder: '#2563eb',
		descriptionTextColor: '#1e3a8a',
		maxWidth: '1200px',
		matchCountField: 'homeMatchCount',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Wygrane u siebie</th>
            <th>Goście</th>
            <th>Statystyki gości (na wyjeździe)</th>
            <th>% Wygranych gospodarzy</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.homeWins}/${result.homeStats.homeMatchCount} (${result.homeWinPercent}%)`
			// For away team, show their away record if available
			const awayStatsText = result.awayStats.homeMatchCount 
				? `${result.awayStats.homeLosses || 0} P, ${result.awayStats.homeDraws || 0} R, ${result.awayStats.homeWins || 0} W`
				: 'Brak danych'
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #2563eb;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 12px;">${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #2563eb; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.homeWinPercent}%
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Zwycięstwa gospodarzy")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showAwayWinsModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'away-wins',
		title: 'TOP 10 - Zwycięstwa gości',
		icon: '✈️',
		description:
			'Znajduje mecze gdzie goście najczęściej wygrywają w swoich meczach wyjazdowych. Idealny typ zakładu: Wygrana gości (2).',
		headerGradient: 'linear-gradient(135deg, #dc2626 0%, #b91c1c 100%)',
		descriptionGradient: 'linear-gradient(135deg, #fee2e2 0%, #fca5a5 100%)',
		descriptionBorder: '#dc2626',
		descriptionTextColor: '#7f1d1d',
		maxWidth: '1200px',
		matchCountField: 'awayMatchCount',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Statystyki gospodarzy (u siebie)</th>
            <th>Goście</th>
            <th>Wygrane na wyjeździe</th>
            <th>% Wygranych gości</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const awayStatsText = `${result.awayStats.awayWins}/${result.awayStats.awayMatchCount} (${result.awayWinPercent}%)`
			// For home team, show their home record if available
			const homeStatsText = result.homeStats.awayMatchCount 
				? `${result.homeStats.awayWins || 0} W, ${result.homeStats.awayDraws || 0} R, ${result.homeStats.awayLosses || 0} P`
				: 'Brak danych'
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #dc2626;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 12px;">${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td>${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #dc2626; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.awayWinPercent}%
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Zwycięstwa gości")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showHomeLossesModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'home-losses',
		title: 'TOP 10 - Najwięcej porażek gospodarzy',
		icon: '📉',
		description:
			'Znajduje mecze gdzie gospodarze najczęściej przegrywają w swoich meczach domowych. Idealny typ zakładu: Wygrana gości (2) lub podwójna szansa X2.',
		headerGradient: 'linear-gradient(135deg, #f97316 0%, #ea580c 100%)',
		descriptionGradient: 'linear-gradient(135deg, #fed7aa 0%, #fdba74 100%)',
		descriptionBorder: '#f97316',
		descriptionTextColor: '#7c2d12',
		maxWidth: '1200px',
		matchCountField: 'homeMatchCount',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Porażki u siebie</th>
            <th>Goście</th>
            <th>Statystyki gości (na wyjeździe)</th>
            <th>% Porażek gospodarzy</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.homeLosses}/${result.homeStats.homeMatchCount} (${result.homeLossPercent}%)`
			// For away team, show their away record if available
			const awayStatsText = result.awayStats.awayMatchCount 
				? `${result.awayStats.awayWins || 0} W, ${result.awayStats.awayDraws || 0} R, ${result.awayStats.awayLosses || 0} P`
				: 'Brak danych'
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #f97316;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 12px;">${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #f97316; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.homeLossPercent}%
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Najwięcej porażek gospodarzy")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showAwayLossesModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'away-losses',
		title: 'TOP 10 - Najwięcej porażek gości',
		icon: '📊',
		description:
			'Znajduje mecze gdzie goście najczęściej przegrywają w swoich meczach wyjazdowych. Idealny typ zakładu: Wygrana gospodarzy (1) lub podwójna szansa 1X.',
		headerGradient: 'linear-gradient(135deg, #84cc16 0%, #65a30d 100%)',
		descriptionGradient: 'linear-gradient(135deg, #ecfccb 0%, #bef264 100%)',
		descriptionBorder: '#84cc16',
		descriptionTextColor: '#365314',
		maxWidth: '1200px',
		matchCountField: 'awayMatchCount',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Statystyki gospodarzy (u siebie)</th>
            <th>Goście</th>
            <th>Porażki na wyjeździe</th>
            <th>% Porażek gości</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const awayStatsText = `${result.awayStats.awayLosses}/${result.awayStats.awayMatchCount} (${result.awayLossPercent}%)`
			// For home team, show their home record if available
			const homeStatsText = result.homeStats.homeMatchCount 
				? `${result.homeStats.homeWins || 0} W, ${result.homeStats.homeDraws || 0} R, ${result.homeStats.homeLosses || 0} P`
				: 'Brak danych'
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #84cc16;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 12px;">${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td>${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #84cc16; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.awayLossPercent}%
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Najwięcej porażek gości")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showHomeAdvantageModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'home-advantage',
		title: 'TOP 10 - Przewaga gospodarzy',
		icon: '🛡️',
		description:
			'Znajduje mecze gdzie gospodarze często wygrywają u siebie, a goście często przegrywają na wyjeździe. Mocna przewaga dla gospodarzy. Idealny typ zakładu: Wygrana gospodarzy (1).',
		headerGradient: 'linear-gradient(135deg, #0891b2 0%, #0e7490 100%)',
		descriptionGradient: 'linear-gradient(135deg, #cffafe 0%, #67e8f9 100%)',
		descriptionBorder: '#0891b2',
		descriptionTextColor: '#164e63',
		maxWidth: '1400px',
		matchCountField: 'homeMatchCount',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Wygrane u siebie</th>
            <th>Goście</th>
            <th>Porażki na wyjeździe</th>
            <th>Wynik przewagi</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.homeWins || 0}/${result.homeStats.homeMatchCount || 0} (${result.homeWinPercent}%)`
			const awayStatsText = `${result.awayStats.awayLosses || 0}/${result.awayStats.awayMatchCount || 0} (${result.awayLossPercent}%)`
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #0891b2;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td style="color: #059669; font-weight: 600;">${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td style="color: #dc2626; font-weight: 600;">${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #0891b2; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.advantageScore}%
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Przewaga gospodarzy")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showAwayAdvantageModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'away-advantage',
		title: 'TOP 10 - Przewaga gości',
		icon: '⚔️',
		description:
			'Znajduje mecze gdzie goście często wygrywają na wyjeździe, a gospodarze często przegrywają u siebie. Mocna przewaga dla gości. Idealny typ zakładu: Wygrana gości (2).',
		headerGradient: 'linear-gradient(135deg, #a855f7 0%, #9333ea 100%)',
		descriptionGradient: 'linear-gradient(135deg, #f3e8ff 0%, #e9d5ff 100%)',
		descriptionBorder: '#a855f7',
		descriptionTextColor: '#581c87',
		maxWidth: '1400px',
		matchCountField: 'awayMatchCount',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Porażki u siebie</th>
            <th>Goście</th>
            <th>Wygrane na wyjeździe</th>
            <th>Wynik przewagi</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeLossStatsText = `${result.homeStats.homeLosses || 0}/${result.homeStats.homeMatchCount || 0} (${result.homeLossPercent}%)`
			const awayWinStatsText = `${result.awayStats.awayWins || 0}/${result.awayStats.awayMatchCount || 0} (${result.awayWinPercent}%)`
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #a855f7;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td style="color: #dc2626; font-weight: 600;">${homeLossStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td style="color: #059669; font-weight: 600;">${awayWinStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #a855f7; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.advantageScore}%
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Przewaga gości")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showLeastCornersModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'least-corners',
		title: 'TOP 10 - Najmniej rzutów rożnych',
		icon: '🔻',
		description:
			'Znajduje mecze gdzie obie drużyny mają najniższą średnią rzutów rożnych. Idealny typ zakładu: Under na rożne.',
		headerGradient: 'linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%)',
		descriptionGradient: 'linear-gradient(135deg, #ede9fe 0%, #c4b5fd 100%)',
		descriptionBorder: '#8b5cf6',
		descriptionTextColor: '#4c1d95',
		maxWidth: '1200px',
		matchCountField: 'cornersMatchCount',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Statystyki gospodarzy</th>
            <th>Goście</th>
            <th>Statystyki gości</th>
            <th>Łączna średnia</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.totalCorners || 0} (śr. ${result.homeStats.avgCorners || 0})`
			const awayStatsText = `${result.awayStats.totalCorners || 0} (śr. ${result.awayStats.avgCorners || 0})`
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #8b5cf6;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td>${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #8b5cf6; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.averageCorners}
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Najmniej rożnych")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showMostOffsidesModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'most-offsides',
		title: 'TOP 10 - Najwięcej spalonych',
		icon: '🚩',
		description:
			'Znajduje mecze gdzie obie drużyny mają najwyższą średnią spalonych. Idealny typ zakładu: Over na spalone.',
		headerGradient: 'linear-gradient(135deg, #059669 0%, #047857 100%)',
		descriptionGradient: 'linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%)',
		descriptionBorder: '#059669',
		descriptionTextColor: '#064e3b',
		maxWidth: '1200px',
		matchCountField: 'offsidesMatchCount',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Statystyki gospodarzy</th>
            <th>Goście</th>
            <th>Statystyki gości</th>
            <th>Łączna średnia</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.totalOffsides || 0} (śr. ${result.homeStats.avgOffsides || 0})`
			const awayStatsText = `${result.awayStats.totalOffsides || 0} (śr. ${result.awayStats.avgOffsides || 0})`
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #059669;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td>${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #059669; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.averageOffsides}
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Najwięcej spalonych")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showLeastOffsidesModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'least-offsides',
		title: 'TOP 10 - Najmniej spalonych',
		icon: '🔻',
		description:
			'Znajduje mecze gdzie obie drużyny mają najniższą średnią spalonych. Idealny typ zakładu: Under na spalone.',
		headerGradient: 'linear-gradient(135deg, #0d9488 0%, #0f766e 100%)',
		descriptionGradient: 'linear-gradient(135deg, #ccfbf1 0%, #99f6e4 100%)',
		descriptionBorder: '#0d9488',
		descriptionTextColor: '#134e4a',
		maxWidth: '1200px',
		matchCountField: 'offsidesMatchCount',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Statystyki gospodarzy</th>
            <th>Goście</th>
            <th>Statystyki gości</th>
            <th>Łączna średnia</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.totalOffsides || 0} (śr. ${result.homeStats.avgOffsides || 0})`
			const awayStatsText = `${result.awayStats.totalOffsides || 0} (śr. ${result.awayStats.avgOffsides || 0})`
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #0d9488;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td>${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #0d9488; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.averageOffsides}
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Najmniej spalonych")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showGoalAdvantageModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'goal-advantage',
		title: 'TOP 10 - Przewaga bramkowa',
		icon: '💪',
		description:
			'Znajduje mecze gdzie jedna drużyna strzela najwięcej bramek, a druga traci najwięcej bramek (niezależnie od bycia gospodarzem/gościem). Idealny typ zakładu: 1X2 na silniejszą drużynę.',
		headerGradient: 'linear-gradient(135deg, #ef4444 0%, #dc2626 100%)',
		descriptionGradient: 'linear-gradient(135deg, #fee2e2 0%, #fca5a5 100%)',
		descriptionBorder: '#ef4444',
		descriptionTextColor: '#7f1d1d',
		maxWidth: '1400px',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Strzelone:Stracone (śr. bramek)</th>
            <th>Goście</th>
            <th>Strzelone:Stracone (śr. bramek)</th>
            <th>Przewaga</th>
            <th>Silniejszy</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.totalGoalsScored}:${result.homeStats.totalGoalsConceded} (śr. ${result.homeStats.avgGoals})`
			const awayStatsText = `${result.awayStats.totalGoalsScored}:${result.awayStats.totalGoalsConceded} (śr. ${result.awayStats.avgGoals})`
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')
			
			// Get standings from current match or team history
			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)

// Highlight strong team
			const homeTeamStyle = result.strongTeam === result.homeTeam 
				? 'color: #10b981; font-weight: 700;' 
				: 'color: #ef4444; font-weight: 600;'
			const awayTeamStyle = result.strongTeam === result.awayTeam 
				? 'color: #10b981; font-weight: 700;' 
				: 'color: #ef4444; font-weight: 600;'

			return `
                <tr>
                    <td style="font-weight: 700; color: #ef4444;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="${homeTeamStyle}">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${formatTeamWithStanding(result.homeTeam, homeStanding, result.date)}
                        </a>
                    </td>
                    <td style="font-size: 13px;">${homeStatsText}</td>
                    <td style="${awayTeamStyle}">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${formatTeamWithStanding(result.awayTeam, awayStanding, result.date)}
                        </a>
                    </td>
                    <td style="font-size: 13px;">${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #ef4444; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.advantageScore}
                    </td>
                    <td style="font-weight: 700; font-size: 14px; color: #10b981;">
                        ${result.strongTeam}
                        <br><span style="font-size: 11px; color: #6b7280;">
                            strzela: ${result.strongTeamScored} | ${result.weakTeam} traci: ${result.weakTeamConceded}
                        </span>
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Przewaga bramkowa")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showWinnerVsLoserModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'winner-vs-loser',
		title: 'TOP 10 - Wygrane vs Przegrane',
		icon: '🏆',
		description:
			'Znajduje mecze gdzie jedna drużyna ma najwyższy procent wygranych, a druga najwyższy procent przegranych w ostatnich meczach. Im wyższy wynik kontrastu, tym większa różnica form.',
		headerGradient: 'linear-gradient(135deg, #06b6d4 0%, #0891b2 100%)',
		descriptionGradient: 'linear-gradient(135deg, #cffafe 0%, #67e8f9 100%)',
		descriptionBorder: '#06b6d4',
		descriptionTextColor: '#164e63',
		maxWidth: '1400px',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>W/D/L % gospodarzy</th>
            <th>Goście</th>
            <th>W/D/L % gości</th>
            <th>Kontrast form</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.wins}W / ${result.homeStats.draws}D / ${result.homeStats.losses}L (${result.homeStats.winPercent}% / ${result.homeStats.drawPercent}% / ${result.homeStats.lossPercent}%)`
			const awayStatsText = `${result.awayStats.wins}W / ${result.awayStats.draws}D / ${result.awayStats.losses}L (${result.awayStats.winPercent}% / ${result.awayStats.drawPercent}% / ${result.awayStats.lossPercent}%)`
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			// Color code based on which team is strong
			const homeTeamStyle =
				result.strongTeam === result.homeTeam
					? 'color: #10b981; font-weight: 700;'
					: 'color: #ef4444; font-weight: 700;'
			const awayTeamStyle =
				result.strongTeam === result.awayTeam
					? 'color: #10b981; font-weight: 700;'
					: 'color: #ef4444; font-weight: 700;'

			return `
                <tr>
                    <td style="font-weight: 700; color: #06b6d4;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600; ${homeTeamStyle}">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 13px;">${homeStatsText}</td>
                    <td style="font-weight: 600; ${awayTeamStyle}">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 13px;">${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #06b6d4; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.contrastScore}
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Wygrane vs Przegrane")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showMostTotalCornersModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'total-corners',
		title: 'TOP 10 - Najwięcej Rożnych Mecz',
		icon: '🚩',
		description:
			'Znajduje mecze gdzie suma rzutów rożnych obu drużyn jest największa. Im wyższa średnia, tym więcej rożnych pada w meczach tych drużyn.',
		headerGradient: 'linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%)',
		descriptionGradient: 'linear-gradient(135deg, #f3e8ff 0%, #e9d5ff 100%)',
		descriptionBorder: '#8b5cf6',
		descriptionTextColor: '#581c87',
		maxWidth: '1400px',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Śr. rożnych (gospodarze)</th>
            <th>Goście</th>
            <th>Śr. rożnych (goście)</th>
            <th>Śr. suma rożnych</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #8b5cf6;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 14px; color: #6b7280;">
                        ${result.homeStats.avgMatchCorners} 
                        <span style="font-size: 11px; color: #9ca3af;">(${
													result.homeStats.cornersMatchCount
												} meczów)</span>
                    </td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 14px; color: #6b7280;">
                        ${result.awayStats.avgMatchCorners}
                        <span style="font-size: 11px; color: #9ca3af;">(${
													result.awayStats.cornersMatchCount
												} meczów)</span>
                    </td>
                    <td style="font-weight: 700; font-size: 18px; color: #8b5cf6; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.averageTotalCorners}
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Najwięcej Rożnych Mecz")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showLeastTotalCornersModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'total-corners-least',
		title: 'TOP 10 - Najmniej Rożnych Mecz',
		icon: '🎯',
		description:
			'Znajduje mecze gdzie suma rzutów rożnych obu drużyn jest najmniejsza. Im niższa średnia, tym mniej rożnych pada w meczach tych drużyn.',
		headerGradient: 'linear-gradient(135deg, #ec4899 0%, #be185d 100%)',
		descriptionGradient: 'linear-gradient(135deg, #fce7f3 0%, #fbcfe8 100%)',
		descriptionBorder: '#ec4899',
		descriptionTextColor: '#831843',
		maxWidth: '1400px',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Śr. rożnych (gospodarze)</th>
            <th>Goście</th>
            <th>Śr. rożnych (goście)</th>
            <th>Śr. suma rożnych</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #ec4899;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 14px; color: #6b7280;">
                        ${result.homeStats.avgMatchCorners} 
                        <span style="font-size: 11px; color: #9ca3af;">(${
													result.homeStats.cornersMatchCount
												} meczów)</span>
                    </td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 14px; color: #6b7280;">
                        ${result.awayStats.avgMatchCorners}
                        <span style="font-size: 11px; color: #9ca3af;">(${
													result.awayStats.cornersMatchCount
												} meczów)</span>
                    </td>
                    <td style="font-weight: 700; font-size: 18px; color: #ec4899; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.averageTotalCorners}
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Najmniej Rożnych Mecz")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showCornerAdvantageModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'corner-advantage',
		title: 'TOP 10 - Przewaga Rożnych',
		icon: '🎯',
		description:
			'Znajduje mecze gdzie jedna drużyna wykonuje dużo rożnych, a druga traci dużo rożnych. Im wyższy wynik przewagi, tym większa różnica potencjału ofensywnego i defensywnego.',
		headerGradient: 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)',
		descriptionGradient: 'linear-gradient(135deg, #fef3c7 0%, #fde68a 100%)',
		descriptionBorder: '#f59e0b',
		descriptionTextColor: '#78350f',
		maxWidth: '1600px',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Rożne ZA/PRZECIW</th>
            <th>Goście</th>
            <th>Rożne ZA/PRZECIW</th>
            <th>Przewaga</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			// Color code based on which team has advantage
			const homeTeamStyle =
				result.strongTeam === result.homeTeam
					? 'color: #10b981; font-weight: 700;'
					: 'color: #6b7280; font-weight: 600;'
			const awayTeamStyle =
				result.strongTeam === result.awayTeam
					? 'color: #10b981; font-weight: 700;'
					: 'color: #6b7280; font-weight: 600;'

			return `
                <tr>
                    <td style="font-weight: 700; color: #f59e0b;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="${homeTeamStyle}">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 13px; color: #6b7280;">
                        Za: <strong style="color: #10b981;">${result.homeStats.avgCornersFor}</strong> / 
                        Przeciw: <strong style="color: #dc2626;">${result.homeStats.avgCornersAgainst}</strong>
                        <br><span style="font-size: 11px; color: #9ca3af;">(${
													result.homeStats.cornersMatchCount
												} meczów)</span>
                    </td>
                    <td style="${awayTeamStyle}">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 13px; color: #6b7280;">
                        Za: <strong style="color: #10b981;">${result.awayStats.avgCornersFor}</strong> / 
                        Przeciw: <strong style="color: #dc2626;">${result.awayStats.avgCornersAgainst}</strong>
                        <br><span style="font-size: 11px; color: #9ca3af;">(${
													result.awayStats.cornersMatchCount
												} meczów)</span>
                    </td>
                    <td style="font-weight: 700; font-size: 18px; color: #f59e0b; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.advantageScore}
                        <br><span style="font-size: 11px; color: #9ca3af; font-weight: 400;">
                            (${result.strongTeam === result.homeTeam ? result.homeTeam : result.awayTeam}: ${
				result.strongTeamCornersFor
			} + 
                            ${result.strongTeam === result.homeTeam ? result.awayTeam : result.homeTeam}: ${
				result.weakTeamCornersAgainst
			})
                        </span>
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Przewaga Rożnych")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showMostTotalOffsidesModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'total-offsides',
		title: 'TOP 10 - Najwięcej Spalonych Mecz',
		icon: '🚩',
		description:
			'Znajduje mecze gdzie suma spalonych obu drużyn jest największa. Im wyższa średnia, tym więcej spalonych pada w meczach tych drużyn.',
		headerGradient: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
		descriptionGradient: 'linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%)',
		descriptionBorder: '#10b981',
		descriptionTextColor: '#065f46',
		maxWidth: '1400px',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Śr. spalonych (gospodarze)</th>
            <th>Goście</th>
            <th>Śr. spalonych (goście)</th>
            <th>Śr. suma spalonych</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #10b981;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 14px; color: #6b7280;">
                        ${result.homeStats.avgMatchOffsides} 
                        <span style="font-size: 11px; color: #9ca3af;">(${
													result.homeStats.offsidesMatchCount
												} meczów)</span>
                    </td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 14px; color: #6b7280;">
                        ${result.awayStats.avgMatchOffsides}
                        <span style="font-size: 11px; color: #9ca3af;">(${
													result.awayStats.offsidesMatchCount
												} meczów)</span>
                    </td>
                    <td style="font-weight: 700; font-size: 18px; color: #10b981; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.averageTotalOffsides}
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Najwięcej Spalonych Mecz")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

function showLeastTotalOffsidesModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'total-offsides-least',
		title: 'TOP 10 - Najmniej Spalonych Mecz',
		icon: '🎯',
		description:
			'Znajduje mecze gdzie suma spalonych obu drużyn jest najmniejsza. Im niższa średnia, tym mniej spalonych pada w meczach tych drużyn.',
		headerGradient: 'linear-gradient(135deg, #14b8a6 0%, #0d9488 100%)',
		descriptionGradient: 'linear-gradient(135deg, #ccfbf1 0%, #99f6e4 100%)',
		descriptionBorder: '#14b8a6',
		descriptionTextColor: '#134e4a',
		maxWidth: '1400px',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Śr. spalonych (gospodarze)</th>
            <th>Goście</th>
            <th>Śr. spalonych (goście)</th>
            <th>Śr. suma spalonych</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			const homeStanding = getTeamStanding(result.homeStats, result.homeTeam, result.date, result.standing_home)
			const awayStanding = getTeamStanding(result.awayStats, result.awayTeam, result.date, result.standing_away)
			const homeTeamDisplay = formatTeamWithStanding(result.homeTeam, homeStanding, result.date)
			const awayTeamDisplay = formatTeamWithStanding(result.awayTeam, awayStanding, result.date)

			return `
                <tr>
                    <td style="font-weight: 700; color: #14b8a6;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${homeTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 14px; color: #6b7280;">
                        ${result.homeStats.avgMatchOffsides} 
                        <span style="font-size: 11px; color: #9ca3af;">(${
													result.homeStats.offsidesMatchCount
												} meczów)</span>
                    </td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${awayTeamDisplay}
                        </a>
                    </td>
                    <td style="font-size: 14px; color: #6b7280;">
                        ${result.awayStats.avgMatchOffsides}
                        <span style="font-size: 11px; color: #9ca3af;">(${
													result.awayStats.offsidesMatchCount
												} meczów)</span>
                    </td>
                    <td style="font-weight: 700; font-size: 18px; color: #14b8a6; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.averageTotalOffsides}
                    </td>
                    <td>
                        <button class="btn-small" onclick='window.addToWatchedMatches(${resultData}, "Najmniej Spalonych Mecz")'>
                            ⭐ Dodaj
                        </button>
                    </td>
                </tr>
            `
		},
	})
}

// =============================================================================
// QUEUE INTEGRATION
// =============================================================================

/**
 * Helper function to add search to queue
 */
function queueSearch(name, executeFunc, type) {
	// Import dynamically to avoid circular dependency
	import('./search-queue.js').then(({ addToQueue }) => {
		addToQueue({
			name,
			execute: executeFunc,
			type,
		})
	})
}

/**
 * Queue versions of search functions
 */
export function queueMostGoals() {
	queueSearch('Najwięcej bramek', () => findMostGoals(), 'most-goals')
}

export function queueLeastGoals() {
	queueSearch('Najmniej bramek', () => findLeastGoals(), 'least-goals')
}

export function queueHandicap15() {
	queueSearch('Handicap 1.5', () => findHandicap15(), 'handicap-15')
}

export function queueMostCorners() {
	queueSearch('Najwięcej rożnych drużyn', () => findMostCorners(), 'most-corners')
}

export function queueLeastCorners() {
	queueSearch('Najmniej rożnych drużyn', () => findLeastCorners(), 'least-corners')
}

export function queueMostBTS() {
	queueSearch('Najwięcej BTS', () => findMostBTS(), 'most-bts')
}

export function queueNoBTS() {
	queueSearch('Bez BTS', () => findNoBTS(), 'no-bts')
}

export function queueHomeWins() {
	queueSearch('Zwycięstwa gospodarzy', () => findHomeWins(), 'home-wins')
}

export function queueAwayWins() {
	queueSearch('Zwycięstwa gości', () => findAwayWins(), 'away-wins')
}

export function queueHomeLosses() {
	queueSearch('Najwięcej porażek gospodarzy', () => findHomeLosses(), 'home-losses')
}

export function queueAwayLosses() {
	queueSearch('Najwięcej porażek gości', () => findAwayLosses(), 'away-losses')
}

export function queueHomeAdvantage() {
	queueSearch('Przewaga gospodarzy', () => findHomeAdvantage(), 'home-advantage')
}

export function queueAwayAdvantage() {
	queueSearch('Przewaga gości', () => findAwayAdvantage(), 'away-advantage')
}

export function queueGoalAdvantage() {
	queueSearch('Przewaga bramkowa', () => findGoalAdvantage(), 'goal-advantage')
}

export function queueWinnerVsLoser() {
	queueSearch('Wygrywający vs Przegrywający', () => findWinnerVsLoser(), 'winner-vs-loser')
}

export function queueMostTotalCorners() {
	queueSearch('Najwięcej rożnych mecz', () => findMostTotalCorners(), 'most-total-corners')
}

export function queueLeastTotalCorners() {
	queueSearch('Najmniej rożnych mecz', () => findLeastTotalCorners(), 'least-total-corners')
}

export function queueCornerAdvantage() {
	queueSearch('Przewaga rożnych', () => findCornerAdvantage(), 'corner-advantage')
}

export function queueMostTotalOffsides() {
	queueSearch('Najwięcej spalonych mecz', () => findMostTotalOffsides(), 'most-total-offsides')
}

export function queueLeastTotalOffsides() {
	queueSearch('Najmniej spalonych mecz', () => findLeastTotalOffsides(), 'least-total-offsides')
}

export function queueMostOffsides() {
	queueSearch('Najwięcej spalonych drużyn', () => findMostOffsides(), 'most-offsides')
}

export function queueLeastOffsides() {
	queueSearch('Najmniej spalonych drużyn', () => findLeastOffsides(), 'least-offsides')
}







