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
			in_queue: 'W kolejce',
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
		
		const jobTypeLabel = job.job_type === 'update_results' ? '🔄 Aktualizacja wyników' : '🆕 Import nowych meczów'
		
			html += `
                <div class="job-card">
                    <div class="job-header">
                        <div class="job-title">Zadanie #${job.id}</div>
                        <span class="job-status-badge ${statusClass}">${statusText}</span>
                    </div>
                    
                    <div class="job-info">
                        <div>🎯 Typ: ${jobTypeLabel}</div>
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
													job.status === 'completed' || job.status === 'failed'
														? `
                            <button class="job-action-btn" style="background: #4caf50; color: white;" onclick="restartJob(${job.id})" title="Utwórz nowe zadanie z tymi samymi parametrami">🔄 Wykonaj ponownie</button>
                        `
														: ''
												}
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

		// Załaduj kolejkę importu na starcie
		await refreshImportQueue()

		// Odświeżaj kolejkę co 5 sekund
		setInterval(refreshImportQueue, 5000)

		// Inicjalizuj bet finder (ustawia domyślne daty i event listenery)
		EventHandlers.initBetFinder()

		// Load watched matches and show card
		WatchedMatches.loadWatchedMatches()

		// Load minimized match details cards
		loadMinimizedMatchCards()

		// Load minimized TOP 10 modals
		loadMinimizedModals()
		WatchedMatches.ensureWatchedMatchesCard() // Show minimized card only

		// Create control buttons for minimized containers
		createMinimizedControls()

		console.log('✅ Application initialized successfully')
	} catch (error) {
		console.error('❌ Error initializing application:', error)
		showToast('Błąd podczas inicjalizacji aplikacji', 'error')
	}
}
// Background jobs refresh handler
window.refreshBackgroundJobs = refreshBackgroundJobs
window.refreshImportQueue = refreshImportQueue

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
	
	// Clear league filter to show all competitions
	document.getElementById('filter-league').value = ''

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

	console.log('🔍 Filter values - Country:', country, 'League:', league, 'Team:', team)

	try {
		const filters = {}
		// When team is selected, show ALL their matches from all competitions (no country/league filters)
		if (team) {
			console.log('🚫 Skipping country & league filters because team is selected:', team)
			filters.team = team
		} else {
			// No team selected - apply country/league filters normally
			if (country) filters.country = country
			if (league) {
				console.log('✅ Adding league filter:', league, '(no team selected)')
				filters.league = league
			}
		}

		console.log('📦 Final filters object:', filters)
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
		
		// Filter matches by selected league (if not "all")
		let filteredMatches = matches
		if (leagueFilter !== 'all') {
			filteredMatches = matches.filter(m => m.league === leagueFilter)
		}
		
		// Apply limit if set
		if (state.selectedLimit) {
			filteredMatches = filteredMatches.sort((a, b) => new Date(b.match_date) - new Date(a.match_date)).slice(0, state.selectedLimit)
		}

		// Calculate statistics based on league filter
		const stats = Statistics.calculateTeamStatistics(state.selectedTeamForColoring, matches, leagueFilter)
		const availableLeagues = [...new Set(matches.map(m => m.league))]
		DOMUtils.displayTeamStatistics(stats, availableLeagues)
		document.getElementById('stats-league-filter').value = leagueFilter
		
		// Display filtered matches
		DOMUtils.displayDatabaseResults(filteredMatches)
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

		// Add listener for job type change
		const jobTypeSelect = document.getElementById('background-job-type')
		const descriptionElem = document.getElementById('job-type-description')
		
		jobTypeSelect.addEventListener('change', function() {
			if (this.value === 'update_results') {
				descriptionElem.textContent = 'Aktualizuje wyniki meczów, które są w bazie jako nierozegrane (is_finished=no).'
			} else {
				descriptionElem.textContent = 'Importuje nadchodzące mecze dla wybranych lig.'
			}
		})

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
	const jobType = document.getElementById('background-job-type').value

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
		const result = await API.createBackgroundJob({ leagueIds, dateFrom, dateTo, jobType })

		closeBackgroundImportDialog()
		const jobTypeLabel = jobType === 'update_results' ? 'Aktualizacja wyników' : 'Import nowych meczów'
		showToast(
			`✅ Zadanie utworzone! ID: ${result.jobId}\n\nTyp: ${jobTypeLabel}\nStart: automatycznie w ciągu 60 sekund.`,
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

async function restartJob(jobId) {
	if (!confirm('Czy na pewno utworzyć nowe zadanie z tymi samymi parametrami?')) return

	try {
		const response = await fetch(`/api/import-jobs/${jobId}/restart`, {
			method: 'POST',
		})

		if (!response.ok) {
			const error = await response.json()
			throw new Error(error.error || 'Błąd restartu zadania')
		}

		const result = await response.json()
		await refreshBackgroundJobs()
		showToast(`✅ ${result.message}`, 'success')
	} catch (error) {
		console.error('Error restarting job:', error)
		showToast('Błąd podczas restartu zadania: ' + error.message, 'error')
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

/**
 * Get color for modal type
 */
function getModalTypeColor(modalType) {
	if (!modalType) return 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' // Default
	
	// Rezultat - cyjan
	if (modalType.includes('winner') || modalType.includes('loser')) {
		return 'linear-gradient(135deg, #06b6d4 0%, #0891b2 100%)'
	}
	
	// Bramki - fioletowy
	if (modalType.includes('goal') || modalType.includes('bts') || modalType.includes('handicap')) {
		return 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)'
	}
	
	// Rożne - fioletowy ciemniejszy
	if (modalType.includes('corner')) {
		return 'linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%)'
	}
	
	// Spalone - zielony
	if (modalType.includes('offside')) {
		return 'linear-gradient(135deg, #10b981 0%, #059669 100%)'
	}
	
	// Dom/Wyjazd - pomarańczowy
	if (modalType.includes('home') || modalType.includes('away') || modalType.includes('advantage')) {
		return 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)'
	}
	
	return 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' // Default
}

// Store minimized modals data
const minimizedModals = new Map()

function saveMinimizedModals() {
	const modalsData = Array.from(minimizedModals.entries()).map(([id, data]) => ({
		id,
		title: data.title,
		results: data.results,
		modalType: data.modalType,
		dateFrom: data.dateFrom,
		dateTo: data.dateTo,
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
		
		// Clear existing cards to prevent duplicates on page reload
		container.innerHTML = ''
		
		modalsData.forEach(({ id, title, results, modalType, dateFrom, dateTo }) => {
				minimizedModals.set(id, { title, results, modalType, dateFrom, dateTo })

				// Recreate the minimized card
				const miniCardId = `minimized-modal-card-${id}`
				if (!document.getElementById(miniCardId)) {
					const miniCard = document.createElement('div')
					miniCard.id = miniCardId
					miniCard.className = 'minimized-card'
					const cardColor = getModalTypeColor(modalType)
					miniCard.style.background = cardColor
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

	// Get modalId from data attribute
	const modalId = modal.dataset.modalId
	if (!modalId) {
		console.error('Modal missing modalId data attribute')
		return
	}

	// Get modal data from BetFinder's store
	const modalData = BetFinder.getModalData(modalId)
	if (!modalData) {
		console.error('Modal data not found for modalId:', modalId)
		return
	}

	// Remove modal from DOM (not just hide it)
	modal.remove()

	// Store modal data
	minimizedModals.set(modalId, modalData)
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
		const cardColor = getModalTypeColor(modalData.modalType)
		miniCard.style.background = cardColor
		miniCard.innerHTML = `
            <div class="minimized-card-content" onclick="window.restoreModal('${modalId}')">
                <span class="minimized-card-icon">⚽</span>
                <span class="minimized-card-text">${modalData.title}</span>
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
	
	// Get stored modal data
	const modalData = minimizedModals.get(modalId)
	if (!modalData) {
		showToast('Nie można odtworzyć modalu: brak danych', 'error')
		return
	}

	// If there's a different modal open, minimize it first
	if (modal) {
		const currentModalId = modal.dataset.modalId
		if (currentModalId !== modalId) {
			// Different modal is open - minimize it
			minimizeModal()
		}
	}

	// Recreate modal using the appropriate show function based on modalType
	const showFunction = BetFinder.modalTypeToShowFunction[modalData.modalType]
	if (showFunction) {
		showFunction(modalData)
	} else {
		showToast('Nie można odtworzyć modalu: nieznany typ', 'error')
		console.error('Unknown modalType:', modalData.modalType)
		return
	}

	// Hide minimized card
	if (miniCard) {
		miniCard.style.display = 'none'
	}
}

