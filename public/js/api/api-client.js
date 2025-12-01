/**
 * API Client
 * All API communication functions
 */

import { showToast } from '../utils/helpers.js'
import { state, setLeagues } from '../config/state.js'

/**
 * Load all available countries
 * @returns {Promise<Array>} Array of countries
 */
export async function loadCountries() {
	try {
		const response = await fetch('/api/countries')
		const countries = await response.json()
		return countries
	} catch (error) {
		showToast('Błąd podczas ładowania krajów', 'error')
		throw error
	}
}

/**
 * Load leagues for a specific country
 * @param {string} country - Country name
 * @returns {Promise<Array>} Array of leagues
 */
export async function loadLeagues(country) {
	try {
		const response = await fetch(`/api/countries/${encodeURIComponent(country)}/leagues`)
		const leagues = await response.json()

		// Update global leagues array
		setLeagues(leagues)

		// Add enabled property based on configuredLeagues
		leagues.forEach(league => {
			league.enabled = state.configuredLeagues.has(league.id)
		})

		return leagues
	} catch (error) {
		showToast('Błąd podczas ładowania lig', 'error')
		throw error
	}
}

/**
 * Add a league to configuration
 * @param {Object} leagueData - League data
 * @returns {Promise<Object>} Response data
 */
export async function addLeague(leagueData) {
	try {
		const response = await fetch('/api/leagues', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify(leagueData),
		})
		return await response.json()
	} catch (error) {
		showToast('Błąd podczas dodawania ligi', 'error')
		throw error
	}
}

/**
 * Remove a league from configuration
 * @param {number} leagueId - League ID
 * @returns {Promise<void>}
 */
export async function removeLeague(leagueId) {
	try {
		await fetch(`/api/leagues/${leagueId}`, { method: 'DELETE' })
	} catch (error) {
		showToast('Błąd podczas usuwania ligi', 'error')
		throw error
	}
}

/**
 * Load configured leagues
 * @returns {Promise<Array>} Array of configured leagues
 */
export async function loadConfiguredLeagues() {
	try {
		const response = await fetch('/api/leagues/configured')
		const leagues = await response.json()
		return leagues
	} catch (error) {
		showToast('Błąd podczas ładowania skonfigurowanych lig', 'error')
		throw error
	}
}

/**
 * Get leagues summary
 * @returns {Promise<Object>} Summary object with total, enabled, disabled counts
 */
export async function getLeaguesSummary() {
	try {
		const response = await fetch('/api/leagues/summary')
		const summary = await response.json()
		return summary
	} catch (error) {
		console.error('Error getting summary', error)
		throw error
	}
}

/**
 * Auto-select recommended leagues
 * @returns {Promise<Object>} Response with selected leagues
 */
export async function autoSelectLeagues() {
	try {
		const response = await fetch('/api/leagues/auto-select', { method: 'POST' })
		const data = await response.json()
		return data
	} catch (error) {
		showToast('Błąd podczas auto-wybierania lig', 'error')
		throw error
	}
}

/**
 * Start or resume import
 * @param {Object} params - Import parameters
 * @returns {Promise<Object>} Import result
 */
export async function startImport(params) {
	try {
		const response = await fetch('/api/import', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify(params),
		})
		const result = await response.json()
		return result
	} catch (error) {
		showToast('Błąd importu. Sprawdź konsolę serwera aby zobaczyć szczegóły.', 'error')
		throw error
	}
}

/**
 * Get import status
 * @returns {Promise<Object>} Import status
 */
export async function getImportStatus() {
	try {
		const response = await fetch('/api/import/status')
		const status = await response.json()
		return status
	} catch (error) {
		throw error
	}
}

/**
 * Stop import (pause)
 * @returns {Promise<Object>} Response data
 */
export async function stopImport() {
	try {
		const response = await fetch('/api/import/stop', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
		})
		const data = await response.json()
		return data
	} catch (error) {
		showToast('Błąd podczas zatrzymywania importu', 'error')
		throw error
	}
}

/**
 * Cancel import (clear state)
 * @returns {Promise<Object>} Response data
 */
export async function cancelImport() {
	try {
		const response = await fetch('/api/import/cancel', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
		})
		const data = await response.json()
		return data
	} catch (error) {
		showToast('Błąd podczas kończenia importu', 'error')
		throw error
	}
}

/**
 * Load all presets
 * @returns {Promise<Array>} Array of presets
 */
export async function loadPresets() {
	try {
		const response = await fetch('/api/presets')
		const presets = await response.json()
		return presets
	} catch (error) {
		showToast('Błąd podczas ładowania szablonów', 'error')
		throw error
	}
}

/**
 * Save a preset
 * @param {Object} presetData - Preset data
 * @returns {Promise<Object>} Response data
 */
