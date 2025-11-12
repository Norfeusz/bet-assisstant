import { PrismaClient } from '@prisma/client'
import { DataImporter } from '../src/services/data-importer'
import { LeagueConfig } from '../src/services/league-selector'
import { ApiFootballClient } from '../src/services/api-football-client'
import { LeagueSelector } from '../src/services/league-selector'
import * as fs from 'fs'
import * as path from 'path'
import nodemailer from 'nodemailer'
import dotenv from 'dotenv'

dotenv.config()

const prisma = new PrismaClient()

interface ImportJob {
	id: number
	leagues: number[]
	date_from: Date
	date_to: Date
	status: string
	progress: JobProgress
	total_matches: number
	imported_matches: number
	failed_matches: number
	rate_limit_remaining: number
	rate_limit_reset_at: Date | null
	error_message?: string | null
	started_at?: Date
}

interface JobProgress {
	current_league?: number
	current_date?: string
	completed_leagues?: number[]
}

class BackgroundImportWorker {
	private logDir: string
	private emailTransporter: nodemailer.Transporter | null = null

	constructor() {
		this.logDir = path.join(process.cwd(), 'logs')

		// Create logs directory if it doesn't exist
		if (!fs.existsSync(this.logDir)) {
			fs.mkdirSync(this.logDir, { recursive: true })
		}

		// Setup email transporter
		this.setupEmailTransporter()
	}

	private setupEmailTransporter() {
		const emailConfig = {
			host: process.env.SMTP_HOST || 'smtp.gmail.com',
			port: parseInt(process.env.SMTP_PORT || '587'),
			secure: false,
			auth: {
				user: process.env.SMTP_USER,
				pass: process.env.SMTP_PASS,
			},
		}

		if (emailConfig.auth.user && emailConfig.auth.pass) {
			this.emailTransporter = nodemailer.createTransport(emailConfig)
		} else {
			console.warn('⚠️  Email credentials not configured, notifications disabled')
		}
	}

	private log(jobId: number, message: string) {
		const timestamp = new Date().toISOString()
		const logMessage = `[${timestamp}] [Job ${jobId}] ${message}\n`

		// Log to console
		console.log(logMessage.trim())

		// Log to file
		const logFile = path.join(this.logDir, `import-${new Date().toISOString().split('T')[0]}.log`)
		fs.appendFileSync(logFile, logMessage)
	}

	private async sendEmail(subject: string, body: string) {
		if (!this.emailTransporter) return

		try {
			await this.emailTransporter.sendMail({
				from: process.env.SMTP_USER,
				to: 'norf.cobain@gmail.com',
				subject: `Bet Assistant: ${subject}`,
				text: body,
				html: body.replace(/\n/g, '<br>'),
			})
			console.log('📧 Email notification sent')
		} catch (error) {
			console.error('❌ Failed to send email:', error)
		}
	}

	private async updateJobStatus(jobId: number, status: string, updates: Partial<ImportJob> = {}): Promise<void> {
		await prisma.$executeRawUnsafe(
			`
			UPDATE import_jobs 
			SET status = $1::job_status_enum, 
				imported_matches = COALESCE($2, imported_matches),
				failed_matches = COALESCE($3, failed_matches),
				rate_limit_remaining = COALESCE($4, rate_limit_remaining),
				rate_limit_reset_at = COALESCE($5, rate_limit_reset_at),
				progress = COALESCE($6::jsonb, progress),
				error_message = COALESCE($7, error_message),
				completed_at = CASE WHEN $1::text IN ('completed', 'failed') THEN NOW() ELSE completed_at END,
				updated_at = NOW()
			WHERE id = $8
		`,
			status,
			updates.imported_matches ?? null,
			updates.failed_matches ?? null,
			updates.rate_limit_remaining ?? null,
			updates.rate_limit_reset_at ?? null,
			updates.progress ? JSON.stringify(updates.progress) : null,
			updates.error_message ?? null,
			jobId
		)
	}

	private async loadLeagueConfigs(): Promise<LeagueConfig[]> {
		// Fetch leagues from the API endpoint
		try {
			const response = await fetch('http://localhost:3000/api/config')
			const data = (await response.json()) as { leagues: LeagueConfig[] }
			return data.leagues
		} catch (error) {
			console.error('Error loading league configs from API:', error)
			throw new Error('Failed to load league configurations')
		}
	}

