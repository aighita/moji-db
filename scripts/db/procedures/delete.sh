#!/bin/bash
NAME=${1:-"bdd-proiect"}
ORACLE_PWD=${2:-"password"}

echo "Dropping stored procedures from container $NAME..."

docker exec -i $NAME sqlplus -S system/$ORACLE_PWD@//localhost:1521/XEPDB1 <<EOF
PROMPT Dropping report_game_history...
DROP PROCEDURE report_game_history;

PROMPT Dropping report_top_players...
DROP PROCEDURE report_top_players;

PROMPT Dropping report_elite_regional...
DROP PROCEDURE report_elite_regional;

PROMPT Dropping view_table_data...
DROP PROCEDURE view_table_data;

PROMPT Dropping get_all_tables...
DROP PROCEDURE get_all_tables;

PROMPT Done.
EXIT;
EOF
