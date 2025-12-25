#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$DIR/../../.."
NAME=${1:-"bdd-proiect"}
ORACLE_PWD=${2:-"password"}

echo "Creating tables in container $NAME..."

# Define the order of creation (Parent tables first)
FILES=(
    "Continents.sql"
    "WritingSystems.sql"
    "Games.sql"
    "Countries.sql"
    "Users.sql"
    "GamesHistory.sql"
    "UserStats.sql"
)

# Create a temporary combined SQL file
COMBINED_SQL=$(mktemp)

echo "SET SQLBLANKLINES ON;" > "$COMBINED_SQL"

for file in "${FILES[@]}"; do
    echo "PROMPT Creating table from $file..." >> "$COMBINED_SQL"
    cat "$PROJECT_ROOT/db/tables/$file" >> "$COMBINED_SQL"
    echo "" >> "$COMBINED_SQL"
done

# Append Triggers at the end
echo "PROMPT Creating Triggers..." >> "$COMBINED_SQL"
for trigger_file in "$PROJECT_ROOT/db/triggers"/*.sql; do
    if [ -f "$trigger_file" ]; then
        echo "PROMPT Creating trigger from $(basename "$trigger_file")..." >> "$COMBINED_SQL"
        cat "$trigger_file" >> "$COMBINED_SQL"
        echo "" >> "$COMBINED_SQL"
    fi
done

echo "EXIT;" >> "$COMBINED_SQL"

cat "$COMBINED_SQL" | docker exec -i $NAME sqlplus -S system/$ORACLE_PWD@//localhost:1521/XEPDB1

rm "$COMBINED_SQL"
