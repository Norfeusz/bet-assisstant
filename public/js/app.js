/**
 * Main Application Entry Point
 * Imports all modules and initializes the application
 */

// Import utilities
import { showToast, validateDateRange, setQuickDate, filterSelectOptions } from './utils/helpers.js';
import * as Storage from './utils/storage.js';
import * as Statistics from './utils/statistics.js';

// Import state management
import { state } from './config/state.js';

// Import API client
import * as API from './api/api-client.js';

// Import UI handlers
import * as EventHandlers from './ui/event-handlers.js';
import * as DOMUtils from './ui/dom-utils.js';

/**
 * Initialize the application
 */
async function init() {
    console.log('🚀 Initializing Bet Assistant...');

    try {
        // Update rate limit on load
        await API.updateRateLimit();

        // Set up rate limit refresh interval (every 30 seconds)
        setInterval(() => {
            API.updateRateLimit();
        }, 30000);

        // Load countries
        const countries = await API.loadCountries();
        DOMUtils.renderCountries(countries);

        // Load configured leagues into state
        await EventHandlers.loadConfiguredLeagues();

        // Update summary
        await EventHandlers.updateSummary();

        // Update country badges
        await EventHandlers.updateCountryBadges();

        // Check for incomplete import
        await checkIncompleteImport();

        console.log('✅ Application initialized successfully');
    } catch (error) {
        console.error('❌ Error initializing application:', error);
        showToast('Błąd podczas inicjalizacji aplikacji', 'error');
    }
}

/**
 * Check for incomplete import and show resume button
 */
async function checkIncompleteImport() {
    try {
        const status = await API.getImportStatus();

        if (status.hasIncomplete) {
            document.getElementById('resume-btn').style.display = 'inline-block';
            showToast('Znaleziono wstrzymany import. Możesz go wznowić.', 'info');
        } else {
            document.getElementById('resume-btn').style.display = 'none';
        }
    } catch (error) {
        console.error('Error checking import status:', error);
    }
}

// =============================================================================
// IMPORT & PRESETS HANDLERS
// =============================================================================

/**
 * Show import dialog
 */
async function showImportDialog() {
    const enabled = await API.getLeaguesSummary();

    if (enabled.enabled === 0) {
        showToast('Proszę najpierw wybrać przynajmniej jedną ligę', 'error');
        return;
    }

    document.getElementById('league-count').textContent = enabled.enabled;

    // Set default dates (last 2 weeks)
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - 14);

    document.getElementById('end-date').value = endDate.toISOString().split('T')[0];
    document.getElementById('start-date').value = startDate.toISOString().split('T')[0];

    document.getElementById('import-modal').classList.add('show');
}

/**
 * Close import dialog
 */
function closeImportDialog() {
    document.getElementById('import-modal').classList.remove('show');
}

/**
 * Start import
 */
async function startImport() {
    const startDate = document.getElementById('start-date').value;
    const endDate = document.getElementById('end-date').value;

    if (!startDate || !endDate) {
        showToast('Proszę wybrać datę początkową i końcową', 'error');
        return;
    }

    if (new Date(startDate) > new Date(endDate)) {
        showToast('Data początkowa musi być przed datą końcową', 'error');
        return;
    }

    await executeImport({ startDate, endDate, resume: false });
}

/**
 * Resume import
 */
async function resumeImport() {
    if (!confirm('Wznowić wstrzymany import?')) {
        return;
    }

    await executeImport({ resume: true });
}

/**
 * Execute import
 */