function closeModalCompletely(event, modalId) {
	event.stopPropagation()

	// Show confirmation dialog
	const confirmed = confirm('Czy na pewno chcesz zamknąć ten modal?')
	if (!confirmed) {
		return // User cancelled, don't close
	}

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

// Helper function to format team name with standing position
function formatTeamWithStanding(teamName, standing, matchDate) {
	if (!standing) return teamName
	
	// Check if standing is approximate (from future match)
	const isApproximate = standing.isApproximate || false
	const standingValue = standing.standing || standing
	
	// Gray out if approximate OR before November 2025
	const cutoffDate = new Date('2025-11-01')
	const date = new Date(matchDate)
	const isBeforeCutoff = date < cutoffDate
	
	const standingColor = (isApproximate || isBeforeCutoff) ? '#999' : '#000'
	return `${teamName} <span style="font-size: 10px; color: ${standingColor};">(${standingValue})</span>`
}

async function showBetFinderMatchDetailsModal(result) {
	console.log('Match details:', result)

	if (!result || !result.homeStats || !result.awayStats) {
		showToast('Brak danych do wyświetlenia', 'warning')
		return
	}

	// Load Superbet link and Flashscore link for this league
	const { getSuperbetLink, createSuperbetIcon, getFlashscoreLink, createFlashscoreButton } = await import('./utils/superbet-links.js')
	
	// Try using leagueId first, fallback to league+country
	let superbetUrl, flashscoreUrl
	if (result.leagueId) {
		superbetUrl = await getSuperbetLink(result.leagueId)
		flashscoreUrl = await getFlashscoreLink(result.leagueId)
	} else {
		superbetUrl = await getSuperbetLink(result.league, result.country)
		flashscoreUrl = await getFlashscoreLink(result.league, result.country)
	}

	// Store current match data for minimization
	currentMatchDetailsData = result

	// Check if this is a home/away search type
	const isHomeAwaySearch = ['home-wins', 'away-wins', 'home-losses', 'away-losses', 'home-advantage', 'away-advantage'].includes(result.searchType)

	// Generate modal HTML
	// For home/away searches, filter matches appropriately based on search type:
	let homeMatches = result.homeStats.matches || []
	let awayMatches = result.awayStats.matches || []
	
	if (isHomeAwaySearch) {
		if (result.searchType === 'home-wins' || result.searchType === 'home-losses') {
			// Home wins/losses: Home team = only HOME matches, Away team = ALL matches
			homeMatches = homeMatches.filter(m => m.isHome === true)
			// awayMatches stays as is (all matches)
		} else if (result.searchType === 'away-wins' || result.searchType === 'away-losses') {
			// Away wins/losses: Home team = ALL matches, Away team = only AWAY matches
			// homeMatches stays as is (all matches)
			awayMatches = awayMatches.filter(m => m.isHome === false)
		} else if (result.searchType === 'home-advantage' || result.searchType === 'away-advantage') {
			// Both advantages: Home team = only HOME matches, Away team = only AWAY matches
			homeMatches = homeMatches.filter(m => m.isHome === true)
			awayMatches = awayMatches.filter(m => m.isHome === false)
		}
	}

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
		// Corners-based search (obie drużyny wykonują najwięcej/najmniej)
		searchType = 'corners'
		avgThreshold = result.averageCorners
		isLeastSearch = result.searchType === 'least-corners'
		homeStatsText = `Śr. rożnych wykonywanych: ${result.homeStats.avgCorners || 0} (${
			result.homeStats.cornersMatchCount || 0
		} meczów)`
		awayStatsText = `Śr. rożnych wykonywanych: ${result.awayStats.avgCorners || 0} (${
			result.awayStats.cornersMatchCount || 0
		} meczów)`
		mainStatText = `Łączna średnia rożnych wykonywanych: ${result.averageCorners}`
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
	} else if (result.searchType === 'most-single-corners' || result.searchType === 'least-single-corners') {
		// Single team corners search
		searchType = result.searchType
		avgThreshold = result.averageCorners || 0
		isLeastSearch = result.searchType === 'least-single-corners'
		// Identify which team is home/away
		const isStrongHome = result.strongTeam === result.homeTeam
		if (result.searchType === 'most-single-corners') {
			homeStatsText = isStrongHome 
				? `Śr. wykonywanych: ${result.strongAvgFor || 0}`
				: `Śr. traconych: ${result.weakAvgAgainst || 0}`
			awayStatsText = isStrongHome
				? `Śr. traconych: ${result.weakAvgAgainst || 0}`
				: `Śr. wykonywanych: ${result.strongAvgFor || 0}`
			mainStatText = `Łączna średnia: ${result.averageCorners} (${result.strongTeam}: ${result.strongAvgFor} wykonywanych)`
		} else {
			homeStatsText = isStrongHome
				? `Śr. traconych: ${result.strongAvgAgainst || 0}`
				: `Śr. wykonywanych: ${result.weakAvgFor || 0}`
			awayStatsText = isStrongHome
				? `Śr. wykonywanych: ${result.weakAvgFor || 0}`
				: `Śr. traconych: ${result.strongAvgAgainst || 0}`
			mainStatText = `Łączna średnia: ${result.averageCorners} (${result.weakTeam}: ${result.weakAvgFor} wykonywanych)`
		}
	} else if (result.searchType === 'most-team-corners' || result.searchType === 'least-team-corners') {
		// Team corners search (drużyna)
		searchType = result.searchType
		avgThreshold = result.averageCorners || 0
		isLeastSearch = result.searchType === 'least-team-corners'
		const isStrongHome = result.strongTeam === result.homeTeam
		if (result.searchType === 'most-team-corners') {
			homeStatsText = isStrongHome 
				? `Śr. wykonywanych: ${result.strongAvgFor || 0}`
				: `Śr. traconych: ${result.weakAvgAgainst || 0}`
			awayStatsText = isStrongHome
				? `Śr. traconych: ${result.weakAvgAgainst || 0}`
				: `Śr. wykonywanych: ${result.strongAvgFor || 0}`
			mainStatText = `Łączna średnia: ${result.averageCorners} (${result.strongTeam}: ${result.strongAvgFor} wykonywanych)`
		} else {
			homeStatsText = isStrongHome
				? `Śr. traconych: ${result.strongAvgAgainst || 0}`
				: `Śr. wykonywanych: ${result.weakAvgFor || 0}`
			awayStatsText = isStrongHome
				? `Śr. wykonywanych: ${result.weakAvgFor || 0}`
				: `Śr. traconych: ${result.strongAvgAgainst || 0}`
			mainStatText = `Łączna średnia: ${result.averageCorners} (${result.weakTeam}: ${result.weakAvgFor} wykonywanych)`
		}
	} else if (result.averageTotalCorners !== undefined) {
		// Total corners search (both most and least)
		searchType = result.searchType === 'total-corners-least' ? 'total-corners-least' : 'total-corners'
		avgThreshold = result.averageTotalCorners
		isLeastSearch = result.searchType === 'total-corners-least'
		homeStatsText = `Śr. suma rożnych w meczach: ${result.homeStats.avgMatchCorners || 0} (${
			result.homeStats.cornersMatchCount || 0
		} meczów)`
		awayStatsText = `Śr. suma rożnych w meczach: ${result.awayStats.avgMatchCorners || 0} (${
			result.awayStats.cornersMatchCount || 0
		} meczów)`
		mainStatText = `Łączna średnia suma rożnych w meczu: ${result.averageTotalCorners}`
	} else if (result.averageTotalOffsides !== undefined) {
		// Total offsides search (both most and least)
		searchType = result.searchType === 'total-offsides-least' ? 'total-offsides-least' : 'total-offsides'
		avgThreshold = result.averageTotalOffsides
		isLeastSearch = result.searchType === 'total-offsides-least'
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
	} else if (isHomeAwaySearch) {
		// Home/Away win/loss statistics
		searchType = result.searchType
		avgThreshold = 0
		
		if (result.searchType === 'home-wins') {
			homeStatsText = `Wygrane u siebie: ${result.homeStats.homeWins || 0}/${result.homeStats.homeMatchCount || 0} (${result.homeWinPercent || 0}%)`
			awayStatsText = `Meczów: ${result.awayStats.homeMatchCount || 0} (śr. goście)`
			mainStatText = `Procent wygranych gospodarzy: ${result.homeWinPercent}%`
		} else if (result.searchType === 'away-wins') {
			homeStatsText = `Meczów: ${result.homeStats.homeMatchCount || 0} (śr. gospodarze)`
			awayStatsText = `Wygrane na wyjeździe: ${result.awayStats.awayWins || 0}/${result.awayStats.awayMatchCount || 0} (${result.awayWinPercent || 0}%)`
			mainStatText = `Procent wygranych gości: ${result.awayWinPercent}%`
		} else if (result.searchType === 'home-losses') {
			homeStatsText = `Porażki u siebie: ${result.homeStats.homeLosses || 0}/${result.homeStats.homeMatchCount || 0} (${result.homeLossPercent || 0}%)`
			awayStatsText = `Meczów: ${result.awayStats.awayMatchCount || 0} (śr. goście)`
			mainStatText = `Procent porażek gospodarzy: ${result.homeLossPercent}%`
		} else if (result.searchType === 'away-losses') {
			homeStatsText = `Meczów: ${result.homeStats.homeMatchCount || 0} (śr. gospodarze)`
			awayStatsText = `Porażki na wyjeździe: ${result.awayStats.awayLosses || 0}/${result.awayStats.awayMatchCount || 0} (${result.awayLossPercent || 0}%)`
			mainStatText = `Procent porażek gości: ${result.awayLossPercent}%`
		} else if (result.searchType === 'home-advantage') {
			homeStatsText = `Wygrane u siebie: ${result.homeStats.homeWins || 0}/${result.homeStats.homeMatchCount || 0} (${result.homeWinPercent || 0}%)`
			awayStatsText = `Porażki na wyjeździe: ${result.awayStats.awayLosses || 0}/${result.awayStats.awayMatchCount || 0} (${result.awayLossPercent || 0}%)`
			mainStatText = `Wynik przewagi gospodarzy: ${result.advantageScore}%`
		} else if (result.searchType === 'away-advantage') {
			homeStatsText = `Porażki u siebie: ${result.homeStats.homeLosses || 0}/${result.homeStats.homeMatchCount || 0} (${result.homeLossPercent || 0}%)`
			awayStatsText = `Wygrane na wyjeździe: ${result.awayStats.awayWins || 0}/${result.awayStats.awayMatchCount || 0} (${result.awayWinPercent || 0}%)`
			mainStatText = `Wynik przewagi gości: ${result.advantageScore}%`
		}
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
		} else if (searchType === 'corners') {
			// Obie drużyny - pokazuj rożne wykonywane przez każdą drużynę osobno
			if (match.homeCorners != null && match.awayCorners != null) {
				const teamName = isHomeTeam ? result.homeTeam : result.awayTeam
				const isTeamHome = match.homeTeam === teamName
				statValue = isTeamHome ? match.homeCorners : match.awayCorners
				statLabel = `${statValue} rż.`
			} else {
				return '<span style="color: #999;">—</span>'
			}
		} else if (searchType === 'total-corners' || searchType === 'total-corners-least') {
			// Mecz - pokazuj sumę rożnych w meczu
			if (match.homeCorners != null && match.awayCorners != null) {
				statValue = (match.homeCorners || 0) + (match.awayCorners || 0)
				statLabel = `${statValue} rż.`
			} else {
				return '<span style="color: #999;">—</span>'
			}
		} else if (searchType === 'most-single-corners' || searchType === 'least-single-corners') {
			// Jedna drużyna - pokazuj rożne wykonywane przez silniejszą/słabszą lub tracone przez drugą
			if (match.homeCorners != null && match.awayCorners != null) {
				const teamName = isHomeTeam ? result.homeTeam : result.awayTeam
				const isTeamHome = match.homeTeam === teamName
				const isStrongTeam = teamName === result.strongTeam
				
				if (searchType === 'most-single-corners') {
					// Dla silnej drużyny pokazuj wykonywane, dla słabej tracone
					if (isStrongTeam) {
						statValue = isTeamHome ? match.homeCorners : match.awayCorners
					} else {
						// Słaba drużyna - pokazuj tracone (rożne przeciwnika)
						statValue = isTeamHome ? match.awayCorners : match.homeCorners
					}
				} else {
					// least-single-corners: dla słabej pokazuj wykonywane, dla silnej tracone
					if (!isStrongTeam) {
						statValue = isTeamHome ? match.homeCorners : match.awayCorners
					} else {
						// Silna drużyna - pokazuj tracone
						statValue = isTeamHome ? match.awayCorners : match.homeCorners
					}
				}
				statLabel = `${statValue} rż.`
			} else {
				return '<span style="color: #999;">—</span>'
			}
		} else if (searchType === 'most-team-corners' || searchType === 'least-team-corners') {
			// Team corners (drużyna) - pokazuj rożne wykonywane
			if (match.homeCorners != null && match.awayCorners != null) {
				const teamName = isHomeTeam ? result.homeTeam : result.awayTeam
				const isTeamHome = match.homeTeam === teamName
				const isStrongTeam = teamName === result.strongTeam
				
				if (searchType === 'most-team-corners') {
					if (isStrongTeam) {
						statValue = isTeamHome ? match.homeCorners : match.awayCorners
					} else {
						statValue = isTeamHome ? match.awayCorners : match.homeCorners
					}
				} else {
					if (!isStrongTeam) {
						statValue = isTeamHome ? match.homeCorners : match.awayCorners
					} else {
						statValue = isTeamHome ? match.awayCorners : match.homeCorners
					}
				}
				statLabel = `${statValue} rż.`
			} else {
				return '<span style="color: #999;">—</span>'
			}
		} else if (searchType === 'corner-advantage') {
			// Przewaga - pokazuj rożne wykonywane przez silną drużynę lub tracone przez słabą
			if (match.homeCorners != null && match.awayCorners != null) {
				const teamName = isHomeTeam ? result.homeTeam : result.awayTeam
				const isTeamHome = match.homeTeam === teamName
				statValue = isTeamHome ? match.homeCorners : match.awayCorners
				statLabel = `${statValue} rż.`
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
		} else if (isHomeAwaySearch) {
			// For home/away searches, show result with color coding (W/D/L)
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
			// For handicap search, calculate goal difference from team perspective
			const teamName = isHomeTeam ? result.homeTeam : result.awayTeam
			const isTeamHome = match.homeTeam === teamName
			const teamGoals = isTeamHome ? match.homeGoals : match.awayGoals
			const opponentGoals = isTeamHome ? match.awayGoals : match.homeGoals
			statValue = (teamGoals || 0) - (opponentGoals || 0)
			statLabel = statValue > 0 ? `+${statValue}` : `${statValue}`
		} else if (searchType === 'advantage') {
			// Calculate goal difference from the perspective of the team we're analyzing
			if (isHomeTeam) {
				// We're looking at home team stats - calculate from their perspective
				if (match.homeTeam === result.homeTeam) {
					// Team played as home
					statValue = (match.homeGoals || 0) - (match.awayGoals || 0)
				} else {
					// Team played as away
					statValue = (match.awayGoals || 0) - (match.homeGoals || 0)
				}
			} else {
				// We're looking at away team stats - calculate from their perspective
				if (match.homeTeam === result.awayTeam) {
					// Team played as home
					statValue = (match.homeGoals || 0) - (match.awayGoals || 0)
				} else {
					// Team played as away
					statValue = (match.awayGoals || 0) - (match.homeGoals || 0)
				}
			}
			statLabel = statValue > 0 ? `+${statValue}` : `${statValue}`
		} else {
			return ''
		}

		// Determine color based on comparison with average
		let color = '#666'
		let bgColor = 'transparent'
		
		if (searchType === 'goals') {
			// Bramki - normalna logika
			if (statValue >= avgThreshold) {
				color = '#059669'
				bgColor = '#d1fae5'
			} else {
				color = '#dc2626'
				bgColor = '#fee2e2'
			}
		} else if (searchType === 'corners') {
			// Obie drużyny - najwyżej/najmniej wykonywanych
			if (isLeastSearch) {
				// Najmniej - zielone gdy <= średnia, czerwone gdy > średnia
				if (statValue <= avgThreshold) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			} else {
				// Najwięcej - zielone gdy >= średnia, czerwone gdy < średnia
				if (statValue >= avgThreshold) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			}
		} else if (searchType === 'total-corners' || searchType === 'total-corners-least') {
			// Mecz - suma rożnych
			if (searchType === 'total-corners-least') {
				// Najmniej - czerwone gdy > średnia, zielone gdy <= średnia
				if (statValue <= avgThreshold) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			} else {
				// Najwięcej - zielone gdy >= średnia, czerwone gdy < średnia
				if (statValue >= avgThreshold) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			}
		} else if (searchType === 'most-single-corners') {
			// Jedna drużyna - najwięcej
			const teamName = isHomeTeam ? result.homeTeam : result.awayTeam
			const isStrongTeam = teamName === result.strongTeam
			
			if (isStrongTeam) {
				// Silna drużyna (wykonuje najwięcej) - porównuj z jej średnią wykonywanych
				const avgFor = parseFloat(result.strongAvgFor) || 0
				if (statValue >= avgFor) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			} else {
				// Słaba drużyna (traci) - porównuj z jej średnią traconych (odwrotnie)
				const avgAgainst = parseFloat(result.weakAvgAgainst) || 0
				if (statValue >= avgAgainst) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			}
		} else if (searchType === 'least-single-corners') {
			// Jedna drużyna - najmniej
			const teamName = isHomeTeam ? result.homeTeam : result.awayTeam
			const isStrongTeam = teamName === result.strongTeam
			
			if (!isStrongTeam) {
				// Słaba drużyna (wykonuje najmniej) - zielone gdy <= średnia wykonywanych
				const avgFor = parseFloat(result.weakAvgFor) || 0
				if (statValue <= avgFor) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			} else {
				// Silna drużyna (traci) - czerwone gdy > średnia traconych, zielone gdy <=
				const avgAgainst = parseFloat(result.strongAvgAgainst) || 0
				if (statValue <= avgAgainst) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			}
		} else if (searchType === 'most-team-corners') {
			// Najwięcej rożnych (drużyna)
			const teamName = isHomeTeam ? result.homeTeam : result.awayTeam
			const isStrongTeam = teamName === result.strongTeam
			
			if (isStrongTeam) {
				const avgFor = parseFloat(result.strongAvgFor) || 0
				if (statValue >= avgFor) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			} else {
				const avgAgainst = parseFloat(result.weakAvgAgainst) || 0
				if (statValue >= avgAgainst) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			}
		} else if (searchType === 'least-team-corners') {
			// Najmniej rożnych (drużyna)
			const teamName = isHomeTeam ? result.homeTeam : result.awayTeam
			const isStrongTeam = teamName === result.strongTeam
			
			if (!isStrongTeam) {
				const avgFor = parseFloat(result.weakAvgFor) || 0
				if (statValue <= avgFor) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			} else {
				const avgAgainst = parseFloat(result.strongAvgAgainst) || 0
				if (statValue <= avgAgainst) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			}
		} else if (searchType === 'corner-advantage') {
			// Przewaga rożnych
			const teamName = isHomeTeam ? result.homeTeam : result.awayTeam
			const isStrongTeam = teamName === result.strongTeam
			
			if (isStrongTeam) {
				// Silna drużyna (wykonuje dużo) - porównuj z jej średnią wykonywanych
				const avgFor = parseFloat(result.strongTeamCornersFor) || 0
				if (statValue >= avgFor) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			} else {
				// Słaba drużyna (traci dużo) - porównuj z jej średnią traconych
				const avgAgainst = parseFloat(result.weakTeamCornersAgainst) || 0
				if (statValue >= avgAgainst) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			}
		} else if (
			searchType === 'most-offsides' ||
			searchType === 'least-offsides' ||
			searchType === 'total-offsides' ||
			searchType === 'total-offsides-least'
		) {
			// Spalone - podobna logika jak rożne
			if (
				searchType === 'least-offsides' ||
				searchType === 'total-offsides-least'
			) {
				if (statValue <= avgThreshold) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			} else {
				if (statValue >= avgThreshold) {
					color = '#059669'
					bgColor = '#d1fae5'
				} else {
					color = '#dc2626'
					bgColor = '#fee2e2'
				}
			}
		} else if (searchType === 'handicap') {
			// For handicap, green only for wins by 2+ goals, red for everything else
			if (statValue >= 2) {
				color = '#059669'
				bgColor = '#d1fae5'
			} else {
				color = '#dc2626'
				bgColor = '#fee2e2'
			}
		} else if (searchType === 'advantage') {
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
            <div class="modal-header" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); position: relative;">
                <h2>📊 Szczegóły: ${result.homeTeam} vs ${result.awayTeam}</h2>
                <div style="display: flex; gap: 10px; align-items: center;">
                    ${superbetUrl ? createSuperbetIcon(superbetUrl) : ''}
                    <button class="btn-small" style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; border: none; padding: 8px 16px; border-radius: 6px; font-size: 14px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);" onclick="window.addToStrefaTypera('${result.homeTeam.replace(/'/g, "\\'")}', '${result.awayTeam.replace(/'/g, "\\'")}', '${result.league.replace(/'/g, "\\'")}', '${result.date}', '${result.country?.replace(/'/g, "\\'") || ''}', ${result.leagueId || 'null'})" title="Dodaj do Strefa Typera">
                        📄 ST
                    </button>
                    <button class="btn-small" style="background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%); color: white; border: none; padding: 8px 16px; border-radius: 6px; font-size: 14px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);" onclick="window.addToWatchedMatches(${JSON.stringify(result).replace(/"/g, '&quot;')}, '${result.searchType || 'manual'}')">
                        ⭐
                    </button>
                    ${flashscoreUrl ? createFlashscoreButton(flashscoreUrl) : ''}
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
                                                <td style="font-size: 11px;">
                                                    ${formatTeamWithStanding(m.homeTeam, m.standing_home, m.date)} - 
                                                    ${formatTeamWithStanding(m.awayTeam, m.standing_away, m.date)}
                                                </td>
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
                                                <td style="font-size: 11px;">
                                                    ${formatTeamWithStanding(m.homeTeam, m.standing_home, m.date)} - 
                                                    ${formatTeamWithStanding(m.awayTeam, m.standing_away, m.date)}
                                                </td>
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

	// If there's an existing match details modal, minimize it instead of removing it
	const existingModal = document.getElementById('match-details-modal')
	if (existingModal) {
		// Call the minimize function
		if (window.minimizeMatchDetailsModal) {
			window.minimizeMatchDetailsModal()
		} else {
			existingModal.remove() // Fallback if minimizeMatchDetailsModal not available
		}
	}

	// Create and show modal
	const modalContainer = document.createElement('div')
	modalContainer.id = 'match-details-modal'
	modalContainer.innerHTML = modalHTML
	document.body.appendChild(modalContainer)
	
	// Add show class and display after a small delay to trigger animations
	setTimeout(() => {
		modalContainer.classList.add('show')
		modalContainer.style.display = 'block'
	}, 10)
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
		const container = ensureCardsContainer()
		
		// Clear existing cards to prevent duplicates on page reload
		container.innerHTML = ''
		
		cardsData.forEach(({ id, data }) => {
				minimizedMatchModals.set(id, data)

				// Recreate the minimized card
				const miniCardId = `minimized-match-card-${id}`
				if (!document.getElementById(miniCardId)) {
					const miniCard = document.createElement('div')
					miniCard.id = miniCardId
					miniCard.className = 'minimized-match-card'
					
					// Extract country code (first 3 letters)
					const countryCode = (data.country || 'INT').substring(0, 3).toUpperCase()
					
					miniCard.innerHTML = `
                        <button class="minimized-card-close" onclick="window.closeMatchDetailsModalCompletely(event, '${id}')" style="order: 1;">×</button>
                        <div class="minimized-card-content" onclick="window.restoreMatchDetailsModal('${id}')" style="order: 2; flex: 1;">
                            <span class="minimized-card-icon">📊</span>
                            <span class="minimized-card-text">${data.homeTeam} vs ${data.awayTeam}</span>
                        </div>
                        <span style="order: 3; font-size: 11px; font-weight: 700; color: #6b7280; padding: 0 8px;">${countryCode}</span>
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
		// Card already exists, just show it and hide modal
		existingMiniCard.style.display = 'flex'
		if (modal) {
			modal.style.display = 'none'
		}
		repositionMinimizedMatchCards()
		return
	}

	// No modal to minimize
	if (!modal) return

	// Hide modal (don't remove it - we need it for restore)
	modal.style.display = 'none'
	modal.classList.remove('show')

	// Store modal data
	minimizedMatchModals.set(matchId, currentMatchDetailsData)
	saveMinimizedMatchCards()

	// Ensure container exists
	const container = ensureCardsContainer()

	// Create minimized card
	const miniCard = document.createElement('div')
	miniCard.id = miniCardId
	miniCard.className = 'minimized-match-card'
	
	// Extract country code (first 3 letters)
	const countryCode = (currentMatchDetailsData.country || 'INT').substring(0, 3).toUpperCase()
	
	miniCard.innerHTML = `
        <button class="minimized-card-close" onclick="window.closeMatchDetailsModalCompletely(event, '${matchId}')" style="order: 1;">×</button>
        <div class="minimized-card-content" onclick="window.restoreMatchDetailsModal('${matchId}')" style="order: 2; flex: 1;">
            <span class="minimized-card-icon">📊</span>
            <span class="minimized-card-text">${currentMatchDetailsData.homeTeam} vs ${currentMatchDetailsData.awayTeam}</span>
        </div>
        <span style="order: 3; font-size: 11px; font-weight: 700; color: #6b7280; padding: 0 8px;">${countryCode}</span>
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

	// Check if modal already exists (hidden)
	const modal = document.getElementById('match-details-modal')
	if (modal) {
		// Modal exists, just show it
		modal.style.display = 'block'
		modal.classList.add('show')
	} else {
		// Get modal data and recreate
		const matchData = minimizedMatchModals.get(matchId)
		if (matchData) {
			showBetFinderMatchDetailsModal(matchData)
		}
	}

	repositionMinimizedMatchCards()
}

function closeMatchDetailsModalCompletely(event, matchId) {
	if (event) {
		event.stopPropagation()
	}

	const miniCardId = `minimized-match-card-${matchId}`
	const miniCard = document.getElementById(miniCardId)
	if (miniCard) {
		miniCard.remove()
	}

	// Also remove the modal if it exists (hidden)
	const modal = document.getElementById('match-details-modal')
	if (modal) {
		modal.remove()
	}
	currentMatchDetailsData = null

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

/**
 * Add match to Strefa Typera spreadsheet
 */
async function addToStrefaTypera(homeTeam, awayTeam, league, date, country, leagueId) {
	try {
		// Step 1: Choose bet type
		const betType = await showBetTypeDialog()
		if (!betType) return // User cancelled
		
		// Step 2: Choose bet option based on bet type (skip for 1 and 2)
		let betOption
		if (betType === '1' || betType === '2') {
			betOption = '-' // No option needed for win bets
		} else {
			betOption = await showBetOptionDialog(betType)
			if (!betOption) return // User cancelled
		}
		
		// Step 3: Enter odds
		const odds = await showOddsDialog()
		if (!odds) return // User cancelled
		
		// Step 4: Get links automatically from Lista rozgrywek.csv (KROK 30)
		const { getSuperbetLink, getFlashscoreLink } = await import('./utils/superbet-links.js')
		let superbetLink = ''
		let flashscoreLink = ''
		
		// Try by league ID first, fallback to league name + country
		if (leagueId) {
			superbetLink = await getSuperbetLink(leagueId) || ''
			flashscoreLink = await getFlashscoreLink(leagueId) || ''
		}
		
		// Fallback to name-based lookup
		if (!superbetLink && !flashscoreLink && league && country) {
			superbetLink = await getSuperbetLink(league, country) || ''
			flashscoreLink = await getFlashscoreLink(league, country) || ''
		}
		
		showToast('Dodawanie do Strefa Typera...', 'info')

		const response = await fetch('/api/strefa-typera/add-match-full', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({ 
				homeTeam, 
				awayTeam, 
				league, 
				date, 
				betType, 
				betOption, 
				odds,
				superbetLink,
				flashscoreLink
			}),
		})

		const result = await response.json()

		if (!response.ok) {
			throw new Error(result.error || 'Błąd dodawania do Strefa Typera')
		}

		showToast(`✅ Dodano ${result.rowsAdded} wiersze do Strefa Typera`, 'success')
	} catch (error) {
		console.error('Error adding to Strefa Typera:', error)
		showToast(`❌ ${error.message}`, 'error')
	}
}

/**
 * Show bet type selection dialog
 */
function showBetTypeDialog() {
	return new Promise((resolve) => {
		const modal = document.createElement('div')
		modal.className = 'modal-overlay'
		modal.style.display = 'flex'
		modal.style.zIndex = '100000'
		
		modal.innerHTML = `
			<div class="modal-content" style="max-width: 400px;">
				<div class="modal-header">
					<h2>Wybierz zakład</h2>
					<button class="modal-close" onclick="this.closest('.modal-overlay').remove(); window.betTypeResolve(null)">×</button>
				</div>
				<div class="modal-body">
					<div style="display: flex; flex-direction: column; gap: 10px;">
						<button class="bet-type-btn" data-value="1">1 (wygrana gospodarzy)</button>
						<button class="bet-type-btn" data-value="2">2 (wygrana gości)</button>
						<button class="bet-type-btn" data-value="bts">BTS (obie drużyny strzelą)</button>
						<button class="bet-type-btn" data-value="handi1">Handi 1 (handicap gospodarzy)</button>
						<button class="bet-type-btn" data-value="handi2">Handi 2 (handicap gości)</button>
						<button class="bet-type-btn" data-value="goals_over">Bramki Over</button>
						<button class="bet-type-btn" data-value="goals_under">Bramki Under</button>
						<button class="bet-type-btn" data-value="corners_1_over">Rożne 1 Over</button>
						<button class="bet-type-btn" data-value="corners_1_under">Rożne 1 Under</button>
						<button class="bet-type-btn" data-value="corners_2_over">Rożne 2 Over</button>
						<button class="bet-type-btn" data-value="corners_2_under">Rożne 2 Under</button>
						<button class="bet-type-btn" data-value="corners_match_over">Rożne Match Over</button>
						<button class="bet-type-btn" data-value="corners_match_under">Rożne Match Under</button>
						<button class="bet-type-btn" data-value="offsides_over">Spalone Over</button>
						<button class="bet-type-btn" data-value="offsides_under">Spalone Under</button>
					</div>
				</div>
			</div>
		`
		
		document.body.appendChild(modal)
		
		window.betTypeResolve = resolve
		
		modal.querySelectorAll('.bet-type-btn').forEach(btn => {
			btn.addEventListener('click', () => {
				const value = btn.dataset.value
				modal.remove()
				resolve(value)
			})
		})
	})
}

/**
 * Show bet option selection dialog based on bet type
 */
function showBetOptionDialog(betType) {
	return new Promise((resolve) => {
		const options = getBetOptions(betType)
		
		const modal = document.createElement('div')
		modal.className = 'modal-overlay'
		modal.style.display = 'flex'
		modal.style.zIndex = '100000'
		
		modal.innerHTML = `
			<div class="modal-content" style="max-width: 400px;">
				<div class="modal-header">
					<h2>Wybierz typ (${getBetTypeLabel(betType)})</h2>
					<button class="modal-close" onclick="this.closest('.modal-overlay').remove(); window.betOptionResolve(null)">×</button>
				</div>
				<div class="modal-body">
					<div style="display: flex; flex-direction: column; gap: 10px;">
						${options.map(opt => `<button class="bet-type-btn" data-value="${opt}">${opt}</button>`).join('')}
					</div>
				</div>
			</div>
		`
		
		document.body.appendChild(modal)
		
		window.betOptionResolve = resolve
		
		modal.querySelectorAll('.bet-type-btn').forEach(btn => {
			btn.addEventListener('click', () => {
				const value = btn.dataset.value
				modal.remove()
				resolve(value)
			})
		})
	})
}

/**
 * Show odds input dialog
 */
function showOddsDialog() {
	return new Promise((resolve) => {
		const modal = document.createElement('div')
		modal.className = 'modal-overlay'
		modal.style.display = 'flex'
		modal.style.zIndex = '100000'
		
		modal.innerHTML = `
			<div class="modal-content" style="max-width: 400px;">
				<div class="modal-header">
					<h2>Wpisz kurs</h2>
					<button class="modal-close" onclick="this.closest('.modal-overlay').remove(); window.oddsResolve(null)">×</button>
				</div>
				<div class="modal-body">
					<input type="number" id="odds-input" step="0.01" min="1" placeholder="np. 1.85" 
						style="width: 100%; padding: 12px; font-size: 16px; border: 2px solid #3b82f6; border-radius: 8px;">
					<button onclick="window.submitOdds()" 
						style="width: 100%; margin-top: 15px; padding: 12px; background: #3b82f6; color: white; border: none; border-radius: 8px; font-size: 16px; font-weight: 600; cursor: pointer;">
						Zatwierdź
					</button>
				</div>
			</div>
		`
		
		document.body.appendChild(modal)
		
		window.oddsResolve = resolve
		
		window.submitOdds = () => {
			const input = document.getElementById('odds-input')
			const value = parseFloat(input.value)
			if (value && value >= 1) {
				modal.remove()
				resolve(value)
			} else {
				showToast('Podaj poprawny kurs (min. 1.00)', 'error')
			}
		}
		
		// Submit on Enter key
		document.getElementById('odds-input').addEventListener('keypress', (e) => {
			if (e.key === 'Enter') {
				window.submitOdds()
			}
		})
		
		// Focus input
		setTimeout(() => document.getElementById('odds-input').focus(), 100)
	})
}

/**
 * Show dialog to enter Superbet and Flashscore links
 */
/**
 * Get bet options based on bet type
 */
function getBetOptions(betType) {
	const options = {
		'1': [],
		'2': [],
		'bts': ['tak', 'nie'],
		'handi1': ['-0.5', '-1.5', '-2.5', '-3.5'],
		'handi2': ['-0.5', '-1.5', '-2.5', '-3.5'],
		'goals_over': ['1.5', '2.5', '3.5', '4.5', '5.5'],
		'goals_under': ['1.5', '2.5', '3.5', '4.5', '5.5'],
		'corners_1_over': ['2.5', '3.5', '4.5', '5.5', '6.5', '7.5', '8.5'],
		'corners_1_under': ['2.5', '3.5', '4.5', '5.5', '6.5', '7.5', '8.5'],
		'corners_2_over': ['2.5', '3.5', '4.5', '5.5', '6.5', '7.5', '8.5'],
		'corners_2_under': ['2.5', '3.5', '4.5', '5.5', '6.5', '7.5', '8.5'],
		'corners_match_over': ['7.5', '8.5', '9.5', '10.5', '11.5', '12.5', '13.5', '14.5', '15.5'],
		'corners_match_under': ['7.5', '8.5', '9.5', '10.5', '11.5', '12.5', '13.5', '14.5', '15.5'],
		'offsides_over': ['2.5', '3.5', '4.5', '5.5', '6.5', '7.5'],
		'offsides_under': ['2.5', '3.5', '4.5']
	}
	return options[betType] || []
}

/**
 * Get bet type label
 */
function getBetTypeLabel(betType) {
	const labels = {
		'1': 'Wygrana gospodarzy',
		'2': 'Wygrana gości',
		'bts': 'BTS',
		'handi1': 'Handicap gospodarzy',
		'handi2': 'Handicap gości',
		'goals_over': 'Bramki Over',
		'goals_under': 'Bramki Under',
		'corners_1_over': 'Rożne 1 Over',
		'corners_1_under': 'Rożne 1 Under',
		'corners_2_over': 'Rożne 2 Over',
		'corners_2_under': 'Rożne 2 Under',
		'corners_match_over': 'Rożne Match Over',
		'corners_match_under': 'Rożne Match Under',
		'offsides_over': 'Spalone Over',
		'offsides_under': 'Spalone Under'
	}
	return labels[betType] || betType
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

// ============================================================================
// MINIMIZED CARDS CONTROLS
// ============================================================================

function expandAllMatchCards() {
	const container = document.getElementById('minimized-cards-container')
	if (container) {
		// Toggle expanded state
		if (container.classList.contains('expanded')) {
			container.classList.remove('expanded')
		} else {
			container.classList.add('expanded')
		}
	}
}

function closeAllMatchCards() {
	const count = minimizedMatchModals.size
	if (count === 0) return
	
	if (!confirm(`Czy na pewno chcesz zamknąć wszystkie karty meczów (${count})?`)) {
		return
	}
	
	const container = document.getElementById('minimized-cards-container')
	if (container) {
		// Close expanded state first
		container.classList.remove('expanded')
		
		// Close all individual cards
		minimizedMatchModals.forEach((_, matchId) => {
			closeMatchDetailsModalCompletely(null, matchId)
		})
	}
}

function expandAllModalCards() {
	const container = document.getElementById('minimized-modals-container')
	if (container) {
		// Toggle expanded state
		if (container.classList.contains('expanded')) {
			container.classList.remove('expanded')
		} else {
			container.classList.add('expanded')
		}
	}
}

function closeAllModalCards() {
	const count = minimizedModals.size
	if (count === 0) return
	
	if (!confirm(`Czy na pewno chcesz zamknąć wszystkie karty TOP10 (${count})?`)) {
		return
	}
	
	const container = document.getElementById('minimized-modals-container')
	if (container) {
		// Close expanded state first
		container.classList.remove('expanded')
		
		// Close all individual modal cards
		minimizedModals.forEach((_, modalId) => {
			const modalElement = document.getElementById(modalId)
			if (modalElement) {
				modalElement.remove()
			}
		})
		minimizedModals.clear()
		saveMinimizedModals()
		
		// Remove all minimized cards
		const cards = container.querySelectorAll('.minimized-card')
		cards.forEach(card => card.remove())
	}
}

// Create control buttons for minimized containers
function createMinimizedControls() {
	// Left controls (for match cards)
	let leftControls = document.getElementById('minimized-match-controls')
	if (!leftControls) {
		leftControls = document.createElement('div')
		leftControls.id = 'minimized-match-controls'
		leftControls.className = 'minimized-controls left'
		leftControls.innerHTML = `
			<button class="minimized-control-btn" onclick="window.expandAllMatchCards()" title="Rozwiń wszystkie karty meczów">
				📖 Rozwiń
			</button>
			<button class="minimized-control-btn danger" onclick="window.closeAllMatchCards()" title="Zamknij wszystkie karty meczów">
				✕ Zamknij
			</button>
		`
		document.body.appendChild(leftControls)
	}
	
	// Right controls (for TOP10 modal cards)
	let rightControls = document.getElementById('minimized-modal-controls')
	if (!rightControls) {
		rightControls = document.createElement('div')
		rightControls.id = 'minimized-modal-controls'
		rightControls.className = 'minimized-controls right'
		rightControls.innerHTML = `
			<button class="minimized-control-btn" onclick="window.expandAllModalCards()" title="Rozwiń wszystkie karty TOP10">
				📖 Rozwiń
			</button>
			<button class="minimized-control-btn danger" onclick="window.closeAllModalCards()" title="Zamknij wszystkie karty TOP10">
				✕ Zamknij
			</button>
		`
		document.body.appendChild(rightControls)
	}
}

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
window.restartJob = restartJob
window.deleteJob = deleteJob

// Minimized cards controls
window.expandAllMatchCards = expandAllMatchCards
window.closeAllMatchCards = closeAllMatchCards
window.expandAllModalCards = expandAllModalCards
window.closeAllModalCards = closeAllModalCards

// Date range controls
window.setTodayDate = EventHandlers.setTodayDate
window.setTomorrowDate = EventHandlers.setTomorrowDate
window.setDayAfterTomorrowDate = EventHandlers.setDayAfterTomorrowDate

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
window.queueMostSingleTeamCorners = BetFinder.queueMostSingleTeamCorners
window.queueLeastSingleTeamCorners = BetFinder.queueLeastSingleTeamCorners
window.queueMostBTS = BetFinder.queueMostBTS
window.queueNoBTS = BetFinder.queueNoBTS
window.queueHomeWins = BetFinder.queueHomeWins
window.queueAwayWins = BetFinder.queueAwayWins
window.queueHomeLosses = BetFinder.queueHomeLosses
window.queueAwayLosses = BetFinder.queueAwayLosses
window.queueHomeAdvantage = BetFinder.queueHomeAdvantage
window.queueAwayAdvantage = BetFinder.queueAwayAdvantage
window.queueGoalAdvantage = BetFinder.queueGoalAdvantage
window.queueWinnerVsLoser = BetFinder.queueWinnerVsLoser
window.queueMostTotalCorners = BetFinder.queueMostTotalCorners
window.queueLeastTotalCorners = BetFinder.queueLeastTotalCorners
window.queueCornerAdvantage = BetFinder.queueCornerAdvantage
window.queueMostTotalOffsides = BetFinder.queueMostTotalOffsides
window.queueLeastTotalOffsides = BetFinder.queueLeastTotalOffsides
window.queueMostOffsides = BetFinder.queueMostOffsides
window.queueLeastOffsides = BetFinder.queueLeastOffsides
window.queueOffsidesAdvantage = BetFinder.queueOffsidesAdvantage
window.queueMostCornersTeam = BetFinder.queueMostCornersTeam
window.queueLeastCornersTeam = BetFinder.queueLeastCornersTeam

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
	BetFinder.queueMostSingleTeamCorners()
	BetFinder.queueLeastSingleTeamCorners()
	BetFinder.queueMostTotalCorners()
	BetFinder.queueLeastTotalCorners()
	BetFinder.queueCornerAdvantage()
	BetFinder.queueMostCornersTeam()
	BetFinder.queueLeastCornersTeam()
	showToast('Dodano 9 wyszukiwań z kategorii "Rożne" do kolejki', 'success')
}

window.queueAllOffsidesSearches = function() {
	BetFinder.queueMostOffsides()
	BetFinder.queueLeastOffsides()
	BetFinder.queueOffsidesAdvantage()
	BetFinder.queueMostTotalOffsides()
	BetFinder.queueLeastTotalOffsides()
	showToast('Dodano 5 wyszukiwań z kategorii "Spalone" do kolejki', 'success')
}

window.queueAllHomeAwaySearches = function() {
	BetFinder.queueHomeWins()
	BetFinder.queueAwayWins()
	BetFinder.queueHomeLosses()
	BetFinder.queueAwayLosses()
	BetFinder.queueHomeAdvantage()
	BetFinder.queueAwayAdvantage()
	showToast('Dodano 6 wyszukiwań z kategorii "Dom/Wyjazd" do kolejki', 'success')
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
window.clearAllWatchedMatches = WatchedMatches.clearAllWatchedMatches
window.addToStrefaTypera = addToStrefaTypera

// Close stat modal on ESC key
document.addEventListener('keydown', function (e) {
	if (e.key === 'Escape') {
		const statModal = document.getElementById('statModal')
		if (statModal && statModal.classList.contains('active')) {
			DOMUtils.closeStatModal()
		}
	}
})

/**
 * Refresh import queue display
 */
async function refreshImportQueue() {
	const container = document.getElementById('import-queue-list')
	const countBadge = document.getElementById('queue-count')
	if (!container) return

	try {
		const response = await fetch('/api/import-jobs/queue')
		const queue = await response.json()

		if (!queue || queue.length === 0) {
			container.innerHTML =
				'<p style="text-align: center; color: #999; padding: 40px;">📭 Kolejka jest pusta</p>'
			if (countBadge) countBadge.textContent = '0'
			return
		}

		if (countBadge) countBadge.textContent = queue.length

		let html = '<div style="display: flex; flex-direction: column; gap: 12px;">'
		
		queue.forEach((job, index) => {
			const createdAt = new Date(job.created_at).toLocaleString('pl-PL')
			const dateFrom = new Date(job.date_from).toLocaleDateString('pl-PL')
			const dateTo = new Date(job.date_to).toLocaleDateString('pl-PL')
			const leagues = typeof job.leagues === 'string' ? JSON.parse(job.leagues) : job.leagues
			
			// Debug: sprawdź faktyczną wartość leagues
			console.log('[DEBUG] Job ID:', job.id, 'leagues type:', typeof job.leagues, 'leagues:', job.leagues, 'parsed:', leagues, 'length:', leagues?.length)
			
			const progress = job.progress ? (typeof job.progress === 'string' ? JSON.parse(job.progress) : job.progress) : {}
			const completedLeagues = progress.completed_leagues || []
			const progressPercent = leagues.length > 0 ? Math.round((completedLeagues.length / leagues.length) * 100) : 0

		const statusEmoji = {
			in_queue: '📋',
			pending: '⏳',
			running: '▶️',
			rate_limited: '⏸️'
		}[job.status] || '❓'

		const statusText = {
			in_queue: 'W kolejce',
			pending: 'Gotowe do startu',
			running: 'W trakcie',
			rate_limited: 'Pauza (limit API)'
		}[job.status] || job.status

		const positionBadge = job.status === 'running'
			? '<span style="background: #10b981; color: white; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: bold;">AKTYWNE</span>'
			: job.status === 'rate_limited'
			? '<span style="background: #f59e0b; color: white; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: bold;">PAUZA</span>'
			: job.status === 'pending'
			? '<span style="background: #3b82f6; color: white; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: bold;">NASTĘPNE</span>'
			: `<span style="background: #6b7280; color: white; padding: 2px 8px; border-radius: 4px; font-size: 11px;">#${index + 1} w kolejce</span>`

			html += `
				<div style="background: #f9fafb; border-radius: 6px; padding: 12px; border-left: 4px solid ${job.status === 'running' ? '#10b981' : job.status === 'rate_limited' ? '#f59e0b' : '#6b7280'};">
					<div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 8px;">
						<div>
							<div style="display: flex; align-items: center; gap: 8px; margin-bottom: 4px;">
								<span style="font-size: 18px;">${statusEmoji}</span>
								<strong style="font-size: 14px;">Zadanie #${job.id}</strong>
								${positionBadge}
							</div>
							<div style="font-size: 12px; color: #6b7280;">
								${statusText} • ${leagues.length} lig • ${dateFrom} - ${dateTo}
							</div>
						</div>
						<div style="text-align: right; font-size: 11px; color: #9ca3af;">
							${createdAt}
						</div>
					</div>
					${progressPercent > 0 ? `
						<div style="margin-top: 8px;">
							<div style="display: flex; justify-content: space-between; font-size: 11px; color: #6b7280; margin-bottom: 4px;">
								<span>Postęp: ${completedLeagues.length}/${leagues.length} lig</span>
								<span>${progressPercent}%</span>
							</div>
							<div style="background: #e5e7eb; height: 6px; border-radius: 3px; overflow: hidden;">
								<div style="background: #10b981; height: 100%; width: ${progressPercent}%; transition: width 0.3s;"></div>
							</div>
						</div>
					` : ''}
					${job.status === 'rate_limited' && job.rate_limit_reset_at ? `
						<div style="margin-top: 8px; font-size: 11px; color: #f59e0b; display: flex; align-items: center; gap: 4px;">
							⏰ Wznowienie za: ${getTimeUntil(new Date(job.rate_limit_reset_at))}
						</div>
					` : ''}
				</div>
			`
		})

		html += '</div>'
		container.innerHTML = html

	} catch (error) {
		console.error('Error loading import queue:', error)
		container.innerHTML =
			'<p style="text-align: center; color: #ef4444; padding: 40px;">❌ Błąd ładowania kolejki</p>'
	}
}

/**
 * Get time until specific date
 */
function getTimeUntil(date) {
	const now = new Date()
	const diff = date - now
	
	if (diff <= 0) return 'już teraz'
	
	const minutes = Math.floor(diff / 60000)
	const seconds = Math.floor((diff % 60000) / 1000)
	
	if (minutes > 0) {
		return `${minutes}m ${seconds}s`
	}
	return `${seconds}s`
}

/**
 * Run Strefa Typera Backfill
 */
window.runStrefaTyperaBackfill = async function() {
	await runBackfill('/api/strefa-typera/backfill-typy', 'Typy')
}

/**
 * Run Bet Builder Backfill
 */
window.runBetBuilderBackfill = async function() {
	await runBackfill('/api/strefa-typera/backfill-bet-builder', 'Bet Builder')
}

/**
 * Generic backfill function
 */
async function runBackfill(endpoint, sheetName) {
	const statusDiv = document.getElementById('backfill-status')
	const messageDiv = document.getElementById('backfill-message')
	const button = event.target
	
	// Show status and disable button
	statusDiv.style.display = 'block'
	button.disabled = true
	button.textContent = '⏳ Przetwarzanie...'
	messageDiv.innerHTML = `<div style="text-align: center;">🔄 Uruchamianie backfill dla "${sheetName}"...</div>`
	
	try {
		const response = await fetch(endpoint, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
		})
		
		const data = await response.json()
		
		if (data.success) {
			messageDiv.innerHTML = `
				<div style="text-align: center;">
					<div style="font-size: 24px; margin-bottom: 10px;">✅</div>
					<div style="font-weight: 600; margin-bottom: 10px;">${data.message}</div>
					<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 10px; margin-top: 15px;">
						<div style="background: rgba(255,255,255,0.2); padding: 10px; border-radius: 4px;">
							<div style="font-size: 20px; font-weight: 600;">${data.totalRows || 0}</div>
							<div style="font-size: 12px; opacity: 0.9;">Wierszy ogółem</div>
						</div>
						<div style="background: rgba(255,255,255,0.2); padding: 10px; border-radius: 4px;">
							<div style="font-size: 20px; font-weight: 600;">${data.rowsUpdated || 0}</div>
							<div style="font-size: 12px; opacity: 0.9;">Zaktualizowano</div>
						</div>
						<div style="background: rgba(255,255,255,0.2); padding: 10px; border-radius: 4px;">
							<div style="font-size: 20px; font-weight: 600;">${data.rowsSkipped || 0}</div>
							<div style="font-size: 12px; opacity: 0.9;">Pominięto</div>
						</div>
						<div style="background: rgba(255,255,255,0.2); padding: 10px; border-radius: 4px;">
							<div style="font-size: 20px; font-weight: 600;">${data.rowsNotFound || 0}</div>
							<div style="font-size: 12px; opacity: 0.9;">Nie znaleziono</div>
						</div>
					</div>
				</div>
			`
		} else {
			throw new Error(data.error || 'Wystąpił błąd')
		}
	} catch (error) {
		console.error('Backfill error:', error)
		messageDiv.innerHTML = `
			<div style="text-align: center;">
				<div style="font-size: 24px; margin-bottom: 10px;">❌</div>
				<div style="font-weight: 600;">Błąd podczas backfill</div>
				<div style="font-size: 12px; margin-top: 5px; opacity: 0.9;">${error.message}</div>
			</div>
		`
	} finally {
		// Re-enable button
		button.disabled = false
		button.textContent = button.textContent.includes('Typy') ? '🔄 Backfill "Typy"' : '🔄 Backfill "Bet Builder"'
	}
}

/**
 * KROK 19: Fix Missing Match IDs
 */
window.fixMissingMatchIds = async function(sheetName = 'Typy') {
	const statusDiv = document.getElementById('backfill-status')
	const messageDiv = document.getElementById('backfill-message')
	
	statusDiv.style.display = 'block'
	messageDiv.innerHTML = `
		<div style="text-align: center;">
			<div class="spinner"></div>
			<div style="font-weight: 600; margin-top: 10px;">Uzupełnianie ID meczów...</div>
			<div style="font-size: 12px; margin-top: 5px; opacity: 0.9;">FC Eindhoven, Lechia Gdansk, Tychy 71</div>
		</div>
	`
	
	try {
		const response = await fetch('/api/strefa-typera/fix-missing-ids', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({ sheetName }),
		})
		
		const data = await response.json()
		
		if (data.success) {
			messageDiv.innerHTML = `
				<div style="text-align: center;">
					<div style="font-size: 24px; margin-bottom: 10px;">✅</div>
					<div style="font-weight: 600;">${data.message}</div>
					<div style="font-size: 12px; margin-top: 5px; opacity: 0.9;">Uzupełniono ${data.fixed} ID</div>
				</div>
			`
		} else {
			throw new Error(data.error || 'Unknown error')
		}
		
		setTimeout(() => {
			statusDiv.style.display = 'none'
		}, 3000)
		
	} catch (error) {
		console.error('Fix IDs error:', error)
		messageDiv.innerHTML = `
			<div style="text-align: center;">
				<div style="font-size: 24px; margin-bottom: 10px;">❌</div>
				<div style="font-weight: 600;">Błąd podczas uzupełniania ID</div>
				<div style="font-size: 12px; margin-top: 5px; opacity: 0.9;">${error.message}</div>
			</div>
		`
	}
}

/**
 * KROK 23: Migrate data from sheets to database (one-time)
 */
window.migrateSheetsToDB = async function() {
	if (!confirm('Czy na pewno chcesz zmigrować dane z arkuszy do bazy danych?\n\nTo jest operacja jednorazowa i może potrwać kilka minut.')) {
		return
	}

	const statusDiv = document.getElementById('actions-status')
	const messageDiv = document.getElementById('actions-message')
	
	if (!statusDiv || !messageDiv) {
		alert('Nie można znaleźć elementów statusu')
		return
	}

	statusDiv.style.display = 'block'
	messageDiv.innerHTML = `
		<div style="text-align: center;">
			<div class="spinner"></div>
			<div style="font-weight: 600; margin-top: 10px;">Migracja danych...</div>
			<div style="font-size: 12px; margin-top: 5px; opacity: 0.9;">Kopiowanie z arkuszy do bazy danych</div>
		</div>
	`
	
	try {
		const response = await fetch('/api/strefa-typera/migrate-sheets-to-db', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
		})
		
		const data = await response.json()
		
		if (data.success) {
			messageDiv.innerHTML = `
				<div style="text-align: center;">
					<div style="font-size: 24px; margin-bottom: 10px;">✅</div>
					<div style="font-weight: 600;">Migracja zakończona pomyślnie!</div>
					<div style="font-size: 12px; margin-top: 5px; opacity: 0.9;">
						Zmigrowano ${data.betsInserted} typów i ${data.couponsInserted} kuponów
					</div>
				</div>
			`
		} else {
			throw new Error(data.error || 'Unknown error')
		}
		
		setTimeout(() => {
			statusDiv.style.display = 'none'
		}, 5000)
		
	} catch (error) {
		console.error('Migration error:', error)
		messageDiv.innerHTML = `
			<div style="text-align: center;">
				<div style="font-size: 24px; margin-bottom: 10px;">❌</div>
				<div style="font-weight: 600;">Błąd podczas migracji</div>
				<div style="font-size: 12px; margin-top: 5px; opacity: 0.9;">${error.message}</div>
			</div>
		`
	}
}

