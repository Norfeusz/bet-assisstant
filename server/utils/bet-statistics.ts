import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

interface MatchStats {
	homePercentage: number | string
	awayPercentage: number | string
	homeMatches: number
	awayMatches: number
}

/**
 * Calculate statistics for bet type
 */
export async function calculateBetStatistics(
	homeTeam: string,
	awayTeam: string,
	betType: string,
	betOption: string,
	assumption: 'overall' | 'ha', // overall = ogółem, ha = home/away
	league?: string // filter by league
): Promise<MatchStats> {
	const limit = 10

	console.log(`[calculateBetStatistics] homeTeam: ${homeTeam}, awayTeam: ${awayTeam}, betType: ${betType}, betOption: ${betOption}, assumption: ${assumption}`)

	try {
		// Determine which matches to fetch based on bet type and assumption
		let homeMatchesFilter: 'home' | 'away' | 'all' = assumption === 'ha' ? 'home' : 'all'
		let awayMatchesFilter: 'home' | 'away' | 'all' = assumption === 'ha' ? 'away' : 'all'

		// Get last 10 matches for home team
		const homeMatches = await getTeamMatches(homeTeam, homeMatchesFilter, limit, league)
		// Get last 10 matches for away team
		const awayMatches = await getTeamMatches(awayTeam, awayMatchesFilter, limit, league)

		console.log(`[calculateBetStatistics] homeMatches: ${homeMatches.length}, awayMatches: ${awayMatches.length}`)

		// Calculate percentage based on bet type
		const homeStats = calculatePercentage(homeMatches, betType, betOption, homeTeam, true)
		const awayStats = calculatePercentage(awayMatches, betType, betOption, awayTeam, false)

		console.log(`[calculateBetStatistics] homePercentage: ${homeStats.percentage}, awayPercentage: ${awayStats.percentage}`)

		return {
			homePercentage: homeStats.percentage,
			awayPercentage: awayStats.percentage,
			homeMatches: homeMatches.length,
			awayMatches: awayMatches.length,
		}
	} catch (error) {
		console.error('Error calculating bet statistics:', error)
		throw error
	}
}

/**
 * Get team matches from database
 */
async function getTeamMatches(team: string, side: 'home' | 'away' | 'all', limit: number, league?: string) {
	const where: any = {
		is_finished: 'yes', // Only finished matches
	}

	// Filter by league if provided
	if (league) {
		where.league = league
	}

	if (side === 'home') {
		where.home_team = team
	} else if (side === 'away') {
		where.away_team = team
	} else {
		// all - both home and away
		where.OR = [{ home_team: team }, { away_team: team }]
	}

	const matches = await prisma.matches.findMany({
		where,
		orderBy: { match_date: 'desc' },
		take: limit,
		select: {
			home_team: true,
			away_team: true,
			home_goals: true,
			away_goals: true,
			home_corners: true,
			away_corners: true,
			home_offsides: true,
			away_offsides: true,
		},
	})

	return matches
}

/**
 * Calculate percentage of matches meeting bet criteria
 */
