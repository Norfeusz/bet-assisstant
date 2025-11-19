/**
 * Refresh background jobs list
 */
let showHiddenJobs = false

async function refreshBackgroundJobs() {
	const container = document.getElementById('background-jobs-list')
	if (!container) return

	try {
		const jobs = await API.loadBackgroundJobs(showHiddenJobs)

		if (!jobs || jobs.length === 0) {
			container.innerHTML =
				'<p style="text-align: center; color: #999; padding: 40px;">📭 Brak zadań do wyświetlenia</p>'
			return
		}

		let html = ''
		let hasActiveJobs = false

		jobs.forEach(job => {
			const createdAt = new Date(job.created_at).toLocaleString('pl-PL')
			const dateFrom = new Date(job.date_from).toLocaleDateString('pl-PL')
			const dateTo = new Date(job.date_to).toLocaleDateString('pl-PL')
			const leagues = typeof job.leagues === 'string' ? JSON.parse(job.leagues) : job.leagues
			const progress = job.progress ? (typeof job.progress === 'string' ? JSON.parse(job.progress) : job.progress) : {}

			const completedLeagues = progress.completed_leagues || []
			const totalLeagues = leagues.length
			const progressPercent = totalLeagues > 0 ? Math.round((completedLeagues.length / totalLeagues) * 100) : 0

			const statusClass = `job-status-${job.status}`
			const statusText =
				{
					pending: 'Oczekuje',
					running: 'W trakcie',
					paused: 'Wstrzymane',
					completed: 'Zakończone',
					failed: 'Błąd',
					rate_limited: 'Limit API',
				}[job.status] || job.status

			if (job.status === 'running' || job.status === 'rate_limited') {
				hasActiveJobs = true
			}

			html += `
                <div class="job-card">
                    <div class="job-header">
                        <div class="job-title">Zadanie #${job.id}</div>
                        <span class="job-status-badge ${statusClass}">${statusText}</span>
                    </div>
                    
                    <div class="job-info">
                        <div>📅 Utworzone: ${createdAt}</div>
                        <div>📆️ Zakres: ${dateFrom} → ${dateTo}</div>
                        <div>🏆 Ligi: ${totalLeagues}</div>
                        <div>✅ Ukończone ligi: ${completedLeagues.length}/${totalLeagues}</div>
                    </div>
                    
                    ${
											job.status === 'running' || job.status === 'paused' || job.status === 'rate_limited'
												? `
                        <div class="job-progress">
                            <div>Postęp: ${progressPercent}%</div>
                            <div class="job-progress-bar-container">
                                <div class="job-progress-bar" style="width: ${progressPercent}%">
                                    ${progressPercent}%
                                </div>
                            </div>
                        </div>
                    `
												: ''
										}
                    
                    ${
											job.error_message
												? `
                        <div style="background: #ffebee; border-left: 4px solid #d32f2f; padding: 10px; margin-top: 10px; border-radius: 4px;">
                            <strong>Błąd:</strong> ${job.error_message}
                        </div>
                    `
												: ''
										}
                    
                    ${
											job.status === 'rate_limited' && job.rate_limit_reset_at
												? `
                        <div style="background: #fff3e0; border-left: 4px solid #f57c00; padding: 10px; margin-top: 10px; border-radius: 4px;">
                            ⏱️ Wznowienie po: ${new Date(job.rate_limit_reset_at).toLocaleString('pl-PL')}
                        </div>
                    `
												: ''
										}
                    
                    <div class="job-actions">
                        ${
													job.status === 'running' || job.status === 'pending'
														? `
                            <button class="job-action-btn" onclick="pauseJob(${job.id})">⏸️ Wstrzymaj</button>
                        `
														: ''
												}
                        ${
													job.status === 'rate_limited'
														? `
                            <button class="job-action-btn" style="background: #f57c00; color: white;" onclick="retryJob(${job.id})" title="Wymuś próbę importu - sprawdzi limit API i spróbuje wznowić">🔄 Retry Now</button>
                            <button class="job-action-btn" onclick="pauseJob(${job.id})">⏸️ Wstrzymaj</button>
                        `
														: ''
												}
                        ${
													job.status === 'paused'
														? `
                            <button class="job-action-btn" onclick="resumeJob(${job.id})">▶️ Wznów</button>
                        `
														: ''
												}
                        <button class="job-action-btn" onclick="viewJobLogs(${job.id})">📄 Logi</button>
                        ${
													showHiddenJobs
														? `
                            <button class="job-action-btn" onclick="unhideJob(${job.id})" title="Przywróć zadanie na listę">↩️ Przywróć</button>
                        `
														: `
                            <button class="job-action-btn" onclick="hideJob(${job.id})" title="Ukryj zadanie z listy">👁️ Ukryj</button>
                        `
												}
                        ${
													job.status !== 'running' && job.status !== 'pending'
														? `
                            <button class="job-action-btn danger" onclick="deleteJob(${job.id})" title="Usuń zadanie (nieodwracalne)">🗑️ Usuń</button>
                        `
														: ''
												}
                    </div>
                </div>
            `
		})

		container.innerHTML = html

		// Manage auto-refresh
		if (hasActiveJobs && !state.backgroundJobsInterval) {
			state.backgroundJobsInterval = setInterval(refreshBackgroundJobs, 5000)
		} else if (!hasActiveJobs && state.backgroundJobsInterval) {
			clearInterval(state.backgroundJobsInterval)
			state.backgroundJobsInterval = null
		}
	} catch (error) {
		console.error('Error refreshing jobs:', error)
		container.innerHTML =
			'<p style="color: #d32f2f; text-align: center; padding: 20px;">⚠️ Błąd podczas ładowania zadań</p>'
	}
}
/**
 * Main Application Entry Point
 * Imports all modules and initializes the application
 */

// Import utilities
import { showToast, validateDateRange, setQuickDate, filterSelectOptions } from './utils/helpers.js'
import * as Storage from './utils/storage.js'
import * as Statistics from './utils/statistics.js'

// Import state management
import { state } from './config/state.js'

// Import API client
import * as API from './api/api-client.js'

// Import UI handlers
import * as EventHandlers from './ui/event-handlers.js'
import * as DOMUtils from './ui/dom-utils.js'

// Import bet finder functions
import * as BetFinder from './bet-finder.js'

// Import search queue module
import './search-queue.js'

// Import watched matches module
import * as WatchedMatches from './watched-matches.js'

/**
 * Initialize the application
 */
async function init() {
	console.log('🚀 Initializing Bet Assistant...')

	try {
		// Update rate limit on load
		await API.updateRateLimit()

		// Set up rate limit refresh interval (every 30 seconds)
		setInterval(() => {
			API.updateRateLimit()
		}, 30000)

		// Load countries
		const countries = await API.loadCountries()
		DOMUtils.renderCountries(countries)

		// Load configured leagues into state
		await EventHandlers.loadConfiguredLeagues()

		// Update summary
		await EventHandlers.updateSummary()

		// Update country badges
		await EventHandlers.updateCountryBadges()

		// Check for incomplete import
		await checkIncompleteImport()

		// Załaduj filtry bazy danych na starcie
		await loadDatabaseFilters()

		// Załaduj zadania w tle na starcie
		await refreshBackgroundJobs()

		// Inicjalizuj bet finder (ustawia domyślne daty i event listenery)
		EventHandlers.initBetFinder()

		// Load watched matches and show card
		WatchedMatches.loadWatchedMatches()

		// Load minimized match details cards
		loadMinimizedMatchCards()

		// Load minimized TOP 10 modals
		loadMinimizedModals()
		WatchedMatches.ensureWatchedMatchesCard() // Show minimized card only

		console.log('✅ Application initialized successfully')
	} catch (error) {
		console.error('❌ Error initializing application:', error)
		showToast('Błąd podczas inicjalizacji aplikacji', 'error')
	}
}
// Background jobs refresh handler
window.refreshBackgroundJobs = refreshBackgroundJobs

/**
 * Check for incomplete import and show resume button
 */
async function checkIncompleteImport() {
	try {
		const status = await API.getImportStatus()

		if (status.hasIncomplete) {
			document.getElementById('resume-btn').style.display = 'inline-block'
			showToast('Znaleziono wstrzymany import. Możesz go wznowić.', 'info')
		} else {
			document.getElementById('resume-btn').style.display = 'none'
		}
	} catch (error) {
		console.error('Error checking import status:', error)
	}
}

// =============================================================================
// IMPORT & PRESETS HANDLERS
// =============================================================================

/**
 * Show import dialog
 */
async function showImportDialog() {
	const enabled = await API.getLeaguesSummary()

	if (enabled.enabled === 0) {
		showToast('Proszę najpierw wybrać przynajmniej jedną ligę', 'error')
		return
	}

	document.getElementById('league-count').textContent = enabled.enabled

	// Set default dates (last 2 weeks)
	const endDate = new Date()
	const startDate = new Date()
	startDate.setDate(startDate.getDate() - 14)

	document.getElementById('end-date').value = endDate.toISOString().split('T')[0]
	document.getElementById('start-date').value = startDate.toISOString().split('T')[0]

	document.getElementById('import-modal').classList.add('show')
}

/**
 * Close import dialog
 */
function closeImportDialog() {
	document.getElementById('import-modal').classList.remove('show')
}

/**
 * Start import
 */
async function startImport() {
	const startDate = document.getElementById('start-date').value
	const endDate = document.getElementById('end-date').value

	if (!startDate || !endDate) {
		showToast('Proszę wybrać datę początkową i końcową', 'error')
		return
	}

	if (new Date(startDate) > new Date(endDate)) {
		showToast('Data początkowa musi być przed datą końcową', 'error')
		return
	}

	await executeImport({ startDate, endDate, resume: false })
}

/**
 * Resume import
 */
async function resumeImport() {
	if (!confirm('Wznowić wstrzymany import?')) {
		return
	}

	await executeImport({ resume: true })
}