/**
 * KROK 29: Verify Types - check match results and update "Wszedł" column
 */
window.verifyTypes = async function() {
	const statusDiv = document.getElementById('actions-status')
	const messageDiv = document.getElementById('actions-message')
	
	statusDiv.style.display = 'block'
	messageDiv.innerHTML = `
		<div style="text-align: center;">
			<div class="spinner"></div>
			<p style="margin-top: 10px;">Weryfikuję typy...</p>
		</div>
	`

	try {
		const response = await fetch('/api/verify-bets', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			}
		})

		const result = await response.json()

		if (result.success) {
			messageDiv.innerHTML = `
				<div style="text-align: center;">
					<p style="color: #10b981; font-weight: 600; font-size: 18px;">✅ Weryfikacja zakończona!</p>
					<p style="margin-top: 10px;">Zweryfikowano: ${result.totalVerified} meczów</p>
					<p>Zaktualizowano: ${result.totalUpdated} typów</p>
				</div>
			`
		} else {
			throw new Error(result.error || 'Unknown error')
		}
	} catch (error) {
		console.error('Error verifying types:', error)
		messageDiv.innerHTML = `
			<div style="text-align: center;">
				<p style="color: #ef4444; font-weight: 600;">❌ Błąd weryfikacji</p>
				<p style="margin-top: 10px; font-size: 14px;">${error.message}</p>
			</div>
		`
	}

	// Hide after 5 seconds
	setTimeout(() => {
		statusDiv.style.display = 'none'
	}, 5000)
}

