/**
 * Team Statistics Calculator
 * Functions for calculating and preparing team statistics
 */

import { findMode } from '../utils/helpers.js';

/**
 * Calculate comprehensive team statistics
 * @param {string} teamName - Team name
 * @param {Array} matches - Array of matches
 * @param {string} leagueFilter - Optional league filter ('all' or league name)
 * @returns {Object|null} Statistics object or null if no matches
 */
export function calculateTeamStatistics(teamName, matches, leagueFilter = null) {
    // Filter only finished matches
    let teamMatches = matches.filter(m => m.is_finished === 'yes');

    // Apply league filter if specified
    if (leagueFilter && leagueFilter !== 'all') {
        teamMatches = teamMatches.filter(m => m.league === leagueFilter);
    }

    const totalMatches = teamMatches.length;
    if (totalMatches === 0) {
        return null;
    }

    let points = 0, homePoints = 0, awayPoints = 0;
    let homeMatches = 0, awayMatches = 0;
    let wins = 0, draws = 0, losses = 0;
    let goalsScored = 0, goalsConceded = 0;
    let goalsScored1H = 0, goalsScored2H = 0;
    let goalsConceded1H = 0, goalsConceded2H = 0;
    let firstHalfWins = 0, secondHalfWins = 0, bothHalvesWins = 0;
    let comebackWins = 0, comebackLosses = 0;
    let firstHalfAndFullWins = 0;

    // Over/Under stats
    let bothTeamsScored = 0;
    let noGoalsScored = 0;
    let atLeast1GoalScored = 0;
    let atLeast2GoalsScored = 0;
    let cleanSheet = 0;
    let atLeast1GoalConceded = 0;
    let atLeast2GoalsConceded = 0;

    // Advanced stats
    let cornersFor = 0, cornersAgainst = 0, cornersCount = 0;
    let offsidesFor = 0, offsidesAgainst = 0, offsidesCount = 0;
    let shotsFor = 0, shotsAgainst = 0, shotsCount = 0;
    let shotsOnTargetFor = 0, shotsOnTargetAgainst = 0, shotsOnTargetCount = 0;
    let xgFor = 0, xgAgainst = 0, xgCount = 0;
    let possessionSum = 0, possessionCount = 0;

    // Arrays for mode calculations
    let cornersForArray = [];
    let cornersAgainstArray = [];

    // Detailed match data for modal
    let matchDetails = [];

    teamMatches.forEach(match => {
        const isHome = match.home_team === teamName;
        const homeGoals = match.home_goals || 0;
        const awayGoals = match.away_goals || 0;
        const homeGoalsHT = match.home_goals_ht || 0;
        const awayGoalsHT = match.away_goals_ht || 0;

        // Match result
        const matchPoints = isHome
            ? (homeGoals > awayGoals ? 3 : homeGoals === awayGoals ? 1 : 0)
            : (awayGoals > homeGoals ? 3 : homeGoals === awayGoals ? 1 : 0);

        points += matchPoints;

        if (isHome) {
            homeMatches++;
            homePoints += matchPoints;
            goalsScored += homeGoals;
            goalsConceded += awayGoals;
            goalsScored1H += homeGoalsHT;
            goalsConceded1H += awayGoalsHT;
            goalsScored2H += (homeGoals - homeGoalsHT);
            goalsConceded2H += (awayGoals - awayGoalsHT);

            // Advanced stats - home
            if (match.home_corners != null && match.away_corners != null) {
                cornersFor += match.home_corners;
                cornersAgainst += match.away_corners;
                cornersForArray.push(match.home_corners);
                cornersAgainstArray.push(match.away_corners);
                cornersCount++;
            }
            if (match.home_possession != null) {
                possessionSum += match.home_possession;
                possessionCount++;
            }
            if (match.home_offsides != null && match.away_offsides != null) {
                offsidesFor += match.home_offsides;
                offsidesAgainst += match.away_offsides;
                offsidesCount++;
            }
            if (match.home_shots != null && match.away_shots != null) {
                shotsFor += match.home_shots;
                shotsAgainst += match.away_shots;
                shotsCount++;
            }
            if (match.home_shots_on_target != null && match.away_shots_on_target != null) {
                shotsOnTargetFor += match.home_shots_on_target;
                shotsOnTargetAgainst += match.away_shots_on_target;
                shotsOnTargetCount++;
            }
            if (match.home_xg != null && match.away_xg != null) {
                xgFor += parseFloat(match.home_xg);
                xgAgainst += parseFloat(match.away_xg);
                xgCount++;
            }
        } else {
            awayMatches++;
            awayPoints += matchPoints;
            goalsScored += awayGoals;
            goalsConceded += homeGoals;
            goalsScored1H += awayGoalsHT;
            goalsConceded1H += homeGoalsHT;
            goalsScored2H += (awayGoals - awayGoalsHT);
            goalsConceded2H += (homeGoals - homeGoalsHT);

            // Advanced stats - away
            if (match.home_corners != null && match.away_corners != null) {
                cornersFor += match.away_corners;
                cornersAgainst += match.home_corners;
                cornersForArray.push(match.away_corners);
                cornersAgainstArray.push(match.home_corners);
                cornersCount++;
            }
            if (match.away_possession != null) {
                possessionSum += match.away_possession;
                possessionCount++;
            }
            if (match.home_offsides != null && match.away_offsides != null) {
                offsidesFor += match.away_offsides;
                offsidesAgainst += match.home_offsides;
                offsidesCount++;
            }
            if (match.home_shots != null && match.away_shots != null) {
                shotsFor += match.away_shots;
                shotsAgainst += match.home_shots;
                shotsCount++;
            }
            if (match.home_shots_on_target != null && match.away_shots_on_target != null) {
                shotsOnTargetFor += match.away_shots_on_target;
                shotsOnTargetAgainst += match.home_shots_on_target;
                shotsOnTargetCount++;
            }
            if (match.home_xg != null && match.away_xg != null) {
                xgFor += parseFloat(match.away_xg);
                xgAgainst += parseFloat(match.home_xg);
                xgCount++;
            }
        }

        // Win/Draw/Loss
        if (matchPoints === 3) wins++;
        else if (matchPoints === 1) draws++;
        else losses++;

        // Half-time analysis
        const teamGoalsHT = isHome ? homeGoalsHT : awayGoalsHT;
        const oppGoalsHT = isHome ? awayGoalsHT : homeGoalsHT;
        const teamGoalsFT = isHome ? homeGoals : awayGoals;
        const oppGoalsFT = isHome ? awayGoals : homeGoals;

        // First half win
        if (teamGoalsHT > oppGoalsHT) firstHalfWins++;

        // Second half win
        const teamGoals2H = teamGoalsFT - teamGoalsHT;
        const oppGoals2H = oppGoalsFT - oppGoalsHT;
        if (teamGoals2H > oppGoals2H) secondHalfWins++;

        // Both halves wins
        if (teamGoalsHT > oppGoalsHT && teamGoals2H > oppGoals2H) bothHalvesWins++;

        // First half and full match win
        if (teamGoalsHT > oppGoalsHT && matchPoints === 3) firstHalfAndFullWins++;

        // Comebacks
        const isComebackWin = teamGoalsHT < oppGoalsHT && teamGoalsFT > oppGoalsFT;
        const isComebackLoss = teamGoalsHT > oppGoalsHT && teamGoalsFT < oppGoalsFT;
        if (isComebackWin) comebackWins++;
        if (isComebackLoss) comebackLosses++;

        // Over/Under stats
        const teamGoalsScored = isHome ? homeGoals : awayGoals;
        const oppGoalsScored = isHome ? awayGoals : homeGoals;

        if (homeGoals > 0 && awayGoals > 0) bothTeamsScored++;
        if (teamGoalsScored === 0) noGoalsScored++;
        if (teamGoalsScored >= 1) atLeast1GoalScored++;
        if (teamGoalsScored >= 2) atLeast2GoalsScored++;
        if (oppGoalsScored === 0) cleanSheet++;
        if (oppGoalsScored >= 1) atLeast1GoalConceded++;
        if (oppGoalsScored >= 2) atLeast2GoalsConceded++;

        // Store detailed match data
        const matchDate = new Date(match.match_date);
        const formattedDate = `${matchDate.getDate().toString().padStart(2, '0')}.${(matchDate.getMonth() + 1).toString().padStart(2, '0')}.${matchDate.getFullYear()}`;
        const opponent = isHome ? match.away_team : match.home_team;
        const homeAway = isHome ? 'D' : 'W';
        const result = matchPoints === 3 ? 'W' : matchPoints === 1 ? 'R' : 'P';
        const resultClass = matchPoints === 3 ? 'win' : matchPoints === 1 ? 'draw' : 'loss';

        matchDetails.push({
            date: formattedDate,
            opponent: opponent,
            homeAway: homeAway,
            result: result,
            resultClass: resultClass,
            isHome: isHome,
            goalsScored: isHome ? homeGoals : awayGoals,
            goalsConceded: isHome ? awayGoals : homeGoals,
            goalsTotal: homeGoals + awayGoals,
            goalsScored1H: isHome ? homeGoalsHT : awayGoalsHT,
            goalsScored2H: teamGoals2H,
            goalsTotal1H: homeGoalsHT + awayGoalsHT,
            goalsTotal2H: teamGoals2H + oppGoals2H,
            isComebackWin: isComebackWin,
            isComebackLoss: isComebackLoss,
            firstHalfWin: teamGoalsHT > oppGoalsHT ? 1 : 0,
            secondHalfWin: teamGoals2H > oppGoals2H ? 1 : 0,
            bothHalvesWin: (teamGoalsHT > oppGoalsHT && teamGoals2H > oppGoals2H) ? 1 : 0,
            firstHalfAndFullWin: (teamGoalsHT > oppGoalsHT && matchPoints === 3) ? 1 : 0,
            bothTeamsScored: (homeGoals > 0 && awayGoals > 0) ? 1 : 0,
            noGoalsScored: (isHome ? homeGoals : awayGoals) === 0 ? 1 : 0,
            atLeast1GoalScored: (isHome ? homeGoals : awayGoals) >= 1 ? 1 : 0,
            atLeast2GoalsScored: (isHome ? homeGoals : awayGoals) >= 2 ? 1 : 0,
            cleanSheet: (isHome ? awayGoals : homeGoals) === 0 ? 1 : 0,
            atLeast1GoalConceded: (isHome ? awayGoals : homeGoals) >= 1 ? 1 : 0,
            atLeast2GoalsConceded: (isHome ? awayGoals : homeGoals) >= 2 ? 1 : 0,
            cornersFor: isHome ? match.home_corners : match.away_corners,
            cornersAgainst: isHome ? match.away_corners : match.home_corners,
            offsidesFor: isHome ? match.home_offsides : match.away_offsides,
            offsidesAgainst: isHome ? match.away_offsides : match.home_offsides,
            shotsFor: isHome ? match.home_shots : match.away_shots,
            shotsAgainst: isHome ? match.away_shots : match.home_shots,
            shotsOnTargetFor: isHome ? match.home_shots_on_target : match.away_shots_on_target,
            shotsOnTargetAgainst: isHome ? match.away_shots_on_target : match.home_shots_on_target,
            xgFor: isHome ? match.home_xg : match.away_xg,
            xgAgainst: isHome ? match.away_xg : match.home_xg,
            possession: isHome ? match.home_possession : match.away_possession
        });
    });

    // Sort matchDetails by date descending
    matchDetails.sort((a, b) => {
        const dateA = a.date.split('.').reverse().join('');
        const dateB = b.date.split('.').reverse().join('');
        return dateB.localeCompare(dateA);
    });

    // Calculate mode for corners
    const cornersForMode = findMode(cornersForArray);
    const cornersAgainstMode = findMode(cornersAgainstArray);

    // Calculate percentage above mode
    const matchesAboveCornersForMode = cornersForArray.filter(c => c > cornersForMode.value).length;
    const percentAboveCornersForMode = cornersForArray.length > 0
        ? ((matchesAboveCornersForMode / cornersForArray.length) * 100).toFixed(1)
        : 'N/A';

    return {
        teamName,
        totalMatches,
        avgPoints: (points / totalMatches).toFixed(2),
        avgPointsHome: homeMatches > 0 ? (homePoints / homeMatches).toFixed(2) : '0.00',
        avgPointsAway: awayMatches > 0 ? (awayPoints / awayMatches).toFixed(2) : '0.00',
        winPercentage: ((wins / totalMatches) * 100).toFixed(1),
        lossPercentage: ((losses / totalMatches) * 100).toFixed(1),
        drawPercentage: ((draws / totalMatches) * 100).toFixed(1),
        avgGoalsScored: (goalsScored / totalMatches).toFixed(2),
        avgGoalsConceded: (goalsConceded / totalMatches).toFixed(2),
        avgGoalsTotal: ((goalsScored + goalsConceded) / totalMatches).toFixed(2),
        avgGoalsScored1H: (goalsScored1H / totalMatches).toFixed(2),
        avgGoalsScored2H: (goalsScored2H / totalMatches).toFixed(2),
        avgGoalsTotal1H: ((goalsScored1H + goalsConceded1H) / totalMatches).toFixed(2),
        avgGoalsTotal2H: ((goalsScored2H + goalsConceded2H) / totalMatches).toFixed(2),
        firstHalfWinPercentage: ((firstHalfWins / totalMatches) * 100).toFixed(1),
        secondHalfWinPercentage: ((secondHalfWins / totalMatches) * 100).toFixed(1),
        bothHalvesWinPercentage: ((bothHalvesWins / totalMatches) * 100).toFixed(1),
        firstHalfAndFullWinPercentage: ((firstHalfAndFullWins / totalMatches) * 100).toFixed(1),
        comebackWinPercentage: ((comebackWins / totalMatches) * 100).toFixed(1),
        comebackLossPercentage: ((comebackLosses / totalMatches) * 100).toFixed(1),
        bothTeamsScoredPercentage: ((bothTeamsScored / totalMatches) * 100).toFixed(1),
        noGoalsScoredPercentage: ((noGoalsScored / totalMatches) * 100).toFixed(1),
        atLeast1GoalScoredPercentage: ((atLeast1GoalScored / totalMatches) * 100).toFixed(1),
        atLeast2GoalsScoredPercentage: ((atLeast2GoalsScored / totalMatches) * 100).toFixed(1),
        cleanSheetPercentage: ((cleanSheet / totalMatches) * 100).toFixed(1),
        atLeast1GoalConcededPercentage: ((atLeast1GoalConceded / totalMatches) * 100).toFixed(1),
        atLeast2GoalsConcededPercentage: ((atLeast2GoalsConceded / totalMatches) * 100).toFixed(1),
        avgCornersFor: cornersCount > 0 ? (cornersFor / cornersCount).toFixed(2) : 'N/A',
        avgCornersAgainst: cornersCount > 0 ? (cornersAgainst / cornersCount).toFixed(2) : 'N/A',
        cornersAvailable: `${cornersCount}/${totalMatches}`,
        avgOffsidesFor: offsidesCount > 0 ? (offsidesFor / offsidesCount).toFixed(2) : 'N/A',
        avgOffsidesAgainst: offsidesCount > 0 ? (offsidesAgainst / offsidesCount).toFixed(2) : 'N/A',
        offsidesAvailable: `${offsidesCount}/${totalMatches}`,
        avgShotsFor: shotsCount > 0 ? (shotsFor / shotsCount).toFixed(2) : 'N/A',
        avgShotsAgainst: shotsCount > 0 ? (shotsAgainst / shotsCount).toFixed(2) : 'N/A',
        shotsAvailable: `${shotsCount}/${totalMatches}`,
        avgShotsOnTargetFor: shotsOnTargetCount > 0 ? (shotsOnTargetFor / shotsOnTargetCount).toFixed(2) : 'N/A',
        avgShotsOnTargetAgainst: shotsOnTargetCount > 0 ? (shotsOnTargetAgainst / shotsOnTargetCount).toFixed(2) : 'N/A',
        shotsOnTargetAvailable: `${shotsOnTargetCount}/${totalMatches}`,
        avgXgFor: xgCount > 0 ? (xgFor / xgCount).toFixed(2) : 'N/A',
        avgXgAgainst: xgCount > 0 ? (xgAgainst / xgCount).toFixed(2) : 'N/A',
        xgAvailable: `${xgCount}/${totalMatches}`,
        avgPossession: possessionCount > 0 ? (possessionSum / possessionCount).toFixed(2) : 'N/A',
        possessionAvailable: `${possessionCount}/${totalMatches}`,
        mostFrequentCornersFor: cornersForMode.value !== 'N/A' ? `${cornersForMode.value} (${cornersForMode.count}x)` : 'N/A',
        mostFrequentCornersAgainst: cornersAgainstMode.value !== 'N/A' ? `${cornersAgainstMode.value} (${cornersAgainstMode.count}x)` : 'N/A',
        percentAboveCornersForMode: percentAboveCornersForMode,
        matchDetails: matchDetails,
        cornersForMode: cornersForMode,
        cornersAgainstMode: cornersAgainstMode
    };
}