/**
 * Execute import
 */
async function executeImport(params) {
	closeImportDialog()
	document.getElementById('progress-modal').classList.add('show')
	document.getElementById('progress-text').textContent = params.resume
		? 'Wznawianie importu...'
		: 'Rozpoczynam import z automatycznym ponowieniem...'
	document.getElementById('progress-fill').style.width = '10%'

	try {
		params.autoRetry = true

		const result = await API.startImport(params)

		if (result.success) {
			document.getElementById('progress-fill').style.width = '30%'
			document.getElementById('progress-text').textContent = 'Import w toku z automatycznym ponowieniem...'

			showToast('Import rozpoczęty! Będzie kontynuowany w tle z automatycznym ponowieniem.', 'success')

			// Poll for completion
			let checkCount = 0
			const checkInterval = setInterval(async () => {
				checkCount++

				try {
					const status = await API.getImportStatus()

					if (!status.hasIncomplete || checkCount > 1000) {
						clearInterval(checkInterval)

						if (!status.hasIncomplete) {
							document.getElementById('progress-fill').style.width = '100%'
							document.getElementById('progress-text').textContent = 'Import zakończony pomyślnie!'

							setTimeout(() => {
								document.getElementById('progress-modal').classList.remove('show')
								document.getElementById('resume-btn').style.display = 'none'
								showToast('Wszystkie mecze zaimportowane pomyślnie!', 'success')
							}, 2000)
						}
					} else {
						const progress = status.progress || 30
						document.getElementById('progress-fill').style.width = `${progress}%`

						let statusText = `Importing... ${progress}% (${status.state.matchesImported} matches)`
						if (status.state.error?.includes('waiting')) {
							statusText = `⏰ Waiting for rate limit... (${status.state.matchesImported} matches imported)`
						}

						document.getElementById('progress-text').textContent = statusText
					}
				} catch (error) {
					// Continue checking
				}
			}, 10000)
		} else {
			throw new Error('Import failed')
		}
	} catch (error) {
		document.getElementById('progress-modal').classList.remove('show')
		showToast('Błąd importu. Sprawdź konsolę serwera aby zobaczyć szczegóły.', 'error')
		await checkIncompleteImport()
	}
}

/**
 * Close progress dialog
 */
function closeProgressDialog() {
	document.getElementById('progress-modal').classList.remove('show')
	showToast('Import kontynuowany w tle z automatycznym ponowieniem', 'success')
}

/**
 * Stop import
 */
async function stopImport() {
	if (!confirm('Zatrzymać import? Możesz go wznowić później.')) {
		return
	}

	try {
		const data = await API.stopImport()

		if (data.success) {
			showToast('Import zostanie zatrzymany po aktualnej lidze', 'info')
			document.getElementById('progress-modal').classList.remove('show')
		}
	} catch (error) {
		showToast('Błąd podczas zatrzymywania importu', 'error')
	}
}

/**
 * Cancel import
 */
async function cancelImport() {
	if (!confirm('Zakończyć import i wyczyścić stan? Nie będzie można wznowić.')) {
		return
	}

	try {
		const data = await API.cancelImport()

		if (data.success) {
			showToast('Import został zakończony', 'success')
			document.getElementById('progress-modal').classList.remove('show')
			await checkIncompleteImport()
		}
	} catch (error) {
		showToast('Błąd podczas kończenia importu', 'error')
	}
}

// =============================================================================
// PRESET HANDLERS
// =============================================================================

/**
 * Show save preset dialog
 */
function showSavePresetDialog() {
	const enabled = state.leagues.filter(l => l.enabled)
	if (enabled.length === 0) {
		showToast('Proszę najpierw wybrać przynajmniej jedną ligę', 'error')
		return
	}
	document.getElementById('save-preset-modal').classList.add('show')
	document.getElementById('preset-name').value = ''
	document.getElementById('preset-description').value = ''
}

/**
 * Close save preset dialog
 */
function closeSavePresetDialog() {
	document.getElementById('save-preset-modal').classList.remove('show')
}

/**
 * Save preset
 */
async function savePreset() {
	const name = document.getElementById('preset-name').value.trim()
	const description = document.getElementById('preset-description').value.trim()

	if (!name) {
		showToast('Proszę podać nazwę szablonu', 'error')
		return
	}

	const enabled = state.leagues.filter(l => l.enabled)
	const leagueIds = enabled.map(l => l.id)

	try {
		const data = await API.savePreset({ name, description, leagueIds })

		if (data.success) {
			showToast(`Szablon "${name}" zapisany pomyślnie!`, 'success')
			closeSavePresetDialog()
		} else {
			showToast('Nie udało się zapisać szablonu', 'error')
		}
	} catch (error) {
		showToast('Błąd podczas zapisywania szablonu', 'error')
	}
}

/**
 * Show load preset dialog
 */
async function showLoadPresetDialog() {
	try {
		const presets = await API.loadPresets()
		DOMUtils.renderPresetsList(presets)
		document.getElementById('load-preset-modal').classList.add('show')
	} catch (error) {
		showToast('Błąd podczas ładowania szablonów', 'error')
	}
}

/**
 * Close load preset dialog
 */
function closeLoadPresetDialog() {
	document.getElementById('load-preset-modal').classList.remove('show')
}

/**
 * Load a preset
 */
async function loadPreset(name) {
	console.log('🔄 Loading preset:', name)

	try {
		const data = await API.loadPreset(name)

		if (data.success) {
			showToast(
				`Szablon "${name}" wczytany! (${data.stats.enabled} włączonych, ${data.stats.added} dodanych)`,
				'success'
			)
			closeLoadPresetDialog()

			await EventHandlers.loadConfiguredLeagues()
			await EventHandlers.updateSummary()
			await EventHandlers.updateCountryBadges()

			if (state.selectedCountry) {
				await EventHandlers.loadLeagues(state.selectedCountry)
			}
		} else {
			showToast('Nie udało się wczytać szablonu', 'error')
		}
	} catch (error) {
		console.error('❌ Error loading preset:', error)
		showToast('Błąd podczas ładowania szablonu', 'error')
	}
}

/**
 * Delete a preset
 */
async function deletePreset(name) {
	if (!confirm(`Usunąć szablon "${name}"?`)) {
		return
	}

	try {
		const data = await API.deletePreset(name)

		if (data.success) {
			showToast(`Szablon "${name}" usunięty`, 'success')
			showLoadPresetDialog() // Refresh list
		} else {
			showToast('Nie udało się usunąć szablonu', 'error')
		}
	} catch (error) {
		showToast('Błąd podczas usuwania szablonu', 'error')
	}
}

// =============================================================================
// DATABASE FILTERS
// =============================================================================

/**
 * Load database filters
 */
async function loadDatabaseFilters() {
	try {
		const countries = await API.loadDatabaseCountries()
		const leagues = await API.loadDatabaseLeagues()
		const teams = await API.loadDatabaseTeams()

		// Store in state
		state.databaseCountries = countries
		state.databaseLeagues = leagues
		state.databaseTeams = teams

		// Populate dropdowns
		const countrySelect = document.getElementById('filter-country')
		countrySelect.innerHTML = '<option value="">Wszystkie Kraje</option>'
		countries.forEach(country => {
			const option = document.createElement('option')
			option.value = country
			option.textContent = country
			countrySelect.appendChild(option)
		})

		const leagueSelect = document.getElementById('filter-league')
		leagueSelect.innerHTML = '<option value="">Wszystkie Ligi</option>'
		leagues.forEach(league => {
			const option = document.createElement('option')
			// league is now an object with {id, name, country}
			const leagueName = typeof league === 'object' ? league.name : league
			option.value = leagueName
			option.textContent = leagueName
			leagueSelect.appendChild(option)
		})

		const teamSelect = document.getElementById('filter-team')
		teamSelect.innerHTML = '<option value="">Wszystkie Drużyny</option>'
		teams.forEach(team => {
			const option = document.createElement('option')
			option.value = team
			option.textContent = team
			teamSelect.appendChild(option)
		})
	} catch (error) {
		console.error('Error loading database filters:', error)
		showToast('Nie udało się załadować filtrów: ' + error.message, 'error')
	}
}

/**
 * Handle country filter change
 */
async function onCountryFilterChange() {
	const country = document.getElementById('filter-country').value

	document.getElementById('filter-league').value = ''
	document.getElementById('filter-team').value = ''

	if (!country) {
		await loadDatabaseFilters()
		return
	}

	try {
		const leagues = await API.loadDatabaseLeagues(country)
		const teams = await API.loadDatabaseTeams({ country })

		const leagueSelect = document.getElementById('filter-league')
		leagueSelect.innerHTML = '<option value="">Wszystkie Ligi</option>'
		leagues.forEach(league => {
			const option = document.createElement('option')
			// league is now an object with {id, name, country}
			const leagueName = typeof league === 'object' ? league.name : league
			option.value = leagueName
			option.textContent = leagueName
			leagueSelect.appendChild(option)
		})

		const teamSelect = document.getElementById('filter-team')
		teamSelect.innerHTML = '<option value="">Wszystkie Drużyny</option>'
		teams.forEach(team => {
			const option = document.createElement('option')
			option.value = team
			option.textContent = team
			teamSelect.appendChild(option)
		})

		console.log('✅ Loaded', leagues.length, 'leagues and', teams.length, 'teams for', country)
	} catch (error) {
		console.error('Error loading leagues/teams:', error)
		showToast('Nie udało się załadować lig/drużyn: ' + error.message, 'error')
	}
}

/**
 * Handle league filter change
 */
