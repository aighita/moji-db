#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$DIR/../../.."
NAME=${1:-"bdd-proiect"}
ORACLE_PWD=${2:-"password"}

echo "Loading fixtures into container $NAME..."

# Define the order of loading
FILES=(
    "Continents.sql"
    "WritingSystems.sql"
    "Games.sql"
    "Countries.sql"
    "GenerateUsersHistoryStats.sql"
)

# Create a temporary combined SQL file to run everything in one session (faster)
COMBINED_SQL=$(mktemp)

echo "SET SERVEROUTPUT ON;" > "$COMBINED_SQL"
echo "SET DEFINE OFF;" >> "$COMBINED_SQL"

for file in "${FILES[@]}"; do
    echo "PROMPT Loading $file..." >> "$COMBINED_SQL"
    cat "$PROJECT_ROOT/db/fixtures/$file" >> "$COMBINED_SQL"
    echo "" >> "$COMBINED_SQL" # Ensure newline
done

echo "EXIT;" >> "$COMBINED_SQL"

cat "$COMBINED_SQL" | docker exec -i $NAME sqlplus -S system/$ORACLE_PWD@//localhost:1521/XEPDB1

rm "$COMBINED_SQL"
