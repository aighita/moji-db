<div align='center'>
    <img src="./assets/logo.svg" width="120">
    <h1>Moji DB</h1>
</div>

**Moji** is an application for learning Japanese writing systems. This project contains the database structure (Oracle SQL) and scripts for managing it.

The database stores user progress (time, accuracy, streak, score) in recognition games, allowing for detailed reports on performance and exercise efficiency.

## 🚀 Getting Started

### Prerequisites
- **Docker** installed on your machine.

### Installation & Setup

1.  **Start the Oracle Database Container**
    ```bash
    ./install-oracle-container.sh [container_name] [password]
    ```
    *Default: container=`bdd-proiect`, password=`password`*

2.  **Create Database Tables**
    ```bash
    ./tables-create.sh
    ```

3.  **Load Fixtures (Sample Data)**
    Populates the database with initial data (Continents, Writing Systems, Games) and generates synthetic data for Users and Game History.
    ```bash
    ./fixtures-load.sh
    ```

## 📂 Database Schema

![Database Schema](./assets/schema.svg)

The database consists of the following tables:

| Table | Description |
| :--- | :--- |
| **CONTINENTS** | Geographic continents data. |
| **COUNTRIES** | Countries linked to continents. |
| **WRITING_SYSTEMS** | Japanese writing systems (Hiragana, Katakana, Kanji, etc.). |
| **GAMES** | Available game modes and descriptions. |
| **USERS** | User accounts and authentication data. |
| **GAMES_HISTORY** | Records of played games, including score, accuracy, and duration. |
| **USER_STATS** | Aggregated statistics for each user (total score, level, etc.). |

## 🛠 Scripts Reference

| Script | Description |
| :--- | :--- |
| `install-oracle-container.sh` | Pulls and runs the Oracle Express Edition Docker container. |
| `tables-create.sh` | Executes `Tables.sql` to create the database schema. |
| `tables-drop.sh` | Drops all project tables (clean slate). |
| `fixtures-load.sh` | Executes `Fixtures.sql` to insert static and generated data. |
| `fixtures-delete.sh` | Deletes all data from tables without dropping the tables themselves. |