/**
 * KROK 18: Accept Types - copy from Bet Builder to Typy
 */
window.acceptTypes = async function() {
	const statusDiv = document.getElementById('actions-status')
	const messageDiv = document.getElementById('actions-message')
	
	statusDiv.style.display = 'block'
	messageDiv.innerHTML = `
		<div style="text-align: center;">
			<div class="spinner"></div>
			<div style="font-weight: 600; margin-top: 10px;">Kopiowanie danych...</div>
			<div style="font-size: 12px; margin-top: 5px; opacity: 0.9;">Przenoszę zakłady z Bet Builder do Typy</div>
		</div>
	`
	
	try {
		const response = await fetch('/api/strefa-typera/accept-types', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
		})
		
		const data = await response.json()
		
		if (data.success) {
			messageDiv.innerHTML = `
				<div style="text-align: center;">
					<div style="font-size: 24px; margin-bottom: 10px;">✅</div>
					<div style="font-weight: 600;">${data.message}</div>
					<div style="font-size: 12px; margin-top: 5px; opacity: 0.9;">Skopiowano ${data.rowsCopied} wierszy</div>
				</div>
			`
		} else {
			throw new Error(data.error || 'Unknown error')
		}
	} catch (error) {
		console.error('Error accepting types:', error)
		messageDiv.innerHTML = `
			<div style="text-align: center;">
				<div style="font-size: 24px; margin-bottom: 10px;">❌</div>
				<div style="font-weight: 600;">Błąd</div>
				<div style="font-size: 12px; margin-top: 5px; opacity: 0.9;">${error.message}</div>
			</div>
		`
	}
	
	setTimeout(() => {
		statusDiv.style.display = 'none'
	}, 3000)
}

