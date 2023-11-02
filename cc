import pandas as pd

# Read the "actual.csv" and "expected.csv" files
actual_df = pd.read_csv("actual.csv")
expected_df = pd.read_csv("expected.csv")

# Get the key columns from the user
key_columns = input("Enter key column names (comma-separated): ").split(',')

# Merge the dataframes using the key columns
merged_df = pd.merge(expected_df, actual_df, on=key_columns, how='outer', indicator=True)

# Function to compare rows and determine status
def compare_rows(row):
    if row['_merge'] == 'both':
        for column in key_columns:
            if row[column + '_x'] != row[column + '_y']:
                return 'Fail'
        return 'Pass'
    else:
        return 'Only in ' + row['_merge'].capitalize()

# Create a new column "status" with pass/fail results
merged_df['status'] = merged_df.apply(compare_rows, axis=1)

# Separate the rows with "Only in expected" and "Only in actual" keys
only_in_expected = merged_df[merged_df['_merge'] == 'left_only']
only_in_actual = merged_df[merged_df['_merge'] == 'right_only']

# Save the results to CSV files
merged_df.to_csv("comparison_result.csv", index=False)
only_in_expected.to_csv("only_in_expected.csv", index=False)
only_in_actual.to_csv("only_in_actual.csv", index=False)
