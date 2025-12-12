/**
 * Watched Matches Module
 * Manages the list of matches user wants to watch
 */

import { showToast } from './utils/helpers.js'

// Watched matches storage
let watchedMatches = []

/**
 * Load watched matches from localStorage
 */
export function loadWatchedMatches() {
	const saved = localStorage.getItem('watchedMatches')
	if (saved) {
		try {
			watchedMatches = JSON.parse(saved)
		} catch (e) {
			console.error('Error loading watched matches:', e)
			watchedMatches = []
		}
	}
	return watchedMatches
}

/**
 * Save watched matches to localStorage
 */
export function saveWatchedMatches() {
	localStorage.setItem('watchedMatches', JSON.stringify(watchedMatches))
}

/**
 * Add match to watched list
 * @param {Object} match - Match data
 * @param {string} searchType - Type of search that found this match
 * @returns {boolean} - True if added, false if already exists
 */
export function addToWatchedMatches(match, searchType) {
	const matchId = `${match.homeTeam}-${match.awayTeam}-${match.date}-${match.league}`

	// Check if already exists
	const exists = watchedMatches.some(
		m =>
			m.homeTeam === match.homeTeam &&
			m.awayTeam === match.awayTeam &&
			m.date === match.date &&
			m.league === match.league
	)

	if (exists) {
		showToast('Ten mecz jest już w obserwowanych', 'warning')
		return false
	}

	// Add match with all data
	watchedMatches.push({
		id: matchId,
		date: match.date,
		league: match.league,
		leagueId: match.leagueId || null,
		country: match.country || '',
		homeTeam: match.homeTeam,
		awayTeam: match.awayTeam,
		searchType: searchType,
		homeStats: match.homeStats || {},
		awayStats: match.awayStats || {},
		odds: '', // Empty by default, user can edit
		note: '', // Empty by default, user can add
		addedAt: new Date().toISOString(),
	})

	saveWatchedMatches()
	showToast('Mecz dodany do obserwowanych', 'success')

	// Update minimized card if exists
	ensureWatchedMatchesCard()

	return true
}

/**
 * Remove match from watched list
 * @param {string} matchId - Match ID
 */
export function removeFromWatchedMatches(matchId) {
	watchedMatches = watchedMatches.filter(m => m.id !== matchId)
	saveWatchedMatches()
	showToast('Mecz usunięty z obserwowanych', 'info')

	// Update card and modal
	ensureWatchedMatchesCard()
	updateWatchedMatchesModal()
}

/**
 * Update watched match odds
 * @param {string} matchId - Match ID
 * @param {string} odds - Odds value
 */
export function updateWatchedMatchOdds(matchId, odds) {
	const match = watchedMatches.find(m => m.id === matchId)
	if (match) {
		match.odds = odds
		saveWatchedMatches()
		ensureWatchedMatchesCard()
	}
}

/**
 * Edit watched match note
 * @param {string} matchId - Match ID
 */
export function editWatchedMatchNote(matchId) {
	const match = watchedMatches.find(m => m.id === matchId)
	if (!match) return

	const currentNote = match.note || ''
	const newNote = prompt('Wprowadź notatkę dla tego meczu:', currentNote)

	if (newNote !== null) {
		// User didn't cancel
		match.note = newNote.trim()
		saveWatchedMatches()
		showWatchedMatchesModal() // Refresh modal
		showToast('Notatka zaktualizowana', 'success')
	}
}

/**
 * Clear all watched matches
 */
export function clearAllWatchedMatches() {
	if (watchedMatches.length === 0) {
		showToast('Brak meczów do usunięcia', 'info')
		return
	}

	const count = watchedMatches.length
	if (confirm(`Czy na pewno chcesz usunąć wszystkie obserwowane mecze (${count})?`)) {
		watchedMatches.length = 0 // Clear array
		saveWatchedMatches()
		showWatchedMatchesModal() // Refresh modal
		ensureWatchedMatchesCard()
		showToast(`Usunięto ${count} ${count === 1 ? 'mecz' : count < 5 ? 'mecze' : 'meczów'}`, 'success')
	}
}

/**
 * Show watched matches modal
 */