/**
 * KROK 10: Create Coupon - placeholder function
 */
// KROK 21: Create Coupon function
window.createCoupon = async function() {
	// Show modal
	document.getElementById('createCouponModal').style.display = 'block'
	
	// Load matches from Bet Builder sheet
	try {
		const response = await fetch('/api/strefa-typera/bet-builder-matches')
		if (!response.ok) {
			throw new Error('Failed to load matches')
		}
		
		const data = await response.json()
		const matchesList = document.getElementById('coupon-matches-list')
		
		if (data.matches.length === 0) {
			matchesList.innerHTML = `
				<div style="text-align: center; padding: 20px; color: #9ca3af;">
					Brak meczów w arkuszu "Bet Builder"
				</div>
			`
			return
		}
		
		// Display matches as checkboxes
		matchesList.innerHTML = data.matches.map((match, index) => `
			<div style="padding: 10px; border-bottom: 1px solid #e5e7eb; display: flex; align-items: center; gap: 10px;">
				<input type="checkbox" id="match-${index}" value="${index}" 
					   onchange="updateCouponSummary()" 
					   style="width: 18px; height: 18px; cursor: pointer;">
				<label for="match-${index}" style="flex: 1; cursor: pointer; display: flex; justify-content: space-between; align-items: center;">
					<div>
						<strong>${match.homeTeam} - ${match.awayTeam}</strong>
						<div style="font-size: 12px; color: #6b7280; margin-top: 2px;">
							${match.betType}: ${match.betOption} | Szanse: ${match.szanse || '-'}
						</div>
					</div>
					<div style="background: #10b981; color: white; padding: 4px 8px; border-radius: 4px; font-weight: 600;">
						${match.odds || '-'}
					</div>
				</label>
			</div>
		`).join('')
		
		// Store matches data for later use
		window.betBuilderMatches = data.matches
		
	} catch (error) {
		console.error('Error loading matches:', error)
		document.getElementById('coupon-matches-list').innerHTML = `
			<div style="text-align: center; padding: 20px; color: #ef4444;">
				❌ Błąd podczas ładowania meczów
			</div>
		`
	}
}

