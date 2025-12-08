import * as fs from 'fs'
import * as path from 'path'

interface League {
	id: number
	name: string
	country: string
	type: string
	priority: number
	enabled: boolean
}

// Read leagues.json
const leaguesPath = path.join(process.cwd(), 'data', 'leagues.json')
const leagues: League[] = JSON.parse(fs.readFileSync(leaguesPath, 'utf-8'))

// Filter enabled leagues
const enabledLeagues = leagues.filter(l => l.enabled)

console.log(`Total leagues: ${leagues.length}`)
console.log(`Enabled leagues: ${enabledLeagues.length}`)

// Read existing CSV with Superbet links
const publicCsvPath = path.join(process.cwd(), 'public', 'Lista rozgrywek.csv')
const existingCsv = fs.readFileSync(publicCsvPath, 'utf-8')
const existingLines = existingCsv.split('\n').filter(line => line.trim())

// Parse existing CSV (skip header)
const existingData = new Map<string, string>()
for (let i = 1; i < existingLines.length; i++) {
	const parts = existingLines[i].split(',')
	if (parts.length >= 2) {
		const key = `${parts[0]}|${parts[1]}`
		const superbetLink = parts.slice(2).join(',') // In case there are commas in the link
		existingData.set(key, superbetLink)
	}
}

// Generate new CSV lines
const csvLines = ['Kraj,Liga,Superbet']

enabledLeagues.forEach(league => {
	const key = `${league.country}|${league.name}`
	const superbetLink = existingData.get(key) || '' // Use existing link or empty
	const line = `${league.country},${league.name},${superbetLink}`
	csvLines.push(line)
})

const csvContent = csvLines.join('\n')

// Write CSV file to public folder
fs.writeFileSync(publicCsvPath, csvContent, 'utf-8')

console.log(`\n✅ CSV file updated: ${publicCsvPath}`)
console.log(`📊 Total rows: ${csvLines.length - 1} (${enabledLeagues.length} leagues)`)
console.log(`🔗 Preserved ${existingData.size} existing Superbet links`)
