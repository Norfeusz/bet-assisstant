/**
 * UI Event Handlers
 * Functions for handling user interactions
 */

import { showToast } from '../utils/helpers.js'
import {
	state,
	setSelectedCountry,
	addConfiguredLeague,
	removeConfiguredLeague,
	clearConfiguredLeagues,
	setLeagues,
	setSelectedLimit,
	setHomeAwayFilter,
	setSelectedMatchCount,
} from '../config/state.js'
import * as API from '../api/api-client.js'

/**
 * Handle country selection
 * @param {string} country - Country name
 */
export async function selectCountry(country) {
	setSelectedCountry(country)

	// Update UI
	document.querySelectorAll('.country-item').forEach(item => {
		item.classList.remove('active')
	})
	event.target.closest('.country-item').classList.add('active')

	// Load leagues
	await loadLeagues(country)
}

/**
 * Load leagues for selected country
 * @param {string} country - Country name
 */
export async function loadLeagues(country) {
	const container = document.getElementById('leagues-list')
	container.innerHTML = '<div class="loading"><div class="spinner"></div>Loading leagues...</div>'

	try {
		const leagues = await API.loadLeagues(country)
		setLeagues(leagues)

		if (leagues.length === 0) {
			container.innerHTML = `
                <div class="empty-state">
                    <div class="empty-state-icon">😕</div>
                    <p>No leagues found for ${country}</p>
                </div>
            `
			return
		}

		const html = leagues
			.map(
				league => `
            <div class="league-item ${state.configuredLeagues.has(league.id) ? 'selected' : ''}" id="league-${
					league.id
				}">
                <input 
                    type="checkbox" 
                    class="league-checkbox" 
                    ${state.configuredLeagues.has(league.id) ? 'checked' : ''}
                    onchange="window.toggleLeague(${league.id}, '${league.name}', '${country}', '${
					league.type
				}', this.checked)"
                >
                <img src="${league.logo}" alt="${league.name}" class="league-logo" onerror="this.style.display='none'">
                <div class="league-info">
                    <div class="league-name">${league.name}</div>
                    <div class="league-type">${league.type}</div>
                </div>
            </div>
        `
			)
			.join('')

		container.innerHTML = html
	} catch (error) {
		container.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">❌</div>
                <p>Error loading leagues</p>
            </div>
        `
	}
}

/**
 * Toggle league enabled/disabled
 * @param {number} id - League ID
 * @param {string} name - League name
 * @param {string} country - Country name
 * @param {string} type - League type
 * @param {boolean} enabled - Enabled status
 */
export async function toggleLeague(id, name, country, type, enabled) {
	try {
		if (enabled) {
			await API.addLeague({
				id,
				name,
				country,
				type,
				priority: 3,
				enabled: true,
			})
			addConfiguredLeague(id)

			const league = state.leagues.find(l => l.id === id)
			if (league) league.enabled = true

			document.getElementById(`league-${id}`).classList.add('selected')
			showToast(`Dodano: ${name}`, 'success')
		} else {
			await API.removeLeague(id)
			removeConfiguredLeague(id)

			const league = state.leagues.find(l => l.id === id)
			if (league) league.enabled = false

			document.getElementById(`league-${id}`).classList.remove('selected')
			showToast(`Usunięto: ${name}`, 'success')
		}

		await updateSummary()
		await updateCountryBadges()
	} catch (error) {
		showToast('Błąd podczas aktualizacji ligi', 'error')
	}
}

/**
 * Update leagues summary
 */
export async function updateSummary() {
	try {
		const summary = await API.getLeaguesSummary()
		document.getElementById('total-leagues').textContent = summary.total
		document.getElementById('enabled-leagues').textContent = summary.enabled
		document.getElementById('disabled-leagues').textContent = summary.disabled
	} catch (error) {
		console.error('Error updating summary', error)
	}
}

/**
 * Update country badges with league counts
 */
export async function updateCountryBadges() {
	try {
		const leagues = await API.loadConfiguredLeagues()

		const counts = leagues.reduce((acc, league) => {
			acc[league.country] = (acc[league.country] || 0) + 1
			return acc
		}, {})

		Object.keys(counts).forEach(country => {
			const badge = document.getElementById(`badge-${country}`)
			if (badge) {
				badge.textContent = counts[country]
			}
		})
	} catch (error) {
		console.error('Error updating badges', error)
	}
}

/**
 * Auto-select recommended leagues
 */
export async function autoSelect() {
	if (!confirm('Auto-wybór rekomendowanych lig? Użyje to zapytań API.')) {
		return
	}

	try {
		showToast('Auto-wybieranie lig...', 'success')
		const data = await API.autoSelectLeagues()

		await loadConfiguredLeagues()
		await updateSummary()
		await updateCountryBadges()

		if (state.selectedCountry) {
			await loadLeagues(state.selectedCountry)
		}

		showToast(`Auto-wybrano ${data.leagues.length} lig`, 'success')
	} catch (error) {
		showToast('Błąd podczas auto-wybierania lig', 'error')
	}
}

/**
 * Clear all configured leagues
 */
export async function clearAll() {
	if (!confirm('Usunąć wszystkie skonfigurowane ligi?')) {
		return
	}

	try {
		const leagues = await API.loadConfiguredLeagues()

		for (const league of leagues) {
			await API.removeLeague(league.id)
		}

		clearConfiguredLeagues()
		await updateSummary()
		await updateCountryBadges()

		if (state.selectedCountry) {
			await loadLeagues(state.selectedCountry)
		}

		showToast('Wszystkie ligi wyczyszczone', 'success')
	} catch (error) {
		showToast('Błąd podczas czyszczenia lig', 'error')
	}
}

/**
 * Load configured leagues into state
 */
export async function loadConfiguredLeagues() {
	try {
		const leagues = await API.loadConfiguredLeagues()
		clearConfiguredLeagues()
		leagues.forEach(league => addConfiguredLeague(league.id))
	} catch (error) {
		showToast('Błąd podczas ładowania skonfigurowanych lig', 'error')
	}
}

/**
 * Switch between tabs
 * @param {string} tabName - Tab name to switch to
 */
export function switchTab(tabName) {
	// Hide all tab contents
	document.querySelectorAll('.tab-content').forEach(tab => {
		tab.classList.remove('active')
	})

	// Deactivate all tab buttons
	document.querySelectorAll('.tab-button').forEach(btn => {
		btn.classList.remove('active')
	})

	// Show selected tab
	document.getElementById(`tab-${tabName}`).classList.add('active')

	// Activate selected button
	event.target.classList.add('active')

	// Load data if needed
	if (tabName === 'database') {
		// Załaduj filtry asynchronicznie i obsłuż ewentualne błędy
		loadDatabaseFilters().catch(e => console.error('Błąd ładowania filtrów:', e))
	}

	if (tabName === 'bet-finder') {
		initBetFinder()
	}
}

/**
 * Set result limit for database view
 * @param {number|null} limit - Limit value or null for all
 */
export function setLimit(limit) {
	setSelectedLimit(limit)

	// Update active button
	document.querySelectorAll('.limit-btn').forEach(btn => {
		btn.classList.remove('active')
	})
	event.target.classList.add('active')
}

/**
 * Set limit and apply filters
 * @param {number|null} limit - Limit value
 */
export function setLimitAndFilter(limit) {
	setSelectedLimit(limit)

	// Update active button - find the button that was clicked
	document.querySelectorAll('.limit-btn').forEach(btn => {
		btn.classList.remove('active')
		// Check if this button's onclick matches the current limit
		const btnLimit = btn.getAttribute('onclick')?.match(/setLimitAndFilter\((\d+|null)\)/)?.[1]
		const btnLimitValue = btnLimit === 'null' ? null : parseInt(btnLimit)
		if (btnLimitValue === limit) {
			btn.classList.add('active')
		}
	})

	// Re-filter if we have matches
	if (state.lastFetchedMatches.length > 0) {
		// Import the function from app.js context
		if (typeof window.applyLimitToResults === 'function') {
			window.applyLimitToResults()
		}
	}
}

/**
 * Set home/away filter
 * @param {string} filter - Filter value ('all', 'home', 'away')
 */
export function setHomeAwayFilterHandler(filter) {
	setHomeAwayFilter(filter)

	// Re-apply filters
	if (state.lastFetchedMatches.length > 0) {
		// Import the function from app.js context
		if (typeof window.applyLimitToResults === 'function') {
			window.applyLimitToResults()
		}
	}
}

/**
 * Initialize bet finder tab
 */
export function initBetFinder() {
	console.log('🔧 initBetFinder called')

	// Set default dates (from today to 7 days ahead)
	const today = new Date()
	const nextWeek = new Date()
	nextWeek.setDate(today.getDate() + 7)

	const dateFromInput = document.getElementById('bet-finder-date-from')
	const dateToInput = document.getElementById('bet-finder-date-to')

	if (dateFromInput && dateToInput) {
		dateFromInput.valueAsDate = today
		dateToInput.valueAsDate = nextWeek
		console.log('✅ Dates set:', { from: today, to: nextWeek })
	} else {
		console.warn('⚠️ Date inputs not found')
	}

	// Add event listeners for match count buttons
	const buttons = document.querySelectorAll('.match-count-btn')
	console.log('🔘 Found match count buttons:', buttons.length)

	buttons.forEach(btn => {
		btn.addEventListener('click', function () {
			console.log('🖱️ Match count button clicked:', this.dataset.count)

			document.querySelectorAll('.match-count-btn').forEach(b => b.classList.remove('active'))
			this.classList.add('active')

			const count = this.dataset.count === 'all' ? null : parseInt(this.dataset.count)
			console.log('📊 Setting match count to:', count)
			setSelectedMatchCount(count)
		})
	})
}

/**
 * Set date range to today only
 */
export function setTodayDate() {
	const today = new Date()
	const dateFromInput = document.getElementById('bet-finder-date-from')
	const dateToInput = document.getElementById('bet-finder-date-to')

	if (dateFromInput && dateToInput) {
		dateFromInput.valueAsDate = today
		dateToInput.valueAsDate = today
		console.log('📅 Date range set to today:', today.toISOString().split('T')[0])
	}
}

/**
 * Save and close configuration
 */
export function saveAndClose() {
	showToast('Konfiguracja zapisana!', 'success')
	setTimeout(() => {
		alert('Konfiguracja zapisana! Możesz zamknąć to okno i uruchomić: npm run import')
	}, 1000)
}

// Placeholder functions - will be implemented in other modules
async function loadDatabaseFilters() {
	// Will be implemented in database module
}

async function applyLimitToResults() {
	// Will be implemented in database module
}
