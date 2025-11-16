/**
 * Global State Management
 * Centralized application state
 */

// Global state object
export const state = {
	// Country and league selection
	selectedCountry: null,
	configuredLeagues: new Set(),
	leagues: [],

	// Database filters
	databaseCountries: [],
	databaseLeagues: [],
	databaseTeams: [],
	selectedLimit: null,
	lastFetchedMatches: [],
	selectedTeamForColoring: null,
	homeAwayFilter: 'all',

	// Bet finder
	selectedMatchCount: 10,

	// Current team stats
	currentTeamStats: null,

	// Background jobs
	backgroundJobsInterval: null,
}

// Export individual getters/setters for convenience
export function setSelectedCountry(country) {
	state.selectedCountry = country
}

export function getSelectedCountry() {
	return state.selectedCountry
}

export function addConfiguredLeague(leagueId) {
	state.configuredLeagues.add(leagueId)
}

export function removeConfiguredLeague(leagueId) {
	state.configuredLeagues.delete(leagueId)
}

export function clearConfiguredLeagues() {
	state.configuredLeagues.clear()
}

export function setLeagues(leagues) {
	state.leagues = leagues
}

export function getLeagues() {
	return state.leagues
}

export function setDatabaseCountries(countries) {
	state.databaseCountries = countries
}

export function setDatabaseLeagues(leagues) {
	state.databaseLeagues = leagues
}

export function setDatabaseTeams(teams) {
	state.databaseTeams = teams
}

export function setSelectedLimit(limit) {
	state.selectedLimit = limit
}

export function getSelectedLimit() {
	return state.selectedLimit
}

export function setLastFetchedMatches(matches) {
	state.lastFetchedMatches = matches
}

export function getLastFetchedMatches() {
	return state.lastFetchedMatches
}

export function setSelectedTeamForColoring(team) {
	state.selectedTeamForColoring = team
}

export function getSelectedTeamForColoring() {
	return state.selectedTeamForColoring
}

export function setHomeAwayFilter(filter) {
	state.homeAwayFilter = filter
}

export function getHomeAwayFilter() {
	return state.homeAwayFilter
}

export function setSelectedMatchCount(count) {
	state.selectedMatchCount = count
}

export function getSelectedMatchCount() {
	return state.selectedMatchCount
}

export function setCurrentTeamStats(stats) {
	state.currentTeamStats = stats
	// Also expose globally for modal access
	window.currentTeamStats = stats
}

export function getCurrentTeamStats() {
	return state.currentTeamStats
}