async function executeImport(params) {
    closeImportDialog();
    document.getElementById('progress-modal').classList.add('show');
    document.getElementById('progress-text').textContent = params.resume ? 'Wznawianie importu...' : 'Rozpoczynam import z automatycznym ponowieniem...';
    document.getElementById('progress-fill').style.width = '10%';

    try {
        params.autoRetry = true;

        const result = await API.startImport(params);

        if (result.success) {
            document.getElementById('progress-fill').style.width = '30%';
            document.getElementById('progress-text').textContent = 'Import w toku z automatycznym ponowieniem...';

            showToast('Import rozpoczęty! Będzie kontynuowany w tle z automatycznym ponowieniem.', 'success');

            // Poll for completion
            let checkCount = 0;
            const checkInterval = setInterval(async () => {
                checkCount++;

                try {
                    const status = await API.getImportStatus();

                    if (!status.hasIncomplete || checkCount > 1000) {
                        clearInterval(checkInterval);

                        if (!status.hasIncomplete) {
                            document.getElementById('progress-fill').style.width = '100%';
                            document.getElementById('progress-text').textContent = 'Import zakończony pomyślnie!';

                            setTimeout(() => {
                                document.getElementById('progress-modal').classList.remove('show');
                                document.getElementById('resume-btn').style.display = 'none';
                                showToast('Wszystkie mecze zaimportowane pomyślnie!', 'success');
                            }, 2000);
                        }
                    } else {
                        const progress = status.progress || 30;
                        document.getElementById('progress-fill').style.width = `${progress}%`;

                        let statusText = `Importing... ${progress}% (${status.state.matchesImported} matches)`;
                        if (status.state.error?.includes('waiting')) {
                            statusText = `⏰ Waiting for rate limit... (${status.state.matchesImported} matches imported)`;
                        }

                        document.getElementById('progress-text').textContent = statusText;
                    }
                } catch (error) {
                    // Continue checking
                }
            }, 10000);
        } else {
            throw new Error('Import failed');
        }
    } catch (error) {
        document.getElementById('progress-modal').classList.remove('show');
        showToast('Błąd importu. Sprawdź konsolę serwera aby zobaczyć szczegóły.', 'error');
        await checkIncompleteImport();
    }
}

/**
 * Close progress dialog
 */
function closeProgressDialog() {
    document.getElementById('progress-modal').classList.remove('show');
    showToast('Import kontynuowany w tle z automatycznym ponowieniem', 'success');
}

/**
 * Stop import
 */
async function stopImport() {
    if (!confirm('Zatrzymać import? Możesz go wznowić później.')) {
        return;
    }

    try {
        const data = await API.stopImport();

        if (data.success) {
            showToast('Import zostanie zatrzymany po aktualnej lidze', 'info');
            document.getElementById('progress-modal').classList.remove('show');
        }
    } catch (error) {
        showToast('Błąd podczas zatrzymywania importu', 'error');
    }
}

/**
 * Cancel import
 */
async function cancelImport() {
    if (!confirm('Zakończyć import i wyczyścić stan? Nie będzie można wznowić.')) {
        return;
    }

    try {
        const data = await API.cancelImport();

        if (data.success) {
            showToast('Import został zakończony', 'success');
            document.getElementById('progress-modal').classList.remove('show');
            await checkIncompleteImport();
        }
    } catch (error) {
        showToast('Błąd podczas kończenia importu', 'error');
    }
}

// =============================================================================
// PRESET HANDLERS
// =============================================================================

/**
 * Show save preset dialog
 */
function showSavePresetDialog() {
    const enabled = state.leagues.filter(l => l.enabled);
    if (enabled.length === 0) {
        showToast('Proszę najpierw wybrać przynajmniej jedną ligę', 'error');
        return;
    }
    document.getElementById('save-preset-modal').classList.add('show');
    document.getElementById('preset-name').value = '';
    document.getElementById('preset-description').value = '';
}

/**
 * Close save preset dialog
 */
function closeSavePresetDialog() {
    document.getElementById('save-preset-modal').classList.remove('show');
}

/**
 * Save preset
 */
async function savePreset() {
    const name = document.getElementById('preset-name').value.trim();
    const description = document.getElementById('preset-description').value.trim();

    if (!name) {
        showToast('Proszę podać nazwę szablonu', 'error');
        return;
    }

    const enabled = state.leagues.filter(l => l.enabled);
    const leagueIds = enabled.map(l => l.id);

    try {
        const data = await API.savePreset({ name, description, leagueIds });

        if (data.success) {
            showToast(`Szablon "${name}" zapisany pomyślnie!`, 'success');
            closeSavePresetDialog();
        } else {
            showToast('Nie udało się zapisać szablonu', 'error');
        }
    } catch (error) {
        showToast('Błąd podczas zapisywania szablonu', 'error');
    }
}

/**
 * Show load preset dialog
 */
async function showLoadPresetDialog() {
    try {
        const presets = await API.loadPresets();
        DOMUtils.renderPresetsList(presets);
        document.getElementById('load-preset-modal').classList.add('show');
    } catch (error) {
        showToast('Błąd podczas ładowania szablonów', 'error');
    }
}

/**
 * Close load preset dialog
 */
