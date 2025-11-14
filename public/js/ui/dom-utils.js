/**
 * DOM Rendering Utilities
 * Functions for rendering and displaying data in the UI
 */

import { showToast, getPercentageColorClass } from '../utils/helpers.js';
import { state, setCurrentTeamStats } from '../config/state.js';
import * as API from '../api/api-client.js';

/**
 * Render countries list
 * @param {Array} countries - Array of countries
 */
export function renderCountries(countries) {
    const html = countries.map(country => `
        <div class="country-item" onclick="window.selectCountry('${country.name}')">
            <span class="country-name">${country.flag} ${country.name}</span>
            <span class="country-badge" id="badge-${country.name}">0</span>
        </div>
    `).join('');

    document.getElementById('countries-list').innerHTML = html;
}

/**
 * Display database results (matches)
 * @param {Array} matches - Array of matches
 * @param {string|null} selectedTeam - Selected team for coloring
 */
export function displayDatabaseResults(matches, selectedTeam = null) {
    const resultsDiv = document.getElementById('database-results');

    if (matches.length === 0) {
        resultsDiv.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">❌</div>
                <p>Nie znaleziono meczów dla wybranych filtrów</p>
            </div>
        `;
        return;
    }

    // Split matches into upcoming and finished
    const upcomingMatches = matches.filter(m => m.is_finished === 'no');
    const finishedMatches = matches.filter(m => m.is_finished === 'yes');

    let tableHTML = `
        <div class="results-header">
            <div class="results-count">📊 Wyświetlam ${matches.length} meczów (${upcomingMatches.length} nadchodzących, ${finishedMatches.length} zakończonych)</div>
            ${selectedTeam ? `
                <div style="display: flex; gap: 10px; margin-top: 10px;">
                    <button class="limit-btn ${state.homeAwayFilter === 'all' ? 'active' : ''}" 
                            onclick="window.setHomeAwayFilter('all')" 
                            style="flex: 1;">
                        Wszystkie
                    </button>
                    <button class="limit-btn ${state.homeAwayFilter === 'home' ? 'active' : ''}" 
                            onclick="window.setHomeAwayFilter('home')" 
                            style="flex: 1;">
                        🏠 Mecze domowe
                    </button>
                    <button class="limit-btn ${state.homeAwayFilter === 'away' ? 'active' : ''}" 
                            onclick="window.setHomeAwayFilter('away')" 
                            style="flex: 1;">
                        ✈️ Mecze wyjazdowe
                    </button>
                </div>
            ` : ''}
        </div>
    `;

    // Render upcoming matches
    if (upcomingMatches.length > 0) {
        tableHTML += renderMatchesTable(upcomingMatches, '🔜 Nadchodzące mecze', selectedTeam);
    }

    // Render finished matches
    if (finishedMatches.length > 0) {
        tableHTML += renderMatchesTable(finishedMatches, '✅ Zakończone mecze', selectedTeam);
    }

    resultsDiv.innerHTML = tableHTML;
}

/**
 * Render matches table
 * @param {Array} matchesList - Array of matches
 * @param {string} sectionTitle - Section title
 * @param {string|null} selectedTeam - Selected team for coloring
 * @returns {string} HTML string
 */
export function renderMatchesTable(matchesList, sectionTitle, selectedTeam = null) {
    if (matchesList.length === 0) return '';

    let html = `
        <div class="matches-section">
            <h3 class="section-title">${sectionTitle}</h3>
            <div style="overflow-x: auto;">
                <table class="matches-table">
                    <thead>
                        <tr>
                            <th>Data</th>
                            <th>Mecz</th>
                            <th>Wynik</th>
                            <th>Liga</th>
                            <th style="text-align: center;">Status</th>
                            <th style="text-align: center;">Szczegóły</th>
                        </tr>
                    </thead>
                    <tbody>
    `;

    matchesList.forEach(match => {
        const date = new Date(match.match_date).toLocaleDateString('pl-PL', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
        });

        const result = match.result || 'draw';
        const isFinished = match.is_finished === 'yes';

        // Determine team colors
        let homeClass = '';
        let awayClass = '';

        if (selectedTeam) {
            if (match.home_team === selectedTeam) {
                if (result === 'home_win' || result === 'h-win') {
                    homeClass = 'win';
                } else if (result === 'away_win' || result === 'a-win') {
                    homeClass = 'loss';
                } else {
                    homeClass = 'draw';
                }
            } else if (match.away_team === selectedTeam) {
                if (result === 'away_win' || result === 'a-win') {
                    awayClass = 'win';
                } else if (result === 'home_win' || result === 'h-win') {
                    awayClass = 'loss';
                } else {
                    awayClass = 'draw';
                }
            }
        } else {
            if (result === 'home_win' || result === 'h-win') {
                homeClass = 'win';
                awayClass = 'loss';
            } else if (result === 'away_win' || result === 'a-win') {
                homeClass = 'loss';
                awayClass = 'win';
            } else if (result === 'draw') {
                homeClass = 'draw';
                awayClass = 'draw';
            }
        }

        const homeGoals = match.home_goals !== null && match.home_goals !== undefined ? match.home_goals : '-';
        const awayGoals = match.away_goals !== null && match.away_goals !== undefined ? match.away_goals : '-';
        const homeGoalsHT = match.home_goals_ht;
        const awayGoalsHT = match.away_goals_ht;

        const htScoreDisplay = (homeGoalsHT !== null && homeGoalsHT !== undefined && awayGoalsHT !== null && awayGoalsHT !== undefined)
            ? `(${homeGoalsHT}:${awayGoalsHT})`
            : '';

        const statusIcon = isFinished ? '✅' : '❓';

        html += `
            <tr>
                <td class="match-date">${date}</td>
                <td>
                    <div class="match-teams">
                        <span class="team-name ${homeClass}">${match.home_team}</span>
                        <span>-</span>
                        <span class="team-name ${awayClass}">${match.away_team}</span>
                    </div>
                </td>
                <td class="match-score">
                    <span class="score-main ${homeClass}">${homeGoals}</span>
                    <span>:</span>
                    <span class="score-main ${awayClass}">${awayGoals}</span>
                    ${htScoreDisplay ? `<span class="score-ht">${htScoreDisplay}</span>` : ''}
                </td>
                <td class="match-league">${match.league}</td>
                <td class="match-status">${statusIcon}</td>
                <td class="expand-icon" onclick="alert('Szczegóły meczu - wkrótce!')">📊</td>
            </tr>
        `;
    });

    html += `
                    </tbody>
                </table>
            </div>
        </div>
    `;

    return html;
}

/**
 * Display team statistics panel
 * @param {Object} stats - Statistics object
 * @param {Array} availableLeagues - Available leagues for filter
 */
export function displayTeamStatistics(stats, availableLeagues) {
    if (!stats) {
        document.getElementById('team-stats-container').style.display = 'none';
        return;
    }

    // Store stats globally for modal access
    setCurrentTeamStats(stats);

    const container = document.getElementById('team-stats-container');
    container.style.display = 'block';

    let leagueOptions = '<option value="all">Wszystkie rozgrywki</option>';
    availableLeagues.forEach(league => {
        leagueOptions += `<option value="${league}">${league}</option>`;
    });

    container.innerHTML = `
        <div class="team-stats-panel">
            <div class="team-stats-header">
                <h3>⚽ Statystyki: ${stats.teamName}</h3>
                <select class="team-stats-league-select" id="stats-league-filter" onchange="window.onStatsLeagueChange()">
                    ${leagueOptions}
                </select>
            </div>
            <div class="team-stats-grid">
                <div class="stat-card highlight">
                    <div class="stat-card-label">Mecze</div>
                    <div class="stat-card-value">${stats.totalMatches}</div>
                </div>

                <!-- GRUPA 1: PUNKTY -->
                <div class="stat-card group-points">
                    <div class="stat-card-label">Śr. punktów</div>
                    <div class="stat-card-value">${stats.avgPoints}</div>
                    <div class="stat-card-subtitle">ogólnie</div>
                </div>
                <div class="stat-card group-points">
                    <div class="stat-card-label">Śr. punktów</div>
                    <div class="stat-card-value">${stats.avgPointsHome}</div>
                    <div class="stat-card-subtitle">u siebie</div>
                </div>
                <div class="stat-card group-points">
                    <div class="stat-card-label">Śr. punktów</div>
                    <div class="stat-card-value">${stats.avgPointsAway}</div>
                    <div class="stat-card-subtitle">na wyjeździe</div>
                </div>
                <div class="stat-card group-points border-green">
                    <div class="stat-card-label">% Wygranych</div>
                    <div class="stat-card-value">${stats.winPercentage}%</div>
                </div>
                <div class="stat-card group-points border-yellow">
                    <div class="stat-card-label">% Remisów</div>
                    <div class="stat-card-value">${stats.drawPercentage}%</div>
                </div>
                <div class="stat-card group-points border-red">
                    <div class="stat-card-label">% Porażek</div>
                    <div class="stat-card-value">${stats.lossPercentage}%</div>
                </div>

                <!-- GRUPA 2: POŁOWY -->
                <div class="stat-card group-halves">
                    <div class="stat-card-label">% Wygr. 1 poł.</div>
                    <div class="stat-card-value ${getPercentageColorClass(stats.firstHalfWinPercentage)}">${stats.firstHalfWinPercentage}%</div>
                </div>
                <div class="stat-card group-halves">
                    <div class="stat-card-label">% Wygr. 2 poł.</div>
                    <div class="stat-card-value ${getPercentageColorClass(stats.secondHalfWinPercentage)}">${stats.secondHalfWinPercentage}%</div>
                </div>
                <div class="stat-card group-halves">
                    <div class="stat-card-label">% Wygr. obu poł.</div>
                    <div class="stat-card-value ${getPercentageColorClass(stats.bothHalvesWinPercentage)}">${stats.bothHalvesWinPercentage}%</div>
                </div>
                <div class="stat-card group-halves">
                    <div class="stat-card-label">% Wygr. 1 poł. i cały mecz</div>
                    <div class="stat-card-value ${getPercentageColorClass(stats.firstHalfAndFullWinPercentage)}">${stats.firstHalfAndFullWinPercentage}%</div>
                </div>

                <!-- GRUPA 3: GOLE -->
                <div class="stat-card group-goals border-green">
                    <div class="stat-card-label">Śr. goli</div>
                    <div class="stat-card-value">${stats.avgGoalsScored}</div>
                    <div class="stat-card-subtitle">strzelonych</div>
                </div>
                <div class="stat-card group-goals border-red">
                    <div class="stat-card-label">Śr. goli</div>
                    <div class="stat-card-value">${stats.avgGoalsConceded}</div>
                    <div class="stat-card-subtitle">straconych</div>
                </div>
                <div class="stat-card group-goals">
                    <div class="stat-card-label">Śr. goli</div>
                    <div class="stat-card-value">${stats.avgGoalsTotal}</div>
                    <div class="stat-card-subtitle">w sumie</div>
                </div>

                <!-- GRUPA 4: ROŻNE -->
                <div class="stat-card group-corners border-green">
                    <div class="stat-card-label">Śr. rożnych +</div>
                    <div class="stat-card-value">${stats.avgCornersFor}</div>
                    <div class="stat-card-subtitle">(${stats.cornersAvailable})</div>
                </div>
                <div class="stat-card group-corners border-red">
                    <div class="stat-card-label">Śr. rożnych -</div>
                    <div class="stat-card-value">${stats.avgCornersAgainst}</div>
                    <div class="stat-card-subtitle">(${stats.cornersAvailable})</div>
                </div>

                <!-- More stats groups can be added here -->
            </div>
        </div>
    `;
}

/**
 * Render presets list
 * @param {Array} presets - Array of presets
 */
export function renderPresetsList(presets) {
    const list = document.getElementById('presets-list');

    if (presets.length === 0) {
        list.innerHTML = '<p style="text-align: center; color: #999; padding: 40px;">No saved presets. Create one first!</p>';
        return;
    }

    list.innerHTML = presets.map(preset => `
        <div style="background: #f7fafc; border-radius: 8px; padding: 15px; margin-bottom: 10px; border: 1px solid #e2e8f0;">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div style="flex: 1;">
                    <h3 style="margin: 0 0 5px 0; font-size: 16px; color: #2d3748;">${preset.name}</h3>
                    <p style="margin: 0 0 5px 0; color: #718096; font-size: 13px;">${preset.description || 'No description'}</p>
                    <p style="margin: 0; color: #a0aec0; font-size: 12px;">${preset.leagueIds.length} leagues • ${new Date(preset.createdAt).toLocaleDateString()}</p>
                </div>
                <div style="display: flex; gap: 8px;">
                    <button class="btn load-preset-btn" data-preset-name="${preset.name}" style="background: #3b82f6; color: white; padding: 8px 16px; font-size: 13px;">
                        📂 Load
                    </button>
                    <button class="btn delete-preset-btn" data-preset-name="${preset.name}" style="background: #ef4444; color: white; padding: 8px 16px; font-size: 13px;">
                        🗑️
                    </button>
                </div>
            </div>
        </div>
    `).join('');

    // Add event listeners
    setTimeout(() => {
        document.querySelectorAll('.load-preset-btn').forEach(btn => {
            btn.addEventListener('click', function () {
                const name = this.getAttribute('data-preset-name');
                window.loadPreset(name);
            });
        });

        document.querySelectorAll('.delete-preset-btn').forEach(btn => {
            btn.addEventListener('click', function () {
                const name = this.getAttribute('data-preset-name');
                window.deletePreset(name);
            });
        });
    }, 0);
}