/**
 * Prepare modal data for specific stat type
 * @param {Object} stats - Statistics object
 * @param {string} statType - Type of stat to prepare
 * @returns {Array} Array of match data for modal
 */
export function prepareModalData(stats, statType) {
    if (!stats || !stats.matchDetails) return [];

    return stats.matchDetails.map(match => {
        let value, displayValue;

        switch (statType) {
            case 'goalsScored':
                value = match.goalsScored;
                displayValue = value.toString();
                break;
            case 'goalsConceded':
                value = match.goalsConceded;
                displayValue = value.toString();
                break;
            case 'goalsTotal':
                value = match.goalsTotal;
                displayValue = value.toString();
                break;
            case 'goalsScored1H':
                value = match.goalsScored1H;
                displayValue = value.toString();
                break;
            case 'goalsScored2H':
                value = match.goalsScored2H;
                displayValue = value.toString();
                break;
            case 'goalsTotal1H':
                value = match.goalsTotal1H;
                displayValue = value.toString();
                break;
            case 'goalsTotal2H':
                value = match.goalsTotal2H;
                displayValue = value.toString();
                break;
            case 'cornersFor':
                value = match.cornersFor;
                displayValue = value != null ? value.toString() : 'N/A';
                break;
            case 'cornersAgainst':
                value = match.cornersAgainst;
                displayValue = value != null ? value.toString() : 'N/A';
                break;
            case 'offsidesFor':
                value = match.offsidesFor;
                displayValue = value != null ? value.toString() : 'N/A';
                break;
            case 'offsidesAgainst':
                value = match.offsidesAgainst;
                displayValue = value != null ? value.toString() : 'N/A';
                break;
            case 'shotsFor':
                value = match.shotsFor;
                displayValue = value != null ? value.toString() : 'N/A';
                break;
            case 'shotsAgainst':
                value = match.shotsAgainst;
                displayValue = value != null ? value.toString() : 'N/A';
                break;
            case 'shotsOnTargetFor':
                value = match.shotsOnTargetFor;
                displayValue = value != null ? value.toString() : 'N/A';
                break;
            case 'shotsOnTargetAgainst':
                value = match.shotsOnTargetAgainst;
                displayValue = value != null ? value.toString() : 'N/A';
                break;
            case 'xgFor':
                value = match.xgFor;
                displayValue = value != null ? parseFloat(value).toFixed(2) : 'N/A';
                break;
            case 'xgAgainst':
                value = match.xgAgainst;
                displayValue = value != null ? parseFloat(value).toFixed(2) : 'N/A';
                break;
            case 'possession':
                value = match.possession;
                displayValue = value != null ? value + '%' : 'N/A';
                break;
            default:
                value = 0;
                displayValue = 'N/A';
        }

        return {
            date: match.date,
            opponent: match.opponent,
            homeAway: match.homeAway,
            result: match.result,
            resultClass: match.resultClass,
            value: value,
            displayValue: displayValue
        };
    }).filter(m => m.displayValue !== 'N/A');
}

