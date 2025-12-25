CREATE TABLE USERS(
    id              NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    created_at      TIMESTAMP(6) DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC') NOT NULL,
    status          VARCHAR2(8 CHAR) DEFAULT 'active' NOT NULL CHECK (status IN ('active', 'banned', 'deleted')),
    username        VARCHAR2(32 CHAR) UNIQUE NOT NULL,
    password_hash   VARCHAR2(255 CHAR) NOT NULL,
    country_id      NUMBER(10) NOT NULL,
    deleted_at      TIMESTAMP(6),
    -- updated_at   TIMESTAMP(6) -- TODO: Do I need this?

    CONSTRAINT fk_users_country
        FOREIGN KEY (country_id) REFERENCES COUNTRIES(id)
);
