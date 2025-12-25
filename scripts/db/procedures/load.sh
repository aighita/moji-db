#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$DIR/../../.."
NAME=${1:-"bdd-proiect"}
ORACLE_PWD=${2:-"password"}

echo "Loading stored procedures into container $NAME..."

PROCEDURES_DIR="$PROJECT_ROOT/db/procedures"

if [ ! -d "$PROCEDURES_DIR" ]; then
  echo "Directory $PROCEDURES_DIR does not exist."
  exit 1
fi

for f in "$PROCEDURES_DIR"/*.sql; do
    if [ -f "$f" ]; then
        echo "Loading $(basename "$f")..."
        # Prepend SET DEFINE OFF to avoid issues with special chars
        # Append EXIT to ensure sqlplus closes
        cat <(echo "SET DEFINE OFF;") "$f" <(echo "EXIT;") | docker exec -i $NAME sqlplus -S system/$ORACLE_PWD@//localhost:1521/XEPDB1
    fi
done
