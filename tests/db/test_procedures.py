import pytest
import oracledb

def test_report_game_history(db_cursor):
    """
    Test the report_game_history stored procedure.
    """
    # 1. Setup: Ensure we have a user and some game history
    # We'll insert a test user and a game record to be sure
    
    # Create a test user
    test_username = "test_report_user"
    try:
        db_cursor.execute("INSERT INTO USERS (username, password_hash, country_id) VALUES (:1, 'hash', 1) RETURNING id INTO :2", [test_username, oracledb.NUMBER])
        user_id = db_cursor.fetchone()[0]
    except oracledb.IntegrityError:
        # User might exist from previous run if cleanup failed
        db_cursor.execute("SELECT id FROM USERS WHERE username = :1", [test_username])
        user_id = db_cursor.fetchone()[0]

    # Insert a game history record
    game_id = 1
    ws_id = 1
    db_cursor.execute("""
        INSERT INTO GAMES_HISTORY (user_id, game_id, writing_system_id, score, accuracy_pct, duration_seconds, streak)
        VALUES (:1, :2, :3, 1000, 95.5, 60, 10)
    """, [user_id, game_id, ws_id])

    # 2. Execute the procedure
    # The procedure signature: report_game_history(p_user_id, p_game_id, p_ws_id, p_min_accuracy, p_cursor)
    out_cursor = db_cursor.connection.cursor()
    
    db_cursor.callproc("report_game_history", [user_id, game_id, ws_id, 0, out_cursor])

    # 3. Verify results
    rows = out_cursor.fetchall()
    assert len(rows) > 0, "Report should return at least one row"
    
    # Check the first row columns (based on procedure output)
    # v_username, v_game_name, v_ws_name, v_started_at, v_ended_at, v_duration_sec, v_accuracy, v_score, v_streak
    row = rows[0]
    assert row[0] == test_username
    assert row[5] == 60 # duration
    assert row[6] == 95.5 # accuracy
    assert row[7] == 1000 # score

def test_report_top_players(db_cursor):
    """
    Test the report_top_players stored procedure.
    """
    # 1. Setup: Insert a high scoring game for a user
    test_username = "top_player_test"
    try:
        db_cursor.execute("INSERT INTO USERS (username, password_hash, country_id) VALUES (:1, 'hash', 1) RETURNING id INTO :2", [test_username, oracledb.NUMBER])
        user_id = db_cursor.fetchone()[0]
    except oracledb.IntegrityError:
        db_cursor.execute("SELECT id FROM USERS WHERE username = :1", [test_username])
        user_id = db_cursor.fetchone()[0]

    game_id = 1
    ws_id = 1
    high_score = 999999
    
    db_cursor.execute("""
        INSERT INTO GAMES_HISTORY (user_id, game_id, writing_system_id, score, accuracy_pct, duration_seconds, streak)
        VALUES (:1, :2, :3, :4, 100, 120, 50)
    """, [user_id, game_id, ws_id, high_score])

    # 2. Execute
    out_cursor = db_cursor.connection.cursor()
    db_cursor.callproc("report_top_players", [game_id, ws_id, out_cursor])

    # 3. Verify
    rows = out_cursor.fetchall()
    assert len(rows) > 0
    
    # Find our user in the list
    found = False
    for row in rows:
        # v_username, v_created_at, v_avg_acc, v_best_score, v_streak, v_duration
        if row[0] == test_username:
            assert row[3] == high_score
            found = True
            break
    
    assert found, f"User {test_username} with score {high_score} should be in top players report"
