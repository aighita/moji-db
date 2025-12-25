#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$DIR/.."
NAME=${1:-"bdd-proiect"}
ORACLE_PWD=${2:-"password"}

echo "Running report tests in container $NAME..."
# Concatenate procedure definitions and the test script, then pipe to sqlplus
# We prepend SET DEFINE OFF to avoid issues with ampersands in comments
cat <(echo "SET DEFINE OFF;") \
    "$PROJECT_ROOT/db/procedures/Report1.GameHistory.sql" \
    "$PROJECT_ROOT/db/procedures/Report2.TopPlayersPerformance.sql" \
    "$PROJECT_ROOT/db/procedures/Report3.EliteRegionalAnalysis.sql" \
    "$PROJECT_ROOT/tests/procedures-test.sql" \
    | docker exec -i $NAME sqlplus -S system/$ORACLE_PWD@//localhost:1521/XEPDB1
