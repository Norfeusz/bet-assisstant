import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function checkAndFixJobs() {
	try {
		// Check job #9
		const job9 = await prisma.import_jobs.findUnique({
			where: { id: 9 },
		})

		if (job9) {
			console.log('Job #9 details:')
			console.log(`  Status: ${job9.status}`)
			console.log(`  Created: ${job9.created_at}`)
			console.log(`  Updated: ${job9.updated_at}`)
			console.log(`  Job type: ${job9.job_type}`)
			console.log(`  Rate limit reset at: ${job9.rate_limit_reset_at}`)
			console.log(`  Rate limit remaining: ${job9.rate_limit_remaining}`)
			console.log(`  Progress:`, job9.progress)
			
			if (job9.status === 'rate_limited') {
				console.log('\n⚠️  Job #9 is rate_limited')
				
				// Check if rate_limit_reset_at is in the past
				const now = new Date()
				if (job9.rate_limit_reset_at && job9.rate_limit_reset_at < now) {
					console.log('✅ Rate limit has expired, promoting to pending...')
					await prisma.import_jobs.update({
						where: { id: 9 },
						data: {
							status: 'pending',
							updated_at: new Date(),
						},
					})
					console.log('✅ Job #9 promoted to pending')
				} else if (!job9.rate_limit_reset_at) {
					console.log('⚠️  rate_limit_reset_at is NULL! Setting it to 15 minutes from last update...')
					const resetTime = new Date(job9.updated_at)
					resetTime.setMinutes(resetTime.getMinutes() + 15)
					
					await prisma.import_jobs.update({
						where: { id: 9 },
						data: {
							rate_limit_reset_at: resetTime,
							updated_at: new Date(),
						},
					})
					console.log(`✅ Set rate_limit_reset_at to ${resetTime}`)
					
					// If reset time is already in the past, promote immediately
					if (resetTime < now) {
						console.log('✅ Reset time is in the past, promoting to pending...')
						await prisma.import_jobs.update({
							where: { id: 9 },
							data: {
								status: 'pending',
								updated_at: new Date(),
							},
						})
						console.log('✅ Job #9 promoted to pending')
					}
				} else {
					const minutesRemaining = Math.ceil((job9.rate_limit_reset_at.getTime() - now.getTime()) / 60000)
					console.log(`⏳ Rate limit will reset in ${minutesRemaining} minutes`)
				}
			}
		}

	} catch (error) {
		console.error('Error:', error)
	} finally {
		await prisma.$disconnect()
	}
}

checkAndFixJobs()
