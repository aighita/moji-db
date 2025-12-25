import pytest
import oracledb

def test_trigger_update_user_stats(db_cursor):
    """
    Test that inserting into GAMES_HISTORY updates USER_STATS via trigger.
    """
    # 1. Create a new user
    username = "stats_trigger_user"
    db_cursor.execute("INSERT INTO USERS (username, password_hash, country_id) VALUES (:1, 'hash', 1) RETURNING id INTO :2", [username, oracledb.NUMBER])
    user_id = db_cursor.fetchone()[0]

    # Verify no stats initially
    db_cursor.execute("SELECT count(*) FROM USER_STATS WHERE user_id = :1", [user_id])
    assert db_cursor.fetchone()[0] == 0

    # 2. Insert first game
    score1 = 100
    acc1 = 80
    db_cursor.execute("""
        INSERT INTO GAMES_HISTORY (user_id, game_id, writing_system_id, score, accuracy_pct, duration_seconds, streak)
        VALUES (:1, 1, 1, :2, :3, 60, 5)
    """, [user_id, score1, acc1])

    # 3. Verify stats created
    db_cursor.execute("SELECT total_games, total_score, avg_accuracy FROM USER_STATS WHERE user_id = :1", [user_id])
    row = db_cursor.fetchone()
    assert row is not None
    assert row[0] == 1 # total_games
    assert row[1] == score1 # total_score
    assert row[2] == acc1 # avg_accuracy

    # 4. Insert second game
    score2 = 200
    acc2 = 90
    db_cursor.execute("""
        INSERT INTO GAMES_HISTORY (user_id, game_id, writing_system_id, score, accuracy_pct, duration_seconds, streak)
        VALUES (:1, 1, 1, :2, :3, 60, 5)
    """, [user_id, score2, acc2])

    # 5. Verify stats updated
    db_cursor.execute("SELECT total_games, total_score, avg_accuracy FROM USER_STATS WHERE user_id = :1", [user_id])
    row = db_cursor.fetchone()
    assert row[0] == 2 # total_games
    assert row[1] == score1 + score2 # total_score
    # Avg of 80 and 90 is 85
    assert row[2] == 85 # avg_accuracy

def test_trigger_soft_delete(db_cursor):
    """
    Test that setting status to 'deleted' sets deleted_at timestamp.
    """
    # 1. Create user
    username = "soft_delete_user"
    db_cursor.execute("INSERT INTO USERS (username, password_hash, country_id, status) VALUES (:1, 'hash', 1, 'active') RETURNING id INTO :2", [username, oracledb.NUMBER])
    user_id = db_cursor.fetchone()[0]

    # Verify deleted_at is NULL
    db_cursor.execute("SELECT deleted_at FROM USERS WHERE id = :1", [user_id])
    assert db_cursor.fetchone()[0] is None

    # 2. Update status to deleted
    db_cursor.execute("UPDATE USERS SET status = 'deleted' WHERE id = :1", [user_id])

    # 3. Verify deleted_at is set
    db_cursor.execute("SELECT deleted_at FROM USERS WHERE id = :1", [user_id])
    deleted_at = db_cursor.fetchone()[0]
    assert deleted_at is not None

    # 4. Restore user
    db_cursor.execute("UPDATE USERS SET status = 'active' WHERE id = :1", [user_id])

    # 5. Verify deleted_at is NULL again
    db_cursor.execute("SELECT deleted_at FROM USERS WHERE id = :1", [user_id])
    assert db_cursor.fetchone()[0] is None
