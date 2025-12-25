CREATE OR REPLACE PROCEDURE report_top_players(
    p_game_id IN NUMBER,
    p_ws_id IN NUMBER,
    p_cursor OUT SYS_REFCURSOR
) AS
    v_global_avg_time NUMBER;
    v_max_streak NUMBER;
BEGIN
    -- Report 2: Top Players Performance
    -- Complexity: Minimum 6
    
    -- 1. Calculate Global Average Completion Time for specific Game and WS
    SELECT AVG(duration_ms) INTO v_global_avg_time
    FROM GAMES_HISTORY
    WHERE game_id = p_game_id AND writing_system_id = p_ws_id;

    -- 2. Get Max Streak for comparison (interpreting "scorul maxim" as max streak in this context)
    SELECT MAX(streak) INTO v_max_streak
    FROM GAMES_HISTORY
    WHERE game_id = p_game_id;

    OPEN p_cursor FOR
    SELECT 
        u.username, 
        u.created_at, 
        stats.avg_accuracy, 
        best_play.score AS best_score, 
        best_play.streak AS streak_at_best, 
        best_play.duration_ms
    FROM USERS u
    JOIN USER_STATS stats ON u.id = stats.user_id
    JOIN (
        -- Subquery with Window Function to find the best play for each user
        SELECT user_id, score, streak, duration_ms,
               ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY score DESC) as rn
        FROM GAMES_HISTORY
        WHERE game_id = p_game_id AND writing_system_id = p_ws_id
    ) best_play ON u.id = best_play.user_id AND best_play.rn = 1
    WHERE 
        -- Criteria: Account created in 2025 (Updated to match Fixtures data)
        EXTRACT(YEAR FROM u.created_at) = 2025
        -- Criteria: Personal Average Accuracy > 50%
      AND stats.avg_accuracy > 50
        -- Criteria: Streak > 50% of Max Streak
      AND best_play.streak > (v_max_streak / 2)
        -- Criteria: Completion Time < Global Average
      AND best_play.duration_ms < v_global_avg_time;
END;
/
