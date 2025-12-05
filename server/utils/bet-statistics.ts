import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

interface MatchStats {
	homePercentage: number
	awayPercentage: number
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

	try {
		// Get last 10 matches for home team
		const homeMatches = await getTeamMatches(homeTeam, assumption === 'ha' ? 'home' : 'all', limit, league)
		// Get last 10 matches for away team
		const awayMatches = await getTeamMatches(awayTeam, assumption === 'ha' ? 'away' : 'all', limit, league)

		// Calculate percentage based on bet type
		const homeStats = calculatePercentage(homeMatches, betType, betOption, homeTeam, true)
		const awayStats = calculatePercentage(awayMatches, betType, betOption, awayTeam, false)

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
): { percentage: number; count: number } {
	if (matches.length === 0) {
		return { percentage: 0, count: 0 }
	}

	let matchingCount = 0

	for (const match of matches) {
		// Determine if the team was home or away in this match
		const isTeamHome = match.home_team === teamName
		const teamGoals = isTeamHome ? match.home_goals : match.away_goals
		const opponentGoals = isTeamHome ? match.away_goals : match.home_goals
		const teamCorners = isTeamHome ? match.home_corners : match.away_corners
		const opponentCorners = isTeamHome ? match.away_corners : match.home_corners
		const teamOffsides = isTeamHome ? match.home_offsides : match.away_offsides
		const opponentOffsides = isTeamHome ? match.away_offsides : match.home_offsides

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

			case 'corners_over': // Corners over
				const cornersOverValue = parseFloat(betOption)
				meetsCondition = totalCorners > cornersOverValue
				break

			case 'corners_under': // Corners under
				const cornersUnderValue = parseFloat(betOption)
				meetsCondition = totalCorners < cornersUnderValue
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

	const percentage = Math.round((matchingCount / matches.length) * 100)

	return { percentage, count: matchingCount }
}
