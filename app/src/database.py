import cx_Oracle

class OracleConnection:
    def __init__(self, host, port, schema, username, password):
        self.host = host
        self.port = port
        self.schema = schema
        self.username = username
        self.password = password
        self.db = None
        self.cursor = None

    def openConnection(self):
        try:
            dsn_tns = cx_Oracle.makedsn(host=self.host, port=self.port, service_name=self.schema)
            self.db = cx_Oracle.connect(self.username, self.password, dsn_tns)
            self.cursor = self.db.cursor()
            print("Connection open!")
        except Exception as e:
            print("Connection not open!")
            print(e)

    def closeConnection(self):
        try:
            if self.cursor:
                self.cursor.close()
            if self.db:
                self.db.close()
            print("Connection close!")
        except Exception as e:
            print("Connection not closed!")
            print(e)

    def report_game_history(self, user_id, game_id, ws_id, min_accuracy):
        """
        Calls the stored procedure report_game_history
        """
        try:
            # Prepare the output cursor
            out_cursor = self.cursor.var(cx_Oracle.CURSOR)
            
            # Call the procedure
            # Parameters: p_user_id, p_game_id, p_ws_id, p_min_accuracy, p_cursor
            self.cursor.callproc("report_game_history", [user_id, game_id, ws_id, min_accuracy, out_cursor])
            
            # Return the list of rows directly
            return out_cursor.getvalue()
                
        except Exception as e:
            print("Error executing report_game_history:")
            print(e)
            return []

    def report_top_players(self, game_id, ws_id):
        """
        Calls the stored procedure report_top_players
        """
        try:
            out_cursor = self.cursor.var(cx_Oracle.CURSOR)
            
            # Call the procedure
            # Parameters: p_game_id, p_ws_id, p_cursor
            self.cursor.callproc("report_top_players", [game_id, ws_id, out_cursor])
            
            # Return the list of rows directly
            return out_cursor.getvalue()
                
        except Exception as e:
            print("Error executing report_top_players:")
            print(e)
            return []

    def report_elite_regional(self, game_id, continent_name, min_games, min_playtime):
        """
        Calls the stored procedure report_elite_regional
        """
        try:
            out_cursor = self.cursor.var(cx_Oracle.CURSOR)
            
            # Call the procedure
            # Parameters: p_game_id, p_continent_name, p_min_games, p_min_playtime, p_cursor
            self.cursor.callproc("report_elite_regional", [game_id, continent_name, min_games, min_playtime, out_cursor])
            
            return out_cursor.getvalue()
        except Exception as e:
            print("Error executing report_elite_regional:")
            print(e)
            return []

    def get_all_tables(self):
        """
        Calls the stored procedure get_all_tables
        """
        try:
            out_cursor = self.cursor.var(cx_Oracle.CURSOR)
            self.cursor.callproc("get_all_tables", [out_cursor])
            # Return list of table names (first column of each row)
            return [row[0] for row in out_cursor.getvalue()]
        except Exception as e:
            print("Error executing get_all_tables:")
            print(e)
            return []

    def view_table_data(self, table_name):
        """
        Calls the stored procedure view_table_data
        """
        try:
            out_cursor = self.cursor.var(cx_Oracle.CURSOR)
            self.cursor.callproc("view_table_data", [table_name, out_cursor])
            
            # Get the actual cursor object
            cursor_obj = out_cursor.getvalue()
            
            # Get column names from cursor description
            columns = [col[0] for col in cursor_obj.description]
            data = cursor_obj.fetchall()
            
            return data, columns
        except Exception as e:
            print(f"Error executing view_table_data for {table_name}:")
            print(e)
            return [], []
