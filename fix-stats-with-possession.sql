-- Fix statistics: replace NULL with 0 when Ball Possession exists
-- Logic: If we have possession data, it means match had real statistics
-- Missing values should be 0 (truly zero), not NULL (no data)

UPDATE matches
SET 
    home_shots = COALESCE(home_shots, 0),
    away_shots = COALESCE(away_shots, 0),
    home_shots_on_target = COALESCE(home_shots_on_target, 0),
    away_shots_on_target = COALESCE(away_shots_on_target, 0),
    home_corners = COALESCE(home_corners, 0),
    away_corners = COALESCE(away_corners, 0),
    home_offsides = COALESCE(home_offsides, 0),
    away_offsides = COALESCE(away_offsides, 0),
    home_y_cards = COALESCE(home_y_cards, 0),
    away_y_cards = COALESCE(away_y_cards, 0),
    home_r_cards = COALESCE(home_r_cards, 0),
    away_r_cards = COALESCE(away_r_cards, 0),
    home_fouls = COALESCE(home_fouls, 0),
    away_fouls = COALESCE(away_fouls, 0)
WHERE 
    -- Only update matches that have possession data (indicator of real stats)
    home_possession IS NOT NULL
    -- And have at least one NULL statistic that needs fixing
    AND (
        home_shots IS NULL OR away_shots IS NULL OR
        home_shots_on_target IS NULL OR away_shots_on_target IS NULL OR
        home_corners IS NULL OR away_corners IS NULL OR
        home_offsides IS NULL OR away_offsides IS NULL OR
        home_y_cards IS NULL OR away_y_cards IS NULL OR
        home_r_cards IS NULL OR away_r_cards IS NULL OR
        home_fouls IS NULL OR away_fouls IS NULL
    );

-- Check results
SELECT 
    COUNT(*) as total_matches,
    COUNT(home_possession) as matches_with_possession_data,
    SUM(CASE WHEN home_possession IS NOT NULL AND home_y_cards IS NULL THEN 1 ELSE 0 END) as possession_but_no_cards_before_fix,
    SUM(CASE WHEN home_possession IS NULL THEN 1 ELSE 0 END) as matches_without_stats
FROM matches;

-- Detailed breakdown: matches with possession vs without
SELECT 
    'With Possession' as category,
    COUNT(*) as total,
    COUNT(home_y_cards) as has_yellow_cards,
    COUNT(home_corners) as has_corners,
    COUNT(home_offsides) as has_offsides
FROM matches 
WHERE home_possession IS NOT NULL

UNION ALL

SELECT 
    'Without Possession' as category,
    COUNT(*) as total,
    COUNT(home_y_cards) as has_yellow_cards,
    COUNT(home_corners) as has_corners,
    COUNT(home_offsides) as has_offsides
FROM matches 
WHERE home_possession IS NULL;
