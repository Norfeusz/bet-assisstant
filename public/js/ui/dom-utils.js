/**
 * DOM Rendering Utilities
 * Functions for rendering and displaying data in the UI
 */

import { showToast, getPercentageColorClass } from '../utils/helpers.js'
import { state, setCurrentTeamStats } from '../config/state.js'
import * as API from '../api/api-client.js'
import { prepareModalData, preparePercentageModalData } from '../utils/statistics.js'

/**
 * Render countries list
 * @param {Array} countries - Array of countries
 */
export function renderCountries(countries) {
	const html = countries
		.map(
			country => `
        <div class="country-item" onclick="window.selectCountry('${country.name}')">
            <span class="country-name">${country.flag} ${country.name}</span>
            <span class="country-badge" id="badge-${country.name}">0</span>
        </div>
    `
		)
		.join('')

	document.getElementById('countries-list').innerHTML = html
}

/**
 * Display database results (matches)
 * @param {Array} matches - Array of matches
 * @param {string|null} selectedTeam - Selected team for coloring
 */
export function displayDatabaseResults(matches, selectedTeam = null) {
	const resultsDiv = document.getElementById('database-results')

	if (matches.length === 0) {
		resultsDiv.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">❌</div>
                <p>Nie znaleziono meczów dla wybranych filtrów</p>
            </div>
        `
		return
	}

	// Split matches into upcoming and finished
	const upcomingMatches = matches.filter(m => m.is_finished === 'no')
	const finishedMatches = matches.filter(m => m.is_finished === 'yes')

	let tableHTML = `
        <div class="results-header">
            <div class="results-count">📊 Wyświetlam ${matches.length} meczów (${
		upcomingMatches.length
	} nadchodzących, ${finishedMatches.length} zakończonych)</div>
            ${
							selectedTeam
								? `
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
            `
								: ''
						}
        </div>
    `

	// Render upcoming matches
	if (upcomingMatches.length > 0) {
		tableHTML += renderMatchesTable(upcomingMatches, '🔜 Nadchodzące mecze', selectedTeam)
	}

	// Render finished matches
	if (finishedMatches.length > 0) {
		tableHTML += renderMatchesTable(finishedMatches, '✅ Zakończone mecze', selectedTeam)
	}

	resultsDiv.innerHTML = tableHTML
}

/**
 * Render matches table
 * @param {Array} matchesList - Array of matches
 * @param {string} sectionTitle - Section title
 * @param {string|null} selectedTeam - Selected team for coloring
 * @returns {string} HTML string
 */
export function renderMatchesTable(matchesList, sectionTitle, selectedTeam = null) {
	if (matchesList.length === 0) return ''

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
    `

	matchesList.forEach(match => {
		const date = new Date(match.match_date).toLocaleDateString('pl-PL', {
			year: 'numeric',
			month: '2-digit',
			day: '2-digit',
		})

		const result = match.result || 'draw'
		const isFinished = match.is_finished === 'yes'

		// Determine team colors
		let homeClass = ''
		let awayClass = ''

		if (selectedTeam) {
			if (match.home_team === selectedTeam) {
				if (result === 'home_win' || result === 'h-win') {
					homeClass = 'win'
				} else if (result === 'away_win' || result === 'a-win') {
					homeClass = 'loss'
				} else {
					homeClass = 'draw'
				}
			} else if (match.away_team === selectedTeam) {
				if (result === 'away_win' || result === 'a-win') {
					awayClass = 'win'
				} else if (result === 'home_win' || result === 'h-win') {
					awayClass = 'loss'
				} else {
					awayClass = 'draw'
				}
			}
		} else {
			if (result === 'home_win' || result === 'h-win') {
				homeClass = 'win'
				awayClass = 'loss'
			} else if (result === 'away_win' || result === 'a-win') {
				homeClass = 'loss'
				awayClass = 'win'
			} else if (result === 'draw') {
				homeClass = 'draw'
				awayClass = 'draw'
			}
		}

		const homeGoals = match.home_goals !== null && match.home_goals !== undefined ? match.home_goals : '-'
		const awayGoals = match.away_goals !== null && match.away_goals !== undefined ? match.away_goals : '-'
		const homeGoalsHT = match.home_goals_ht
		const awayGoalsHT = match.away_goals_ht

		const htScoreDisplay =
			homeGoalsHT !== null && homeGoalsHT !== undefined && awayGoalsHT !== null && awayGoalsHT !== undefined
				? `(${homeGoalsHT}:${awayGoalsHT})`
				: ''

		const statusIcon = isFinished ? '✅' : '❓'

		html += `
            <tr>
                <td class="match-date">${date}</td>
                <td>
                    <div class="match-teams">
                        <span class="team-name ${homeClass}" style="cursor: pointer; text-decoration: underline;" onclick="window.loadTeamStats('${match.home_team.replace(/'/g, "\\'")}')">${match.home_team}</span>
                        <span>-</span>
                        <span class="team-name ${awayClass}" style="cursor: pointer; text-decoration: underline;" onclick="window.loadTeamStats('${match.away_team.replace(/'/g, "\\'")}')">${match.away_team}</span>
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
                <td class="expand-icon" onclick="window.showMatchDetailsModal(${match.id})">📊</td>
            </tr>
        `
	})

	html += `
                    </tbody>
                </table>
            </div>
        </div>
    `

	return html
}

/**
 * Display team statistics panel
 * @param {Object} stats - Statistics object
 * @param {Array} availableLeagues - Available leagues for filter
 */
export function displayTeamStatistics(stats, availableLeagues) {
	if (!stats) {
		document.getElementById('team-stats-container').style.display = 'none'
		return
	}

	// Store stats globally for modal access
	setCurrentTeamStats(stats)

	const container = document.getElementById('team-stats-container')
	container.style.display = 'block'

	let leagueOptions = '<option value="all">Wszystkie rozgrywki</option>'
	availableLeagues.forEach(league => {
		leagueOptions += `<option value="${league}">${league}</option>`
	})

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
                    <div class="stat-card-value ${getPercentageColorClass(stats.firstHalfWinPercentage)}">${
		stats.firstHalfWinPercentage
	}%</div>
                </div>
                <div class="stat-card group-halves">
                    <div class="stat-card-label">% Wygr. 2 poł.</div>
                    <div class="stat-card-value ${getPercentageColorClass(stats.secondHalfWinPercentage)}">${
		stats.secondHalfWinPercentage
	}%</div>
                </div>
                <div class="stat-card group-halves">
                    <div class="stat-card-label">% Wygr. obu poł.</div>
                    <div class="stat-card-value ${getPercentageColorClass(stats.bothHalvesWinPercentage)}">${
		stats.bothHalvesWinPercentage
	}%</div>
                </div>
                <div class="stat-card group-halves">
                    <div class="stat-card-label">% Wygr. 1 poł. i cały mecz</div>
                    <div class="stat-card-value ${getPercentageColorClass(stats.firstHalfAndFullWinPercentage)}">${
		stats.firstHalfAndFullWinPercentage
	}%</div>
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
                <div class="stat-card group-goals">
                    <div class="stat-card-label">Śr. goli 1H</div>
                    <div class="stat-card-value">${stats.avgGoalsScored1H}</div>
                    <div class="stat-card-subtitle">strzelonych</div>
                </div>
                <div class="stat-card group-goals">
                    <div class="stat-card-label">Śr. goli 1H</div>
                    <div class="stat-card-value">${stats.avgGoalsTotal1H}</div>
                    <div class="stat-card-subtitle">w sumie</div>
                </div>
                <div class="stat-card group-goals">
                    <div class="stat-card-label">Śr. goli 2H</div>
                    <div class="stat-card-value">${stats.avgGoalsTotal2H}</div>
                    <div class="stat-card-subtitle">w sumie</div>
                </div>
                <div class="stat-card group-goals">
                    <div class="stat-card-label">% meczów BTS</div>
                    <div class="stat-card-value ${getPercentageColorClass(stats.bothTeamsScoredPercentage)}">${
		stats.bothTeamsScoredPercentage
	}%</div>
                    <div class="stat-card-subtitle">obie strzeliły</div>
                </div>
                <div class="stat-card group-goals border-green">
                    <div class="stat-card-label">Śr. xG +</div>
                    <div class="stat-card-value">${stats.avgXgFor}</div>
                    <div class="stat-card-subtitle">(${stats.xgAvailable})</div>
                </div>
                <div class="stat-card group-goals border-red">
                    <div class="stat-card-label">Śr. xG -</div>
                    <div class="stat-card-value">${stats.avgXgAgainst}</div>
                    <div class="stat-card-subtitle">(${stats.xgAvailable})</div>
                </div>

                <!-- GRUPA 3a: OVER/UNDER -->
                <div class="stat-card group-overunder">
                    <div class="stat-card-label">% meczów bez strzelonej bramki</div>
                    <div class="stat-card-value ${getPercentageColorClass(stats.noGoalsScoredPercentage)}">${
		stats.noGoalsScoredPercentage
	}%</div>
                    <div class="stat-card-subtitle">0 goli</div>
                </div>
                <div class="stat-card group-overunder">
                    <div class="stat-card-label">% meczów ze strzeloną bramką</div>
                    <div class="stat-card-value ${getPercentageColorClass(stats.atLeast1GoalScoredPercentage)}">${
		stats.atLeast1GoalScoredPercentage
	}%</div>
                    <div class="stat-card-subtitle">≥1 gol</div>
                </div>
                <div class="stat-card group-overunder">
                    <div class="stat-card-label">% meczów ze strzelonymi 2 bramkami</div>
                    <div class="stat-card-value ${getPercentageColorClass(stats.atLeast2GoalsScoredPercentage)}">${
		stats.atLeast2GoalsScoredPercentage
	}%</div>
                    <div class="stat-card-subtitle">≥2 gole</div>
                </div>
                <div class="stat-card group-overunder">
                    <div class="stat-card-label">% meczów z czystym kontem</div>
                    <div class="stat-card-value ${getPercentageColorClass(stats.cleanSheetPercentage)}">${
		stats.cleanSheetPercentage
	}%</div>
                    <div class="stat-card-subtitle">0 straconych</div>
                </div>
                <div class="stat-card group-overunder">
                    <div class="stat-card-label">% meczów ze straconą bramką</div>
                    <div class="stat-card-value ${getPercentageColorClass(stats.atLeast1GoalConcededPercentage)}">${
		stats.atLeast1GoalConcededPercentage
	}%</div>
                    <div class="stat-card-subtitle">≥1 stracony</div>
                </div>
                <div class="stat-card group-overunder">
                    <div class="stat-card-label">% meczów ze straconymi 2 bramkami</div>
                    <div class="stat-card-value ${getPercentageColorClass(stats.atLeast2GoalsConcededPercentage)}">${
		stats.atLeast2GoalsConcededPercentage
	}%</div>
                    <div class="stat-card-subtitle">≥2 stracone</div>
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
                <div class="stat-card group-corners border-green">
                    <div class="stat-card-label">Najczęściej rożnych +</div>
                    <div class="stat-card-value">${stats.mostFrequentCornersFor}</div>
                </div>
                <div class="stat-card group-corners border-red">
                    <div class="stat-card-label">Najczęściej rożnych -</div>
                    <div class="stat-card-value">${stats.mostFrequentCornersAgainst}</div>
                </div>
                <div class="stat-card group-corners">
                    <div class="stat-card-label">% meczów powyżej rożnych +</div>
                    <div class="stat-card-value">${stats.percentAboveCornersForMode}%</div>
                    <div class="stat-card-subtitle">powyżej najczęstszej</div>
                </div>

                <!-- GRUPA 5: STRZAŁY -->
                <div class="stat-card group-shots border-green">
                    <div class="stat-card-label">Śr. strzałów +</div>
                    <div class="stat-card-value">${stats.avgShotsFor}</div>
                    <div class="stat-card-subtitle">(${stats.shotsAvailable})</div>
                </div>
                <div class="stat-card group-shots border-red">
                    <div class="stat-card-label">Śr. strzałów -</div>
                    <div class="stat-card-value">${stats.avgShotsAgainst}</div>
                    <div class="stat-card-subtitle">(${stats.shotsAvailable})</div>
                </div>
                <div class="stat-card group-shots border-green">
                    <div class="stat-card-label">Śr. strzałów celnych +</div>
                    <div class="stat-card-value">${stats.avgShotsOnTargetFor}</div>
                    <div class="stat-card-subtitle">(${stats.shotsOnTargetAvailable})</div>
                </div>
                <div class="stat-card group-shots border-red">
                    <div class="stat-card-label">Śr. strzałów celnych -</div>
                    <div class="stat-card-value">${stats.avgShotsOnTargetAgainst}</div>
                    <div class="stat-card-subtitle">(${stats.shotsOnTargetAvailable})</div>
                </div>

                <!-- GRUPA 6: SPALENI I POSIADANIE -->
                <div class="stat-card group-other">
                    <div class="stat-card-label">Śr. spalonych +</div>
                    <div class="stat-card-value">${stats.avgOffsidesFor}</div>
                    <div class="stat-card-subtitle">(${stats.offsidesAvailable})</div>
                </div>
                <div class="stat-card group-other">
                    <div class="stat-card-label">Śr. spalonych -</div>
                    <div class="stat-card-value">${stats.avgOffsidesAgainst}</div>
                    <div class="stat-card-subtitle">(${stats.offsidesAvailable})</div>
                </div>
                <div class="stat-card group-other">
                    <div class="stat-card-label">Śr. posiadanie piłki</div>
                    <div class="stat-card-value">${stats.avgPossession}%</div>
                    <div class="stat-card-subtitle">(${stats.possessionAvailable})</div>
                </div>

                <!-- More stats groups can be added here -->
            </div>
        </div>
    `

	// Add click handlers to all stat cards
	setTimeout(() => {
		const statCards = container.querySelectorAll('.stat-card:not(.highlight)')
		statCards.forEach(card => {
			const label = card.querySelector('.stat-card-label')?.textContent
			const subtitle = card.querySelector('.stat-card-subtitle')?.textContent
			const fullLabel = subtitle ? `${label} - ${subtitle}` : label

			card.style.cursor = 'pointer'
			card.onclick = () => {
				let modalData = []
				let highlightValue = null

				// Determine which stat type based on label
				if (label.includes('Śr. punktów')) {
					// Show all matches with result
					modalData = stats.matchDetails.map(m => ({
						...m,
						value: m.result === 'W' ? 3 : m.result === 'R' ? 1 : 0,
						displayValue: `${m.goalsScored}-${m.goalsConceded} (${
							m.result === 'W' ? '3 pkt' : m.result === 'R' ? '1 pkt' : '0 pkt'
						})`,
					}))
				} else if (label.includes('% Wygranych')) {
					modalData = preparePercentageModalData(stats, 'wins')
				} else if (label.includes('% Remisów')) {
					modalData = preparePercentageModalData(stats, 'draws')
				} else if (label.includes('% Porażek')) {
					modalData = preparePercentageModalData(stats, 'losses')
				} else if (label.includes('% Wygr. 1 poł.')) {
					modalData = preparePercentageModalData(stats, 'firstHalfWin')
				} else if (label.includes('% Wygr. 2 poł.')) {
					modalData = preparePercentageModalData(stats, 'secondHalfWin')
				} else if (label.includes('% Wygr. obu poł.')) {
					modalData = preparePercentageModalData(stats, 'bothHalvesWin')
				} else if (label.includes('% Wygr. 1 poł. i cały mecz')) {
					modalData = preparePercentageModalData(stats, 'firstHalfAndFullWin')
				} else if (label.includes('Śr. goli') && subtitle?.includes('strzelonych')) {
					if (subtitle.includes('1H')) {
						modalData = prepareModalData(stats, 'goalsScored1H')
					} else {
						modalData = prepareModalData(stats, 'goalsScored')
					}
				} else if (label.includes('Śr. goli') && subtitle?.includes('straconych')) {
					modalData = prepareModalData(stats, 'goalsConceded')
				} else if (label.includes('Śr. goli') && subtitle?.includes('w sumie')) {
					if (subtitle.includes('1H')) {
						modalData = prepareModalData(stats, 'goalsTotal1H')
					} else if (subtitle.includes('2H')) {
						modalData = prepareModalData(stats, 'goalsTotal2H')
					} else {
						modalData = prepareModalData(stats, 'goalsTotal')
					}
				} else if (label.includes('Śr. xG +')) {
					modalData = prepareModalData(stats, 'xgFor')
				} else if (label.includes('Śr. xG -')) {
					modalData = prepareModalData(stats, 'xgAgainst')
				} else if (label.includes('% meczów BTS')) {
					modalData = preparePercentageModalData(stats, 'bothTeamsScored')
				} else if (label.includes('% meczów bez strzelonej bramki')) {
					modalData = preparePercentageModalData(stats, 'noGoalsScored')
				} else if (label.includes('% meczów ze strzeloną bramką') && !label.includes('2 bramkami')) {
					modalData = preparePercentageModalData(stats, 'atLeast1GoalScored')
				} else if (label.includes('% meczów ze strzelonymi 2 bramkami')) {
					modalData = preparePercentageModalData(stats, 'atLeast2GoalsScored')
				} else if (label.includes('% meczów z czystym kontem')) {
					modalData = preparePercentageModalData(stats, 'cleanSheet')
				} else if (label.includes('% meczów ze straconą bramką') && !label.includes('2 bramkami')) {
					modalData = preparePercentageModalData(stats, 'atLeast1GoalConceded')
				} else if (label.includes('% meczów ze straconymi 2 bramkami')) {
					modalData = preparePercentageModalData(stats, 'atLeast2GoalsConceded')
				} else if (label.includes('Śr. rożnych +')) {
					modalData = prepareModalData(stats, 'cornersFor')
				} else if (label.includes('Śr. rożnych -')) {
					modalData = prepareModalData(stats, 'cornersAgainst')
				} else if (label.includes('Najczęściej rożnych +')) {
					modalData = prepareModalData(stats, 'cornersFor')
					highlightValue = stats.cornersForMode.value
				} else if (label.includes('Najczęściej rożnych -')) {
					modalData = prepareModalData(stats, 'cornersAgainst')
					highlightValue = stats.cornersAgainstMode.value
				} else if (label.includes('% meczów powyżej')) {
					modalData = prepareModalData(stats, 'cornersFor')
					highlightValue = stats.cornersForMode.value
				} else if (label.includes('Śr. strzałów celnych +')) {
					modalData = prepareModalData(stats, 'shotsOnTargetFor')
				} else if (label.includes('Śr. strzałów celnych -')) {
					modalData = prepareModalData(stats, 'shotsOnTargetAgainst')
				} else if (label.includes('Śr. strzałów +')) {
					modalData = prepareModalData(stats, 'shotsFor')
				} else if (label.includes('Śr. strzałów -')) {
					modalData = prepareModalData(stats, 'shotsAgainst')
				} else if (label.includes('Śr. spalonych +')) {
					modalData = prepareModalData(stats, 'offsidesFor')
				} else if (label.includes('Śr. spalonych -')) {
					modalData = prepareModalData(stats, 'offsidesAgainst')
				} else if (label.includes('Śr. posiadanie')) {
					modalData = prepareModalData(stats, 'possession')
				}

				if (modalData.length > 0) {
					showStatModal(fullLabel, modalData, highlightValue)
				}
			}
		})
	}, 100)
}

/**
 * Show statistics modal with match details
 * @param {string} statLabel - Label for the statistic
 * @param {Array} matchesData - Array of match data
 * @param {*} highlightValue - Optional value to highlight
 */
export function showStatModal(statLabel, matchesData, highlightValue = null) {
	const modal = document.getElementById('statModal')
	const modalTitle = document.getElementById('statModalTitle')
	const modalBody = document.getElementById('statModalBody')

	modalTitle.textContent = statLabel

	// Clear previous content
	modalBody.innerHTML = ''

	if (!matchesData || matchesData.length === 0) {
		modalBody.innerHTML = '<p style="text-align: center; color: #999;">Brak danych do wyświetlenia</p>'
	} else {
		matchesData.forEach(match => {
			const matchItem = document.createElement('div')
			matchItem.className = 'modal-match-item'

			// Date
			const dateEl = document.createElement('div')
			dateEl.className = 'modal-match-date'
			dateEl.textContent = match.date

			// Opponent with home/away indicator
			const opponentEl = document.createElement('div')
			opponentEl.className = 'modal-match-opponent'
			opponentEl.textContent = `${match.opponent} (${match.homeAway})`

			// Result badge (W/D/L)
			const resultEl = document.createElement('div')
			resultEl.className = `modal-match-result ${match.resultClass}`
			resultEl.textContent = match.result

			// Value
			const valueEl = document.createElement('div')
			valueEl.className = 'modal-match-value'
			if (highlightValue !== null && match.value === highlightValue) {
				valueEl.classList.add('highlight')
			}
			valueEl.textContent = match.displayValue

			matchItem.appendChild(dateEl)
			matchItem.appendChild(opponentEl)
			matchItem.appendChild(resultEl)
			matchItem.appendChild(valueEl)

			modalBody.appendChild(matchItem)
		})
	}

	modal.classList.add('active')
	document.body.style.overflow = 'hidden'
}

/**
 * Close statistics modal
 * @param {Event} event - Click event
 */
export function closeStatModal(event) {
	if (event && event.target !== event.currentTarget) return

	const modal = document.getElementById('statModal')
	modal.classList.remove('active')
	document.body.style.overflow = ''
}

/**
 * Render presets list
 * @param {Array} presets - Array of presets
 */
export function renderPresetsList(presets) {
	const list = document.getElementById('presets-list')

	if (presets.length === 0) {
		list.innerHTML =
			'<p style="text-align: center; color: #999; padding: 40px;">No saved presets. Create one first!</p>'
		return
	}

	list.innerHTML = presets
		.map(
			preset => `
        <div style="background: #f7fafc; border-radius: 8px; padding: 15px; margin-bottom: 10px; border: 1px solid #e2e8f0;">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div style="flex: 1;">
                    <h3 style="margin: 0 0 5px 0; font-size: 16px; color: #2d3748;">${preset.name}</h3>
                    <p style="margin: 0 0 5px 0; color: #718096; font-size: 13px;">${
											preset.description || 'No description'
										}</p>
                    <p style="margin: 0; color: #a0aec0; font-size: 12px;">${
											preset.leagueIds.length
										} leagues • ${new Date(preset.createdAt).toLocaleDateString()}</p>
                </div>
                <div style="display: flex; gap: 8px;">
                    <button class="btn load-preset-btn" data-preset-name="${
											preset.name
										}" style="background: #3b82f6; color: white; padding: 8px 16px; font-size: 13px;">
                        📂 Load
                    </button>
                    <button class="btn delete-preset-btn" data-preset-name="${
											preset.name
										}" style="background: #ef4444; color: white; padding: 8px 16px; font-size: 13px;">
                        🗑️
                    </button>
                </div>
            </div>
        </div>
    `
		)
		.join('')

	// Add event listeners
	setTimeout(() => {
		document.querySelectorAll('.load-preset-btn').forEach(btn => {
			btn.addEventListener('click', function () {
				const name = this.getAttribute('data-preset-name')
				window.loadPreset(name)
			})
		})

		document.querySelectorAll('.delete-preset-btn').forEach(btn => {
			btn.addEventListener('click', function () {
				const name = this.getAttribute('data-preset-name')
				window.deletePreset(name)
			})
		})
	}, 0)
}

/**
 * Show match details modal
 * @param {number} matchId - Match ID
 */
export async function showMatchDetailsModal(matchId) {
	const modal = document.getElementById('match-details-modal')
	const title = document.getElementById('match-details-title')
	const content = document.getElementById('match-details-content')

	// Show loading state
	modal.style.display = 'flex'
	modal.classList.add('show')
	content.innerHTML = '<div style="text-align: center; padding: 40px;"><div class="spinner"></div><p>Ładowanie szczegółów...</p></div>'

	try {
		const match = await API.loadMatchDetails(matchId)
		
		console.log('Match data received:', match)
		console.log('Is finished:', match.is_finished)

		// Format date
		const matchDate = new Date(match.match_date).toLocaleDateString('pl-PL', {
			weekday: 'long',
			year: 'numeric',
			month: 'long',
			day: 'numeric',
		})

		// Build match details HTML
		let html = `
            <div class="match-details-header">
                <div class="match-details-info">${matchDate} • ${match.league} • ${match.country}</div>
                <div class="match-details-teams">
                    <span>${match.home_team}</span>
                    <span style="color: rgba(255,255,255,0.7);">vs</span>
                    <span>${match.away_team}</span>
                </div>
                ${
									match.is_finished === 'yes'
										? `
                    <div class="match-details-score">
                        ${match.home_goals} : ${match.away_goals}
                        ${
													match.home_goals_ht !== null && match.away_goals_ht !== null
														? `<div style="font-size: 18px; opacity: 0.8; margin-top: 5px;">(HT: ${match.home_goals_ht}:${match.away_goals_ht})</div>`
														: ''
												}
                    </div>
                `
										: '<div class="match-details-score">Mecz nie został jeszcze rozegrany</div>'
								}
            </div>

            <div class="match-stats-grid">
        `

		if (match.is_finished === 'yes') {
			// Goals & Result - ALWAYS show for finished matches
			html += `
                <div class="match-stat-card">
                    <h4>⚽ Bramki i Wynik</h4>
                    <div class="match-stat-row">
                        <span class="match-stat-label">Wynik pełny czas</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value home">${match.home_goals !== null ? match.home_goals : 0}</span>
                            <span>:</span>
                            <span class="match-stat-value away">${match.away_goals !== null ? match.away_goals : 0}</span>
                        </div>
                    </div>
                    ${
											match.home_goals_ht !== null && match.away_goals_ht !== null
												? `
                    <div class="match-stat-row">
                        <span class="match-stat-label">Wynik pierwsza połowa</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value home">${match.home_goals_ht}</span>
                            <span>:</span>
                            <span class="match-stat-value away">${match.away_goals_ht}</span>
                        </div>
                    </div>
                    `
												: ''
										}
                    <div class="match-stat-row">
                        <span class="match-stat-label">Rezultat</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value ${match.result === 'h-win' ? 'highlight' : ''}">
                                ${
																	match.result === 'h-win'
																		? 'Wygrana gospodarzy'
																		: match.result === 'a-win'
																		? 'Wygrana gości'
																		: 'Remis'
																}
                            </span>
                        </div>
                    </div>
                </div>
            `

			// xG Stats
			if (match.home_xg !== null && match.away_xg !== null) {
				html += `
                <div class="match-stat-card">
                    <h4>📈 Expected Goals (xG)</h4>
                    <div class="match-stat-row">
                        <span class="match-stat-label">xG</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value home">${parseFloat(match.home_xg).toFixed(2)}</span>
                            <span>:</span>
                            <span class="match-stat-value away">${parseFloat(match.away_xg).toFixed(2)}</span>
                        </div>
                    </div>
                </div>
            `
			}

			// Shots
			if (match.home_shots !== null || match.away_shots !== null) {
				html += `
                <div class="match-stat-card">
                    <h4>🎯 Strzały</h4>
                    <div class="match-stat-row">
                        <span class="match-stat-label">Wszystkie strzały</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value home">${match.home_shots || 0}</span>
                            <span>:</span>
                            <span class="match-stat-value away">${match.away_shots || 0}</span>
                        </div>
                    </div>
                    ${
											match.home_shots_on_target !== null || match.away_shots_on_target !== null
												? `
                    <div class="match-stat-row">
                        <span class="match-stat-label">Strzały celne</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value home">${match.home_shots_on_target || 0}</span>
                            <span>:</span>
                            <span class="match-stat-value away">${match.away_shots_on_target || 0}</span>
                        </div>
                    </div>
                    `
												: ''
										}
                </div>
            `
			}

			// Corners & Offsides
			if (match.home_corners !== null || match.away_corners !== null) {
				html += `
                <div class="match-stat-card">
                    <h4>🚩 Rożne i spaleni</h4>
                    <div class="match-stat-row">
                        <span class="match-stat-label">Rożne</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value home">${match.home_corners || 0}</span>
                            <span>:</span>
                            <span class="match-stat-value away">${match.away_corners || 0}</span>
                        </div>
                    </div>
                    ${
											match.home_offsides !== null || match.away_offsides !== null
												? `
                    <div class="match-stat-row">
                        <span class="match-stat-label">Spaleni</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value home">${match.home_offsides || 0}</span>
                            <span>:</span>
                            <span class="match-stat-value away">${match.away_offsides || 0}</span>
                        </div>
                    </div>
                    `
												: ''
										}
                </div>
            `
			}

			// Possession
			if (match.home_possession !== null && match.away_possession !== null) {
				html += `
                <div class="match-stat-card">
                    <h4>⚡ Posiadanie piłki</h4>
                    <div class="match-stat-row">
                        <span class="match-stat-label">Posiadanie (%)</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value home">${parseFloat(match.home_possession).toFixed(1)}%</span>
                            <span>:</span>
                            <span class="match-stat-value away">${parseFloat(match.away_possession).toFixed(1)}%</span>
                        </div>
                    </div>
                </div>
            `
			}

			// Cards & Fouls
			if (
				match.home_y_cards !== null ||
				match.away_y_cards !== null ||
				match.home_fouls !== null ||
				match.away_fouls !== null
			) {
				html += `
                <div class="match-stat-card">
                    <h4>🟨 Kartki i faule</h4>
                    ${
											match.home_y_cards !== null || match.away_y_cards !== null
												? `
                    <div class="match-stat-row">
                        <span class="match-stat-label">Żółte kartki</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value home">${match.home_y_cards || 0}</span>
                            <span>:</span>
                            <span class="match-stat-value away">${match.away_y_cards || 0}</span>
                        </div>
                    </div>
                    `
												: ''
										}
                    ${
											match.home_r_cards !== null || match.away_r_cards !== null
												? `
                    <div class="match-stat-row">
                        <span class="match-stat-label">Czerwone kartki</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value home">${match.home_r_cards || 0}</span>
                            <span>:</span>
                            <span class="match-stat-value away">${match.away_r_cards || 0}</span>
                        </div>
                    </div>
                    `
												: ''
										}
                    ${
											match.home_fouls !== null || match.away_fouls !== null
												? `
                    <div class="match-stat-row">
                        <span class="match-stat-label">Faule</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value home">${match.home_fouls || 0}</span>
                            <span>:</span>
                            <span class="match-stat-value away">${match.away_fouls || 0}</span>
                        </div>
                    </div>
                    `
												: ''
										}
                </div>
            `
			}

			// Odds
			if (match.home_odds !== null || match.draw_odds !== null || match.away_odds !== null) {
				html += `
                <div class="match-stat-card">
                    <h4>💰 Kursy bukmacherskie</h4>
                    <div class="match-stat-row">
                        <span class="match-stat-label">Wygrana gospodarzy</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value">${match.home_odds ? parseFloat(match.home_odds).toFixed(2) : 'N/A'}</span>
                        </div>
                    </div>
                    <div class="match-stat-row">
                        <span class="match-stat-label">Remis</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value">${match.draw_odds ? parseFloat(match.draw_odds).toFixed(2) : 'N/A'}</span>
                        </div>
                    </div>
                    <div class="match-stat-row">
                        <span class="match-stat-label">Wygrana gości</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value">${match.away_odds ? parseFloat(match.away_odds).toFixed(2) : 'N/A'}</span>
                        </div>
                    </div>
                </div>
            `
			}

			// Standings
			if (match.standing_home !== null || match.standing_away !== null) {
				html += `
                <div class="match-stat-card">
                    <h4>📊 Pozycja w tabeli</h4>
                    <div class="match-stat-row">
                        <span class="match-stat-label">Gospodarz</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value">${match.standing_home ? `${match.standing_home}. miejsce` : 'N/A'}</span>
                        </div>
                    </div>
                    <div class="match-stat-row">
                        <span class="match-stat-label">Gość</span>
                        <div class="match-stat-values">
                            <span class="match-stat-value">${match.standing_away ? `${match.standing_away}. miejsce` : 'N/A'}</span>
                        </div>
                    </div>
                </div>
            `
			}
		} else {
			html += `<div class="no-data">Mecz nie został jeszcze rozegrany - brak statystyk</div>`
		}

		html += `</div>` // Close match-stats-grid
		
		console.log('📊 Generated HTML length:', html.length)
		console.log('📊 HTML includes match-stat-card:', html.includes('match-stat-card'))
		
		// If no stats were added, show message
		if (!html.includes('match-stat-card')) {
			content.innerHTML = `
				<div class="match-details-header">
					<div class="match-details-info">${matchDate} • ${match.league} • ${match.country}</div>
					<div class="match-details-teams">
						<span>${match.home_team}</span>
						<span style="color: rgba(255,255,255,0.7);">vs</span>
						<span>${match.away_team}</span>
					</div>
					${
						match.is_finished === 'yes'
							? `<div class="match-details-score">${match.home_goals} : ${match.away_goals}</div>`
							: '<div class="match-details-score">Mecz nie został jeszcze rozegrany</div>'
					}
				</div>
				<div class="no-data">Brak szczegółowych statystyk dla tego meczu</div>
			`
		} else {
			content.innerHTML = html
		}
		
		title.textContent = `${match.home_team} vs ${match.away_team}`
	} catch (error) {
		console.error('Error loading match details:', error)
		content.innerHTML = '<div class="no-data">❌ Nie udało się załadować szczegółów meczu</div>'
	}
}

/**
 * Close match details modal
 */
export function closeMatchDetailsModal() {
	const modal = document.getElementById('match-details-modal')
	modal.style.display = 'none'
	modal.classList.remove('show')
}