	private async processJob(job: ImportJob): Promise<void> {
		this.log(job.id, `Starting job: ${job.leagues.length} leagues, ${job.date_from} to ${job.date_to}`)

		await this.updateJobStatus(job.id, 'running', {
			...job,
			started_at: new Date(),
			progress: {
				completed_leagues: job.progress?.completed_leagues || [],
				current_league: undefined,
				current_date: undefined,
			},
		} as any)

		const allLeagues = await this.loadLeagueConfigs()
		const selectedLeagues = allLeagues.filter(l => job.leagues.includes(l.id))

		this.log(job.id, `Leagues: ${selectedLeagues.map(l => l.name).join(', ')}`)

		// Create API client for this job
		const apiClient = new ApiFootballClient(process.env.API_FOOTBALL_KEY!)
		const leagueSelector = new LeagueSelector(apiClient)
		const importer = new DataImporter(apiClient, leagueSelector)

		try {
			// Resume from progress if exists
			const completedLeagues = job.progress?.completed_leagues || []
			const remainingLeagues = selectedLeagues.filter(l => !completedLeagues.includes(l.id))

			this.log(
				job.id,
				`Total leagues: ${selectedLeagues.length}, Completed: ${completedLeagues.length}, Remaining: ${remainingLeagues.length}`
			)

			if (completedLeagues.length > 0) {
				this.log(
					job.id,
					`📝 Resuming from league ${remainingLeagues[0]?.name || 'none'} (skipped ${
						completedLeagues.length
					} completed leagues)`
				)
			}

			// Track cumulative stats
			let cumulativeImported = job.imported_matches || 0
			let cumulativeFailed = job.failed_matches || 0

			for (const league of remainingLeagues) {
				this.log(job.id, `Processing league: ${league.name} (${league.country})`)

				// Update progress
				await this.updateJobStatus(job.id, 'running', {
					...job,
					progress: {
						current_league: league.id,
						current_date: job.date_from.toISOString().split('T')[0],
						completed_leagues: completedLeagues,
					},
				} as any)

				// Import matches for this league - create temp config with single league
				const tempConfigPath = path.join(process.cwd(), 'logs', `temp-config-${job.id}-${league.id}.json`)
				const mainConfigPath = path.join(process.cwd(), 'league-config.json')

				// Write temp config for single league
				fs.writeFileSync(tempConfigPath, JSON.stringify([league], null, 2))

				try {
					// Backup existing config if it exists
					let hadExistingConfig = false
					let backupConfigPath = ''

					if (fs.existsSync(mainConfigPath)) {
						hadExistingConfig = true
						backupConfigPath = path.join(process.cwd(), 'logs', `backup-config-${job.id}.json`)
						fs.copyFileSync(mainConfigPath, backupConfigPath)
					}

					// Use temp config
					fs.copyFileSync(tempConfigPath, mainConfigPath)

					// Create fresh importer with single league
					const tempLeagueSelector = new LeagueSelector(apiClient)
					const tempImporter = new DataImporter(apiClient, tempLeagueSelector)

					await tempImporter.importDateRange(
						job.date_from.toISOString().split('T')[0],
						job.date_to.toISOString().split('T')[0],
						false, // don't resume
						false // no auto-retry (we handle it ourselves)
					)

					// Restore original config if it existed
					if (hadExistingConfig && backupConfigPath) {
						fs.copyFileSync(backupConfigPath, mainConfigPath)
						fs.unlinkSync(backupConfigPath)
					} else {
						// Remove temp config file
						fs.unlinkSync(mainConfigPath)
					}

					// Cleanup temp file
					fs.unlinkSync(tempConfigPath)

					// Check rate limit
					const rateLimitInfo = tempImporter.getRateLimitInfo()
					const progress = tempImporter.getProgress()

					// Log league details
					const leagueProgress = progress.leagues[league.id]
					if (leagueProgress) {
						const total = leagueProgress.imported + leagueProgress.failed
						this.log(
							job.id,
							`✅ ${league.name}: ${leagueProgress.imported}/${total} imported${
								leagueProgress.failed > 0 ? `, ${leagueProgress.failed} failed` : ''
							}`
						)
					}

					// Log failed matches if any
					if (progress.failedMatches > 0) {
						this.log(job.id, `⚠️  Total failures so far: ${cumulativeFailed + progress.failedMatches}`)
					}

					// Update cumulative stats
					cumulativeImported += progress.importedMatches
					cumulativeFailed += progress.failedMatches

					this.log(
						job.id,
						`📊 Progress: ${cumulativeImported} total imported, ${rateLimitInfo.remaining} API requests remaining`
					)

					// Mark league as completed BEFORE checking rate limit
					completedLeagues.push(league.id)

					// Update job with league completion and cumulative stats
					await this.updateJobStatus(job.id, 'running', {
						...job,
						imported_matches: cumulativeImported,
						failed_matches: cumulativeFailed,
						rate_limit_remaining: rateLimitInfo.remaining,
						progress: {
							...job.progress,
							completed_leagues: completedLeagues,
							current_league: undefined,
						},
					} as any)

					this.log(job.id, `✅ Completed league: ${league.name} (${completedLeagues.length}/${selectedLeagues.length})`)

					// If rate limited, pause job
					if (rateLimitInfo.remaining <= 10) {
						// Keep small buffer
						this.log(job.id, '⏸️  Rate limit reached, pausing job for 15 minutes')
						await this.updateJobStatus(job.id, 'rate_limited', {
							...job,
							imported_matches: cumulativeImported,
							failed_matches: cumulativeFailed,
							rate_limit_reset_at: new Date(Date.now() + 15 * 60 * 1000), // 15 minutes
							progress: {
								...job.progress,
								completed_leagues: completedLeagues,
								current_league: undefined,
							},
						} as any)
						return // Exit and let scheduler resume later
					}
				} catch (error: any) {
					this.log(job.id, `❌ Error processing league ${league.name}: ${error.message}`)

					// Cleanup all temp files on error
					const originalConfigPath = path.join(process.cwd(), 'league-config.json')
					const backupConfigPath = path.join(process.cwd(), 'logs', `backup-config-${job.id}.json`)

					if (fs.existsSync(backupConfigPath)) {
						fs.copyFileSync(backupConfigPath, originalConfigPath)
						fs.unlinkSync(backupConfigPath)
					}
					if (fs.existsSync(tempConfigPath)) {
						fs.unlinkSync(tempConfigPath)
					}

					// Continue with next league
				}
			}

			// Job completed
			await this.updateJobStatus(job.id, 'completed', {
				imported_matches: cumulativeImported,
				failed_matches: cumulativeFailed,
			} as any)

			this.log(job.id, `✅ Job completed successfully`)

			// Send completion email
			await this.sendEmail(
				'Import Job Completed',
				`Job #${job.id} has completed successfully.\n\n` +
					`Leagues processed: ${selectedLeagues.map(l => l.name).join(', ')}\n` +
					`Imported: ${cumulativeImported} matches\n` +
					`Failed: ${cumulativeFailed} matches\n` +
					`Date range: ${job.date_from.toISOString().split('T')[0]} to ${job.date_to.toISOString().split('T')[0]}`
			)
		} catch (error: any) {
			this.log(job.id, `❌ Job failed: ${error.message}`)
			await this.updateJobStatus(job.id, 'failed', {
				...job,
				error_message: error.message,
			} as any)

			// Send error email
			await this.sendEmail(
				'Import Job Failed',
				`Job #${job.id} has failed.\n\n` + `Error: ${error.message}\n\n` + `Stack trace:\n${error.stack}`
			)
		}
	}

