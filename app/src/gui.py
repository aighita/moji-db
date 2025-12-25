import streamlit as st
import pandas as pd
import os
from database import OracleConnection

# --- Configuration ---
DB_CONFIG = {
    "host": os.getenv('DB_HOST', 'localhost'),
    "port": 1521,
    "service_name": 'XEPDB1',
    "username": 'system',
    "password": 'password'
}

# --- Database Connection ---
@st.cache_resource
def get_db_connection() -> OracleConnection:
    """Establishes and caches the database connection."""
    db = OracleConnection(
        DB_CONFIG["host"], 
        DB_CONFIG["port"], 
        DB_CONFIG["service_name"], 
        DB_CONFIG["username"], 
        DB_CONFIG["password"]
    )
    db.openConnection()
    return db

# --- Report Views ---

def render_game_history(db: OracleConnection):
    st.header("📜 Game History Report")
    st.markdown("View detailed history of games played by a user.")
    
    with st.form("game_history_form"):
        col1, col2, col3, col4 = st.columns(4)
        with col1:
            user_id = st.number_input("User ID", min_value=1, value=1)
        with col2:
            game_id = st.number_input("Game ID", min_value=1, value=1)
        with col3:
            ws_id = st.number_input("Writing System ID", min_value=1, value=1)
        with col4:
            min_acc = st.slider("Min Accuracy (%)", 0, 100, 50)
        
        submitted = st.form_submit_button("Generate Report")

    if submitted:
        with st.spinner("Fetching data..."):
            data = db.report_game_history(user_id, game_id, ws_id, min_acc)
        
        if data:
            columns = [
                "Username", "Game", "Writing System", "Started At", "Ended At", 
                "Duration (s)", "Accuracy (%)", "Score", "Streak"
            ]
            df = pd.DataFrame(data, columns=columns)
            
            # Metrics
            m1, m2, m3 = st.columns(3)
            m1.metric("Total Games", len(df))
            m2.metric("Avg Score", f"{df['Score'].mean():.1f}")
            m3.metric("Avg Accuracy", f"{df['Accuracy (%)'].mean():.1f}%")
            
            # Data Table
            st.dataframe(df)
            
            # Visualization
            st.subheader("Score Evolution")
            if not df.empty:
                st.line_chart(df.set_index("Started At")["Score"])
        else:
            st.warning("No data found for these criteria.")

def render_top_players(db: OracleConnection):
    st.header("🏆 Top Players Report")
    st.markdown("Identify top performing players based on complex criteria.")
    
    with st.form("top_players_form"):
        col1, col2 = st.columns(2)
        with col1:
            game_id = st.number_input("Game ID", min_value=1, value=1)
        with col2:
            ws_id = st.number_input("Writing System ID", min_value=1, value=1)
        
        submitted = st.form_submit_button("Find Top Players")
        
    if submitted:
        with st.spinner("Analyzing performance..."):
            data = db.report_top_players(game_id, ws_id)
        
        if data:
            columns = [
                "Username", "Joined Date", "Avg Accuracy", "Best Score", 
                "Streak at Best", "Duration (ms)"
            ]
            df = pd.DataFrame(data, columns=columns)
            
            st.success(f"Found {len(df)} top players!")
            st.dataframe(df)
            
            st.subheader("Best Scores Comparison")
            if not df.empty:
                st.bar_chart(df.set_index("Username")["Best Score"])
        else:
            st.info("No players met the 'Top Player' criteria.")

def render_elite_regional(db: OracleConnection):
    st.header("🌍 Elite Regional Analysis")
    st.markdown("Analyze elite players by region (continent).")
    
    # Fetch continents for dropdown
    continents_data, continents_cols = db.view_table_data("CONTINENTS")
    if continents_data:
        df_continents = pd.DataFrame(continents_data, columns=continents_cols)
        # Ensure we get the NAME column, handle case sensitivity if needed
        if "NAME" in df_continents.columns:
            continent_list = df_continents["NAME"].tolist()
        else:
             continent_list = ["Asia", "Europe", "North America", "South America", "Africa", "Oceania", "Antarctica"]
    else:
        continent_list = ["Asia", "Europe", "North America", "South America", "Africa", "Oceania", "Antarctica"]

    with st.form("elite_regional_form"):
        col1, col2 = st.columns(2)
        with col1:
            game_id = st.number_input("Game ID", min_value=1, value=1)
            continent = st.selectbox("Continent Name", continent_list)
        with col2:
            min_games = st.number_input("Min Games Played", min_value=1, value=5)
            min_playtime = st.number_input("Min Playtime (ms)", min_value=0, value=10000)
            
        submitted = st.form_submit_button("Analyze Region")
            
    if submitted:
        with st.spinner("Crunching regional stats..."):
            data = db.report_elite_regional(game_id, continent, min_games, min_playtime)
        
        if data:
            columns = ["Username", "Country", "Continent", "Total Playtime", "Games Played"]
            df = pd.DataFrame(data, columns=columns)
            
            st.success(f"Found {len(df)} elite players in {continent}!")
            st.dataframe(df)
            
            if not df.empty:
                st.subheader("Distribution by Country")
                country_counts = df['Country'].value_counts()
                st.bar_chart(country_counts)
        else:
            st.info("No elite players found for this region.")

def render_database_viewer(db: OracleConnection):
    st.header("🗄️ Database Viewer")
    st.markdown("Explore the raw data in the database tables.")
    
    tables = db.get_all_tables()
    
    if tables:
        selected_table = st.selectbox("Select Table", tables)
        
        if selected_table:
            st.subheader(f"Table: {selected_table}")
            with st.spinner(f"Loading data from {selected_table}..."):
                data, columns = db.view_table_data(selected_table)
            
            if data:
                df = pd.DataFrame(data, columns=columns)
                st.dataframe(df)
                st.caption(f"Showing first {len(df)} rows.")
            else:
                st.info("Table is empty.")
    else:
        st.error("Could not retrieve table list. Check database connection.")

# --- Main Application ---

def main():
    st.set_page_config(
        page_title="Moji DB Dashboard", 
        page_icon="🎌", 
        layout="wide",
        initial_sidebar_state="expanded"
    )

    # --- Sidebar Design ---
    with st.sidebar:
        st.title("🎌 Moji DB")
        st.markdown("*Japanese Learning Analytics*")
        st.markdown("---")
        
        st.header("Navigation")
        view_mode = st.radio("Select Mode", ["Reports", "Database Viewer"], index=0)
        
        st.markdown("---")

        report_type = None
        if view_mode == "Reports":
            st.subheader("📊 Reports")
            report_type = st.selectbox(
                "Choose Analysis",
                ["Game History", "Top Players", "Elite Regional Analysis"]
            )
        elif view_mode == "Database Viewer":
            st.subheader("🗄️ Data Explorer")
            st.info("Direct access to raw database tables.")

        st.markdown("---")
        st.markdown("### System Status")
        status_placeholder = st.empty()
        
        st.markdown("---")
        st.caption("© 2025 Moji Project")

    # --- Main Content ---
    
    try:
        db = get_db_connection()
        status_placeholder.success("✅ Oracle DB Connected")
    except Exception as e:
        status_placeholder.error("❌ DB Connection Failed")
        st.error(f"Failed to connect to database: {e}")
        return

    if view_mode == "Reports":
        if report_type == "Game History":
            render_game_history(db)
        elif report_type == "Top Players":
            render_top_players(db)
        elif report_type == "Elite Regional Analysis":
            render_elite_regional(db)
            
    elif view_mode == "Database Viewer":
        render_database_viewer(db)

if __name__ == "__main__":
    main()