function calculatePercentage(
	matches: any[],
	betType: string,
	betOption: string,
	teamName: string,
	isHomeTeamInUpcomingMatch: boolean // true if this team will be home in the upcoming match
): { percentage: number | string; count: number } {
	if (matches.length === 0) {
		return { percentage: 'za mało danych', count: 0 }
	}

	// Check if this bet type requires corner or offside data
	const requiresCornerData = betType.startsWith('corners_')
	const requiresOffsideData = betType.startsWith('offsides_')

	let matchingCount = 0
	let matchesWithData = 0 // Count matches that have required data

	for (const match of matches) {
		// Determine if the team was home or away in this match
		const isTeamHome = match.home_team === teamName
		const teamGoals = isTeamHome ? match.home_goals : match.away_goals
		const opponentGoals = isTeamHome ? match.away_goals : match.home_goals
		const teamCorners = isTeamHome ? match.home_corners : match.away_corners
		const opponentCorners = isTeamHome ? match.away_corners : match.home_corners
		const teamOffsides = isTeamHome ? match.home_offsides : match.away_offsides
		const opponentOffsides = isTeamHome ? match.away_offsides : match.home_offsides

		// Check if match has required data
		let hasRequiredData = true
		if (requiresCornerData) {
			hasRequiredData = match.home_corners != null && match.away_corners != null
		} else if (requiresOffsideData) {
			hasRequiredData = match.home_offsides != null && match.away_offsides != null
		}

		if (!hasRequiredData) {
			continue // Skip matches without required data
		}

		// Check if we should skip this match for specific bet types
		let shouldSkipMatch = false
		if (betType === 'corners_1_over' || betType === 'corners_1_under') {
			// Corners 1 only applies to home team in upcoming match
			if (!isHomeTeamInUpcomingMatch) {
				shouldSkipMatch = true
			}
		} else if (betType === 'corners_2_over' || betType === 'corners_2_under') {
			// Corners 2 only applies to away team in upcoming match
			if (isHomeTeamInUpcomingMatch) {
				shouldSkipMatch = true
			}
		}

		if (shouldSkipMatch) {
			continue // Skip counting this match entirely
		}

		matchesWithData++

		const totalGoals = (teamGoals || 0) + (opponentGoals || 0)
		const totalCorners = (teamCorners || 0) + (opponentCorners || 0)
		const totalOffsides = (teamOffsides || 0) + (opponentOffsides || 0)

		let meetsCondition = false

		switch (betType) {
			case '1': // Home win bet
				if (isHomeTeamInUpcomingMatch) {
					// For home team: count WINS
					meetsCondition = teamGoals > opponentGoals
				} else {
					// For away team: count LOSSES
					meetsCondition = teamGoals < opponentGoals
				}
				break

			case '2': // Away win bet
				if (isHomeTeamInUpcomingMatch) {
					// For home team: count LOSSES
					meetsCondition = teamGoals < opponentGoals
				} else {
					// For away team: count WINS
					meetsCondition = teamGoals > opponentGoals
				}
				break

			case 'bts': // Both teams score
				if (betOption === 'tak') {
					meetsCondition = teamGoals > 0 && opponentGoals > 0
				} else {
					meetsCondition = teamGoals === 0 || opponentGoals === 0
				}
				break

			case 'handi1': // Handicap home
			case 'handi2': // Handicap away
				const handicapValue = Math.abs(parseFloat(betOption))
				const goalDiff = teamGoals - opponentGoals
				meetsCondition = goalDiff > handicapValue
				break

			case 'goals_over': // Goals over
				const goalsOverValue = parseFloat(betOption)
				meetsCondition = totalGoals > goalsOverValue
				break

			case 'goals_under': // Goals under
				const goalsUnderValue = parseFloat(betOption)
				meetsCondition = totalGoals < goalsUnderValue
				break

		case 'corners_1_over': // Corners 1 over (HOME team in upcoming match will execute corners)
			const corners1OverValue = parseFloat(betOption)
			// Only check for home team (already filtered by shouldSkipMatch)
			meetsCondition = (teamCorners || 0) > corners1OverValue
			break

		case 'corners_1_under': // Corners 1 under (HOME team in upcoming match will execute corners)
			const corners1UnderValue = parseFloat(betOption)
			meetsCondition = (teamCorners || 0) < corners1UnderValue
			break

		case 'corners_2_over': // Corners 2 over (AWAY team in upcoming match will execute corners)
			const corners2OverValue = parseFloat(betOption)
			// Only check for away team (already filtered by shouldSkipMatch)
			meetsCondition = (teamCorners || 0) > corners2OverValue
			break

		case 'corners_2_under': // Corners 2 under (AWAY team in upcoming match will execute corners)
			const corners2UnderValue = parseFloat(betOption)
			meetsCondition = (teamCorners || 0) < corners2UnderValue
			break

		case 'corners_match_over': // Corners match over (total in match)
				const cornersMatchOverValue = parseFloat(betOption)
				meetsCondition = totalCorners > cornersMatchOverValue
				break

			case 'corners_match_under': // Corners match under (total in match)
				const cornersMatchUnderValue = parseFloat(betOption)
				meetsCondition = totalCorners < cornersMatchUnderValue
				break

			case 'offsides_over': // Offsides over
				const offsidesOverValue = parseFloat(betOption)
				meetsCondition = totalOffsides > offsidesOverValue
				break

			case 'offsides_under': // Offsides under
				const offsidesUnderValue = parseFloat(betOption)
				meetsCondition = totalOffsides < offsidesUnderValue
				break
		}

		if (meetsCondition) {
			matchingCount++
		}
	}

	console.log(`[BET STATS] Team: ${teamName}, BetType: ${betType}, IsHome: ${isHomeTeamInUpcomingMatch}, MatchesWithData: ${matchesWithData}, MatchingCount: ${matchingCount}, TotalMatches: ${matches.length}`)

	// Check if we have enough data (at least 7 matches with required data for corners/offsides)
	if ((requiresCornerData || requiresOffsideData) && matchesWithData < 7) {
		return { percentage: 'za mało danych', count: matchingCount }
	}

	// Check if we have any matches to calculate from
	if (matchesWithData === 0) {
		return { percentage: 'za mało danych', count: 0 }
	}

	// For other bet types or when we have enough data, calculate percentage
	const denominator = (requiresCornerData || requiresOffsideData) ? matchesWithData : matches.length
	const percentage = Math.round((matchingCount / denominator) * 100)

	return { percentage, count: matchingCount }
}
