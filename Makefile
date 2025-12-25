.PHONY: help install-db setup-db init-procedures run-app clean test stop-db install-deps all

# Default target
help:
	@echo "Available commands:"
	@echo "  make install-db      - Start Oracle Database container"
	@echo "  make install-deps    - Install local Python dependencies (for init-procedures)"
	@echo "  make setup-db        - Create tables and load fixtures"
	@echo "  make init-procedures - Install extra stored procedures for the app"
	@echo "  make run-app         - Build and run the Streamlit app in Docker"
	@echo "  make clean           - Drop all tables"
	@echo "  make test            - Run Python tests (pytest)"
	@echo "  make stop-db         - Stop and remove the Oracle container"
	@echo "  make all             - Full setup sequence (install, setup, init, run)"

install-db:
	@echo "Starting Oracle Database Container..."
	./scripts/db/install-oracle-container.sh

install-deps:
	pip install -r app/requirements.txt
	pip install -r tests/requirements.txt

test:
	pytest tests/ -v

setup-db:
	@echo "Creating tables and loading fixtures..."
	./scripts/db/tables/create.sh
	./scripts/db/fixtures/load.sh

init-procedures:
	@echo "Initializing extra stored procedures..."
	./scripts/db/procedures/load.sh

run-app:
	@echo "Starting Application..."
	./scripts/app/run.sh

clean:
	@echo "Dropping tables..."
	-./scripts/db/tables/drop.sh

stop-db:
	docker stop bdd-proiect || true
	docker rm bdd-proiect || true

all: install-db clean setup-db init-procedures run-app