function closeLoadPresetDialog() {
    document.getElementById('load-preset-modal').classList.remove('show');
}

/**
 * Load a preset
 */
async function loadPreset(name) {
    console.log('🔄 Loading preset:', name);

    try {
        const data = await API.loadPreset(name);

        if (data.success) {
            showToast(`Szablon "${name}" wczytany! (${data.stats.enabled} włączonych, ${data.stats.added} dodanych)`, 'success');
            closeLoadPresetDialog();

            await EventHandlers.loadConfiguredLeagues();
            await EventHandlers.updateSummary();
            await EventHandlers.updateCountryBadges();

            if (state.selectedCountry) {
                await EventHandlers.loadLeagues(state.selectedCountry);
            }
        } else {
            showToast('Nie udało się wczytać szablonu', 'error');
        }
    } catch (error) {
        console.error('❌ Error loading preset:', error);
        showToast('Błąd podczas ładowania szablonu', 'error');
    }
}

/**
 * Delete a preset
 */
async function deletePreset(name) {
    if (!confirm(`Usunąć szablon "${name}"?`)) {
        return;
    }

    try {
        const data = await API.deletePreset(name);

        if (data.success) {
            showToast(`Szablon "${name}" usunięty`, 'success');
            showLoadPresetDialog(); // Refresh list
        } else {
            showToast('Nie udało się usunąć szablonu', 'error');
        }
    } catch (error) {
        showToast('Błąd podczas usuwania szablonu', 'error');
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
        const countries = await API.loadDatabaseCountries();
        const leagues = await API.loadDatabaseLeagues();
        const teams = await API.loadDatabaseTeams();

        // Store in state
        state.databaseCountries = countries;
        state.databaseLeagues = leagues;
        state.databaseTeams = teams;

        // Populate dropdowns
        const countrySelect = document.getElementById('filter-country');
        countrySelect.innerHTML = '<option value="">Wszystkie Kraje</option>';
        countries.forEach(country => {
            const option = document.createElement('option');
            option.value = country;
            option.textContent = country;
            countrySelect.appendChild(option);
        });

        const leagueSelect = document.getElementById('filter-league');
        leagueSelect.innerHTML = '<option value="">Wszystkie Ligi</option>';
        leagues.forEach(league => {
            const option = document.createElement('option');
            option.value = league;
            option.textContent = league;
            leagueSelect.appendChild(option);
        });

        const teamSelect = document.getElementById('filter-team');
        teamSelect.innerHTML = '<option value="">Wszystkie Drużyny</option>';
        teams.forEach(team => {
            const option = document.createElement('option');
            option.value = team;
            option.textContent = team;
            teamSelect.appendChild(option);
        });

        console.log('✅ Loaded filters:', countries.length, 'countries,', leagues.length, 'leagues,', teams.length, 'teams');
    } catch (error) {
        console.error('Error loading database filters:', error);
        showToast('Nie udało się załadować filtrów: ' + error.message, 'error');
    }
}

/**
 * Handle country filter change
 */
async function onCountryFilterChange() {
    const country = document.getElementById('filter-country').value;

    document.getElementById('filter-league').value = '';
    document.getElementById('filter-team').value = '';

    if (!country) {
        await loadDatabaseFilters();
        return;
    }

    try {
        const leagues = await API.loadDatabaseLeagues(country);
        const teams = await API.loadDatabaseTeams({ country });

        const leagueSelect = document.getElementById('filter-league');
        leagueSelect.innerHTML = '<option value="">Wszystkie Ligi</option>';
        leagues.forEach(league => {
            const option = document.createElement('option');
            option.value = league;
            option.textContent = league;
            leagueSelect.appendChild(option);
        });

        const teamSelect = document.getElementById('filter-team');
        teamSelect.innerHTML = '<option value="">Wszystkie Drużyny</option>';
        teams.forEach(team => {
            const option = document.createElement('option');
            option.value = team;
            option.textContent = team;
            teamSelect.appendChild(option);
        });

        console.log('✅ Loaded', leagues.length, 'leagues and', teams.length, 'teams for', country);
    } catch (error) {
        console.error('Error loading leagues/teams:', error);
        showToast('Nie udało się załadować lig/drużyn: ' + error.message, 'error');
    }
}

/**
 * Handle league filter change
 */