export function showWatchedMatchesModal() {
	// Sort by match date
	const sortedMatches = [...watchedMatches].sort((a, b) => new Date(a.date) - new Date(b.date))

	let modalHTML = `
        <div class="modal-backdrop" onclick="window.minimizeWatchedMatchesModal()"></div>
        <div class="modal-dialog">
            <div class="modal-header" style="background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);">
                <h2>⭐ Obserwowane mecze (${watchedMatches.length})</h2>
                <div style="display: flex; gap: 10px;">
                    <button class="btn-small" onclick="window.open('https://docs.google.com/spreadsheets/d/1xMCeRR4TxxtdBQNwcCLKvs-AqxPk3l1Hqm_MNyKRWnM/edit', '_blank')" 
                        style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; padding: 6px 12px; font-size: 13px; font-weight: 600;"
                        title="Otwórz arkusz Strefa Typera">
                        📄 ST
                    </button>
                    <button class="btn-small" onclick="window.clearAllWatchedMatches()" 
                        style="background: #7f1d1d; color: white; padding: 6px 12px; font-size: 13px;"
                        title="Usuń wszystkie obserwowane mecze">
                        🗑️ Usuń wszystkie
                    </button>
                    <button class="modal-minimize" onclick="window.minimizeWatchedMatchesModal()" title="Minimalizuj">−</button>
                    <button class="modal-close" onclick="window.closeWatchedMatchesModal()">×</button>
                </div>
            </div>
            <div class="modal-body" style="background: #f9fafb; padding: 25px;">
    `

	if (sortedMatches.length === 0) {
		modalHTML += `
            <div style="text-align: center; padding: 40px 20px; color: #6b7280;">
                <div style="font-size: 48px; margin-bottom: 15px;">📭</div>
                <p style="font-size: 18px; font-weight: 600; margin-bottom: 10px;">Brak obserwowanych meczów</p>
                <p style="font-size: 14px;">Dodaj mecze z wyszukiwania Bet Finder, aby śledzić je tutaj</p>
            </div>
        `
	} else {
		modalHTML += `
            <table class="results-table">
                <thead>
                    <tr>
                        <th>Data</th>
                        <th>Liga</th>
                        <th>Gospodarze</th>
                        <th>Goście</th>
                        <th>Typ</th>
                        <th>Kurs</th>
                        <th>Notatka</th>
                        <th>Akcje</th>
                    </tr>
                </thead>
                <tbody>
        `

		sortedMatches.forEach(match => {
			const formattedDate = new Date(match.date).toLocaleDateString('pl-PL')
			const oddsValue = match.odds || '-'

			modalHTML += `
                <tr>
                    <td style="padding: 12px; font-weight: 600;">${formattedDate}</td>
                    <td style="padding: 12px; font-size: 12px; color: #666;">${match.league}</td>
                    <td style="padding: 12px; font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${match.homeTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${match.homeTeam}
                        </a>
                    </td>
                    <td style="padding: 12px; font-weight: 600;">
                        <a href="#" class="team-link" onclick="window.openTeamStats('${match.awayTeam.replace(
													/'/g,
													"\\'"
												)}'); return false;">
                            ${match.awayTeam}
                        </a>
                    </td>
                    <td style="padding: 12px; font-size: 11px;">
                        <a href="#" 
                            onclick="window.showBetFinderMatchDetailsModal(${JSON.stringify(match).replace(/"/g, '&quot;')}); return false;"
                            style="color: #3b82f6; text-decoration: underline; cursor: pointer;"
                            onmouseover="this.style.color='#2563eb'"
                            onmouseout="this.style.color='#3b82f6'">
                            ${match.searchType || '-'}
                        </a>
                    </td>
                    <td style="padding: 12px;">
                        <input type="text" value="${oddsValue}" 
                            onchange="window.updateWatchedMatchOdds('${match.id}', this.value)"
                            style="width: 60px; padding: 4px 8px; border: 1px solid #d1d5db; border-radius: 4px; font-size: 12px;"
                            placeholder="Kurs">
                    </td>
                    <td style="padding: 12px; text-align: center;">
                        <div style="display: inline-flex; align-items: center; gap: 8px;">
                            ${
															match.note
																? `
                                <span 
                                    style="font-size: 18px; cursor: help; color: #3b82f6;" 
                                    title="${match.note.replace(/"/g, '&quot;')}">
                                    ℹ️
                                </span>
                            `
																: ''
														}
                            <button 
                                onclick="window.editWatchedMatchNote('${match.id}')" 
                                style="background: #3b82f6; color: white; border: none; padding: 6px 10px; border-radius: 4px; cursor: pointer; font-size: 11px; white-space: nowrap;"
                                onmouseover="this.style.background='#2563eb'"
                                onmouseout="this.style.background='#3b82f6'"
                                title="${match.note ? 'Edytuj notatkę' : 'Dodaj notatkę'}">
                                ${match.note ? '✏️' : '➕'}
                            </button>
                        </div>
                    </td>
                    <td style="padding: 12px;">
                        <div style="display: flex; gap: 8px;">
                            <button
                                onclick="window.addToStrefaTypera('${match.homeTeam.replace(/'/g, "\\'")}', '${match.awayTeam.replace(/'/g, "\\'")}', '${match.league.replace(/'/g, "\\'")}', '${match.date}', '${match.country?.replace(/'/g, "\\'") || ''}', ${match.leagueId || 'null'})"
                                style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; border: none; padding: 8px 14px; border-radius: 6px; cursor: pointer; font-size: 12px; font-weight: 600; white-space: nowrap; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"
                                onmouseover="this.style.background='linear-gradient(135deg, #059669 0%, #047857 100%)'"
                                onmouseout="this.style.background='linear-gradient(135deg, #10b981 0%, #059669 100%)'"
                                title="Dodaj do Strefa Typera">
                                📄 ST
                            </button>
                            <button
                                onclick="window.removeFromWatchedMatches('${match.id}')"
                                style="background: #dc2626; color: white; border: none; padding: 8px 14px; border-radius: 6px; cursor: pointer; font-size: 12px; font-weight: 600; white-space: nowrap;"
                                onmouseover="this.style.background='#b91c1c'"
                                onmouseout="this.style.background='#dc2626'"
                                title="Usuń z obserwowanych">
                                🗑️ Usuń
                            </button>
                        </div>
                    </td>
                </tr>
            `
		})

		modalHTML += `
                </tbody>
            </table>
        `
	}

	modalHTML += `
            </div>
        </div>
    `

	// Remove existing modal
	const existingModal = document.getElementById('watched-matches-modal')
	if (existingModal) {
		existingModal.remove()
	}

	// Create and show modal
	const modalContainer = document.createElement('div')
	modalContainer.id = 'watched-matches-modal'
	modalContainer.innerHTML = modalHTML
	document.body.appendChild(modalContainer)
}

