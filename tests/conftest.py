import pytest
import oracledb
import os

# Configuration - can be overridden by env vars
DB_USER = os.getenv("DB_USER", "system")
DB_PASSWORD = os.getenv("DB_PASSWORD", "password")
DB_DSN = os.getenv("DB_DSN", "localhost:1521/XEPDB1")

@pytest.fixture(scope="module")
def db_connection():
    """
    Creates a database connection for the test module.
    """
    try:
        connection = oracledb.connect(
            user=DB_USER,
            password=DB_PASSWORD,
            dsn=DB_DSN
        )
        yield connection
        connection.close()
    except oracledb.Error as e:
        pytest.fail(f"Database connection failed: {e}")

@pytest.fixture(scope="function")
def db_cursor(db_connection):
    """
    Creates a cursor for a test function. 
    Automatically rolls back changes after the test to keep DB clean.
    """
    cursor = db_connection.cursor()
    yield cursor
    db_connection.rollback() # Rollback changes made during the test
    cursor.close()
