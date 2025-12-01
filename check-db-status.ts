import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function checkDatabase() {
	try {
		console.log('Checking database status...\n')

		// Count total matches
		const totalMatches = await prisma.matches.count()
		console.log(`📊 Total matches: ${totalMatches}`)

		// Get date range
		const dateRange = await prisma.matches.aggregate({
			_min: { match_date: true },
			_max: { match_date: true },
		})

		console.log(`📅 Date range: ${dateRange._min.match_date} → ${dateRange._max.match_date}`)

		// Count by month
		const matchesByMonth = await prisma.$queryRaw<Array<{ month: string; count: bigint }>>`
			SELECT 
				TO_CHAR(match_date, 'YYYY-MM') as month,
				COUNT(*) as count
			FROM matches
			GROUP BY TO_CHAR(match_date, 'YYYY-MM')
			ORDER BY month DESC
			LIMIT 12
		`

		console.log('\n📆 Matches by month:')
		matchesByMonth.forEach(row => {
			console.log(`  ${row.month}: ${row.count} matches`)
		})

		// Count finished vs upcoming
		const finishedCount = await prisma.matches.count({
			where: { is_finished: 'yes' },
		})
		const upcomingCount = totalMatches - finishedCount

		console.log(`\n✅ Finished: ${finishedCount}`)
		console.log(`⏳ Upcoming: ${upcomingCount}`)

		// Get recent matches
		const recentMatches = await prisma.matches.findMany({
			take: 5,
			orderBy: { match_date: 'desc' },
			select: {
				fixture_id: true,
				match_date: true,
				home_team: true,
				away_team: true,
			},
		})

		console.log('\n🔍 Recent 5 matches:')
		recentMatches.forEach(m => {
			console.log(`  ${m.match_date.toISOString().split('T')[0]} - ${m.home_team} vs ${m.away_team}`)
		})
	} catch (error) {
		console.error('Error:', error)
	} finally {
		await prisma.$disconnect()
	}
}

checkDatabase()