async function onLeagueFilterChange() {
	const country = document.getElementById('filter-country').value
	const league = document.getElementById('filter-league').value

	document.getElementById('filter-team').value = ''

	if (!league) {
		if (country) {
			await onCountryFilterChange()
		} else {
			await loadDatabaseFilters()
		}
		return
	}

	try {
		const filters = {}
		if (country) filters.country = country
		if (league) filters.league = league

		const teams = await API.loadDatabaseTeams(filters)

		const teamSelect = document.getElementById('filter-team')
		teamSelect.innerHTML = '<option value="">Wszystkie Drużyny</option>'
		teams.forEach(team => {
			const option = document.createElement('option')
			option.value = team
			option.textContent = team
			teamSelect.appendChild(option)
		})

		console.log('✅ Loaded', teams.length, 'teams for', league)
	} catch (error) {
		console.error('Error loading teams:', error)
		showToast('Nie udało się załadować drużyn: ' + error.message, 'error')
	}
}

/**
 * Handle team filter change
 */
function onTeamFilterChange() {
	console.log('Team filter changed:', document.getElementById('filter-team').value)
}

/**
 * Apply database filters
 */
/**
 * Load statistics for specific team (called when clicking team name)
 * @param {string} teamName - Team name to load
 */
async function loadTeamStats(teamName) {
	console.log('Loading stats for team:', teamName)

	// Set the team filter
	document.getElementById('filter-team').value = teamName

	// Update the search input to match
	const teamSearch = document.getElementById('filter-team-search')
	if (teamSearch) {
		teamSearch.value = ''
	}

	// Apply filters which will load matches and show stats
	await applyFilters()

	// Scroll to stats container
	const statsContainer = document.getElementById('team-stats-container')
	if (statsContainer && statsContainer.style.display !== 'none') {
		statsContainer.scrollIntoView({ behavior: 'smooth', block: 'start' })
	}
}

/**
 * Apply filters and load matches
 */
async function applyFilters() {
	const country = document.getElementById('filter-country').value
	const league = document.getElementById('filter-league').value
	const team = document.getElementById('filter-team').value

	console.log('Applying filters:', { country, league, team, limit: state.selectedLimit })

	try {
		const filters = {}
		if (country) filters.country = country
		if (league) filters.league = league
		if (team) filters.team = team

		const allMatches = await API.loadDatabaseMatches(filters)

		state.lastFetchedMatches = allMatches
		state.selectedTeamForColoring = team
		state.homeAwayFilter = 'all'

		// Display team statistics if team selected
		if (team) {
			const availableLeagues = [...new Set(allMatches.map(m => m.league))]
			const stats = Statistics.calculateTeamStatistics(team, allMatches, 'all')
			DOMUtils.displayTeamStatistics(stats, availableLeagues)
		} else {
			document.getElementById('team-stats-container').style.display = 'none'
		}

		// Apply limit
		applyLimitToResults()

		showToast(`Znaleziono ${allMatches.length} meczów`, 'success')
	} catch (error) {
		console.error('Error applying filters:', error)
		showToast('Nie udało się załadować meczów: ' + error.message, 'error')
	}
}

/**
 * Apply limit to results
 */
function applyLimitToResults() {
	let matches = [...state.lastFetchedMatches]

	// Apply home/away filter if team is selected
	if (state.selectedTeamForColoring && state.homeAwayFilter !== 'all') {
		matches = matches.filter(match => {
			if (state.homeAwayFilter === 'home') {
				return match.home_team === state.selectedTeamForColoring
			} else if (state.homeAwayFilter === 'away') {
				return match.away_team === state.selectedTeamForColoring
			}
			return true
		})
	}

	// Split matches
	const upcomingMatches = matches.filter(m => m.is_finished === 'no')
	const finishedMatches = matches.filter(m => m.is_finished === 'yes')

	// Apply limit to finished matches only
	let limitedFinishedMatches = finishedMatches
	if (state.selectedLimit) {
		limitedFinishedMatches = finishedMatches
			.sort((a, b) => new Date(b.match_date) - new Date(a.match_date))
			.slice(0, state.selectedLimit)
	} else {
		limitedFinishedMatches = finishedMatches.sort((a, b) => new Date(b.match_date) - new Date(a.match_date))
	}

	const finalMatches = [...upcomingMatches, ...limitedFinishedMatches]

	// Recalculate stats if team selected
	if (state.selectedTeamForColoring) {
		const availableLeagues = [...new Set(finalMatches.map(m => m.league))]
		const currentLeagueFilter = document.getElementById('stats-league-filter')?.value || 'all'
		const stats = Statistics.calculateTeamStatistics(state.selectedTeamForColoring, finalMatches, currentLeagueFilter)
		DOMUtils.displayTeamStatistics(stats, availableLeagues)
		if (document.getElementById('stats-league-filter')) {
			document.getElementById('stats-league-filter').value = currentLeagueFilter
		}
	}

	// Display results
	DOMUtils.displayDatabaseResults(finalMatches, state.selectedTeamForColoring)

	const limitText = state.selectedLimit ? ` (limit zakończonych: ${state.selectedLimit})` : ''
	const homeAwayText =
		state.homeAwayFilter === 'home' ? ' (domowe)' : state.homeAwayFilter === 'away' ? ' (wyjazdowe)' : ''
	showToast(
		`Wyświetlono ${finalMatches.length} meczów (${upcomingMatches.length} nadchodzących, ${limitedFinishedMatches.length} zakończonych)${limitText}${homeAwayText}`,
		'success'
	)
}

/**
 * Reset filters
 */
function resetFilters() {
	document.getElementById('filter-country').value = ''
	document.getElementById('filter-league').value = ''
	document.getElementById('filter-team').value = ''

	document.getElementById('filter-country-search').value = ''
	document.getElementById('filter-league-search').value = ''
	document.getElementById('filter-team-search').value = ''

	filterSelectOptions('filter-country', 'filter-country-search')
	filterSelectOptions('filter-league', 'filter-league-search')
	filterSelectOptions('filter-team', 'filter-team-search')

	state.selectedLimit = null
	state.lastFetchedMatches = []
	state.selectedTeamForColoring = null
	state.homeAwayFilter = 'all'

	document.getElementById('team-stats-container').style.display = 'none'

	document.querySelectorAll('.limit-btn').forEach(btn => {
		btn.classList.remove('active')
	})
	document.querySelector('.limit-btn[onclick="window.setLimitAndFilter(null)"]').classList.add('active')

	loadDatabaseFilters()

	document.getElementById('database-results').innerHTML = `
        <div class="empty-state">
            <div class="empty-state-icon">🔍</div>
            <p>Wybierz filtry i kliknij Szukaj aby zobaczyć mecze</p>
        </div>
    `

	showToast('Filtry zresetowane', 'success')
}

/**
 * Handle stats league filter change
 */
function onStatsLeagueChange() {
	const leagueFilter = document.getElementById('stats-league-filter').value
	if (state.selectedTeamForColoring && state.lastFetchedMatches.length > 0) {
		let matches = [...state.lastFetchedMatches]
		if (state.selectedLimit) {
			matches = matches.sort((a, b) => new Date(b.match_date) - new Date(a.match_date)).slice(0, state.selectedLimit)
		}

		const stats = Statistics.calculateTeamStatistics(state.selectedTeamForColoring, matches, leagueFilter)
		const availableLeagues = [...new Set(matches.map(m => m.league))]
		DOMUtils.displayTeamStatistics(stats, availableLeagues)
		document.getElementById('stats-league-filter').value = leagueFilter
	}
}

// =============================================================================
// PLACEHOLDER FUNCTIONS (TO BE IMPLEMENTED)
// =============================================================================

// Background jobs placeholders

// Otwórz modal i załaduj listę lig
async function showBackgroundImportDialog() {
	const modal = document.getElementById('background-import-modal')
	const leaguesList = document.getElementById('background-leagues-list')

	// Load leagues from config (contains numeric IDs)
	try {
		const response = await fetch('/api/config')
		if (!response.ok) throw new Error('Failed to load leagues')
		const data = await response.json()
		const leagues = data.leagues

		let html = ''
		leagues.forEach(league => {
			html += `
                <label style="display: block; padding: 8px; cursor: pointer; border-radius: 4px; margin-bottom: 4px; transition: background 0.2s;"
                       onmouseover="this.style.background='#e0e0e0'"
                       onmouseout="this.style.background='transparent'">
                    <input type="checkbox" value="${league.id}" class="background-league-checkbox" style="margin-right: 8px;">
                    <span style="font-weight: 600;">${league.name}</span>
                    <span style="color: #666; font-size: 12px;"> (${league.country})</span>
                </label>
            `
		})

		leaguesList.innerHTML = html

		// Set default dates (last 7 days)
		const today = new Date()
		const weekAgo = new Date(today)
		weekAgo.setDate(weekAgo.getDate() - 7)

		document.getElementById('background-date-from').value = weekAgo.toISOString().split('T')[0]
		document.getElementById('background-date-to').value = today.toISOString().split('T')[0]

		modal.style.display = 'flex'
	} catch (error) {
		console.error('Error loading leagues:', error)
		showToast('Błąd podczas ładowania lig: ' + error.message, 'error')
	}
}

// Zamknij modal
function closeBackgroundImportDialog() {
	document.getElementById('background-import-modal').style.display = 'none'
}

// Toggle all leagues (select/deselect all)
function toggleAllBackgroundLeagues() {
	const checkboxes = document.querySelectorAll('.background-league-checkbox')
	const btn = document.getElementById('toggle-all-leagues-btn')
	
	// Check if all are currently selected
	const allSelected = Array.from(checkboxes).every(cb => cb.checked)
	
	// Toggle all
	checkboxes.forEach(cb => {
		cb.checked = !allSelected
	})
	
	// Update button text
	if (allSelected) {
		btn.innerHTML = '☑️ Zaznacz wszystkie'
		btn.style.background = '#3b82f6'
	} else {
		btn.innerHTML = '☐ Odznacz wszystkie'
		btn.style.background = '#ef4444'
	}
}