window.closeCouponModal = function() {
	document.getElementById('createCouponModal').style.display = 'none'
	// Reset form
	document.getElementById('coupon-stake').value = ''
	document.getElementById('coupon-potential-win').value = ''
	document.getElementById('coupon-summary').style.display = 'none'
	window.betBuilderMatches = []
}

window.updateCouponSummary = function() {
	const checkboxes = document.querySelectorAll('#coupon-matches-list input[type="checkbox"]:checked')
	const count = checkboxes.length
	const summary = document.getElementById('coupon-summary')
	
	if (count > 0) {
		summary.style.display = 'block'
		document.getElementById('selected-matches-count').textContent = count
		
		// Calculate total odds
		let totalOdds = 1
		checkboxes.forEach(checkbox => {
			const index = parseInt(checkbox.value)
			const match = window.betBuilderMatches[index]
			const odds = parseFloat(match.odds) || 1
			totalOdds *= odds
		})
		
		document.getElementById('total-odds').textContent = totalOdds.toFixed(2)
	} else {
		summary.style.display = 'none'
	}
}

window.saveCoupon = async function() {
	const checkboxes = document.querySelectorAll('#coupon-matches-list input[type="checkbox"]:checked')
	const stake = parseFloat(document.getElementById('coupon-stake').value)
	const potentialWin = parseFloat(document.getElementById('coupon-potential-win').value)
	
	if (checkboxes.length === 0) {
		alert('Wybierz przynajmniej jeden mecz')
		return
	}
	
	if (!stake || stake <= 0) {
		alert('Wpisz poprawną stawkę')
		return
	}
	
	if (!potentialWin || potentialWin <= 0) {
		alert('Wpisz poprawną potencjalną wygraną')
		return
	}
	
	// Collect selected match indices
	const selectedIndices = Array.from(checkboxes).map(cb => parseInt(cb.value))
	
	try {
		const response = await fetch('/api/strefa-typera/create-coupon', {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: JSON.stringify({
				matchIndices: selectedIndices,
				stake: stake,
				potentialWin: potentialWin
			})
		})
		
		if (!response.ok) {
			throw new Error('Failed to create coupon')
		}
		
		const result = await response.json()
		
		// Show success message
		alert(`✅ Kupon ${result.couponId} został utworzony!\nDodano ${result.rowsAdded} wierszy do arkusza "Kupony".`)
		
		// Close modal
		closeCouponModal()
		
	} catch (error) {
		console.error('Error creating coupon:', error)
		alert('❌ Błąd podczas tworzenia kuponu')
	}
}