export async function savePreset(presetData) {
	try {
		const response = await fetch('/api/presets', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify(presetData),
		})
		const data = await response.json()
		return data
	} catch (error) {
		showToast('Błąd podczas zapisywania szablonu', 'error')
		throw error
	}
}

/**
 * Load a preset
 * @param {string} name - Preset name
 * @returns {Promise<Object>} Response data
 */
export async function loadPreset(name) {
	try {
		const response = await fetch(`/api/presets/${encodeURIComponent(name)}/load`, {
			method: 'POST',
		})
		const data = await response.json()
		return data
	} catch (error) {
		showToast('Błąd podczas ładowania szablonu', 'error')
		throw error
	}
}

/**
 * Delete a preset
 * @param {string} name - Preset name
 * @returns {Promise<Object>} Response data
 */
export async function deletePreset(name) {
	try {
		const response = await fetch(`/api/presets/${encodeURIComponent(name)}`, {
			method: 'DELETE',
		})
		const data = await response.json()
		return data
	} catch (error) {
		showToast('Błąd podczas usuwania szablonu', 'error')
		throw error
	}
}

/**
 * Load database countries
 * @returns {Promise<Array>} Array of countries
 */
export async function loadDatabaseCountries() {
	try {
		const response = await fetch('/api/database/countries')
		if (!response.ok) throw new Error('Failed to load countries')
		const countries = await response.json()
		return countries
	} catch (error) {
		showToast('Nie udało się załadować krajów: ' + error.message, 'error')
		throw error
	}
}

/**
 * Load database leagues
 * @param {string} country - Optional country filter
 * @returns {Promise<Array>} Array of leagues
 */
export async function loadDatabaseLeagues(country = null) {
	try {
		const url = country ? `/api/database/leagues?country=${encodeURIComponent(country)}` : '/api/database/leagues'
		const response = await fetch(url)
		if (!response.ok) throw new Error('Failed to load leagues')
		const leagues = await response.json()
		return leagues
	} catch (error) {
		showToast('Nie udało się załadować lig: ' + error.message, 'error')
		throw error
	}
}

/**
 * Load database teams
 * @param {Object} filters - Optional filters (country, league)
 * @returns {Promise<Array>} Array of teams
 */
export async function loadDatabaseTeams(filters = {}) {
	try {
		const params = new URLSearchParams()
		if (filters.country) params.append('country', filters.country)
		if (filters.league) params.append('league', filters.league)

		const url = `/api/database/teams${params.toString() ? '?' + params.toString() : ''}`
		const response = await fetch(url)
		if (!response.ok) throw new Error('Failed to load teams')
		const teams = await response.json()
		return teams
	} catch (error) {
		showToast('Nie udało się załadować drużyn: ' + error.message, 'error')
		throw error
	}
}

/**
 * Load matches from database
 * @param {Object} filters - Filters (country, league, team)
 * @returns {Promise<Array>} Array of matches
 */
export async function loadDatabaseMatches(filters = {}) {
	try {
		const params = new URLSearchParams()
		if (filters.country) params.append('country', filters.country)
		if (filters.league) params.append('league', filters.league)
		if (filters.team) params.append('team', filters.team)

		const url = `/api/database/matches${params.toString() ? '?' + params.toString() : ''}`
		console.log('🌐 API Request:', url, 'Filters:', filters)
		const response = await fetch(url)
		if (!response.ok) throw new Error('Failed to load matches')
		const matches = await response.json()
		console.log(`✅ API Response: ${matches.length} matches`, matches.slice(0, 3))
		return matches
	} catch (error) {
		showToast('Nie udało się załadować meczów: ' + error.message, 'error')
		throw error
	}
}

/**
 * Load single match details by ID
 * @param {number} matchId - Match ID
 * @returns {Promise<Object>} Match details
 */
export async function loadMatchDetails(matchId) {
	try {
		const response = await fetch(`/api/database/matches/${matchId}`)
		if (!response.ok) throw new Error('Failed to load match details')
		const match = await response.json()
		return match
	} catch (error) {
		showToast('Nie udało się załadować szczegółów meczu: ' + error.message, 'error')
		throw error
	}
}

/**
 * Find matches for bet finder
 * @param {Object} criteria - Search criteria
 * @returns {Promise<Array>} Array of matching results
 */
export async function findBetMatches(criteria) {
	try {
		const response = await fetch('/api/bet-finder/matches', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify(criteria),
		})
		if (!response.ok) throw new Error('Search failed')
		const results = await response.json()
		return results
	} catch (error) {
		showToast('Błąd podczas wyszukiwania: ' + error.message, 'error')
		throw error
	}
}

/**
 * Load background jobs
 * @param {boolean} showHidden - Show hidden jobs
 * @returns {Promise<Array>} Array of jobs
 */
export async function loadBackgroundJobs(showHidden = false) {
	try {
		const url = showHidden ? '/api/import-jobs?showHidden=true' : '/api/import-jobs'
		const response = await fetch(url)
		const jobs = await response.json()
		return jobs
	} catch (error) {
		showToast('Błąd podczas ładowania zadań', 'error')
		throw error
	}
}

