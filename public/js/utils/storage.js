/**
 * LocalStorage Management
 * Centralized functions for saving/loading app state
 */

/**
 * Load watched matches from localStorage
 * @returns {Array} Array of watched matches
 */
export function loadWatchedMatches() {
    try {
        const saved = localStorage.getItem('watchedMatches');
        return saved ? JSON.parse(saved) : [];
    } catch (error) {
        console.error('Error loading watched matches:', error);
        return [];
    }
}

/**
 * Save watched matches to localStorage
 * @param {Array} matches - Array of watched matches
 */
export function saveWatchedMatches(matches) {
    try {
        localStorage.setItem('watchedMatches', JSON.stringify(matches));
    } catch (error) {
        console.error('Error saving watched matches:', error);
    }
}

/**
 * Load open modals state from localStorage
 * @returns {Array} Array of open modal states
 */
export function loadOpenModals() {
    try {
        const saved = localStorage.getItem('openModals');
        return saved ? JSON.parse(saved) : [];
    } catch (error) {
        console.error('Error loading open modals:', error);
        return [];
    }
}

/**
 * Save open modals state to localStorage
 * @param {Array} modals - Array of modal states
 */
export function saveOpenModals(modals) {
    try {
        localStorage.setItem('openModals', JSON.stringify(modals));
    } catch (error) {
        console.error('Error saving open modals:', error);
    }
}

/**
 * Load minimized match cards from localStorage
 * @returns {Array} Array of minimized card states
 */
export function loadMinimizedMatchCards() {
    try {
        const saved = localStorage.getItem('minimizedMatchCards');
        return saved ? JSON.parse(saved) : [];
    } catch (error) {
        console.error('Error loading minimized cards:', error);
        return [];
    }
}

/**
 * Save minimized match cards to localStorage
 * @param {Array} cards - Array of minimized card states
 */
export function saveMinimizedMatchCards(cards) {
    try {
        localStorage.setItem('minimizedMatchCards', JSON.stringify(cards));
    } catch (error) {
        console.error('Error saving minimized cards:', error);
    }
}
