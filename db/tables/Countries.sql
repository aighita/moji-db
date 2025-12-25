CREATE TABLE COUNTRIES(
    id              NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name            VARCHAR2(100 CHAR) NOT NULL,
    iso_code        VARCHAR2(2 CHAR) UNIQUE NOT NULL,
    iso3_code       VARCHAR2(3 CHAR) UNIQUE NOT NULL,
    numeric_code    NUMBER(3) CHECK (numeric_code BETWEEN 1 AND 999),
    continent_id    NUMBER(10) NOT NULL,
    -- region_id    INT, -- TODO: Foreign key. Countries have region ids?
    -- TODO: created_at Should this be used here?

    CONSTRAINT fk_countries_continents
        FOREIGN KEY (continent_id) REFERENCES CONTINENTS(id)
);