// Utwórz zadanie importu
async function createBackgroundJob() {
	const checkboxes = document.querySelectorAll('.background-league-checkbox:checked')
	const leagueIds = Array.from(checkboxes).map(cb => cb.value)
	const dateFrom = document.getElementById('background-date-from').value
	const dateTo = document.getElementById('background-date-to').value

	if (leagueIds.length === 0) {
		showToast('Wybierz przynajmniej jedną ligę', 'error')
		return
	}

	if (!dateFrom || !dateTo) {
		showToast('Wybierz zakres dat', 'error')
		return
	}

	if (new Date(dateFrom) > new Date(dateTo)) {
		showToast('Data początkowa nie może być późniejsza niż końcowa', 'error')
		return
	}

	try {
		const result = await API.createBackgroundJob({ leagueIds, dateFrom, dateTo })

		closeBackgroundImportDialog()
		showToast(
			`✅ Zadanie utworzone! ID: ${result.jobId}\n\nImport rozpocznie się automatycznie w ciągu 60 sekund.`,
			'success'
		)

		// Refresh jobs list
		await refreshBackgroundJobs()

		// Start auto-refresh if not already running
		if (!state.backgroundJobsInterval) {
			state.backgroundJobsInterval = setInterval(refreshBackgroundJobs, 5000)
		}
	} catch (error) {
		console.error('Error creating job:', error)
		showToast('Błąd podczas tworzenia zadania: ' + error.message, 'error')
	}
}

function toggleHiddenJobs() {
	showHiddenJobs = !showHiddenJobs
	const btn = document.getElementById('toggle-hidden-btn')

	if (showHiddenJobs) {
		btn.innerHTML = '👁️ Pokaż Aktywne'
		btn.style.background = '#f59e0b'
	} else {
		btn.innerHTML = '👁️ Pokaż Ukryte'
		btn.style.background = '#6b7280'
	}

	refreshBackgroundJobs()
}

async function pauseJob(jobId) {
	if (!confirm('Czy na pewno wstrzymać to zadanie?')) return

	try {
		const response = await fetch(`/api/import-jobs/${jobId}/pause`, {
			method: 'POST',
		})

		if (!response.ok) {
			throw new Error('Błąd wstrzymywania zadania')
		}

		await refreshBackgroundJobs()
	} catch (error) {
		console.error('Error pausing job:', error)
		showToast('Błąd podczas wstrzymywania zadania: ' + error.message, 'error')
	}
}

async function resumeJob(jobId) {
	try {
		const response = await fetch(`/api/import-jobs/${jobId}/resume`, {
			method: 'POST',
		})

		if (!response.ok) {
			throw new Error('Błąd wznawiania zadania')
		}

		await refreshBackgroundJobs()

		// Start auto-refresh
		if (!state.backgroundJobsInterval) {
			state.backgroundJobsInterval = setInterval(refreshBackgroundJobs, 5000)
		}
	} catch (error) {
		console.error('Error resuming job:', error)
		showToast('Błąd podczas wznawiania zadania: ' + error.message, 'error')
	}
}

async function retryJob(jobId) {
	try {
		const response = await fetch(`/api/import-jobs/${jobId}/retry`, {
			method: 'POST',
		})

		if (!response.ok) {
			const errorData = await response.json().catch(() => ({ error: 'Unknown error' }))
			throw new Error(errorData.error || `HTTP ${response.status}: ${response.statusText}`)
		}

		const data = await response.json()
		showToast(
			data.message || 'Próba importu zainicjowana. Worker sprawdzi limity API i spróbuje wznowić zadanie.',
			'success'
		)

		await refreshBackgroundJobs()

		// Start auto-refresh
		if (!state.backgroundJobsInterval) {
			state.backgroundJobsInterval = setInterval(refreshBackgroundJobs, 5000)
		}
	} catch (error) {
		console.error('Error retrying job:', error)
		showToast('Błąd podczas próby ponownego importu: ' + error.message, 'error')
	}
}

async function viewJobLogs(jobId) {
	try {
		const response = await fetch(`/api/import-jobs/${jobId}/logs`)

		if (!response.ok) {
			throw new Error('Błąd pobierania logów')
		}

		const data = await response.json()

		if (data.logs.length === 0) {
			showToast('Brak logów dla tego zadania', 'warning')
			return
		}

		// Create modal to display logs
		const modal = document.createElement('div')
		modal.className = 'modal'
		modal.style.display = 'flex'
		modal.innerHTML = `
            <div class="modal-content" style="max-width: 900px; max-height: 80vh;">
                <h2>📄 Logi zadania #${jobId}</h2>
                <div style="background: #1e1e1e; color: #d4d4d4; padding: 15px; border-radius: 4px; overflow-y: auto; max-height: 500px; font-family: 'Courier New', monospace; font-size: 12px; margin: 20px 0;">
                    ${data.logs.map(line => `<div style="margin-bottom: 4px;">${line}</div>`).join('')}
                </div>
                <div style="text-align: center;">
                    <button class="btn" style="background: #718096; color: white;" onclick="this.closest('.modal').remove()">
                        Zamknij
                    </button>
                </div>
            </div>
        `

		document.body.appendChild(modal)

		// Close on background click
		modal.addEventListener('click', e => {
			if (e.target === modal) modal.remove()
		})
	} catch (error) {
		console.error('Error viewing logs:', error)
		showToast('Błąd podczas pobierania logów: ' + error.message, 'error')
	}
}

async function hideJob(jobId) {
	if (!confirm('Czy na pewno ukryć to zadanie? Będzie nadal dostępne w widoku ukrytych zadań.')) return

	try {
		const response = await fetch(`/api/import-jobs/${jobId}/hide`, {
			method: 'POST',
		})

		if (!response.ok) {
			throw new Error('Błąd ukrywania zadania')
		}

		await refreshBackgroundJobs()
		showToast('✅ Zadanie ukryte', 'success')
	} catch (error) {
		console.error('Error hiding job:', error)
		showToast('Błąd podczas ukrywania zadania: ' + error.message, 'error')
	}
}

async function unhideJob(jobId) {
	try {
		const response = await fetch(`/api/import-jobs/${jobId}/unhide`, {
			method: 'POST',
		})

		if (!response.ok) {
			throw new Error('Błąd przywracania zadania')
		}

		await refreshBackgroundJobs()
		showToast('✅ Zadanie przywrócone', 'success')
	} catch (error) {
		console.error('Error unhiding job:', error)
		showToast('Błąd podczas przywracania zadania: ' + error.message, 'error')
	}
}

async function deleteJob(jobId) {
	if (
		!confirm(
			'⚠️ Czy na pewno USUNĄĆ to zadanie?\n\nTa operacja jest NIEODWRACALNA!\nWszystkie dane zadania, w tym logi, zostaną utracone.'
		)
	)
		return

	try {
		const response = await fetch(`/api/import-jobs/${jobId}`, {
			method: 'DELETE',
		})

		if (!response.ok) {
			throw new Error('Błąd usuwania zadania')
		}

		await refreshBackgroundJobs()
		showToast('✅ Zadanie usunięte', 'success')
	} catch (error) {
		console.error('Error deleting job:', error)
		showToast('Błąd podczas usuwania zadania: ' + error.message, 'error')
	}
}

// =============================================================================
// MODAL HELPERS FOR BET FINDER
// =============================================================================

// Store minimized modals data
const minimizedModals = new Map()

function saveMinimizedModals() {
	const modalsData = Array.from(minimizedModals.entries()).map(([id, data]) => ({
		id,
		title: data.title,
		results: data.results,
		modalType: data.modalType,
	}))
	localStorage.setItem('minimizedModals', JSON.stringify(modalsData))
}

function loadMinimizedModals() {
	const saved = localStorage.getItem('minimizedModals')
	if (saved) {
		try {
			const modalsData = JSON.parse(saved)

			// Ensure container exists
			const container = ensureModalsContainer()

			modalsData.forEach(({ id, title, results, modalType }) => {
				minimizedModals.set(id, { title, results, modalType })

				// Recreate the minimized card
				const miniCardId = `minimized-modal-card-${id}`
				if (!document.getElementById(miniCardId)) {
					const miniCard = document.createElement('div')
					miniCard.id = miniCardId
					miniCard.className = 'minimized-card'
					miniCard.innerHTML = `
                        <div class="minimized-card-content" onclick="window.restoreModal('${id}')">
                            <span class="minimized-card-icon">⚽</span>
                            <span class="minimized-card-text">${title}</span>
                        </div>
                        <button class="minimized-card-close" onclick="window.closeModalCompletely(event, '${id}')">×</button>
                    `
					container.appendChild(miniCard)
				}
			})
		} catch (e) {
			console.error('Error loading minimized modals:', e)
		}
	}
}

function ensureModalsContainer() {
	let container = document.getElementById('minimized-modals-container')
	if (!container) {
		container = document.createElement('div')
		container.id = 'minimized-modals-container'
		container.className = 'minimized-modals-container'
		document.body.appendChild(container)
	}
	return container
}

function minimizeModal() {
	const modal = document.getElementById('bet-finder-modal')
	if (!modal) return

	// Get modal title to create unique ID
	const modalHeader = modal.querySelector('.modal-header h2')
	const modalTitle = modalHeader?.textContent || 'TOP 10'
	const modalId = modalTitle.replace(/[^a-zA-Z0-9]/g, '-').toLowerCase()

	// Hide modal
	modal.style.display = 'none'

	// Get current modal data from bet-finder
	const modalData = BetFinder.getCurrentModalData()

	// Store modal data
	minimizedModals.set(modalId, {
		title: modalTitle,
		results: modalData.results,
		modalType: modalData.modalType,
	})
	saveMinimizedModals()

	// Ensure container exists
	const container = ensureModalsContainer()

	// Check if minimized card already exists
	const miniCardId = `minimized-modal-card-${modalId}`
	let miniCard = document.getElementById(miniCardId)

	if (!miniCard) {
		// Create minimized card
		miniCard = document.createElement('div')
		miniCard.id = miniCardId
		miniCard.className = 'minimized-card'
		miniCard.innerHTML = `
            <div class="minimized-card-content" onclick="window.restoreModal('${modalId}')">
                <span class="minimized-card-icon">⚽</span>
                <span class="minimized-card-text">${modalTitle}</span>
            </div>
            <button class="minimized-card-close" onclick="window.closeModalCompletely(event, '${modalId}')">×</button>
        `
		container.appendChild(miniCard)
	} else {
		miniCard.style.display = 'flex'
	}

	repositionMinimizedCards()
}

