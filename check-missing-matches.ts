import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function checkMatches() {
	const teams = [
		{ home: 'FC Eindhoven', away: 'Jong PSV U21' },
		{ home: 'Lechia Gdansk', away: 'Gornik Zabrze' },
		{ home: 'Tychy 71', away: 'Polonia Warszawa' },
	]

	for (const { home, away } of teams) {
		console.log(`\n🔍 Searching for: ${home} vs ${away}`)
		
		// Try exact match
		const exactMatch = await prisma.matches.findFirst({
			where: {
				home_team: home,
				away_team: away,
			},
			select: {
				id: true,
				home_team: true,
				away_team: true,
				match_date: true,
				league: true,
			}
		})

		if (exactMatch) {
			console.log('✅ Found exact match:', exactMatch)
		} else {
			console.log('❌ No exact match found')
			
			// Try finding similar home team
			const similarHome = await prisma.matches.findMany({
				where: {
					home_team: {
						contains: home.split(' ')[0], // Search by first word
					}
				},
				take: 3,
				select: {
					home_team: true,
					away_team: true,
					match_date: true,
				}
			})
			
			if (similarHome.length > 0) {
				console.log('🔎 Similar home teams found:')
				similarHome.forEach(m => console.log(`   - ${m.home_team} vs ${m.away_team} (${m.match_date})`))
			}

			// Try finding similar away team
			const similarAway = await prisma.matches.findMany({
				where: {
					away_team: {
						contains: away.split(' ')[0], // Search by first word
					}
				},
				take: 3,
				select: {
					home_team: true,
					away_team: true,
					match_date: true,
				}
			})
			
			if (similarAway.length > 0) {
				console.log('🔎 Similar away teams found:')
				similarAway.forEach(m => console.log(`   - ${m.home_team} vs ${m.away_team} (${m.match_date})`))
			}
		}
	}

	await prisma.$disconnect()
}

checkMatches()