/**
 * Prepare modal data for percentage stats
 * @param {Object} stats - Statistics object
 * @param {string} statType - Type of stat
 * @returns {Array} Filtered match data
 */
export function preparePercentageModalData(stats, statType) {
    if (!stats || !stats.matchDetails) return [];

    return stats.matchDetails.filter(match => {
        switch (statType) {
            case 'wins':
                return match.result === 'W';
            case 'draws':
                return match.result === 'R';
            case 'losses':
                return match.result === 'P';
            case 'firstHalfWin':
                return match.firstHalfWin === 1;
            case 'secondHalfWin':
                return match.secondHalfWin === 1;
            case 'bothHalvesWin':
                return match.bothHalvesWin === 1;
            case 'firstHalfAndFullWin':
                return match.firstHalfAndFullWin === 1;
            case 'bothTeamsScored':
                return match.bothTeamsScored === 1;
            case 'noGoalsScored':
                return match.noGoalsScored === 1;
            case 'atLeast1GoalScored':
                return match.atLeast1GoalScored === 1;
            case 'atLeast2GoalsScored':
                return match.atLeast2GoalsScored === 1;
            case 'cleanSheet':
                return match.cleanSheet === 1;
            case 'atLeast1GoalConceded':
                return match.atLeast1GoalConceded === 1;
            case 'atLeast2GoalsConceded':
                return match.atLeast2GoalsConceded === 1;
            default:
                return false;
        }
    }).map(match => ({
        date: match.date,
        opponent: match.opponent,
        homeAway: match.homeAway,
        result: match.result,
        resultClass: match.resultClass,
        value: `${match.goalsScored}-${match.goalsConceded}`,
        displayValue: `${match.goalsScored}-${match.goalsConceded}`
    }));
}
