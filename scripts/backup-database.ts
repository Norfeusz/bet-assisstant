/**
 * Database Backup Script
 * Creates SQL dump of the database and commits to GitHub
 */

import { exec } from 'child_process'
import { promisify } from 'util'
import * as path from 'path'
import * as fs from 'fs'
import * as dotenv from 'dotenv'

dotenv.config()

const execAsync = promisify(exec)

interface BackupOptions {
	pushToGit?: boolean
	skipIfNoChanges?: boolean
}

export class DatabaseBackup {
	private backupDir: string
	private backupFile: string
	private pgDumpPath: string

	constructor() {
		this.backupDir = path.join(process.cwd(), 'backups')
		this.backupFile = path.join(this.backupDir, 'database-backup.sql')
		this.pgDumpPath = 'C:\\Program Files\\PostgreSQL\\18\\bin\\pg_dump.exe'

		// Create backups directory if it doesn't exist
		if (!fs.existsSync(this.backupDir)) {
			fs.mkdirSync(this.backupDir, { recursive: true })
			console.log(`📁 Created backups directory: ${this.backupDir}`)
		}
	}

	/**
	 * Create database backup
	 */
	async createBackup(options: BackupOptions = {}): Promise<void> {
		const { pushToGit = true, skipIfNoChanges = true } = options

		try {
			console.log('\n💾 Creating database backup...')

			// Extract connection details from DATABASE_URL
			const dbUrl = process.env.DATABASE_URL!
			const match = dbUrl.match(/postgresql:\/\/([^:]+):([^@]+)@([^:]+):(\d+)\/(.+)/)

			if (!match) {
				throw new Error('Invalid DATABASE_URL format')
			}

			const [, user, password, host, port, database] = match

			// Set password environment variable for pg_dump
			const env = { ...process.env, PGPASSWORD: password }

			// Create backup using pg_dump
			const dumpCommand = `"${this.pgDumpPath}" -h ${host} -p ${port} -U ${user} -d ${database} --clean --if-exists --no-owner --no-privileges`

			console.log(`  🔄 Running pg_dump...`)
			const { stdout } = await execAsync(dumpCommand, { env, maxBuffer: 50 * 1024 * 1024 })

			// Write to file
			fs.writeFileSync(this.backupFile, stdout, 'utf8')

			// Get file size
			const stats = fs.statSync(this.backupFile)
			const fileSizeKB = (stats.size / 1024).toFixed(2)

			console.log(`  ✅ Backup created: ${this.backupFile}`)
			console.log(`  📊 Size: ${fileSizeKB} KB`)

			// Count tables and records
			const tableCount = (stdout.match(/CREATE TABLE/g) || []).length
			const insertCount = (stdout.match(/INSERT INTO/g) || []).length

			console.log(`  📋 Tables: ${tableCount}`)
			console.log(`  📝 Insert statements: ${insertCount}`)

			if (pushToGit) {
				await this.pushToGitHub(skipIfNoChanges)
			}

			console.log('✅ Backup completed successfully!\n')
		} catch (error: any) {
			console.error('❌ Backup failed:', error.message)
			throw error
		}
	}

	/**
	 * Push backup to GitHub
	 */
	private async pushToGitHub(skipIfNoChanges: boolean): Promise<void> {
		try {
			console.log('\n📤 Pushing backup to GitHub...')

			// Check if there are changes
			const { stdout: statusOutput } = await execAsync('git status --porcelain')

			if (!statusOutput.includes('backups/database-backup.sql')) {
				if (skipIfNoChanges) {
					console.log('  ℹ️  No changes in backup file, skipping push')
					return
				}
			}

			// Add backup file
			await execAsync('git add backups/database-backup.sql')
			console.log('  ✅ Added backup file to git')

			// Get current date for commit message
			const now = new Date()
			const dateStr = now.toISOString().split('T')[0]
			const timeStr = now.toTimeString().split(' ')[0]

			// Commit
			const commitMessage = `chore: database backup ${dateStr} ${timeStr}`
			await execAsync(`git commit -m "${commitMessage}"`)
			console.log(`  ✅ Committed: ${commitMessage}`)

			// Push to current branch
			const { stdout: branchOutput } = await execAsync('git branch --show-current')
			const currentBranch = branchOutput.trim()

			await execAsync(`git push origin ${currentBranch}`)
			console.log(`  ✅ Pushed to origin/${currentBranch}`)

			console.log('✅ Successfully pushed backup to GitHub!\n')
		} catch (error: any) {
			// If git operations fail, don't throw - backup was still created
			console.warn('⚠️  Failed to push to GitHub:', error.message)
			console.log('💡 Tip: You can manually push later with: git push\n')
		}
	}

	/**
	 * Get backup file path
	 */
	getBackupPath(): string {
		return this.backupFile
	}
}

// CLI usage
if (require.main === module) {
	const backup = new DatabaseBackup()
	backup
		.createBackup({
			pushToGit: process.argv.includes('--push'),
			skipIfNoChanges: !process.argv.includes('--force'),
		})
		.catch(error => {
			console.error('Fatal error:', error)
			process.exit(1)
		})
}
