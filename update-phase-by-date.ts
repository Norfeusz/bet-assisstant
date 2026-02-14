/**
 * Update phase for existing records based on match_date
 * 
 * Faza A: 2025-12-06 - 2026-01-22
 * Faza B: 2026-01-23 - 2026-02-07
 * Faza C: 2026-02-08 - bez daty zakończenia
 */

import { prisma } from './src/db'

async function updatePhaseByDate() {
	try {
		console.log('🔄 Aktualizacja faz dla istniejących rekordów...\n')
		
		// Update bets table
		console.log('📊 Tabela BETS:')
		
		// Faza A: 2025-12-06 - 2026-01-22
		const betsPhaseA = await prisma.bets.updateMany({
			where: {
				match_date: {
					gte: new Date('2025-12-06'),
					lte: new Date('2026-01-22')
				}
			},
			data: {
				phase: 'A'
			}
		})
		console.log(`  ✅ Faza A: ${betsPhaseA.count} rekordów`)
		
		// Faza B: 2026-01-23 - 2026-02-07
		const betsPhaseB = await prisma.bets.updateMany({
			where: {
				match_date: {
					gte: new Date('2026-01-23'),
					lte: new Date('2026-02-07')
				}
			},
			data: {
				phase: 'B'
			}
		})
		console.log(`  ✅ Faza B: ${betsPhaseB.count} rekordów`)
		
		// Faza C: 2026-02-08 - bez daty zakończenia
		const betsPhaseC = await prisma.bets.updateMany({
			where: {
				match_date: {
					gte: new Date('2026-02-08')
				}
			},
			data: {
				phase: 'C'
			}
		})
		console.log(`  ✅ Faza C: ${betsPhaseC.count} rekordów`)
		
		// Update coupons table
		console.log('\n📊 Tabela COUPONS:')
		
		// Faza A
		const couponsPhaseA = await prisma.coupons.updateMany({
			where: {
				match_date: {
					gte: new Date('2025-12-06'),
					lte: new Date('2026-01-22')
				}
			},
			data: {
				phase: 'A'
			}
		})
		console.log(`  ✅ Faza A: ${couponsPhaseA.count} rekordów`)
		
		// Faza B
		const couponsPhaseB = await prisma.coupons.updateMany({
			where: {
				match_date: {
					gte: new Date('2026-01-23'),
					lte: new Date('2026-02-07')
				}
			},
			data: {
				phase: 'B'
			}
		})
		console.log(`  ✅ Faza B: ${couponsPhaseB.count} rekordów`)
		
		// Faza C
		const couponsPhaseC = await prisma.coupons.updateMany({
			where: {
				match_date: {
					gte: new Date('2026-02-08')
				}
			},
			data: {
				phase: 'C'
			}
		})
		console.log(`  ✅ Faza C: ${couponsPhaseC.count} rekordów`)
		
		// Summary
		const totalBets = betsPhaseA.count + betsPhaseB.count + betsPhaseC.count
		const totalCoupons = couponsPhaseA.count + couponsPhaseB.count + couponsPhaseC.count
		
		console.log('\n📈 Podsumowanie:')
		console.log(`  Bets: ${totalBets} rekordów zaktualizowanych`)
		console.log(`  Coupons: ${totalCoupons} rekordów zaktualizowanych`)
		console.log(`  Łącznie: ${totalBets + totalCoupons} rekordów`)
		
		// Verify
		console.log('\n🔍 Weryfikacja:')
		const betsStats = await prisma.$queryRaw<any[]>`
			SELECT phase, COUNT(*) as count
			FROM bets
			WHERE phase IS NOT NULL
			GROUP BY phase
			ORDER BY phase
		`
		
		console.log('  Bets:')
		betsStats.forEach(s => console.log(`    Faza ${s.phase}: ${s.count}`))
		
		const couponsStats = await prisma.$queryRaw<any[]>`
			SELECT phase, COUNT(*) as count
			FROM coupons
			WHERE phase IS NOT NULL
			GROUP BY phase
			ORDER BY phase
		`
		
		console.log('  Coupons:')
		couponsStats.forEach(s => console.log(`    Faza ${s.phase}: ${s.count}`))
		
		console.log('\n✅ Aktualizacja zakończona pomyślnie!')
		
	} catch (error: any) {
		console.error('❌ Error:', error.message)
		console.error(error.stack)
	} finally {
		await prisma.$disconnect()
	}
}

updatePhaseByDate()
