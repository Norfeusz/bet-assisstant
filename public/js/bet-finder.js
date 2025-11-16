/**
 * Bet Finder Module
 * Functions for finding and analyzing matches based on various criteria
 */

import { showToast } from './utils/helpers.js'
import { state } from './config/state.js'

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
 * Generic function to find and analyze matches based on various criteria
 * @param {Object} config - Configuration object
 * @returns {Promise<void>}
 */
async function findMatches(config) {
	const {
		searchMessage,
		calculateStats,
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

			const history = await fetch(
				`/api/database/matches?team=${encodeURIComponent(team)}&league=${encodeURIComponent(
					league
				)}&is_finished=yes&sort=date_desc${state.selectedMatchCount ? `&limit=${state.selectedMatchCount}` : ''}`
			).then(res => res.json())

			historyCache.set(cacheKey, history)
			return history
		}

		// Calculate statistics for each match
		const matchStats = []
		let processedCount = 0
		let skippedCount = 0

		console.log(`🔍 Analyzing ${upcomingMatches.length} upcoming matches...`)
		console.log(`📊 Using match count limit: ${state.selectedMatchCount || 'all'}`)

		for (const match of upcomingMatches) {
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
			const homeStats = calculateStats(homeHistory, homeTeam)
			const awayStats = calculateStats(awayHistory, awayTeam)

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
			}
		},
		sortMatches: (a, b) => b.averageCorners - a.averageCorners,
		showModal: showMostCornersModal,
		noMatchesMessage:
			'Nie znaleziono meczów z danymi o rzutach rożnych (obie drużyny muszą mieć min. 5 zakończonych meczów z dostępnymi statystykami)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => homeStats.cornersMatchCount > 0 && awayStats.cornersMatchCount > 0,
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
			}
		},
		sortMatches: (a, b) => a.averageCorners - b.averageCorners, // ASCENDING for least corners
		showModal: showLeastCornersModal,
		noMatchesMessage:
			'Nie znaleziono meczów z danymi o rzutach rożnych (obie drużyny muszą mieć min. 5 zakończonych meczów z dostępnymi statystykami)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => homeStats.cornersMatchCount > 0 && awayStats.cornersMatchCount > 0,
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
			}
		},
		sortMatches: (a, b) => b.averageTotalCorners - a.averageTotalCorners,
		showModal: showMostTotalCornersModal,
		noMatchesMessage:
			'Nie znaleziono meczów z danymi o rzutach rożnych (obie drużyny muszą mieć min. 5 zakończonych meczów z dostępnymi statystykami)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => homeStats.cornersMatchCount > 0 && awayStats.cornersMatchCount > 0,
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
			}
		},
		sortMatches: (a, b) => a.averageTotalCorners - b.averageTotalCorners,
		showModal: showLeastTotalCornersModal,
		noMatchesMessage:
			'Nie znaleziono meczów z danymi o rzutach rożnych (obie drużyny muszą mieć min. 5 zakończonych meczów z dostępnymi statystykami)',
		minMatches: 5,
		validateTeamStats: (homeStats, awayStats) => homeStats.cornersMatchCount > 0 && awayStats.cornersMatchCount > 0,
	})
}

// ==========================================
// MODAL DISPLAY FUNCTIONS
// ==========================================

// Store modal data globally
let currentModalResults = null
let currentModalType = null

// Getters for modal data
export function getCurrentModalData() {
	return {
		results: currentModalResults,
		modalType: currentModalType,
	}
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
}

