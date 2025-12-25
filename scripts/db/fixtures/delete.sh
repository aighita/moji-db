#!/bin/bash
NAME=${1:-"bdd-proiect"}
ORACLE_PWD=${2:-"password"}

echo "Deleting all data from tables in container $NAME..."
docker exec -i $NAME sqlplus -S system/$ORACLE_PWD@//localhost:1521/XEPDB1 <<EOF
SET SERVEROUTPUT ON;

PROMPT Deleting data from USER_STATS...
DELETE FROM USER_STATS;

PROMPT Deleting data from GAMES_HISTORY...
DELETE FROM GAMES_HISTORY;

PROMPT Deleting data from USERS...
DELETE FROM USERS;

PROMPT Deleting data from COUNTRIES...
DELETE FROM COUNTRIES;

PROMPT Deleting data from GAMES...
DELETE FROM GAMES;

PROMPT Deleting data from WRITING_SYSTEMS...
DELETE FROM WRITING_SYSTEMS;

PROMPT Deleting data from CONTINENTS...
DELETE FROM CONTINENTS;

COMMIT;
PROMPT All data deleted.
EXIT;
EOF
