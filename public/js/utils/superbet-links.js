/**
 * Superbet Links Manager
 * Loads and manages links to Superbet leagues
 */

let superbetLinksCache = null

/**
 * Normalize string by removing diacritics (ó→o, ü→u, etc.) and standardizing punctuation
 */
function normalizeString(str) {
	return str
		// Fix common encoding issues (ó shown as łn, etc)
		.replace(/ałn/g, 'on')  // División incorrectly encoded
		.replace(/ałł/g, 'o')
		.normalize('NFD') // Decompose characters
		.replace(/[\u0300-\u036f]/g, '') // Remove diacritics
		.replace(/[\u2010-\u2015]/g, '-') // Normalize all dash types to hyphen
		.replace(/\s+/g, ' ') // Normalize multiple spaces to single space
		.toLowerCase()
		.trim()
}

/**
 * Load Superbet links from CSV file
 */
async function loadSuperbetLinks() {
	if (superbetLinksCache) {
		return superbetLinksCache
	}

	try {
		const response = await fetch('/Lista rozgrywek.csv')
		const text = await response.text()
		
		// Parse CSV - simple parser that handles commas in values
		const lines = text.split('\n').filter(line => line.trim())
		
		// Create map: normalized "Country|League" -> {originalKey, superbetUrl}
		const linksMap = {}
		
		for (let i = 1; i < lines.length; i++) {
			const line = lines[i].trim()
			if (!line) continue
			
			// Split by comma - get first 3 parts: Country, League, Superbet URL
			const firstComma = line.indexOf(',')
			if (firstComma === -1) continue
			
			const secondComma = line.indexOf(',', firstComma + 1)
			if (secondComma === -1) continue
			
			const country = line.substring(0, firstComma).trim()
			const league = line.substring(firstComma + 1, secondComma).trim()
			const superbetUrl = line.substring(secondComma + 1).trim()
			
			if (country && league && superbetUrl && superbetUrl.startsWith('http')) {
				// Use normalized "Country|League" as key for matching with diacritics
				const normalizedKey = `${normalizeString(country)}|${normalizeString(league)}`
				const originalKey = `${country}|${league}`
				linksMap[normalizedKey] = {
					originalKey,
					superbetUrl
				}
			}
		}
		
		superbetLinksCache = linksMap
		console.log('✅ Loaded Superbet links:', Object.keys(linksMap).length, 'leagues')
		return linksMap
	} catch (error) {
		console.error('❌ Failed to load Superbet links:', error)
		return {}
	}
}

/**
 * Get Superbet link for a specific league and country
 */
export async function getSuperbetLink(leagueName, countryName) {
	const links = await loadSuperbetLinks()
	const normalizedKey = `${normalizeString(countryName)}|${normalizeString(leagueName)}`
	const result = links[normalizedKey]
	return result ? result.superbetUrl : null
}

/**
 * Create Superbet icon HTML
 */
export function createSuperbetIcon(url) {
	return `
		<a href="${url}" target="_blank" rel="noopener noreferrer" class="superbet-icon" title="Zobacz na Superbet">
			<img src="/images/superbet.webp" alt="Superbet" />
		</a>
	`
}