async function onLeagueFilterChange() {
    const country = document.getElementById('filter-country').value;
    const league = document.getElementById('filter-league').value;

    document.getElementById('filter-team').value = '';

    if (!league) {
        if (country) {
            await onCountryFilterChange();
        } else {
            await loadDatabaseFilters();
        }
        return;
    }

    try {
        const filters = {};
        if (country) filters.country = country;
        if (league) filters.league = league;

        const teams = await API.loadDatabaseTeams(filters);

        const teamSelect = document.getElementById('filter-team');
        teamSelect.innerHTML = '<option value="">Wszystkie Drużyny</option>';
        teams.forEach(team => {
            const option = document.createElement('option');
            option.value = team;
            option.textContent = team;
            teamSelect.appendChild(option);
        });

        console.log('✅ Loaded', teams.length, 'teams for', league);
    } catch (error) {
        console.error('Error loading teams:', error);
        showToast('Nie udało się załadować drużyn: ' + error.message, 'error');
    }
}

/**
 * Handle team filter change
 */
function onTeamFilterChange() {
    console.log('Team filter changed:', document.getElementById('filter-team').value);
}

/**
 * Apply database filters
 */
async function applyFilters() {
    const country = document.getElementById('filter-country').value;
    const league = document.getElementById('filter-league').value;
    const team = document.getElementById('filter-team').value;

    console.log('Applying filters:', { country, league, team, limit: state.selectedLimit });

    try {
        const filters = {};
        if (country) filters.country = country;
        if (league) filters.league = league;
        if (team) filters.team = team;

        const allMatches = await API.loadDatabaseMatches(filters);

        state.lastFetchedMatches = allMatches;
        state.selectedTeamForColoring = team;
        state.homeAwayFilter = 'all';

        // Display team statistics if team selected
        if (team) {
            const availableLeagues = [...new Set(allMatches.map(m => m.league))];
            const stats = Statistics.calculateTeamStatistics(team, allMatches, 'all');
            DOMUtils.displayTeamStatistics(stats, availableLeagues);
        } else {
            document.getElementById('team-stats-container').style.display = 'none';
        }

        // Apply limit
        applyLimitToResults();

        showToast(`Znaleziono ${allMatches.length} meczów`, 'success');
    } catch (error) {
        console.error('Error applying filters:', error);
        showToast('Nie udało się załadować meczów: ' + error.message, 'error');
    }
}

/**
 * Apply limit to results
 */
function applyLimitToResults() {
    let matches = [...state.lastFetchedMatches];

    // Apply home/away filter if team is selected
    if (state.selectedTeamForColoring && state.homeAwayFilter !== 'all') {
        matches = matches.filter(match => {
            if (state.homeAwayFilter === 'home') {
                return match.home_team === state.selectedTeamForColoring;
            } else if (state.homeAwayFilter === 'away') {
                return match.away_team === state.selectedTeamForColoring;
            }
            return true;
        });
    }

    // Split matches
    const upcomingMatches = matches.filter(m => m.is_finished === 'no');
    const finishedMatches = matches.filter(m => m.is_finished === 'yes');

    // Apply limit to finished matches only
    let limitedFinishedMatches = finishedMatches;
    if (state.selectedLimit) {
        limitedFinishedMatches = finishedMatches
            .sort((a, b) => new Date(b.match_date) - new Date(a.match_date))
            .slice(0, state.selectedLimit);
    } else {
        limitedFinishedMatches = finishedMatches
            .sort((a, b) => new Date(b.match_date) - new Date(a.match_date));
    }

    const finalMatches = [...upcomingMatches, ...limitedFinishedMatches];

    // Recalculate stats if team selected
    if (state.selectedTeamForColoring) {
        const availableLeagues = [...new Set(finalMatches.map(m => m.league))];
        const currentLeagueFilter = document.getElementById('stats-league-filter')?.value || 'all';
        const stats = Statistics.calculateTeamStatistics(state.selectedTeamForColoring, finalMatches, currentLeagueFilter);
        DOMUtils.displayTeamStatistics(stats, availableLeagues);
        if (document.getElementById('stats-league-filter')) {
            document.getElementById('stats-league-filter').value = currentLeagueFilter;
        }
    }

    // Display results
    DOMUtils.displayDatabaseResults(finalMatches, state.selectedTeamForColoring);

    const limitText = state.selectedLimit ? ` (limit zakończonych: ${state.selectedLimit})` : '';
    const homeAwayText = state.homeAwayFilter === 'home' ? ' (domowe)' : state.homeAwayFilter === 'away' ? ' (wyjazdowe)' : '';
    showToast(`Wyświetlono ${finalMatches.length} meczów (${upcomingMatches.length} nadchodzących, ${limitedFinishedMatches.length} zakończonych)${limitText}${homeAwayText}`, 'success');
}

