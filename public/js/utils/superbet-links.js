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
		
		// Create map: normalized "Country|League" -> {originalKey, superbetUrl, flashscoreUrl}
		const linksMap = {}
		
		for (let i = 1; i < lines.length; i++) {
			const line = lines[i].trim()
			if (!line) continue
			
			// Split by comma - get first 4 parts: Country, League, Superbet URL, Flashscore URL
			const firstComma = line.indexOf(',')
			if (firstComma === -1) continue
			
			const secondComma = line.indexOf(',', firstComma + 1)
			if (secondComma === -1) continue
			
			const thirdComma = line.indexOf(',', secondComma + 1)
			
			const country = line.substring(0, firstComma).trim()
			const league = line.substring(firstComma + 1, secondComma).trim()
			const superbetUrl = line.substring(secondComma + 1, thirdComma !== -1 ? thirdComma : undefined).trim()
			const flashscoreUrl = thirdComma !== -1 ? line.substring(thirdComma + 1).trim() : ''
			
			if (country && league) {
				// Use normalized "Country|League" as key for matching with diacritics
				const normalizedKey = `${normalizeString(country)}|${normalizeString(league)}`
				const originalKey = `${country}|${league}`
				linksMap[normalizedKey] = {
					originalKey,
					superbetUrl: superbetUrl && superbetUrl.startsWith('http') ? superbetUrl : null,
					flashscoreUrl: flashscoreUrl && flashscoreUrl.startsWith('http') ? flashscoreUrl : null
				}
			}
		}
		
		superbetLinksCache = linksMap
		console.log('✅ Loaded league links:', Object.keys(linksMap).length, 'leagues')
		return linksMap
	} catch (error) {
		console.error('❌ Failed to load league links:', error)
		return {}
	}
}

/**
 * Get Superbet link for a specific league and country
 */
export async function getSuperbetLink(leagueName, countryName) {
	// Hard-coded link for Primera División - Chile
	if (normalizeString(countryName) === 'chile' && normalizeString(leagueName).includes('primera')) {
		return 'https://superbet.pl/zaklady-bukmacherskie/pilka-nozna/chile/primera-division/wszystko?ct=m'
	}
	
	// Hard-coded link for Primera División - Costa Rica (with or without hyphen)
	const normalizedCountry = normalizeString(countryName).replace(/\s/g, '').replace(/-/g, '')
	if (normalizedCountry === 'costarica' && normalizeString(leagueName).includes('primera')) {
		return 'https://superbet.pl/zaklady-bukmacherskie/pilka-nozna/kostaryka/primera-division-apertura/wszystko?ct=m'
	}
	
	// Hard-coded link for Primera División - Bolivia
	if (normalizeString(countryName) === 'bolivia' && normalizeString(leagueName).includes('primera')) {
		return 'https://superbet.pl/zaklady-bukmacherskie/pilka-nozna/boliwia/liga-profesional-apertura/wszystko?ct=m'
	}
	
	const links = await loadSuperbetLinks()
	const normalizedKey = `${normalizeString(countryName)}|${normalizeString(leagueName)}`
	const result = links[normalizedKey]
	return result ? result.superbetUrl : null
}

/**
 * Get Flashscore link for a specific league and country
 */
export async function getFlashscoreLink(leagueName, countryName) {
	const links = await loadSuperbetLinks()
	const normalizedKey = `${normalizeString(countryName)}|${normalizeString(leagueName)}`
	const result = links[normalizedKey]
	return result ? result.flashscoreUrl : null
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

/**
 * Create Flashscore button HTML
 */
export function createFlashscoreButton(url) {
	return `
		<a href="${url}" target="_blank" rel="noopener noreferrer" 
			class="btn-small" 
			style="background: linear-gradient(135deg, #f97316 0%, #ea580c 100%); color: white; padding: 8px 16px; border-radius: 6px; text-decoration: none; font-size: 14px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"
			title="Zobacz na Flashscore">
			⚡ Flashscore
		</a>
	`
}
