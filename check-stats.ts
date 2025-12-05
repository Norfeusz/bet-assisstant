import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function checkStats() {
	try {
		const leagues = ['Championship', 'Ekstraklasa', 'Premier League', 'Bundesliga']

		for (const league of leagues) {
			console.log(`\n${'='.repeat(60)}`)
			console.log(`Liga: ${league}`)
			console.log('='.repeat(60))

			// Check stats availability by date range
			const statsAvailability = await prisma.$queryRaw<
				Array<{ date_month: string; total: bigint; with_stats: bigint }>
			>`
				SELECT 
					TO_CHAR(match_date, 'YYYY-MM') as date_month,
					COUNT(*) as total,
					COUNT(home_shots) as with_stats
				FROM matches
				WHERE league = ${league}
				GROUP BY TO_CHAR(match_date, 'YYYY-MM')
				ORDER BY date_month DESC
				LIMIT 6
			`

			console.log('\n📊 Dostępność szczegółowych statystyk:')
			statsAvailability.forEach(row => {
				const percentage = (Number(row.with_stats) / Number(row.total)) * 100
				const bar = '█'.repeat(Math.floor(percentage / 10))
				console.log(
					`  ${row.date_month}: ${String(row.with_stats).padStart(3)}/${String(row.total).padStart(3)} (${percentage.toFixed(1).padStart(5)}%) ${bar}`
				)
			})
		}
	} catch (error) {
		console.error('Error:', error)
	} finally {
		await prisma.$disconnect()
	}
}

checkStats()
