import ibm_db
import pandas as pd
from datetime import datetime

class TestExecution:
    def __init__(self, connection_string):
        self.connection_string = connection_string
        self.connection = None

    def connect_to_db(self):
        try:
            self.connection = ibm_db.connect(self.connection_string, '', '')
            print("Connected to DB2 database successfully!")
        except Exception as e:
            print(f"Error connecting to DB2 database: {e}")

    def disconnect_from_db(self):
        if self.connection:
            ibm_db.close(self.connection)
            print("Disconnected from DB2 database.")

    def get_execution_count(self):
        query = "SELECT COUNT(*) FROM execution"
        stmt = ibm_db.exec_immediate(self.connection, query)
        result = ibm_db.fetch_both(stmt)
        return result[0]

    def save_execution(self, overall_status, execution_type, mandate, asset_class):
        execution_id = self.get_execution_count() + 1
        start_ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        end_ts = start_ts
        status = overall_status

        query = f"INSERT INTO execution (execution_id, name, mandate, asset_class, start_ts, end_ts, status, execution_type) VALUES ({execution_id}, 'Execution_{execution_id}', '{mandate}', '{asset_class}', '{start_ts}', '{end_ts}', '{status}', '{execution_type}')"
        try:
            stmt = ibm_db.exec_immediate(self.connection, query)
            print(f"Execution record saved with execution ID: {execution_id}")
            return execution_id
        except Exception as e:
            print(f"Error saving execution record: {e}")
            return None

    def save_testcases_and_fields(self, comparison_df, execution_id):
        for index, row in comparison_df.iterrows():
            testcase_name = row['expected_TestcaseID']
            query = "SELECT COUNT(*) FROM testcase"
            stmt = ibm_db.exec_immediate(self.connection, query)
            result = ibm_db.fetch_both(stmt)
            testcase_id = result[0] + 1

            query = f"INSERT INTO testcase (id, testcase_name, execution_id) VALUES ({testcase_id}, '{testcase_name}', {execution_id})"
            try:
                stmt = ibm_db.exec_immediate(self.connection, query)
                print(f"Testcase record saved with ID: {testcase_id}")
            except Exception as e:
                print(f"Error saving testcase record: {e}")

            # Iterate through each trio of fields for the row and save the testcase field validation
            for column in comparison_df.columns:
                if column.startswith('expected_'):
                    field_suffix = column.replace('expected_', '')
                    expected_value = row[column]
                    actual_value = row[f'actual_{field_suffix}']
                    result_value = row[f'result_{field_suffix}']
                    
                    # Get the field ID from the field table
                    query = f"SELECT id FROM field WHERE field_name = '{field_suffix}'"
                    stmt = ibm_db.exec_immediate(self.connection, query)
                    field_id_row = ibm_db.fetch_assoc(stmt)
                    if field_id_row:
                        field_id = field_id_row['ID']
                        # Save to testcase_field_validation table
                        query = f"INSERT INTO testcase_field_validation (fieldId, actual_value, expected_value, result_value) VALUES ({field_id}, '{actual_value}', '{expected_value}', '{result_value}')"
                        try:
                            stmt = ibm_db.exec_immediate(self.connection, query)
                            print(f"Testcase field validation record saved for Field ID: {field_id}")
                        except Exception as e:
                            print(f"Error saving testcase field validation record: {e}")

if __name__ == "__main__":
    connection_string = "DATABASE=your_database;HOSTNAME=your_hostname;PORT=your_port;PROTOCOL=TCPIP;UID=username;PWD=password;"
    execution = TestExecution(connection_string)
    execution.connect_to_db()

    # Mock comparison dataframe
    comparison_df = pd.DataFrame({
        'expected_TestcaseID': ['testcase1', 'testcase2', 'testcase3'],
        'expected_fabc': [1, 2, 3],
        'actual_fabc': [1, 2, 3],
        'result_fabc': [True, True, False],
        'expected_xyz': ['a', 'b', 'c'],
        'actual_xyz': ['a', 'b', 'd'],
        'result_xyz': [True, True, False]
    })

    overall_status = 'Completed'
    execution_type = 'TypeA'
    mandate = 'MandateA'
    asset_class = 'AssetClassA'

    execution_id = execution.save_execution(overall_status, execution_type, mandate, asset_class)
    if execution_id:
        execution.save_testcases_and_fields(comparison_df, execution_id)

    execution.disconnect_from_db()