	async start() {
		console.log('🚀 Background Import Worker started')
		console.log(`📁 Logs directory: ${this.logDir}`)
		console.log('⏰ Checking for jobs every 60 seconds...\n')

		// Check immediately on start
		await this.checkAndProcessJobs()

		// Check for pending/rate_limited jobs every minute
		setInterval(async () => {
			await this.checkAndProcessJobs()
		}, 60000) // Check every minute

		// Keep process alive
		process.on('SIGINT', async () => {
			console.log('\n⏹️  Shutting down worker...')
			await prisma.$disconnect()
			process.exit(0)
		})
	}

	private async checkAndProcessJobs() {
		try {
			console.log('🔍 Checking for pending jobs...')

			// Find jobs that need processing
			const jobs = await prisma.$queryRaw<ImportJob[]>`
				SELECT * FROM import_jobs
				WHERE status IN ('pending', 'rate_limited')
				AND (
					status = 'pending' 
					OR (status = 'rate_limited' AND rate_limit_reset_at < NOW())
				)
				ORDER BY created_at ASC
				LIMIT 1
			`

			if (jobs.length > 0) {
				const job = jobs[0]

				// Parse progress if it's a string
				if (typeof job.progress === 'string') {
					job.progress = JSON.parse(job.progress)
				}

				console.log(`✅ Found job #${job.id} to process`)

				// If resuming from rate_limited, reset status to running
				if (job.status === 'rate_limited') {
					const completedCount = job.progress?.completed_leagues?.length || 0
					console.log(`🔄 Resuming rate-limited job #${job.id} (${completedCount} leagues already completed)`)
					await this.updateJobStatus(job.id, 'running', {
						...job,
						rate_limit_reset_at: null,
					} as any)
				}

				await this.processJob(job)
			} else {
				console.log('💤 No jobs to process')
			}
		} catch (error) {
			console.error('❌ Worker error:', error)
		}
	}
}

// Start worker
const worker = new BackgroundImportWorker()
worker.start()