/**
 * Create background job
 * @param {Object} jobData - Job parameters
 * @returns {Promise<Object>} Created job
 */
export async function createBackgroundJob(jobData) {
	try {
		const response = await fetch('/api/import-jobs', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify(jobData),
		})
		const data = await response.json()
		return data
	} catch (error) {
		showToast('Błąd podczas tworzenia zadania', 'error')
		throw error
	}
}

/**
 * Pause a background job
 * @param {number} jobId - Job ID
 * @returns {Promise<Object>} Response data
 */
export async function pauseJob(jobId) {
	try {
		const response = await fetch(`/api/import-jobs/${jobId}/pause`, {
			method: 'POST',
		})
		const data = await response.json()
		return data
	} catch (error) {
		showToast('Błąd podczas pauzowania zadania', 'error')
		throw error
	}
}

/**
 * Resume a background job
 * @param {number} jobId - Job ID
 * @returns {Promise<Object>} Response data
 */
export async function resumeJob(jobId) {
	try {
		const response = await fetch(`/api/import-jobs/${jobId}/resume`, {
			method: 'POST',
		})
		const data = await response.json()
		return data
	} catch (error) {
		showToast('Błąd podczas wznawiania zadania', 'error')
		throw error
	}
}

/**
 * Retry a failed job
 * @param {number} jobId - Job ID
 * @returns {Promise<Object>} Response data
 */
export async function retryJob(jobId) {
	try {
		const response = await fetch(`/api/import-jobs/${jobId}/retry`, {
			method: 'POST',
		})
		const data = await response.json()
		return data
	} catch (error) {
		showToast('Błąd podczas ponawiania zadania', 'error')
		throw error
	}
}

/**
 * Get job logs
 * @param {number} jobId - Job ID
 * @returns {Promise<Array>} Array of log entries
 */
export async function getJobLogs(jobId) {
	try {
		const response = await fetch(`/api/import-jobs/${jobId}/logs`)
		const logs = await response.json()
		return logs
	} catch (error) {
		showToast('Błąd podczas ładowania logów', 'error')
		throw error
	}
}

/**
 * Hide a job
 * @param {number} jobId - Job ID
 * @returns {Promise<Object>} Response data
 */
export async function hideJob(jobId) {
	try {
		const response = await fetch(`/api/import-jobs/${jobId}/hide`, {
			method: 'POST',
		})
		const data = await response.json()
		return data
	} catch (error) {
		showToast('Błąd podczas ukrywania zadania', 'error')
		throw error
	}
}

/**
 * Unhide a job
 * @param {number} jobId - Job ID
 * @returns {Promise<Object>} Response data
 */
export async function unhideJob(jobId) {
	try {
		const response = await fetch(`/api/import-jobs/${jobId}/unhide`, {
			method: 'POST',
		})
		const data = await response.json()
		return data
	} catch (error) {
		showToast('Błąd podczas pokazywania zadania', 'error')
		throw error
	}
}

/**
 * Delete a job
 * @param {number} jobId - Job ID
 * @returns {Promise<Object>} Response data
 */
export async function deleteJob(jobId) {
	try {
		const response = await fetch(`/api/import-jobs/${jobId}`, {
			method: 'DELETE',
		})
		const data = await response.json()
		return data
	} catch (error) {
		showToast('Błąd podczas usuwania zadania', 'error')
		throw error
	}
}

/**
 * Update rate limit display
 * @returns {Promise<void>}
 */
export async function updateRateLimit() {
	try {
		const response = await fetch('/api/rate-limit')
		const data = await response.json()

		const remaining = data.remaining
		const total = data.limit
		const resetTime = new Date(data.resetTime)

		const remainingEl = document.getElementById('rate-limit-remaining')
		const totalEl = document.getElementById('rate-limit-total')
		const resetEl = document.getElementById('rate-limit-reset')
		const progressBar = document.getElementById('rate-limit-bar')

		// Only update if elements exist
		if (remainingEl) remainingEl.textContent = remaining
		if (totalEl) totalEl.textContent = total
		if (resetEl) resetEl.textContent = resetTime.toLocaleTimeString('pl-PL')

		// Update progress bar
		if (progressBar) {
			const percentage = (remaining / total) * 100
			progressBar.style.width = `${percentage}%`

			if (percentage < 20) {
				progressBar.style.background = 'linear-gradient(135deg, #dc2626, #ef4444)'
			} else if (percentage < 50) {
				progressBar.style.background = 'linear-gradient(135deg, #f59e0b, #fbbf24)'
			} else {
				progressBar.style.background = 'linear-gradient(135deg, #10b981, #34d399)'
			}
		}
	} catch (error) {
		console.error('Error updating rate limit:', error)
	}
}
