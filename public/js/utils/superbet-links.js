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
		
		// Create maps: ID -> {superbetUrl, flashscoreUrl} and normalized "Country|League" -> same (for fallback)
		const linksMapById = {}
		const linksMapByName = {}
		
		for (let i = 1; i < lines.length; i++) {
			const line = lines[i].trim()
			if (!line) continue
			
			// Split by comma - get first 5 parts: ID, Country, League, Superbet URL, Flashscore URL
			const firstComma = line.indexOf(',')
			if (firstComma === -1) continue
			
			const secondComma = line.indexOf(',', firstComma + 1)
			if (secondComma === -1) continue
			
			const thirdComma = line.indexOf(',', secondComma + 1)
			if (thirdComma === -1) continue
			
			const fourthComma = line.indexOf(',', thirdComma + 1)
			
			const id = line.substring(0, firstComma).trim()
			const country = line.substring(firstComma + 1, secondComma).trim()
			const league = line.substring(secondComma + 1, thirdComma).trim()
			const superbetUrl = line.substring(thirdComma + 1, fourthComma !== -1 ? fourthComma : undefined).trim()
			const flashscoreUrl = fourthComma !== -1 ? line.substring(fourthComma + 1).trim() : ''
			
			const linkData = {
				superbetUrl: superbetUrl && superbetUrl.startsWith('http') ? superbetUrl : null,
				flashscoreUrl: flashscoreUrl && flashscoreUrl.startsWith('http') ? flashscoreUrl : null
			}
			
			// Map by ID (primary)
			if (id) {
				linksMapById[id] = linkData
			}
			
			// Map by normalized "Country|League" (fallback for legacy code)
			if (country && league) {
				const normalizedKey = `${normalizeString(country)}|${normalizeString(league)}`
				linksMapByName[normalizedKey] = linkData
			}
		}
		
		superbetLinksCache = { byId: linksMapById, byName: linksMapByName }
		console.log('✅ Loaded league links:', Object.keys(linksMapById).length, 'leagues by ID,', Object.keys(linksMapByName).length, 'by name')
		return superbetLinksCache
	} catch (error) {
		console.error('❌ Failed to load league links:', error)
		return { byId: {}, byName: {} }
	}
}

/**
 * Get Superbet link for a specific league
 * @param {string|number} leagueNameOrId - League name (for fallback) or league ID
 * @param {string} [countryName] - Country name (only used with league name fallback)
 */
export async function getSuperbetLink(leagueNameOrId, countryName) {
	const links = await loadSuperbetLinks()
	
	// Try by ID first (if it's a number or numeric string)
	if (leagueNameOrId && !countryName && (typeof leagueNameOrId === 'number' || !isNaN(leagueNameOrId))) {
		const result = links.byId[leagueNameOrId.toString()]
		if (result && result.superbetUrl) {
			return result.superbetUrl
		}
	}
	
	// Fallback to name-based lookup if countryName is provided
	if (countryName) {
		// Hard-coded link for Primera División - Chile
		if (normalizeString(countryName) === 'chile' && normalizeString(leagueNameOrId).includes('primera')) {
			return 'https://superbet.pl/zaklady-bukmacherskie/pilka-nozna/chile/primera-division/wszystko?ct=m'
		}
		
		// Hard-coded link for Primera División - Costa Rica (with or without hyphen)
		const normalizedCountry = normalizeString(countryName).replace(/\s/g, '').replace(/-/g, '')
		if (normalizedCountry === 'costarica' && normalizeString(leagueNameOrId).includes('primera')) {
			return 'https://superbet.pl/zaklady-bukmacherskie/pilka-nozna/kostaryka/primera-division-apertura/wszystko?ct=m'
		}
		
		// Hard-coded link for Primera División - Bolivia
		if (normalizeString(countryName) === 'bolivia' && normalizeString(leagueNameOrId).includes('primera')) {
			return 'https://superbet.pl/zaklady-bukmacherskie/pilka-nozna/boliwia/liga-profesional-apertura/wszystko?ct=m'
		}
		
		const normalizedKey = `${normalizeString(countryName)}|${normalizeString(leagueNameOrId)}`
		const result = links.byName[normalizedKey]
		return result ? result.superbetUrl : null
	}
	
	return null
}

/**
 * Get Flashscore link for a specific league
 * @param {string|number} leagueNameOrId - League name (for fallback) or league ID
 * @param {string} [countryName] - Country name (only used with league name fallback)
 */
export async function getFlashscoreLink(leagueNameOrId, countryName) {
	const links = await loadSuperbetLinks()
	
	// Try by ID first (if it's a number or numeric string)
	if (leagueNameOrId && !countryName && (typeof leagueNameOrId === 'number' || !isNaN(leagueNameOrId))) {
		const result = links.byId[leagueNameOrId.toString()]
		if (result && result.flashscoreUrl) {
			return result.flashscoreUrl
		}
	}
	
	// Fallback to name-based lookup if countryName is provided
	if (countryName) {
		const normalizedKey = `${normalizeString(countryName)}|${normalizeString(leagueNameOrId)}`
		const result = links.byName[normalizedKey]
		return result ? result.flashscoreUrl : null
	}
	
	return null
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