function repositionMinimizedCards() {
	const container = document.getElementById('minimized-modals-container')
	if (!container) return

	// Cards are already in correct order due to flex-direction: column and justify-content: flex-end
	// No need to manually position them
}

function restoreModal(modalId) {
	const miniCardId = `minimized-modal-card-${modalId}`
	const miniCard = document.getElementById(miniCardId)

	const modal = document.getElementById('bet-finder-modal')
	if (modal && modal.style.display === 'none') {
		// Modal exists but is hidden - show it
		modal.style.display = 'flex'
		if (miniCard) {
			miniCard.style.display = 'none'
		}
	} else if (!modal) {
		// Modal doesn't exist (after page refresh) - recreate from stored data
		const modalData = minimizedModals.get(modalId)
		if (modalData && modalData.results && modalData.modalType) {
			// Map modalType to appropriate show function
			const showFunctions = {
				'most-goals': BetFinder.showMostGoalsModal,
				'least-goals': BetFinder.showLeastGoalsModal,
				'most-corners': BetFinder.showMostCornersModal,
				'least-corners': BetFinder.showLeastCornersModal,
				'most-advantage': BetFinder.showGoalAdvantageModal,
				'most-handicap': BetFinder.showHandicap15Modal,
			}

			const showFunction = showFunctions[modalData.modalType]
			if (showFunction) {
				showFunction(modalData.results)
				if (miniCard) {
					miniCard.style.display = 'none'
				}
			} else {
				showToast('Nie można odtworzyć modalu: nieznany typ', 'error')
			}
		} else {
			showToast('Modal został utracony po odświeżeniu. Uruchom wyszukiwanie ponownie.', 'info')
		}
	}
}

function closeModalCompletely(event, modalId) {
	event.stopPropagation()

	if (modalId) {
		// Close specific minimized card
		const miniCardId = `minimized-modal-card-${modalId}`
		const miniCard = document.getElementById(miniCardId)
		if (miniCard) {
			miniCard.remove()
		}

		// Remove from map and save
		minimizedModals.delete(modalId)
		saveMinimizedModals()
		repositionMinimizedCards()
	}

	// Also close the main modal
	const modal = document.getElementById('bet-finder-modal')
	if (modal) {
		modal.remove()
	}
}

function closeModal() {
	const modal = document.getElementById('bet-finder-modal')
	if (modal) {
		// Show confirmation dialog for TOP 10 modals
		const confirmed = confirm('Czy na pewno chcesz zamknąć ten modal?')
		if (!confirmed) {
			return // User cancelled, don't close
		}
		modal.remove()
	}
}

