/**
 * Search Queue Module
 * Manages a queue of search operations with progress tracking
 */

import { showToast } from './utils/helpers.js'

// Queue state
const searchQueue = {
	items: [],
	currentSearch: null,
	isProcessing: false,
	cancelRequested: false,
}

/**
 * Add search to queue
 * @param {Object} searchConfig - Search configuration
 * @param {string} searchConfig.name - Display name of the search
 * @param {Function} searchConfig.execute - Function to execute the search
 * @param {string} searchConfig.type - Type of search (for identification)
 */
export function addToQueue(searchConfig) {
	const id = Date.now() + Math.random()
	const item = {
		id,
		name: searchConfig.name,
		execute: searchConfig.execute,
		type: searchConfig.type,
		status: 'queued', // queued, processing, completed, cancelled, error
		addedAt: new Date(),
		startedAt: null,
		completedAt: null,
		error: null,
	}

	searchQueue.items.push(item)
	updateQueueUI()

	// Auto-start processing if not already processing
	if (!searchQueue.isProcessing) {
		processQueue()
	}

	showToast(`Dodano do kolejki: ${item.name}`, 'info')
	return id
}

/**
 * Remove item from queue
 * @param {number} id - Item ID
 */
export function removeFromQueue(id) {
	const index = searchQueue.items.findIndex(item => item.id === id)
	if (index !== -1) {
		const item = searchQueue.items[index]

		// Can't remove currently processing item
		if (searchQueue.currentSearch?.id === id) {
			showToast('Nie można usunąć aktualnie przetwarzanego wyszukiwania', 'warning')
			return false
		}

		searchQueue.items.splice(index, 1)
		updateQueueUI()
		showToast(`Usunięto z kolejki: ${item.name}`, 'info')
		return true
	}
	return false
}

/**
 * Cancel current search
 */
export function cancelCurrentSearch() {
	if (!searchQueue.currentSearch) {
		showToast('Brak aktywnego wyszukiwania', 'warning')
		return
	}

	searchQueue.cancelRequested = true
	showToast('Anulowanie wyszukiwania...', 'info')
}

/**
 * Check if cancellation was requested
 */
export function isCancelled() {
	return searchQueue.cancelRequested
}

/**
 * Process queue items one by one
 */
async function processQueue() {
	if (searchQueue.isProcessing) {
		return
	}

	searchQueue.isProcessing = true

	while (searchQueue.items.length > 0) {
		const nextItem = searchQueue.items.find(item => item.status === 'queued')

		if (!nextItem) {
			break
		}

		searchQueue.currentSearch = nextItem
		searchQueue.cancelRequested = false
		nextItem.status = 'processing'
		nextItem.startedAt = new Date()
		updateQueueUI()

		try {
			await nextItem.execute()

			if (searchQueue.cancelRequested) {
				nextItem.status = 'cancelled'
				nextItem.completedAt = new Date()
				// Remove cancelled item after a short delay
				setTimeout(() => {
					const index = searchQueue.items.findIndex(item => item.id === nextItem.id)
					if (index !== -1) {
						searchQueue.items.splice(index, 1)
						updateQueueUI()
					}
				}, 1000)
			} else {
				nextItem.status = 'completed'
				nextItem.completedAt = new Date()
				// Automatically remove completed item after a short delay
				setTimeout(() => {
					const index = searchQueue.items.findIndex(item => item.id === nextItem.id)
					if (index !== -1) {
						searchQueue.items.splice(index, 1)
						updateQueueUI()
					}
				}, 2000)
			}
		} catch (error) {
			console.error('Search execution error:', error)
			nextItem.status = 'error'
			nextItem.error = error.message
			nextItem.completedAt = new Date()
			showToast(`Błąd wyszukiwania: ${nextItem.name}`, 'error')
			// Keep error items visible longer
			setTimeout(() => {
				const index = searchQueue.items.findIndex(item => item.id === nextItem.id)
				if (index !== -1) {
					searchQueue.items.splice(index, 1)
					updateQueueUI()
				}
			}, 5000)
		}

		searchQueue.currentSearch = null
		updateQueueUI()

		// Small delay between searches
		await new Promise(resolve => setTimeout(resolve, 500))
	}

	searchQueue.isProcessing = false
	updateQueueUI()
}

