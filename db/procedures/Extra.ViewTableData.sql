CREATE OR REPLACE PROCEDURE view_table_data(
    p_table_name IN VARCHAR2,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    -- Dynamic SQL to select from the given table
    -- Using DBMS_ASSERT to prevent SQL Injection (validates it's a valid SQL object name)
    OPEN p_cursor FOR 'SELECT * FROM ' || DBMS_ASSERT.SQL_OBJECT_NAME(p_table_name) || ' FETCH FIRST 100 ROWS ONLY';
END;
/

CREATE OR REPLACE PROCEDURE get_all_tables(
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR 
        SELECT table_name 
        FROM user_tables 
        WHERE table_name IN (
            'CONTINENTS', 
            'COUNTRIES', 
            'WRITING_SYSTEMS', 
            'GAMES', 
            'USERS', 
            'GAMES_HISTORY', 
            'USER_STATS'
        )
        ORDER BY table_name;
END;
/
