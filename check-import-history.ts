import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function checkImportHistory() {
	try {
		const jobs = await prisma.import_jobs.findMany({
			orderBy: { created_at: 'desc' },
			take: 30,
			select: {
				id: true,
				job_type: true,
				status: true,
				date_from: true,
				date_to: true,
				created_at: true,
				completed_at: true,
			},
		})

		console.log('📋 Ostatnie zadania importu:\n')
		jobs.forEach(j => {
			const duration = j.completed_at
				? `(${Math.round((j.completed_at.getTime() - j.created_at.getTime()) / 1000)}s)`
				: ''
			console.log(
				`[${j.id}] ${j.job_type?.padEnd(15)} | ${j.status?.padEnd(10)} | ${j.date_from} → ${j.date_to} | ${j.created_at.toISOString().split('T')[0]} ${duration}`
			)
		})
	} catch (error) {
		console.error('Error:', error)
	} finally {
		await prisma.$disconnect()
	}
}

checkImportHistory()
