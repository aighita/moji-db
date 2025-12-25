# Test Suite Structure

## `conftest.py` - Configuration test
Shared Pytest fixtures.
- `db_connection`: Module-level connection to Oracle.
- `db_cursor`: Function-level cursor that auto-rollbacks changes.

## `db/`
Contains integration tests that connect to the running Oracle Database container.
- **Requires**: `make install-db` to be running.
- **Focus**: Stored procedures, Triggers, Constraints, Data integrity.

## `app/`
Contains unit and functional tests for the Streamlit application logic.
- **Focus**: Python functions in `app/src/`, UI rendering logic (where possible), utility functions.
- **Note**: These should ideally mock the database connection to run fast.
