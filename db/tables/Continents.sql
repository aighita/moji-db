CREATE TABLE CONTINENTS(
    id          NUMBER(10) PRIMARY KEY,
    -- created_at TODO: Should it have this field?
    name        VARCHAR2(20 CHAR) NOT NULL,
    code        VARCHAR2(2 CHAR) NOT NULL CHECK(code IN ('AF', 'AN', 'AS', 'EU', 'NA', 'OC', 'SA')),
    hemisphere  VARCHAR2(8 CHAR) NOT NULL CHECK(hemisphere IN ('North', 'South', 'Both')) -- TODO: Should this be normalized?
);
