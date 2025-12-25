CREATE TABLE GAMES_HISTORY(
    id                  NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id             NUMBER(10) NOT NULL,
    game_id             NUMBER(10) NOT NULL,
    writing_system_id   NUMBER(10) NOT NULL,
    started_at          TIMESTAMP(6) NOT NULL,
    ended_at            TIMESTAMP(6) NOT NULL,
    duration_ms         NUMBER(12) GENERATED ALWAYS AS (
        (EXTRACT(DAY FROM (ended_at - started_at)) * 86400000) +
        (EXTRACT(HOUR FROM (ended_at - started_at)) * 3600000) +
        (EXTRACT(MINUTE FROM (ended_at - started_at)) * 60000) +
        (EXTRACT(SECOND FROM (ended_at - started_at)) * 1000)
    ) VIRTUAL,
    accuracy_pct        NUMBER(5, 2) CHECK (accuracy_pct BETWEEN 0 AND 100),
    score               NUMBER(10) CHECK (score >= 0),
    streak              NUMBER(10) CHECK (streak >= 0),
    device              VARCHAR2(32 CHAR),

    CONSTRAINT fk_games_history_user
        FOREIGN KEY (user_id) REFERENCES USERS(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_games_history_game
        FOREIGN KEY (game_id) REFERENCES GAMES(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_games_history_ws
        FOREIGN KEY (writing_system_id) REFERENCES  WRITING_SYSTEMS(id)
        ON DELETE CASCADE,

    CONSTRAINT check_dates
        CHECK (ended_at >= started_at)
);
