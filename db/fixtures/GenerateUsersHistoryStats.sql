PROMPT Generating Users, History, and Stats...
DECLARE
    TYPE t_id_tab IS TABLE OF NUMBER;
    v_country_ids t_id_tab;
    v_game_ids t_id_tab;
    v_ws_ids t_id_tab;
    
    v_user_id NUMBER;
    v_random_country_id NUMBER;
    v_random_game_id NUMBER;
    v_random_ws_id NUMBER;
    v_history_count NUMBER;
    v_start_date TIMESTAMP;
    v_end_date TIMESTAMP;
    v_score NUMBER;
    v_accuracy NUMBER;
    v_streak NUMBER;
    
    -- Configuration
    c_num_users CONSTANT NUMBER := 1000; -- Number of users to generate
BEGIN
    -- Get IDs into collections
    SELECT id BULK COLLECT INTO v_country_ids FROM COUNTRIES;
    SELECT id BULK COLLECT INTO v_game_ids FROM GAMES;
    SELECT id BULK COLLECT INTO v_ws_ids FROM WRITING_SYSTEMS;

    FOR i IN 1..c_num_users LOOP
        -- Pick random Country ID
        v_random_country_id := v_country_ids(TRUNC(dbms_random.value(1, v_country_ids.COUNT + 1)));

        -- Insert User
        INSERT INTO USERS (username, password_hash, country_id, status)
        VALUES (
            'user_' || i,
            'hash_' || dbms_random.string('x', 10),
            v_random_country_id,
            CASE WHEN dbms_random.value > 0.95 THEN 'banned' ELSE 'active' END
        ) RETURNING id INTO v_user_id;

        -- Generate Games History for this user
        v_history_count := TRUNC(dbms_random.value(5, 50)); -- 5 to 50 games per user

        FOR j IN 1..v_history_count LOOP
            v_start_date := SYSTIMESTAMP - dbms_random.value(1, 365); -- Random time in last year
            v_end_date := v_start_date + numtodsinterval(dbms_random.value(30, 600), 'SECOND'); -- 30s to 10m duration
            v_accuracy := ROUND(dbms_random.value(50, 100), 2);
            v_score := TRUNC(v_accuracy * 10 + dbms_random.value(0, 50));
            v_streak := TRUNC(dbms_random.value(0, 20));
            
            -- Pick random Game and WS IDs
            v_random_game_id := v_game_ids(TRUNC(dbms_random.value(1, v_game_ids.COUNT + 1)));
            v_random_ws_id := v_ws_ids(TRUNC(dbms_random.value(1, v_ws_ids.COUNT + 1)));

            INSERT INTO GAMES_HISTORY (user_id, game_id, writing_system_id, started_at, ended_at, accuracy_pct, score, streak, device)
            VALUES (
                v_user_id,
                v_random_game_id,
                v_random_ws_id,
                v_start_date,
                v_end_date,
                v_accuracy,
                v_score,
                v_streak,
                CASE WHEN dbms_random.value > 0.5 THEN 'mobile' ELSE 'desktop' END
            );
        END LOOP;
        
        -- Commit every 100 users to avoid large rollback segments
        IF MOD(i, 100) = 0 THEN
            COMMIT;
        END IF;

    END LOOP;
    COMMIT;
END;
/
PROMPT Data generation completed.