// KROK 15: Open league link (Superbet or Flashscore)
window.openLeagueLink = async function(type, league) {
	try {
		// Get country from current filter or from the team's league
		const country = document.getElementById('filter-country').value
		
		if (!country) {
			showToast('Nie można określić kraju dla tej ligi', 'error')
			return
		}
		
		// Fetch CSV with league links
		const response = await fetch('/Lista rozgrywek.csv')
		const csvText = await response.text()
		const lines = csvText.split('\n')
		
		// Find matching league
		for (const line of lines) {
			const [csvCountry, csvLeague, superbetLink, flashscoreLink] = line.split(',')
			if (csvCountry === country && csvLeague === league) {
				const link = type === 'superbet' ? superbetLink : flashscoreLink
				if (link && link.trim()) {
					window.open(link.trim(), '_blank')
					return
				} else {
					showToast(`Brak linku ${type === 'superbet' ? 'Superbet' : 'Flashscore'} dla tej ligi`, 'warning')
					return
				}
			}
		}
		
		showToast('Nie znaleziono ligi w bazie', 'error')
	} catch (error) {
		console.error('Error opening league link:', error)
		showToast('Błąd podczas otwierania linku: ' + error.message, 'error')
	}
}

/**
 * Show modal for automatic type addition
 */
window.showAutoAddTypesModal = function() {
	const allBetTypes = [
		{ name: '🏆 Wygrane vs Przegrane', func: 'queueWinnerVsLoser', group: 'Rezultat' },
		{ name: '⚽ Najwięcej bramek', func: 'queueMostGoals', group: 'Bramki' },
		{ name: '⚽ Najmniej bramek', func: 'queueLeastGoals', group: 'Bramki' },
		{ name: '⚽ BTS - Obie strzelają', func: 'queueMostBTS', group: 'Bramki' },
		{ name: '⚽ No BTS', func: 'queueNoBTS', group: 'Bramki' },
		{ name: '⚽ Przewaga bramkowa', func: 'queueGoalAdvantage', group: 'Bramki' },
		{ name: '🚩 Najwięcej rożnych pojedynczo', func: 'queueMostSingleTeamCorners', group: 'Rożne' },
		{ name: '🚩 Najmniej rożnych pojedynczo', func: 'queueLeastSingleTeamCorners', group: 'Rożne' },
		{ name: '🚩 Najwięcej rożnych mecz', func: 'queueMostTotalCorners', group: 'Rożne' },
		{ name: '🚩 Najmniej rożnych mecz', func: 'queueLeastTotalCorners', group: 'Rożne' },
		{ name: '🚩 Przewaga rożnych', func: 'queueCornerAdvantage', group: 'Rożne' },
		{ name: '🚩 Najwięcej rożnych (drużyna)', func: 'queueMostCornersTeam', group: 'Rożne' },
		{ name: '🚩 Najmniej rożnych (drużyna)', func: 'queueLeastCornersTeam', group: 'Rożne' },
		{ name: '🏠 Wygrane u siebie', func: 'queueHomeWins', group: 'Dom/Wyjazd' },
		{ name: '✈️ Wygrane na wyjeździe', func: 'queueAwayWins', group: 'Dom/Wyjazd' },
		{ name: '🏠 Porażki u siebie', func: 'queueHomeLosses', group: 'Dom/Wyjazd' },
		{ name: '✈️ Porażki na wyjeździe', func: 'queueAwayLosses', group: 'Dom/Wyjazd' },
		{ name: '🏠 Przewaga gospodarzy', func: 'queueHomeAdvantage', group: 'Dom/Wyjazd' },
		{ name: '✈️ Przewaga gości', func: 'queueAwayAdvantage', group: 'Dom/Wyjazd' },
		{ name: '⛔ Najwięcej spalonych (drużyna)', func: 'queueMostOffsides', group: 'Spalone' },
		{ name: '⛔ Najmniej spalonych (drużyna)', func: 'queueLeastOffsides', group: 'Spalone' },
		{ name: '⚡ Przewaga spalonych', func: 'queueOffsidesAdvantage', group: 'Spalone' },
		{ name: '⛔ Najwięcej spalonych (mecz)', func: 'queueMostTotalOffsides', group: 'Spalone' },
		{ name: '⛔ Najmniej spalonych (mecz)', func: 'queueLeastTotalOffsides', group: 'Spalone' },
	]

	const modal = document.createElement('div')
	modal.className = 'modal-overlay'
	modal.style.display = 'flex'
	modal.style.zIndex = '100000'
	
	const groupedTypes = {}
	allBetTypes.forEach(type => {
		if (!groupedTypes[type.group]) {
			groupedTypes[type.group] = []
		}
		groupedTypes[type.group].push(type)
	})

	let checkboxesHTML = ''
	Object.keys(groupedTypes).forEach(group => {
		checkboxesHTML += `
			<div style="margin-bottom: 20px;">
				<h4 style="color: #1e40af; margin-bottom: 10px; font-size: 15px; font-weight: 700;">${group}</h4>
				<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
		`
		groupedTypes[group].forEach(type => {
			checkboxesHTML += `
				<label style="display: flex; align-items: center; gap: 8px; padding: 8px; background: #f3f4f6; border-radius: 6px; cursor: pointer; transition: all 0.2s;"
					onmouseover="this.style.background='#e5e7eb'"
					onmouseout="this.style.background='#f3f4f6'">
					<input type="checkbox" class="bet-type-checkbox" value="${type.func}" style="cursor: pointer;">
					<span style="font-size: 13px; font-weight: 500;">${type.name}</span>
				</label>
			`
		})
		checkboxesHTML += `
				</div>
			</div>
		`
	})
	
	modal.innerHTML = `
		<div class="modal-content" style="max-width: 800px; max-height: 90vh; overflow-y: auto;">
			<div class="modal-header">
				<h2>🎯 Automatyczne dodawanie typów</h2>
				<button class="modal-close" onclick="this.closest('.modal-overlay').remove()">×</button>
			</div>
			<div class="modal-body">
				<div style="margin-bottom: 20px; display: flex; gap: 10px;">
					<button onclick="window.selectAllBetTypes()" 
						style="flex: 1; padding: 10px; background: #10b981; color: white; border: none; border-radius: 6px; font-weight: 600; cursor: pointer;">
						✓ Zaznacz wszystkie
					</button>
					<button onclick="window.deselectAllBetTypes()" 
						style="flex: 1; padding: 10px; background: #6b7280; color: white; border: none; border-radius: 6px; font-weight: 600; cursor: pointer;">
						✗ Odznacz wszystkie
					</button>
				</div>
				
				${checkboxesHTML}
				
				<div style="display: flex; gap: 10px; margin-top: 25px; padding-top: 20px; border-top: 2px solid #e5e7eb;">
					<button onclick="window.startAutoAddTypes('all')" 
						style="flex: 1; padding: 14px; background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); color: white; border: none; border-radius: 8px; font-size: 15px; font-weight: 700; cursor: pointer; box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3);">
						🚀 Wszystkie typy
					</button>
					<button onclick="window.startAutoAddTypes('selected')" 
						style="flex: 1; padding: 14px; background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); color: white; border: none; border-radius: 8px; font-size: 15px; font-weight: 700; cursor: pointer; box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);">
						✓ Wybrane typy
					</button>
					<button onclick="this.closest('.modal-overlay').remove()" 
						style="flex: 1; padding: 14px; background: #6b7280; color: white; border: none; border-radius: 8px; font-size: 15px; font-weight: 700; cursor: pointer;">
						Anuluj
					</button>
				</div>
			</div>
		</div>
	`
	
	document.body.appendChild(modal)
}

