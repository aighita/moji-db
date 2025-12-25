CREATE OR REPLACE TRIGGER trg_update_user_stats
AFTER INSERT ON GAMES_HISTORY
FOR EACH ROW
DECLARE
    v_exists NUMBER;
BEGIN
    -- Check if user stats record exists
    SELECT COUNT(*) INTO v_exists FROM USER_STATS WHERE user_id = :NEW.user_id;

    IF v_exists = 0 THEN
        -- Initialize stats if first game
        INSERT INTO USER_STATS (user_id, total_games, avg_accuracy, total_score, best_streak, xp_total, level_no, updated_at)
        VALUES (:NEW.user_id, 1, :NEW.accuracy_pct, :NEW.score, :NEW.streak, :NEW.score * 2, 1, SYSTIMESTAMP);
    ELSE
        -- Update existing stats
        UPDATE USER_STATS
        SET total_games = total_games + 1,
            total_score = total_score + :NEW.score,
            -- Calculate new moving average for accuracy
            avg_accuracy = ROUND(((avg_accuracy * total_games) + :NEW.accuracy_pct) / (total_games + 1), 2),
            best_streak = GREATEST(best_streak, :NEW.streak),
            xp_total = xp_total + (:NEW.score * 2),
            level_no = TRUNC((xp_total + (:NEW.score * 2)) / 1000) + 1,
            updated_at = SYSTIMESTAMP
        WHERE user_id = :NEW.user_id;
    END IF;
END;
/