function showBetFinderMatchDetailsModal(result) {
	console.log('Match details:', result)

	if (!result || !result.homeStats || !result.awayStats) {
		showToast('Brak danych do wyświetlenia', 'warning')
		return
	}

	// Store current match data for minimization
	currentMatchDetailsData = result

	// Generate modal HTML
	const homeMatches = result.homeStats.matches || []
	const awayMatches = result.awayStats.matches || []

	// Determine what type of statistics to show and how to render them
	let homeStatsText = ''
	let awayStatsText = ''
	let mainStatText = ''
	let searchType = 'default'
	let avgThreshold = 0
	let isLeastSearch = false // Flag to reverse color logic

	if (result.averageGoals !== undefined) {
		// Goals-based search
		searchType = 'goals'
		avgThreshold = result.averageGoals
		isLeastSearch = result.searchType === 'least-goals'
		homeStatsText = `${result.homeStats.totalGoalsScored || 0}:${result.homeStats.totalGoalsConceded || 0} (śr. ${
			result.homeStats.avgGoals || 0
		})`
		awayStatsText = `${result.awayStats.totalGoalsScored || 0}:${result.awayStats.totalGoalsConceded || 0} (śr. ${
			result.awayStats.avgGoals || 0
		})`
		mainStatText = `Łączna średnia bramek: ${result.averageGoals}`
	} else if (result.averageCorners !== undefined) {
		// Corners-based search
		searchType = 'corners'
		avgThreshold = result.averageCorners
		isLeastSearch = result.searchType === 'least-corners'
		homeStatsText = `Śr. rożnych: ${result.homeStats.avgCorners || 0} (${
			result.homeStats.cornersMatchCount || 0
		} meczów)`
		awayStatsText = `Śr. rożnych: ${result.awayStats.avgCorners || 0} (${
			result.awayStats.cornersMatchCount || 0
		} meczów)`
		mainStatText = `Łączna średnia rożnych: ${result.averageCorners}`
	} else if (result.handicapScore !== undefined) {
		// Handicap 1.5 search
		searchType = 'handicap'
		avgThreshold = 0 // Not used for handicap
		const homeWinsPct =
			result.homeStats.matchCount > 0
				? (((result.homeStats.winsBy2Plus || 0) / result.homeStats.matchCount) * 100).toFixed(1)
				: 0
		const awayWinsPct =
			result.awayStats.matchCount > 0
				? (((result.awayStats.winsBy2Plus || 0) / result.awayStats.matchCount) * 100).toFixed(1)
				: 0
		homeStatsText = `Wygrane 2+ bramkami: ${result.homeStats.winsBy2Plus || 0} (${homeWinsPct}%)`
		awayStatsText = `Wygrane 2+ bramkami: ${result.awayStats.winsBy2Plus || 0} (${awayWinsPct}%)`
		mainStatText = `Handicap 1.5 score: ${result.handicapScore} (${result.strongTeam})`
	} else if (result.goalDifference !== undefined) {
		// Goal difference search
		searchType = 'handicap'
		avgThreshold = result.goalDifference
		homeStatsText = `${result.homeStats.totalGoalsScored || 0}:${result.homeStats.totalGoalsConceded || 0} (${
			result.homeStats.matchCount || 0
		} meczów)`
		awayStatsText = `${result.awayStats.totalGoalsScored || 0}:${result.awayStats.totalGoalsConceded || 0} (${
			result.awayStats.matchCount || 0
		} meczów)`
		mainStatText = `Różnica bramek: ${result.goalDifference}`
	} else if (result.advantageScore !== undefined && result.strongTeamCornersFor !== undefined) {
		// Corner advantage search - CHECK THIS FIRST before goal advantage
		searchType = 'corner-advantage'
		avgThreshold = 0 // Not used
		homeStatsText = `Za: ${result.homeStats.avgCornersFor || 0} / Przeciw: ${
			result.homeStats.avgCornersAgainst || 0
		} (${result.homeStats.cornersMatchCount || 0} meczów)`
		awayStatsText = `Za: ${result.awayStats.avgCornersFor || 0} / Przeciw: ${
			result.awayStats.avgCornersAgainst || 0
		} (${result.awayStats.cornersMatchCount || 0} meczów)`
		mainStatText = `Przewaga rożnych: ${result.advantageScore} (${result.strongTeam}: ${result.strongTeamCornersFor} + ${result.weakTeam}: ${result.weakTeamCornersAgainst})`
	} else if (result.advantageScore !== undefined) {
		// Goal advantage search
		searchType = 'advantage'
		avgThreshold = result.advantageScore
		homeStatsText = `Strzelone: ${(
			(result.homeStats.totalGoalsScored || 0) / (result.homeStats.matchCount || 1)
		).toFixed(2)} | Stracone: ${(
			(result.homeStats.totalGoalsConceded || 0) / (result.homeStats.matchCount || 1)
		).toFixed(2)}`
		awayStatsText = `Strzelone: ${(
			(result.awayStats.totalGoalsScored || 0) / (result.awayStats.matchCount || 1)
		).toFixed(2)} | Stracone: ${(
			(result.awayStats.totalGoalsConceded || 0) / (result.awayStats.matchCount || 1)
		).toFixed(2)}`
		mainStatText = `Przewaga: ${result.strongTeam} (score: ${result.advantageScore})`
	} else if (result.homeAdvantage !== undefined) {
		// Old goal advantage format (fallback)
		searchType = 'advantage'
		avgThreshold = result.homeAdvantage
		homeStatsText = `${result.homeStats.totalGoalsScored || 0}:${result.homeStats.totalGoalsConceded || 0} (${
			result.homeStats.matchCount || 0
		} meczów)`
		awayStatsText = `${result.awayStats.totalGoalsScored || 0}:${result.awayStats.totalGoalsConceded || 0} (${
			result.awayStats.matchCount || 0
		} meczów)`
		mainStatText = `Przewaga gospodarza: ${result.homeAdvantage}`
	} else if (result.contrastScore !== undefined) {
		// Winner vs Loser search
		searchType = 'winloss'
		avgThreshold = 0 // Not used for win/loss
		homeStatsText = `W: ${result.homeStats.wins || 0} | D: ${result.homeStats.draws || 0} | L: ${
			result.homeStats.losses || 0
		} (${result.homeStats.winPercent || 0}% / ${result.homeStats.drawPercent || 0}% / ${
			result.homeStats.lossPercent || 0
		}%)`
		awayStatsText = `W: ${result.awayStats.wins || 0} | D: ${result.awayStats.draws || 0} | L: ${
			result.awayStats.losses || 0
		} (${result.awayStats.winPercent || 0}% / ${result.awayStats.drawPercent || 0}% / ${
			result.awayStats.lossPercent || 0
		}%)`
		mainStatText = `Kontrast form: ${result.contrastScore} (Mocny: ${result.strongTeam} ${result.strongTeamWinPercent}% W, Słaby: ${result.weakTeam} ${result.weakTeamLossPercent}% L)`
	} else if (result.averageTotalCorners !== undefined) {
		// Total corners search (both most and least)
		searchType = result.searchType === 'total-corners-least' ? 'total-corners-least' : 'total-corners'
		avgThreshold = 0 // Not used
		homeStatsText = `Śr. suma rożnych: ${result.homeStats.avgMatchCorners || 0} (${
			result.homeStats.cornersMatchCount || 0
		} meczów)`
		awayStatsText = `Śr. suma rożnych: ${result.awayStats.avgMatchCorners || 0} (${
			result.awayStats.cornersMatchCount || 0
		} meczów)`
		mainStatText = `Średnia suma rożnych w meczu: ${result.averageTotalCorners}`
	} else if (result.averageTotalOffsides !== undefined) {
		// Total offsides search (both most and least)
		searchType = result.searchType === 'total-offsides-least' ? 'total-offsides-least' : 'total-offsides'
		avgThreshold = 0 // Not used
		homeStatsText = `Śr. suma spalonych: ${result.homeStats.avgMatchOffsides || 0} (${
			result.homeStats.offsidesMatchCount || 0
		} meczów)`
		awayStatsText = `Śr. suma spalonych: ${result.awayStats.avgMatchOffsides || 0} (${
			result.awayStats.offsidesMatchCount || 0
		} meczów)`
		mainStatText = `Średnia suma spalonych w meczu: ${result.averageTotalOffsides}`
	} else if (result.averageOffsides !== undefined) {
		// Offsides-based search (single team)
		searchType = result.searchType === 'least-offsides' ? 'least-offsides' : 'most-offsides'
		avgThreshold = result.averageOffsides
		isLeastSearch = result.searchType === 'least-offsides'
		homeStatsText = `Śr. spalonych: ${result.homeStats.avgOffsides || 0} (${
			result.homeStats.offsidesMatchCount || 0
		} meczów)`
		awayStatsText = `Śr. spalonych: ${result.awayStats.avgOffsides || 0} (${
			result.awayStats.offsidesMatchCount || 0
		} meczów)`
		mainStatText = `Łączna średnia spalonych: ${result.averageOffsides}`
	} else {
		// Default fallback
		searchType = 'default'
		homeStatsText = `Meczów: ${result.homeStats.matchCount || 0}`
		awayStatsText = `Meczów: ${result.awayStats.matchCount || 0}`
		mainStatText = 'Statystyki'
	}

	// Calculate missing statistics
	const calculateMissingStats = matches => {
		if (
			searchType === 'corners' ||
			searchType === 'total-corners' ||
			searchType === 'total-corners-least' ||
			searchType === 'corner-advantage'
		) {
			// Count matches without corner data
			const missingCount = matches.filter(m => m.homeCorners == null || m.awayCorners == null).length
			const totalCount = matches.length
			const withDataCount = totalCount - missingCount

			return {
				missing: missingCount,
				total: totalCount,
				withData: withDataCount,
				hasMissing: missingCount > 0,
			}
		} else if (
			searchType === 'most-offsides' ||
			searchType === 'least-offsides' ||
			searchType === 'total-offsides' ||
			searchType === 'total-offsides-least'
		) {
			// Count matches without offsides data
			const missingCount = matches.filter(m => m.homeOffsides == null || m.awayOffsides == null).length
			const totalCount = matches.length
			const withDataCount = totalCount - missingCount

			return {
				missing: missingCount,
				total: totalCount,
				withData: withDataCount,
				hasMissing: missingCount > 0,
			}
		}
		// For other search types, no missing data
		return {
			missing: 0,
			total: matches.length,
			withData: matches.length,
			hasMissing: false,
		}
	}

	const homeMissingStats = calculateMissingStats(homeMatches)
	const awayMissingStats = calculateMissingStats(awayMatches)

	// Helper function to render match statistic with color coding
	const renderMatchStat = (match, isHomeTeam) => {
		let statValue = 0
		let statLabel = ''

		if (searchType === 'goals') {
			statValue = (match.homeGoals || 0) + (match.awayGoals || 0)
			statLabel = `${statValue} br.`
		} else if (
			searchType === 'corners' ||
			searchType === 'total-corners' ||
			searchType === 'total-corners-least' ||
			searchType === 'corner-advantage'
		) {
			if (match.homeCorners != null && match.awayCorners != null) {
				if (searchType === 'corner-advantage') {
					// Show individual team corners with "Za" label
					const teamName = isHomeTeam ? result.homeTeam : result.awayTeam
					const isTeamHome = match.homeTeam === teamName
					const teamCorners = isTeamHome ? match.homeCorners : match.awayCorners
					statLabel = `${teamCorners} rż.`
				} else {
					// Show total corners
					statValue = (match.homeCorners || 0) + (match.awayCorners || 0)
					statLabel = `${statValue} rż.`
				}
			} else {
				return '<span style="color: #999;">—</span>'
			}
		} else if (
			searchType === 'most-offsides' ||
			searchType === 'least-offsides' ||
			searchType === 'total-offsides' ||
			searchType === 'total-offsides-least'
		) {
			if (match.homeOffsides != null && match.awayOffsides != null) {
				if (searchType === 'most-offsides' || searchType === 'least-offsides') {
					// Show individual team offsides
					const teamName = isHomeTeam ? result.homeTeam : result.awayTeam
					const isTeamHome = match.homeTeam === teamName
					const teamOffsides = isTeamHome ? match.homeOffsides : match.awayOffsides
					statValue = teamOffsides
					statLabel = `${teamOffsides} sp.`
				} else {
					// Show total offsides (sum of both teams)
					statValue = (match.homeOffsides || 0) + (match.awayOffsides || 0)
					statLabel = `${statValue} sp.`
				}
			} else {
				return '<span style="color: #999;">—</span>'
			}
		} else if (searchType === 'winloss') {
			// For win/loss search, show result with color coding
			// Determine if this was a win, draw, or loss for the team
			const teamName = isHomeTeam ? result.homeTeam : result.awayTeam
			const isTeamHome = match.homeTeam === teamName
			const teamGoals = isTeamHome ? match.homeGoals : match.awayGoals
			const opponentGoals = isTeamHome ? match.awayGoals : match.homeGoals

			if (teamGoals > opponentGoals) {
				// Win - green
				statLabel = 'W'
				return `<span style="display: inline-block; padding: 2px 8px; border-radius: 4px; font-weight: 700; background: #d1fae5; color: #059669;">${statLabel}</span>`
			} else if (teamGoals < opponentGoals) {
				// Loss - red
				statLabel = 'L'
				return `<span style="display: inline-block; padding: 2px 8px; border-radius: 4px; font-weight: 700; background: #fee2e2; color: #dc2626;">${statLabel}</span>`
			} else {
				// Draw - yellow
				statLabel = 'D'
				return `<span style="display: inline-block; padding: 2px 8px; border-radius: 4px; font-weight: 700; background: #fef3c7; color: #d97706;">${statLabel}</span>`
			}
		} else if (searchType === 'handicap') {
			const isMatchHome = match.homeTeam === result.homeTeam || match.homeTeam === result.awayTeam
			if (isHomeTeam) {
				statValue = (match.homeGoals || 0) - (match.awayGoals || 0)
			} else {
				statValue = (match.awayGoals || 0) - (match.homeGoals || 0)
			}
			statLabel = statValue > 0 ? `+${statValue}` : `${statValue}`
		} else if (searchType === 'advantage') {
			statValue = (match.homeGoals || 0) - (match.awayGoals || 0)
			statLabel = statValue > 0 ? `+${statValue}` : `${statValue}`
		} else {
			return ''
		}

		// Determine color based on comparison with average
		let color = '#666'
		let bgColor = 'transparent'
		if (
			searchType === 'goals' ||
			searchType === 'corners' ||
			searchType === 'total-corners' ||
			searchType === 'total-corners-least' ||
			searchType === 'most-offsides' ||
			searchType === 'least-offsides' ||
			searchType === 'total-offsides' ||
			searchType === 'total-offsides-least'
		) {
			// For "least" searches, reverse the color logic
			if (
				isLeastSearch ||
				searchType === 'total-corners-least' ||
				searchType === 'least-offsides' ||
				searchType === 'total-offsides-least'
			) {
				if (statValue < avgThreshold) {
					color = '#059669' // Green for below average in "least" search
					bgColor = '#d1fae5'
				} else if (statValue > avgThreshold) {
					color = '#dc2626' // Red for above average in "least" search
					bgColor = '#fee2e2'
				}
			} else {
				// Normal logic for "most" searches
				if (statValue > avgThreshold) {
					color = '#059669' // Green for above average
					bgColor = '#d1fae5'
				} else if (statValue < avgThreshold) {
					color = '#dc2626' // Red for below average
					bgColor = '#fee2e2'
				}
			}
		} else if (searchType === 'corner-advantage') {
			// For corner advantage, don't color code (just display the value)
			color = '#666'
			bgColor = 'transparent'
		} else if (searchType === 'handicap' || searchType === 'advantage') {
			if (statValue > 0) {
				color = '#059669'
				bgColor = '#d1fae5'
			} else if (statValue < 0) {
				color = '#dc2626'
				bgColor = '#fee2e2'
			}
		}

		return `<span style="display: inline-block; padding: 2px 6px; border-radius: 4px; font-weight: 600; background: ${bgColor}; color: ${color};">${statLabel}</span>`
	}

	const modalHTML = `
        <div class="modal-backdrop" onclick="window.closeMatchDetailsModal()"></div>
        <div class="modal-dialog" style="max-width: 1200px;">
            <div class="modal-header" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                <h2>📊 Szczegóły: ${result.homeTeam} vs ${result.awayTeam}</h2>
                <div style="display: flex; gap: 10px;">
                    <button class="modal-minimize" onclick="window.minimizeMatchDetailsModal()">−</button>
                    <button class="modal-close" onclick="window.closeMatchDetailsModal()">×</button>
                </div>
            </div>
            <div class="modal-body">
                <div style="background: linear-gradient(135deg, #fef3c7 0%, #fcd34d 100%); padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #f59e0b;">
                    <p style="margin: 0; color: #78350f; font-size: 14px; font-weight: 600;">
                        ${mainStatText} | ${new Date(result.date).toLocaleDateString('pl-PL')} | ${result.league}
                    </p>
                </div>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <!-- Home Team -->
                    <div>
                        <h3 style="margin-bottom: 15px; color: #667eea;">🏠 ${result.homeTeam}</h3>
                        <p style="margin-bottom: 10px; font-weight: 600; background: #f3f4f6; padding: 10px; border-radius: 6px;">
                            ${homeStatsText}
                        </p>
                        ${
													homeMissingStats.hasMissing
														? `
                        <div style="background: #fef3c7; border-left: 4px solid #f59e0b; padding: 10px; margin-bottom: 10px; border-radius: 4px;">
                            <p style="margin: 0; font-size: 12px; color: #92400e;">
                                ⚠️ Wskazana średnia nie uwzględnia <strong>${homeMissingStats.missing}</strong> ${
																homeMissingStats.missing === 1
																	? 'meczu'
																	: homeMissingStats.missing < 5
																	? 'meczów'
																	: 'meczów'
														  } dla ${homeMissingStats.missing === 1 ? 'którego' : 'których'} brakuje statystyk.
                                ${
																	homeMissingStats.withData > 0
																		? `Średnia oparta na ${homeMissingStats.withData} ${
																				homeMissingStats.withData === 1
																					? 'meczu'
																					: homeMissingStats.withData < 5
																					? 'meczach'
																					: 'meczach'
																		  }.`
																		: ''
																}
                            </p>
                        </div>
                        `
														: ''
												}
                        <div style="max-height: 400px; overflow-y: auto;">${
													homeMatches.length > 0
														? `
                                <table class="results-table" style="font-size: 12px;">
                                    <thead>
                                        <tr>
                                            <th>Data</th>
                                            <th>Mecz</th>
                                            <th>Wynik</th>
                                            ${searchType !== 'default' ? '<th>Statystyka</th>' : ''}
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${homeMatches
																					.map(
																						m => `
                                            <tr>
                                                <td>${new Date(m.date).toLocaleDateString('pl-PL')}</td>
                                                <td style="font-size: 11px;">${m.homeTeam} - ${m.awayTeam}</td>
                                                <td style="font-weight: 600;">${m.homeGoals}:${m.awayGoals}</td>
                                                ${
																									searchType !== 'default'
																										? `<td style="text-align: center;">${renderMatchStat(m, true)}</td>`
																										: ''
																								}
                                            </tr>
                                        `
																					)
																					.join('')}
                                    </tbody>
                                </table>
                            `
														: '<p style="text-align: center; color: #999;">Brak danych historycznych</p>'
												}
                        </div>
                    </div>
                    
                    <!-- Away Team -->
                    <div>
                        <h3 style="margin-bottom: 15px; color: #764ba2;">✈️ ${result.awayTeam}</h3>
                        <p style="margin-bottom: 10px; font-weight: 600; background: #f3f4f6; padding: 10px; border-radius: 6px;">
                            ${awayStatsText}
                        </p>
                        ${
													awayMissingStats.hasMissing
														? `
                        <div style="background: #fef3c7; border-left: 4px solid #f59e0b; padding: 10px; margin-bottom: 10px; border-radius: 4px;">
                            <p style="margin: 0; font-size: 12px; color: #92400e;">
                                ⚠️ Wskazana średnia nie uwzględnia <strong>${awayMissingStats.missing}</strong> ${
																awayMissingStats.missing === 1
																	? 'meczu'
																	: awayMissingStats.missing < 5
																	? 'meczów'
																	: 'meczów'
														  } dla ${awayMissingStats.missing === 1 ? 'którego' : 'których'} brakuje statystyk.
                                ${
																	awayMissingStats.withData > 0
																		? `Średnia oparta na ${awayMissingStats.withData} ${
																				awayMissingStats.withData === 1
																					? 'meczu'
																					: awayMissingStats.withData < 5
																					? 'meczach'
																					: 'meczach'
																		  }.`
																		: ''
																}
                            </p>
                        </div>
                        `
														: ''
												}
                        <div style="max-height: 400px; overflow-y: auto;">
                            ${
															awayMatches.length > 0
																? `
                                <table class="results-table" style="font-size: 12px;">
                                    <thead>
                                        <tr>
                                            <th>Data</th>
                                            <th>Mecz</th>
                                            <th>Wynik</th>
                                            ${searchType !== 'default' ? '<th>Statystyka</th>' : ''}
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${awayMatches
																					.map(
																						m => `
                                            <tr>
                                                <td>${new Date(m.date).toLocaleDateString('pl-PL')}</td>
                                                <td style="font-size: 11px;">${m.homeTeam} - ${m.awayTeam}</td>
                                                <td style="font-weight: 600;">${m.homeGoals}:${m.awayGoals}</td>
                                                ${
																									searchType !== 'default'
																										? `<td style="text-align: center;">${renderMatchStat(
																												m,
																												false
																										  )}</td>`
																										: ''
																								}
                                            </tr>
                                        `
																					)
																					.join('')}
                                    </tbody>
                                </table>
                            `
																: '<p style="text-align: center; color: #999;">Brak danych historycznych</p>'
														}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `

	// Remove existing modal
	const existingModal = document.getElementById('match-details-modal')
	if (existingModal) {
		existingModal.remove()
	}

	// Create and show modal
	const modalContainer = document.createElement('div')
	modalContainer.id = 'match-details-modal'
	modalContainer.innerHTML = modalHTML
	document.body.appendChild(modalContainer)
}