/**
 * Reset filters
 */
function resetFilters() {
    document.getElementById('filter-country').value = '';
    document.getElementById('filter-league').value = '';
    document.getElementById('filter-team').value = '';

    document.getElementById('filter-country-search').value = '';
    document.getElementById('filter-league-search').value = '';
    document.getElementById('filter-team-search').value = '';

    filterSelectOptions('filter-country', 'filter-country-search');
    filterSelectOptions('filter-league', 'filter-league-search');
    filterSelectOptions('filter-team', 'filter-team-search');

    state.selectedLimit = null;
    state.lastFetchedMatches = [];
    state.selectedTeamForColoring = null;
    state.homeAwayFilter = 'all';

    document.getElementById('team-stats-container').style.display = 'none';

    document.querySelectorAll('.limit-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelector('.limit-btn[onclick="window.setLimitAndFilter(null)"]').classList.add('active');

    loadDatabaseFilters();

    document.getElementById('database-results').innerHTML = `
        <div class="empty-state">
            <div class="empty-state-icon">🔍</div>
            <p>Wybierz filtry i kliknij Szukaj aby zobaczyć mecze</p>
        </div>
    `;

    showToast('Filtry zresetowane', 'success');
}

/**
 * Handle stats league filter change
 */
function onStatsLeagueChange() {
    const leagueFilter = document.getElementById('stats-league-filter').value;
    if (state.selectedTeamForColoring && state.lastFetchedMatches.length > 0) {
        let matches = [...state.lastFetchedMatches];
        if (state.selectedLimit) {
            matches = matches
                .sort((a, b) => new Date(b.match_date) - new Date(a.match_date))
                .slice(0, state.selectedLimit);
        }

        const stats = Statistics.calculateTeamStatistics(state.selectedTeamForColoring, matches, leagueFilter);
        const availableLeagues = [...new Set(matches.map(m => m.league))];
        DOMUtils.displayTeamStatistics(stats, availableLeagues);
        document.getElementById('stats-league-filter').value = leagueFilter;
    }
}

// =============================================================================
// EXPORT TO WINDOW (for onclick handlers in HTML)
// =============================================================================

window.init = init;
window.showToast = showToast;
window.setQuickDate = setQuickDate;
window.filterSelectOptions = filterSelectOptions;

// Country & League handlers
window.selectCountry = EventHandlers.selectCountry;
window.toggleLeague = EventHandlers.toggleLeague;
window.autoSelect = EventHandlers.autoSelect;
window.clearAll = EventHandlers.clearAll;
window.saveAndClose = EventHandlers.saveAndClose;

// Tab switching
window.switchTab = EventHandlers.switchTab;

// Limit handlers
window.setLimit = EventHandlers.setLimit;
window.setLimitAndFilter = EventHandlers.setLimitAndFilter;
window.setHomeAwayFilter = EventHandlers.setHomeAwayFilterHandler;

// Import handlers
window.showImportDialog = showImportDialog;
window.closeImportDialog = closeImportDialog;
window.startImport = startImport;
window.resumeImport = resumeImport;
window.stopImport = stopImport;
window.cancelImport = cancelImport;
window.closeProgressDialog = closeProgressDialog;

// Preset handlers
window.showSavePresetDialog = showSavePresetDialog;
window.closeSavePresetDialog = closeSavePresetDialog;
window.savePreset = savePreset;
window.showLoadPresetDialog = showLoadPresetDialog;
window.closeLoadPresetDialog = closeLoadPresetDialog;
window.loadPreset = loadPreset;
window.deletePreset = deletePreset;

// Database filter handlers
window.onCountryFilterChange = onCountryFilterChange;
window.onLeagueFilterChange = onLeagueFilterChange;
window.onTeamFilterChange = onTeamFilterChange;
window.applyFilters = applyFilters;
window.resetFilters = resetFilters;
window.onStatsLeagueChange = onStatsLeagueChange;

// Initialize on DOM load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}
