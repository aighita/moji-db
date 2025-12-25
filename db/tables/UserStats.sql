CREATE TABLE USER_STATS(
    user_id         NUMBER(10) PRIMARY KEY,
    total_games     NUMBER(10) DEFAULT 0 CHECK (total_games >= 0),
    avg_accuracy    NUMBER(5,2) CHECK (avg_accuracy BETWEEN 0 AND 100),
    total_score     NUMBER(12) DEFAULT 0 CHECK (total_score >= 0),
    best_streak     NUMBER(10) DEFAULT 0,
    xp_total        NUMBER(12) DEFAULT 0,
    level_no        NUMBER(4) DEFAULT 1,
    updated_at      TIMESTAMP(6) DEFAULT SYSTIMESTAMP,

    CONSTRAINT fk_user_stats
        FOREIGN KEY (user_id) REFERENCES USERS(id)
        ON DELETE CASCADE
);