// Store minimized match modals data
let minimizedMatchModals = new Map() // matchId -> match details data
let currentMatchDetailsData = null

// Save/load minimized match cards from localStorage
function saveMinimizedMatchCards() {
	const cardsData = Array.from(minimizedMatchModals.entries()).map(([id, data]) => ({
		id,
		data,
	}))
	localStorage.setItem('minimizedMatchCards', JSON.stringify(cardsData))
}

function loadMinimizedMatchCards() {
	const saved = localStorage.getItem('minimizedMatchCards')
	if (saved) {
		try {
			const cardsData = JSON.parse(saved)

			// Ensure container exists
			ensureCardsContainer()
			const container = document.getElementById('minimized-cards-container')

			cardsData.forEach(({ id, data }) => {
				minimizedMatchModals.set(id, data)

				// Recreate the minimized card
				const miniCardId = `minimized-match-card-${id}`
				if (!document.getElementById(miniCardId)) {
					const miniCard = document.createElement('div')
					miniCard.id = miniCardId
					miniCard.className = 'minimized-match-card'
					miniCard.innerHTML = `
                        <div class="minimized-card-content" onclick="window.restoreMatchDetailsModal('${id}')">
                            <span class="minimized-card-icon">📊</span>
                            <span class="minimized-card-text">${data.homeTeam} vs ${data.awayTeam}</span>
                        </div>
                        <button class="minimized-card-close" onclick="window.closeMatchDetailsModalCompletely(event, '${id}')">×</button>
                    `
					container.appendChild(miniCard)
				}
			})
			repositionMinimizedMatchCards()
		} catch (e) {
			console.error('Error loading minimized match cards:', e)
		}
	}
}

function ensureCardsContainer() {
	let container = document.getElementById('minimized-cards-container')
	if (!container) {
		container = document.createElement('div')
		container.id = 'minimized-cards-container'
		container.className = 'minimized-cards-container'
		document.body.appendChild(container)
	}
	return container
}

function closeMatchDetailsModal() {
	const modal = document.getElementById('match-details-modal')
	if (modal) {
		modal.remove()
	}
	currentMatchDetailsData = null
}

function minimizeMatchDetailsModal() {
	const modal = document.getElementById('match-details-modal')
	if (!currentMatchDetailsData) return

	// Create unique ID from match data
	const matchId =
		`${currentMatchDetailsData.homeTeam}-${currentMatchDetailsData.awayTeam}-${currentMatchDetailsData.date}`
			.replace(/[^a-zA-Z0-9]/g, '-')
			.toLowerCase()

	// Check if minimized card already exists
	const miniCardId = `minimized-match-card-${matchId}`
	const existingMiniCard = document.getElementById(miniCardId)

	if (existingMiniCard) {
		// Card already exists, just show it and remove modal
		existingMiniCard.style.display = 'flex'
		if (modal) {
			modal.remove()
		}
		repositionMinimizedMatchCards()
		return
	}

	// No modal to minimize
	if (!modal) return

	// Remove modal
	modal.remove()

	// Store modal data
	minimizedMatchModals.set(matchId, currentMatchDetailsData)
	saveMinimizedMatchCards()

	// Ensure container exists
	const container = ensureCardsContainer()

	// Create minimized card
	const miniCard = document.createElement('div')
	miniCard.id = miniCardId
	miniCard.className = 'minimized-match-card'
	miniCard.innerHTML = `
        <div class="minimized-card-content" onclick="window.restoreMatchDetailsModal('${matchId}')">
            <span class="minimized-card-icon">📊</span>
            <span class="minimized-card-text">${currentMatchDetailsData.homeTeam} vs ${currentMatchDetailsData.awayTeam}</span>
        </div>
        <button class="minimized-card-close" onclick="window.closeMatchDetailsModalCompletely(event, '${matchId}')">×</button>
    `
	container.appendChild(miniCard)

	// Reposition all minimized match cards
	repositionMinimizedMatchCards()
}

function restoreMatchDetailsModal(matchId) {
	const miniCardId = `minimized-match-card-${matchId}`
	const miniCard = document.getElementById(miniCardId)
	if (miniCard) {
		miniCard.style.display = 'none'
	}

	// Get modal data
	const matchData = minimizedMatchModals.get(matchId)
	if (matchData) {
		showBetFinderMatchDetailsModal(matchData)
	}

	repositionMinimizedMatchCards()
}