/**
 * Get queue status
 */
export function getQueueStatus() {
	return {
		total: searchQueue.items.length,
		queued: searchQueue.items.filter(item => item.status === 'queued').length,
		processing: searchQueue.currentSearch ? 1 : 0,
		completed: searchQueue.items.filter(item => item.status === 'completed').length,
		isProcessing: searchQueue.isProcessing,
		currentSearch: searchQueue.currentSearch,
	}
}

/**
 * Update queue UI
 */
function updateQueueUI() {
	const status = getQueueStatus()

	// Always show queue panel
	const queuePanel = document.getElementById('search-queue-panel')
	if (queuePanel) {
		queuePanel.classList.add('active')
	}

	// Update current search info
	const currentInfo = document.getElementById('current-search-info')
	if (currentInfo) {
		if (searchQueue.currentSearch) {
			currentInfo.innerHTML = `
				<div style="display: flex; align-items: center; gap: 10px;">
					<div class="spinner"></div>
					<div>
						<div style="font-weight: 600;">${searchQueue.currentSearch.name}</div>
						<div style="font-size: 12px; color: #666;">Wyszukiwanie...</div>
					</div>
				</div>
			`
		} else if (status.queued > 0) {
			currentInfo.innerHTML = `
				<div style="color: #666; font-size: 14px;">
					Oczekujące wyszukiwania: ${status.queued}
				</div>
			`
		} else {
			currentInfo.innerHTML = `
				<div style="color: #666; font-size: 14px; text-align: center;">
					Kliknij przycisk wyszukiwania, aby dodać do kolejki
				</div>
			`
		}
	}

	// Update queue list
	const queueList = document.getElementById('search-queue-list')
	if (queueList) {
		if (searchQueue.items.length === 0) {
			queueList.innerHTML =
				'<div style="color: #666; text-align: center; padding: 20px;">Brak wyszukiwań w kolejce</div>'
		} else {
			queueList.innerHTML = searchQueue.items
				.map(item => {
					let statusIcon = ''
					let statusColor = ''
					let statusText = ''

					switch (item.status) {
						case 'queued':
							statusIcon = '⏳'
							statusColor = '#666'
							statusText = 'Oczekuje'
							break
						case 'processing':
							statusIcon = '<div class="spinner-small"></div>'
							statusColor = '#3b82f6'
							statusText = 'Wyszukiwanie...'
							break
						case 'completed':
							statusIcon = '✓'
							statusColor = '#059669'
							statusText = 'Zakończono'
							break
						case 'cancelled':
							statusIcon = '✗'
							statusColor = '#f59e0b'
							statusText = 'Anulowano'
							break
						case 'error':
							statusIcon = '⚠'
							statusColor = '#dc2626'
							statusText = 'Błąd'
							break
					}

					const canRemove = item.status !== 'processing'
					const removeButton = canRemove
						? `<button onclick="window.removeFromSearchQueue(${item.id})" 
						class="queue-remove-btn" title="Usuń z kolejki">×</button>`
						: ''

					return `
					<div class="queue-item" data-status="${item.status}">
						<div style="display: flex; align-items: center; gap: 8px; flex: 1;">
							<span style="color: ${statusColor}; font-size: 18px; min-width: 24px; text-align: center;">
								${statusIcon}
							</span>
							<div style="flex: 1;">
								<div style="font-weight: 500; font-size: 14px;">${item.name}</div>
								<div style="font-size: 12px; color: ${statusColor};">${statusText}</div>
							</div>
						</div>
						${removeButton}
					</div>
				`
				})
				.join('')
		}
	}

	// Update cancel button
	const cancelBtn = document.getElementById('cancel-search-btn')
	if (cancelBtn) {
		if (searchQueue.currentSearch && !searchQueue.cancelRequested) {
			cancelBtn.disabled = false
			cancelBtn.style.opacity = '1'
		} else {
			cancelBtn.disabled = true
			cancelBtn.style.opacity = '0.5'
		}
	}
}

// Export for window binding
window.removeFromSearchQueue = removeFromQueue
window.cancelCurrentSearch = cancelCurrentSearch