// Helper function to generate "Add to Watched" button
function generateAddButton(result, searchType) {
	const resultData = JSON.stringify(result).replace(/"/g, '&quot;').replace(/'/g, "\\'")
	return `<button class="btn-small" onclick='window.addToWatchedMatches(JSON.parse("${resultData}"), "${searchType}")'>⭐ Dodaj</button>`
}

// Generic function to create TOP 10 modal structure
function createTop10Modal(config) {
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

	// Remove existing modal of ANY type before creating new one
	const existingModal = document.getElementById('bet-finder-modal')
	if (existingModal) {
		existingModal.remove()
	}

	// Create and show modal
	const modalContainer = document.createElement('div')
	modalContainer.id = 'bet-finder-modal'
	modalContainer.innerHTML = modalHTML
	document.body.appendChild(modalContainer)
}

function showMostGoalsModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'most-goals',
		title: 'TOP 10 - Najwięcej bramek',
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
                            ${result.homeTeam}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${result.awayTeam}
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
                            ${result.homeTeam}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${result.awayTeam}
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
		maxWidth: '1200px',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Statystyki gospodarzy</th>
            <th>Goście</th>
            <th>Statystyki gości</th>
            <th>Różnica</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.totalGoalsScored}:${result.homeStats.totalGoalsConceded} (śr. ${result.homeStats.avgGoals})`
			const awayStatsText = `${result.awayStats.totalGoalsScored}:${result.awayStats.totalGoalsConceded} (śr. ${result.awayStats.avgGoals})`
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

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
                            ${result.homeTeam}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${result.awayTeam}
                        </a>
                    </td>
                    <td>${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #10b981; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.goalDifference}
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
                            ${result.homeTeam}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${result.awayTeam}
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
                            ${result.homeTeam}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${result.awayTeam}
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

function showGoalAdvantageModal(results, dateFrom, dateTo) {
	createTop10Modal({
		results,
		dateFrom,
		dateTo,
		modalType: 'goal-advantage',
		title: 'TOP 10 - Przewaga bramkowa',
		icon: '💪',
		description:
			'Znajduje mecze gdzie gospodarze mają dużą przewagę w strzelaniu bramek u siebie. Idealny typ zakładu: 1 (wygrana gospodarzy).',
		headerGradient: 'linear-gradient(135deg, #ef4444 0%, #dc2626 100%)',
		descriptionGradient: 'linear-gradient(135deg, #fee2e2 0%, #fca5a5 100%)',
		descriptionBorder: '#ef4444',
		descriptionTextColor: '#7f1d1d',
		maxWidth: '1200px',
		tableHeaders: `
            <th>#</th>
            <th>Data</th>
            <th>Liga</th>
            <th>Gospodarze</th>
            <th>Statystyki gospodarzy</th>
            <th>Goście</th>
            <th>Statystyki gości</th>
            <th>Przewaga</th>
            <th>Akcje</th>
        `,
		renderTableRow: (result, index) => {
			const homeStatsText = `${result.homeStats.totalGoalsScored}:${result.homeStats.totalGoalsConceded} (śr. ${result.homeStats.avgGoals})`
			const awayStatsText = `${result.awayStats.totalGoalsScored}:${result.awayStats.totalGoalsConceded} (śr. ${result.awayStats.avgGoals})`
			const resultData = JSON.stringify(result).replace(/"/g, '&quot;')

			return `
                <tr>
                    <td style="font-weight: 700; color: #ef4444;">${index + 1}</td>
                    <td>${new Date(result.date).toLocaleDateString('pl-PL')}</td>
                    <td style="font-size: 12px; color: #666;">${result.league}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${result.homeTeam}
                        </a>
                    </td>
                    <td>${homeStatsText}</td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${result.awayTeam}
                        </a>
                    </td>
                    <td>${awayStatsText}</td>
                    <td style="font-weight: 700; font-size: 18px; color: #ef4444; cursor: pointer; text-decoration: underline;"
                        onclick='window.showBetFinderMatchDetailsModal(${resultData})'
                        title="Kliknij aby zobaczyć szczegóły meczów">
                        ${result.homeAdvantage}
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
                            ${result.homeTeam}
                        </a>
                    </td>
                    <td style="font-size: 13px;">${homeStatsText}</td>
                    <td style="font-weight: 600; ${awayTeamStyle}">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${result.awayTeam}
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
                            ${result.homeTeam}
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
                            ${result.awayTeam}
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
                            ${result.homeTeam}
                        </a>
                    </td>
                    <td style="font-size: 14px; color: #6b7280;">
                        ${result.homeStats.avgMatchCorners} 
                        <span style="font-size: 11px; color: #9ca3af;">(${result.homeStats.cornersMatchCount} meczów)</span>
                    </td>
                    <td style="font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${result.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${result.awayTeam}
                        </a>
                    </td>
                    <td style="font-size: 14px; color: #6b7280;">
                        ${result.awayStats.avgMatchCorners}
                        <span style="font-size: 11px; color: #9ca3af;">(${result.awayStats.cornersMatchCount} meczów)</span>
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