/**
 * Minimize watched matches modal
 */
export function minimizeWatchedMatchesModal() {
	const modal = document.getElementById('watched-matches-modal')
	if (modal) {
		modal.remove()
	}
	ensureWatchedMatchesCard()
}

/**
 * Close watched matches modal
 */
export function closeWatchedMatchesModal() {
	const modal = document.getElementById('watched-matches-modal')
	if (modal) {
		modal.remove()
	}
}

/**
 * Update watched matches modal if open
 */
function updateWatchedMatchesModal() {
	const modal = document.getElementById('watched-matches-modal')
	if (modal) {
		showWatchedMatchesModal()
	}
}

/**
 * Ensure watched matches minimized card exists and is up to date
 */
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

export function ensureWatchedMatchesCard() {
	const container = ensureCardsContainer()
	let miniCard = document.getElementById('minimized-watched-matches-card')

	if (!miniCard) {
		miniCard = document.createElement('div')
		miniCard.id = 'minimized-watched-matches-card'
		miniCard.className = 'minimized-match-card watched-matches-card'
		miniCard.innerHTML = `
            <div class="minimized-card-content" onclick="window.restoreWatchedMatchesModal()">
                <span class="minimized-card-icon">⭐</span>
                <span class="minimized-card-text">Obserwowane (${watchedMatches.length})</span>
            </div>
        `
		container.appendChild(miniCard)
	} else {
		// Update count
		const textSpan = miniCard.querySelector('.minimized-card-text')
		if (textSpan) {
			textSpan.textContent = `Obserwowane (${watchedMatches.length})`
		}
		miniCard.style.display = 'flex'
	}

	repositionMinimizedMatchCards()
}

/**
 * Restore watched matches modal
 */
export function restoreWatchedMatchesModal() {
	const miniCard = document.getElementById('minimized-watched-matches-card')
	if (miniCard) {
		miniCard.style.display = 'none'
	}
	showWatchedMatchesModal()
}

/**
 * Reposition minimized match cards (left side)
 */
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

/**
 * Get watched matches count
 */
export function getWatchedMatchesCount() {
	return watchedMatches.length
}
