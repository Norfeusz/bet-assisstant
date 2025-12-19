import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function checkJob() {
	const job = await prisma.$queryRaw`
		SELECT 
			id, 
			status, 
			progress,
			rate_limit_remaining,
			rate_limit_reset_at,
			imported_matches,
			failed_matches,
			created_at
		FROM import_jobs 
		WHERE id = 6
	`

	console.log('Job #6 details:')
	console.log(JSON.stringify(job, null, 2))

	const now = new Date()
	console.log('\nCurrent time:', now.toISOString())

	await prisma.$disconnect()
}

checkJob()
