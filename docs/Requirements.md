# 🗺️ Moji DB - Development Requirements

## 1. Database Architecture (The Foundation)
**Goal**: Design a normalized schema (3NF) with at least **7 tables** to store user activity and educational content.

### 1.1 Schema Design

1.  **`CONTINENTS`**: Geographic grouping (Europe, Asia, etc.).
2.  **`COUNTRIES`**: Linked to continents; used for regional analysis.
3.  **`WRITING_SYSTEMS`**: The curriculum content (Hiragana, Katakana, Kanji).
4.  **`GAMES`**: The types of exercises available (Flashcards, Typing, etc.).
5.  **`USERS`**: User profiles linked to countries.
6.  **`GAMES_HISTORY`**: The core transactional table recording every game session.
7.  **`USER_STATS`**: An optimization table storing aggregated metrics (Total Score, Level) to avoid expensive recalculations.

### 1.2 Data Integrity

-   **Constraints**: Primary Keys, Foreign Keys, and `CHECK` constraints (e.g., `accuracy` must be between 0-100).
-   **Triggers**: Automated logic to update `USER_STATS` whenever a new record is added to `GAMES_HISTORY`.

## 2. Data Management & Seeding

### 2.1 Automation Scripts
-   `scripts/db/tables/create.sh`: Script to build the schema.
-   `scripts/db/tables/drop.sh`: Script to clean the database.

### 2.2 Fixtures
-   **Static Data**: Populate Continents, Countries, Writing Systems, and Games.
-   **Synthetic Data**: Generate dummy Users and Game History records to simulate a live application environment (essential for testing reports).

## 3. Advanced Reporting (The Core Logic)

### 📊 Report 1: Game History
*   **Objective**: Retrieve detailed logs for a specific user, filtered by game and performance.
*   **Complexity Target**: Minimum 4.
*   **Implementation Plan**:
    -   Use `JOIN` to link History with Users and Games.
    -   Calculate `Duration` dynamically from timestamps.
    -   Apply `FETCH FIRST` for pagination.

### 🏆 Report 2: Top Players Performance
*   **Objective**: Identify high-performing players by comparing them against global averages.
*   **Complexity Target**: Minimum 6.
*   **Implementation Plan**:
    -   Filter players with **Average Accuracy > 50%**.
    -   Compare player **Streak** against 50% of the maximum recorded streak.
    -   Ensure **Completion Time** is better (lower) than the global average for that game.
    -   Focus on newer accounts (created in the current year).

### 🌍 Report 3: Elite Regional Analysis
*   **Objective**: A deep dive into the best players from a specific region during a specific timeframe.
*   **Complexity Target**: Minimum 7.
*   **Implementation Plan**:
    -   Filter by **Region** (Continent) and **Timeframe** (e.g., June 2025).
    -   **Engagement**: Filter by minimum playtime and games played.
    -   **Versatility Check**: Use `NOT EXISTS` / `MINUS` to ensure the player has tried **ALL** available game modes.
    -   **Challenge Check**: Ensure they have played the hardest Writing System.

## 4. Application Development (The Interface)

### 4.1 Tech Stack
-   **Language**: Python 3.9+
-   **Framework**: Streamlit (for rapid UI development)
-   **Driver**: `cx_Oracle` (for database connectivity)
-   **Containerization**: Docker (to bundle the app and dependencies).

### 4.2 Features
-   **Sidebar Navigation**: Switch between different views.
-   **Report Generators**: Input forms for report parameters (User ID, Date, etc.) and visual output (Tables, Charts).
-   **Database Viewer**: A raw data inspector to view the contents of any table in the database.

## 5. Quality Assurance & Documentation

### 5.1 Testing
-   Develop `procedures-test.sql` to verify that stored procedures return correct results.
-   Create a `Makefile` to automate `install`, `setup`, `test`, and `run` commands.

### 5.2 Documentation
-   Maintain `Documentation.md` with the ER Diagram and technical details.
-   Ensure code is commented and follows best practices.
