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

// Generate CSV
const csvLines = ['Kraj,Liga,ID']

enabledLeagues.forEach(league => {
	const line = `${league.country},${league.name},${league.id}`
	csvLines.push(line)
})

const csvContent = csvLines.join('\n')

// Write CSV file
const csvPath = path.join(process.cwd(), 'Lista rozgrywek.csv')
fs.writeFileSync(csvPath, csvContent, 'utf-8')

console.log(`\n✅ CSV file updated: ${csvPath}`)
console.log(`📊 Total rows: ${csvLines.length - 1} (${enabledLeagues.length} leagues)`)
