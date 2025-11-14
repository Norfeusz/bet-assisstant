/**
 * Utility Helper Functions
 * Reusable functions for validation, notifications, filtering, etc.
 */

/**
 * Display a toast notification
 * @param {string} message - Message to display
 * @param {string} type - Type of toast ('success', 'error', 'info')
 */
export function showToast(message, type = 'success') {
    const toast = document.getElementById('toast');
    const messageEl = document.getElementById('toast-message');

    messageEl.textContent = message;
    toast.className = `toast ${type} show`;

    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}

/**
 * Validate date range from input fields
 * @returns {Object|null} { dateFrom, dateTo } or null if invalid
 */
export function validateDateRange() {
    const dateFrom = document.getElementById('bet-finder-date-from').value;
    const dateTo = document.getElementById('bet-finder-date-to').value;

    if (!dateFrom || !dateTo) {
        showToast('Proszę wybrać zakres dat', 'error');
        return null;
    }

    const from = new Date(dateFrom);
    const to = new Date(dateTo);

    if (from > to) {
        showToast('Data początkowa musi być przed datą końcową', 'error');
        return null;
    }

    return { dateFrom, dateTo };
}

/**
 * Find mode (most frequent value) in an array
 * @param {Array} arr - Array of values
 * @returns {Object} { value, count } - Most frequent value and its count
 */
export function findMode(arr) {
    if (arr.length === 0) return { value: 'N/A', count: 0 };

    const frequency = {};
    let maxFreq = 0;
    let mode = arr[0];

    arr.forEach(val => {
        frequency[val] = (frequency[val] || 0) + 1;
        if (frequency[val] > maxFreq) {
            maxFreq = frequency[val];
            mode = val;
        }
    });

    return { value: mode, count: maxFreq };
}

/**
 * Set quick date range for import dialog
 * @param {string} range - Range type ('week', '2weeks', 'month', '3months')
 */
export function setQuickDate(range) {
    const endDate = new Date();
    const startDate = new Date();

    switch (range) {
        case 'week':
            startDate.setDate(startDate.getDate() - 7);
            break;
        case '2weeks':
            startDate.setDate(startDate.getDate() - 14);
            break;
        case 'month':
            startDate.setDate(startDate.getDate() - 30);
            break;
        case '3months':
            startDate.setMonth(startDate.getMonth() - 3);
            break;
    }

    document.getElementById('end-date').value = endDate.toISOString().split('T')[0];
    document.getElementById('start-date').value = startDate.toISOString().split('T')[0];
}

/**
 * Filter select dropdown options based on search input (with debounce)
 * @param {string} selectId - ID of select element
 * @param {string} searchInputId - ID of search input element
 */
const searchDebounceTimers = {};
export function filterSelectOptions(selectId, searchInputId) {
    // Clear existing timer for this search input
    if (searchDebounceTimers[searchInputId]) {
        clearTimeout(searchDebounceTimers[searchInputId]);
    }

    // Set new timer - execute after 500ms of no typing
    searchDebounceTimers[searchInputId] = setTimeout(() => {
        const searchInput = document.getElementById(searchInputId);
        const select = document.getElementById(selectId);
        const searchTerm = searchInput.value.toLowerCase();

        // Get all options except the first one (default "Wszystkie...")
        const options = Array.from(select.options);

        options.forEach((option, index) => {
            if (index === 0) {
                // Always show the default option
                option.style.display = '';
                return;
            }

            const text = option.textContent.toLowerCase();
            if (text.includes(searchTerm)) {
                option.style.display = '';
            } else {
                option.style.display = 'none';
            }
        });
    }, 500); // 500ms = 0.5 seconds
}

/**
 * Get color class based on percentage value
 * @param {string} percentage - Percentage value as string
 * @returns {string} CSS class name
 */
export function getPercentageColorClass(percentage) {
    const value = parseFloat(percentage);
    if (value >= 67) return 'text-green';
    if (value >= 34) return 'text-yellow';
    return 'text-red';
}
