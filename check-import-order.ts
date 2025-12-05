import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function checkImportOrder() {
	try {
		// Get Championship matches from 27.09.2025
		const matches = await prisma.matches.findMany({
			where: {
				league: 'Championship',
				match_date: {
					gte: new Date('2025-09-27T00:00:00Z'),
					lt: new Date('2025-09-28T00:00:00Z'),
				},
			},
			orderBy: { id: 'asc' }, // Order by insertion order (ID)
			select: {
				id: true,
				fixture_id: true,
				home_team: true,
				away_team: true,
				home_shots: true,
				home_possession: true,
				created_at: true,
			},
		})

		console.log(`Championship - mecze z 27.09.2025 (${matches.length} meczów):\n`)
		console.log('ID kolumny | Fixture ID | Mecz | Ma stats? | Czas utworzenia')
		console.log('-'.repeat(100))

		matches.forEach(m => {
			const hasStats = m.home_shots !== null || m.home_possession !== null
			const statsSymbol = hasStats ? '✅' : '❌'
			const createdAt = m.created_at ? m.created_at.toISOString().split('.')[0] : 'unknown'

			console.log(
				`${String(m.id).padStart(4)} | ${String(m.fixture_id).padStart(7)} | ${m.home_team.padEnd(20)} vs ${m.away_team.padEnd(20)} | ${statsSymbol} | ${createdAt}`
			)
		})

		// Find the breaking point
		const withStats = matches.filter(m => m.home_shots !== null)
		const withoutStats = matches.filter(m => m.home_shots === null)

		console.log(`\n📊 Podsumowanie:`)
		console.log(`  ✅ Ze statystykami: ${withStats.length} meczów`)
		console.log(`  ❌ Bez statystyk: ${withoutStats.length} meczów`)

		if (withStats.length > 0 && withoutStats.length > 0) {
			const lastWithStats = withStats[withStats.length - 1]
			const firstWithoutStats = withoutStats[0]

			console.log(`\n🔍 Punkt przerwania:`)
			console.log(`  Ostatni ze stats: ID ${lastWithStats.id} - ${lastWithStats.home_team} vs ${lastWithStats.away_team}`)
			console.log(`  Pierwszy bez stats: ID ${firstWithoutStats.id} - ${firstWithoutStats.home_team} vs ${firstWithoutStats.away_team}`)
		}
	} catch (error) {
		console.error('Error:', error)
	} finally {
		await prisma.$disconnect()
	}
}

checkImportOrder()
