import streamlit as st
import pandas as pd

# Sample data
data = {
    'key': [1, 2, 3, 4, 5],
    'expected_adeid': [123, 234, 345, 456, 567],
    'actual_adeid': [123, 345, 678, 234, 789],
    'result_adeid': ['pass', 'fail', 'fail', 'pass', 'pass'],
    'expected_amount': [1000, 2000, 3000, 4000, 5000],
    'actual_amount': [1000, 2500, 3500, 4000, 5500],
    'result_amount': ['pass', 'fail', 'fail', 'pass', 'pass'],
    'overall_status': ['pass', 'fail', 'fail', 'pass', 'pass']
}

df = pd.DataFrame(data)

# Sidebar filters
st.sidebar.header("Filters")
search_key = st.sidebar.text_input("Search by Key")
filter_result_adeid = st.sidebar.selectbox("Filter by Result ade ID", ['', 'pass', 'fail'])
filter_overall_status = st.sidebar.multiselect("Filter by Overall Status", df['overall_status'].unique())

# Apply filters to the DataFrame
filtered_df = df

if search_key:
    filtered_df = filtered_df[filtered_df['key'] == int(search_key)]

if filter_result_adeid:
    filtered_df = filtered_df[filtered_df['result_deid'] == filter_result_tdeid]

if filter_overall_status:
    filtered_df = filtered_df[filtered_df['overall_status'].isin(filter_overall_status)]

# Display filtered data in the main section
st.header("Filtered Data")
st.write(filtered_df)

# You can further display this filtered data as a table or any other visualization
