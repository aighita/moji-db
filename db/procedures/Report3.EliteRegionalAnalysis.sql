CREATE OR REPLACE PROCEDURE report_elite_regional(
    p_game_id IN NUMBER,
    p_continent_name IN VARCHAR2,
    p_min_games IN NUMBER,
    p_min_playtime IN NUMBER,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    -- Report 3: Elite Regional Analysis
    -- Complexity: Minimum 7
    
    OPEN p_cursor FOR
    SELECT 
        u.username, 
        c.name AS country,
        cont.name AS continent,
        sum_stats.total_playtime, 
        sum_stats.games_played
    FROM USERS u
    JOIN COUNTRIES c ON u.country_id = c.id
    JOIN CONTINENTS cont ON c.continent_id = cont.id
    JOIN (
        -- Aggregated stats for the specific timeframe (Last 12 Months)
        SELECT user_id,
               COUNT(*) as games_played,
               SUM(duration_ms) as total_playtime
        FROM GAMES_HISTORY
        WHERE started_at >= ADD_MONTHS(SYSTIMESTAMP, -12)
          AND game_id = p_game_id
        GROUP BY user_id
    ) sum_stats ON u.id = sum_stats.user_id
    WHERE 
        -- Filter by Region (Continent)
        cont.name = p_continent_name
        -- Filter by Activity
      AND sum_stats.games_played >= p_min_games
        -- Filter by Engagement
      AND sum_stats.total_playtime > p_min_playtime
        -- Versatility: Has tried ALL games
      AND NOT EXISTS (
          SELECT id FROM GAMES
          MINUS
          SELECT game_id FROM GAMES_HISTORY gh_all WHERE gh_all.user_id = u.id
      )
        -- Challenge: Played in WS with highest difficulty
      AND EXISTS (
          SELECT 1
          FROM GAMES_HISTORY gh_diff
          JOIN WRITING_SYSTEMS ws ON gh_diff.writing_system_id = ws.id
          WHERE gh_diff.user_id = u.id
            AND ws.difficulty = (SELECT MAX(difficulty) FROM WRITING_SYSTEMS)
      );
END;
/