/**
 * Select all bet type checkboxes
 */
window.selectAllBetTypes = function() {
	document.querySelectorAll('.bet-type-checkbox').forEach(cb => cb.checked = true)
}

/**
 * Deselect all bet type checkboxes
 */
window.deselectAllBetTypes = function() {
	document.querySelectorAll('.bet-type-checkbox').forEach(cb => cb.checked = false)
}

/**
 * Start automatic type addition
 */
window.startAutoAddTypes = async function(mode) {
	const modal = document.querySelector('.modal-overlay')
	
	let selectedFunctions = []
	
	if (mode === 'all') {
		// All types
		selectedFunctions = [
			'queueWinnerVsLoser', 'queueMostGoals', 'queueLeastGoals', 'queueHandicap15',
			'queueMostBTS', 'queueNoBTS', 'queueGoalAdvantage', 'queueMostCorners',
			'queueLeastCorners', 'queueMostSingleTeamCorners', 'queueLeastSingleTeamCorners',
			'queueMostTotalCorners', 'queueLeastTotalCorners', 'queueCornerAdvantage',
			'queueHomeWins', 'queueAwayWins', 'queueHomeLosses', 'queueAwayLosses',
			'queueHomeAdvantage', 'queueAwayAdvantage', 'queueMostOffsides', 'queueLeastOffsides',
			'queueMostTotalOffsides', 'queueLeastTotalOffsides'
		]
	} else {
		// Selected types
		const checkboxes = document.querySelectorAll('.bet-type-checkbox:checked')
		if (checkboxes.length === 0) {
			showToast('Wybierz przynajmniej jeden typ', 'warning')
			return
		}
		selectedFunctions = Array.from(checkboxes).map(cb => cb.value)
	}
	
	modal.remove()
	
	// Map function names to their modal types for auto-adding
	const functionToModalType = {
		'queueWinnerVsLoser': 'winner-vs-loser',
		'queueMostGoals': 'most-goals',
		'queueLeastGoals': 'least-goals',
		'queueHandicap15': 'handicap-15',
		'queueMostBTS': 'most-bts',
		'queueNoBTS': 'no-bts',
		'queueGoalAdvantage': 'goal-advantage',
		'queueMostCorners': 'most-corners',
		'queueLeastCorners': 'least-corners',
		'queueMostSingleTeamCorners': 'most-single-team-corners',
		'queueLeastSingleTeamCorners': 'least-single-team-corners',
		'queueMostTotalCorners': 'total-corners',
		'queueLeastTotalCorners': 'total-corners-least',
		'queueCornerAdvantage': 'corner-advantage',
		'queueMostCornersTeam': 'most-team-corners',
		'queueLeastCornersTeam': 'least-team-corners',
		'queueHomeWins': 'home-wins',
		'queueAwayWins': 'away-wins',
		'queueHomeLosses': 'home-losses',
		'queueAwayLosses': 'away-losses',
		'queueHomeAdvantage': 'home-advantage',
		'queueAwayAdvantage': 'away-advantage',
		'queueMostOffsides': 'most-offsides',
		'queueLeastOffsides': 'least-offsides',
		'queueOffsidesAdvantage': 'offsides-advantage',
		'queueMostTotalOffsides': 'most-total-offsides',
		'queueLeastTotalOffsides': 'least-total-offsides'
	}
	
	// Enable auto-add mode
	window.autoAddToBetBuilder = true
	window.autoAddModalTypes = selectedFunctions.map(fn => functionToModalType[fn]).filter(Boolean)
	
	// Add all to queue
	selectedFunctions.forEach(funcName => {
		if (window[funcName]) {
			window[funcName]()
		}
	})
	
	showToast(`Uruchamiam automatyczne dodawanie dla ${selectedFunctions.length} typów...`, 'success')
}

// Initialize on DOM load
if (document.readyState === 'loading') {
	document.addEventListener('DOMContentLoaded', init)
} else {
	init()
}


