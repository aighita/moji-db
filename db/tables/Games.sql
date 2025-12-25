CREATE TABLE GAMES(
    id                  NUMBER(10) PRIMARY KEY,
    name                VARCHAR2(50 CHAR),
    "mode"              VARCHAR2(10 CHAR) CHECK ("mode" IN ('reading','listening','writing')),
    description         VARCHAR2(400 CHAR),
    -- difficulty       INT, -- TODO: ?
    is_active           NUMBER(1) DEFAULT 1 CHECK(is_active IN (0, 1))
    -- release_version  INT, -- TODO: ?
    -- release_date     TIMESTAMP -- TODO: Date and time
);
