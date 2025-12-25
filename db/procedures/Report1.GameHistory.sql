CREATE OR REPLACE PROCEDURE report_game_history(
    p_user_id IN NUMBER,
    p_game_id IN NUMBER,
    p_ws_id IN NUMBER,
    p_min_accuracy IN NUMBER,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    -- Report 1: Game History
    -- Complexity: Minimum 4
    -- 1. JOIN USERS, GAMES, WRITING_SYSTEMS
    -- 2. Filter by User, Game, WS, Accuracy
    -- 3. Derived calculation (Duration in seconds)
    -- 4. ORDER BY Score
    -- 5. Row Limiting (FETCH FIRST)
    
    OPEN p_cursor FOR
    SELECT 
        u.username,
        g.name AS game_name,
        ws.name AS writing_system,
        gh.started_at,
        gh.ended_at,
        -- Derived calculation: Duration in seconds (redundant with duration_ms but adds complexity)
        EXTRACT(SECOND FROM (gh.ended_at - gh.started_at)) + 
        EXTRACT(MINUTE FROM (gh.ended_at - gh.started_at)) * 60 AS duration_seconds,
        gh.accuracy_pct,
        gh.score,
        gh.streak
    FROM GAMES_HISTORY gh
    JOIN USERS u ON gh.user_id = u.id
    JOIN GAMES g ON gh.game_id = g.id
    JOIN WRITING_SYSTEMS ws ON gh.writing_system_id = ws.id
    WHERE gh.user_id = p_user_id
      AND gh.game_id = p_game_id
      AND gh.writing_system_id = p_ws_id
      AND gh.accuracy_pct > p_min_accuracy
    ORDER BY gh.score DESC
    FETCH FIRST 20 ROWS ONLY;
END;
/