function closeMatchDetailsModalCompletely(event, matchId) {
	event.stopPropagation()

	const miniCardId = `minimized-match-card-${matchId}`
	const miniCard = document.getElementById(miniCardId)
	if (miniCard) {
		miniCard.remove()
	}

	// Remove from map
	minimizedMatchModals.delete(matchId)
	saveMinimizedMatchCards()
	repositionMinimizedMatchCards()
}

function repositionMinimizedMatchCards() {
	const container = document.getElementById('minimized-cards-container')
	if (!container) return

	const matchCards = Array.from(
		container.querySelectorAll(
			'.minimized-match-card[style*="display: flex"], .minimized-match-card:not([style*="display: none"])'
		)
	)

	// Separate watched matches card from others
	const watchedCard = matchCards.find(card => card.id === 'minimized-watched-matches-card')
	const detailCards = matchCards.filter(card => card.id !== 'minimized-watched-matches-card')

	// Clear existing order and reappend in correct order
	// First, add detail cards (they stack above watched card)
	detailCards.forEach(card => {
		container.appendChild(card)
	})

	// Then add watched card at the end (bottom of container)
	if (watchedCard) {
		watchedCard.classList.add('watched-matches-card')
		container.appendChild(watchedCard)
	}
}

function openTeamStats(teamName) {
	// Switch to database tab and filter by team
	switchTab('database')

	// Wait for tab to switch and then filter
	setTimeout(() => {
		const teamSearchInput = document.getElementById('filter-team-search')
		if (teamSearchInput) {
			teamSearchInput.value = teamName
			// Trigger filtering to show matching teams
			filterSelectOptions('filter-team', 'filter-team-search')
		}

		// Set the select value
		const teamSelect = document.getElementById('filter-team')
		if (teamSelect) {
			teamSelect.value = teamName
			// Trigger search
			applyFilters()
		}
	}, 100)
}

function addToBackgroundJobs(homeTeam, awayTeam, league, date) {
	// TODO: Implement adding to background jobs
	console.log('Add to background jobs:', { homeTeam, awayTeam, league, date })
	showToast('Dodawanie do zadań w tle - funkcja w trakcie implementacji', 'info')
}

// =============================================================================
// EXPORT TO WINDOW (for onclick handlers in HTML)
// =============================================================================

window.init = init
window.showToast = showToast
window.setQuickDate = setQuickDate
window.filterSelectOptions = filterSelectOptions

// Country & League handlers
window.selectCountry = EventHandlers.selectCountry
window.toggleLeague = EventHandlers.toggleLeague
window.autoSelect = EventHandlers.autoSelect
window.clearAll = EventHandlers.clearAll
window.saveAndClose = EventHandlers.saveAndClose

// Tab switching
window.switchTab = EventHandlers.switchTab

// Limit handlers
window.setLimit = EventHandlers.setLimit
window.setLimitAndFilter = EventHandlers.setLimitAndFilter
window.setHomeAwayFilter = EventHandlers.setHomeAwayFilterHandler

// Import handlers
window.showImportDialog = showImportDialog
window.closeImportDialog = closeImportDialog
window.startImport = startImport
window.resumeImport = resumeImport
window.stopImport = stopImport
window.cancelImport = cancelImport
window.closeProgressDialog = closeProgressDialog

// Preset handlers
window.showSavePresetDialog = showSavePresetDialog
window.closeSavePresetDialog = closeSavePresetDialog
window.savePreset = savePreset
window.showLoadPresetDialog = showLoadPresetDialog
window.closeLoadPresetDialog = closeLoadPresetDialog
window.loadPreset = loadPreset
window.deletePreset = deletePreset

// Database filter handlers
window.onCountryFilterChange = onCountryFilterChange
window.onLeagueFilterChange = onLeagueFilterChange
window.onTeamFilterChange = onTeamFilterChange
window.applyFilters = applyFilters
window.resetFilters = resetFilters
window.onStatsLeagueChange = onStatsLeagueChange
window.applyLimitToResults = applyLimitToResults
window.loadTeamStats = loadTeamStats

// Statistics modal
window.closeStatModal = DOMUtils.closeStatModal

// Match details modal
window.showMatchDetailsModal = DOMUtils.showMatchDetailsModal
window.closeMatchDetailsModal = DOMUtils.closeMatchDetailsModal

// Bet finder match details modal (different from database match details)
window.showBetFinderMatchDetailsModal = showBetFinderMatchDetailsModal

// Background jobs (placeholders)
window.showBackgroundImportDialog = showBackgroundImportDialog
window.closeBackgroundImportDialog = closeBackgroundImportDialog
window.toggleAllBackgroundLeagues = toggleAllBackgroundLeagues
window.createBackgroundJob = createBackgroundJob
window.toggleHiddenJobs = toggleHiddenJobs
window.pauseJob = pauseJob
window.resumeJob = resumeJob
window.retryJob = retryJob
window.viewJobLogs = viewJobLogs
window.hideJob = hideJob
window.unhideJob = unhideJob
window.deleteJob = deleteJob

// Bet finder functions
window.findMostGoals = BetFinder.findMostGoals
window.findLeastGoals = BetFinder.findLeastGoals
window.findHandicap15 = BetFinder.findHandicap15
window.findMostCorners = BetFinder.findMostCorners
window.findLeastCorners = BetFinder.findLeastCorners
window.findGoalAdvantage = BetFinder.findGoalAdvantage
window.findWinnerVsLoser = BetFinder.findWinnerVsLoser
window.findMostTotalCorners = BetFinder.findMostTotalCorners
window.findLeastTotalCorners = BetFinder.findLeastTotalCorners
window.findCornerAdvantage = BetFinder.findCornerAdvantage
window.findMostTotalOffsides = BetFinder.findMostTotalOffsides
window.findLeastTotalOffsides = BetFinder.findLeastTotalOffsides
window.findMostOffsides = BetFinder.findMostOffsides
window.findLeastOffsides = BetFinder.findLeastOffsides

// Bet finder queue functions
window.queueMostGoals = BetFinder.queueMostGoals
window.queueLeastGoals = BetFinder.queueLeastGoals
window.queueHandicap15 = BetFinder.queueHandicap15
window.queueMostCorners = BetFinder.queueMostCorners
window.queueLeastCorners = BetFinder.queueLeastCorners
window.queueGoalAdvantage = BetFinder.queueGoalAdvantage
window.queueWinnerVsLoser = BetFinder.queueWinnerVsLoser
window.queueMostTotalCorners = BetFinder.queueMostTotalCorners
window.queueLeastTotalCorners = BetFinder.queueLeastTotalCorners
window.queueCornerAdvantage = BetFinder.queueCornerAdvantage
window.queueMostTotalOffsides = BetFinder.queueMostTotalOffsides
window.queueLeastTotalOffsides = BetFinder.queueLeastTotalOffsides
window.queueMostOffsides = BetFinder.queueMostOffsides
window.queueLeastOffsides = BetFinder.queueLeastOffsides

// Queue all searches by category
window.queueAllResultSearches = function() {
	BetFinder.queueWinnerVsLoser()
	showToast('Dodano 1 wyszukiwanie z kategorii "Rezultat" do kolejki', 'success')
}

window.queueAllGoalsSearches = function() {
	BetFinder.queueMostGoals()
	BetFinder.queueLeastGoals()
	BetFinder.queueGoalAdvantage()
	BetFinder.queueHandicap15()
	showToast('Dodano 4 wyszukiwania z kategorii "Bramki" do kolejki', 'success')
}

window.queueAllCornersSearches = function() {
	BetFinder.queueMostCorners()
	BetFinder.queueLeastCorners()
	BetFinder.queueMostTotalCorners()
	BetFinder.queueLeastTotalCorners()
	BetFinder.queueCornerAdvantage()
	showToast('Dodano 5 wyszukiwań z kategorii "Rożne" do kolejki', 'success')
}

window.queueAllOffsidesSearches = function() {
	BetFinder.queueMostOffsides()
	BetFinder.queueLeastOffsides()
	BetFinder.queueMostTotalOffsides()
	BetFinder.queueLeastTotalOffsides()
	showToast('Dodano 4 wyszukiwania z kategorii "Spalone" do kolejki', 'success')
}

// Bet finder modal helpers
window.minimizeModal = minimizeModal
window.closeModal = closeModal
window.minimizeMatchDetailsModal = minimizeMatchDetailsModal
window.restoreMatchDetailsModal = restoreMatchDetailsModal
window.closeMatchDetailsModalCompletely = closeMatchDetailsModalCompletely
window.openTeamStats = openTeamStats
window.addToBackgroundJobs = addToBackgroundJobs
window.restoreModal = restoreModal
window.closeModalCompletely = closeModalCompletely

// Watched matches functions
window.addToWatchedMatches = WatchedMatches.addToWatchedMatches
window.removeFromWatchedMatches = WatchedMatches.removeFromWatchedMatches
window.updateWatchedMatchOdds = WatchedMatches.updateWatchedMatchOdds
window.editWatchedMatchNote = WatchedMatches.editWatchedMatchNote
window.showWatchedMatchesModal = WatchedMatches.showWatchedMatchesModal
window.minimizeWatchedMatchesModal = WatchedMatches.minimizeWatchedMatchesModal
window.closeWatchedMatchesModal = WatchedMatches.closeWatchedMatchesModal
window.restoreWatchedMatchesModal = WatchedMatches.restoreWatchedMatchesModal

// Close stat modal on ESC key
document.addEventListener('keydown', function (e) {
	if (e.key === 'Escape') {
		const statModal = document.getElementById('statModal')
		if (statModal && statModal.classList.contains('active')) {
			DOMUtils.closeStatModal()
		}
	}
})

// Initialize on DOM load
if (document.readyState === 'loading') {
	document.addEventListener('DOMContentLoaded', init)
} else {
	init()
}
