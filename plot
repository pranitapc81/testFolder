import pandas as pd
import streamlit as st
import plotly.graph_objects as go

# Load the main CSV file
main_file_path = 'D:\\Rohan_hd\\pranita\\comparison_result.csv'
df = pd.read_csv(main_file_path)

# Get the number of keys from the main CSV
num_keys = len(df['key'])

# Count the number of "Pass" keys
pass_keys = df[df['overall_status'] == 'Pass']
pass_count = len(pass_keys)

# Count the number of "Fail" keys
fail_keys = df[df['overall_status'] == 'Fail']
fail_count = len(fail_keys)

# Create a list of labels and values for the donut chart
labels = ["Pass", "Fail"]
values = [pass_count, fail_count]

# Create a Plotly figure to display the number of keys
fig_total = go.Figure(go.Indicator(
    mode="number",
    value=num_keys,
    title="Total Keys",
    number={'valueformat': ',d'},
))
fig_total.update_layout(paper_bgcolor="lightblue")  # Set your desired background color


# Create a Plotly figure for the count of "Pass" keys
fig_pass = go.Figure(go.Indicator(
    mode="number",
    value=pass_count,
    title="Pass Keys",
    number={'valueformat': ',d'},
))
fig_pass.update_layout(paper_bgcolor="lightblue")  # Set your desired background color


# Create a Plotly figure for the count of "Fail" keys
fig_fail = go.Figure(go.Indicator(
    mode="number",
    value=fail_count,
    title="Fail Keys",
    number={'valueformat': ',d'},
))
fig_fail.update_layout(paper_bgcolor="lightblue")  # Set your desired background color


# Load the 'only_actual.csv' and 'only_expected.csv' files
actual_file_path = 'D:\\Rohan_hd\\pranita\\only_actual.csv'
expected_file_path = 'D:\\Rohan_hd\\pranita\\only_expected.csv'

# Read the CSV files for 'only_actual.csv' and 'only_expected.csv'
actual_df = pd.read_csv(actual_file_path)
expected_df = pd.read_csv(expected_file_path)

# Get the number of keys from 'only_actual.csv'
num_actual_keys = len(actual_df)

# Get the number of keys from 'only_expected.csv'
num_expected_keys = len(expected_df)

# Create a Plotly figure for the count of keys from 'only_actual.csv'
fig_actual = go.Figure(go.Indicator(
    mode="number",
    value=num_actual_keys,
    title="Keys from only_actual.csv",
    number={'valueformat': ',d'},
))
fig_actual.update_layout(paper_bgcolor="lightblue")  # Set your desired background color


# Create a Plotly figure for the count of keys from 'only_expected.csv'
fig_expected = go.Figure(go.Indicator(
    mode="number",
    value=num_expected_keys,
    title="Keys from only_expected.csv",
    number={'valueformat': ',d'},
))
fig_expected.update_layout(paper_bgcolor="lightblue")  # Set your desired background color


# Create a Plotly figure for the donut chart
fig_donut = go.Figure(data=[go.Pie(labels=labels, values=values, hole=0.5)]
)
fig_donut.update_layout(title="Pass/Fail Distribution")

# Customize the appearance of the figures
# fig_total.update_layout(title="Key Counts")
# fig_pass.update_layout(title="Pass Keys")
# fig_fail.update_layout(title="Fail Keys")
# fig_actual.update_layout(title="Keys from only_actual.csv")
# fig_expected.update_layout(title="Keys from only_expected.csv")

# Display the figures in a Streamlit layout with reduced whitespace
st.write("## Key Counts and Distribution")

# Adjust column widths to reduce whitespace
col1, col2, col3, col4, col5 = st.columns([1, 1, 1, 1, 3])

# Set the width of the graph objects
fig_width = 100  # Adjust the width as needed
fig_height = 100  # Adjust the height as needed

col1.plotly_chart(fig_total, use_container_width=True, width=fig_width, height=fig_height)
col2.plotly_chart(fig_pass, use_container_width=True, width=fig_width, height=fig_height)
col3.plotly_chart(fig_fail, use_container_width=True, width=fig_width, height=fig_height)
col4.plotly_chart(fig_actual, use_container_width=True, width=fig_width, height=fig_height)
col5.plotly_chart(fig_expected, use_container_width=True)

# Create a section header for the donut chart
st.write("## Pass/Fail Distribution")

# Display the donut chart
st.plotly_chart(fig_donut, use_container_width=True)
# st.set_page_config(layout="wide")






















# import streamlit as st

# Set the title of the score card.
label = "Score"

# Calculate the value of the metric.
value = 0.8

# Calculate the change in the metric since the last time it was measured.
delta = 0.1

# Display the score card.
st.metric(label=label, value=value, delta=delta)



# import streamlit as st

# Set the title of the score card.
label = "Score"

# Calculate the value of the metric.
value = 0.89999

# Display the score card.
st.write(f"{label}: {value}")



import streamlit as st
import plotly.express as px

# Set the titles of the score cards.
label1 = "Score 1"
label2 = "Score 2"

# Calculate the values of the metrics.
value1 = 0.8
value2 = 0.7

# Create a Plotly figure.
fig = px.bar([label1, label2], [value1, value2], color=[value1, value2], title="Score Card")

# Add a title to the figure.
fig.update_layout(title_text="Score Card")

# Display the Plotly figure in Streamlit.
st.plotly_chart(fig)



import streamlit as st
import matplotlib.pyplot as plt

# Set the title of the card.
label = "Score"

# Calculate the value of the metric.
value = 0.8

# Create a figure.
fig, ax = plt.subplots()

# Add a rectangle to the figure.
ax.add_patch(plt.Rectangle((0, 0), 1, 1, color="white"))

# Add the score and value to the figure.
ax.text(0.5, 0.5, f"{label}: {value}", ha="center", va="center", fontsize=20)

# Set the axis limits.
ax.set_xlim(0, 1)
ax.set_ylim(0, 1)

# Display the figure in Streamlit.
st.pyplot(fig)

















import streamlit as st
import matplotlib.pyplot as plt
import numpy as np

def plot_key_indicator_card(value, title, subtitle, color):
  """Plots a key indicator card.

  Args:
    value: The value to display on the card.
    title: The title of the card.
    subtitle: The subtitle of the card.
    color: The color of the card.
  """

  fig, ax = plt.subplots(figsize=(4, 3))

  # Create a rectangle object
  rectangle = plt.Rectangle((0, 0), 4, 3, color=color, alpha=0.5)

  # Add the rectangle to the axes
  ax.add_patch(rectangle)

  # Add the text to the card
  ax.text(0.5, 0.5, str(value), ha='center', va='center', fontsize=24, fontweight='bold', color='white')
  ax.set_title(title, fontsize=16, color='white')
  fig.suptitle(subtitle, fontsize=14, color='white')

  # Turn off the axes
  ax.set_axis_off()

  # Draw the canvas
  fig.canvas.draw()

  # Convert the canvas to an image
  img = np.fromstring(fig.canvas.tostring_rgb(), dtype='uint8')
  img = img.reshape(fig.canvas.get_width_height()[::-1] + (3,))

  # Display the image in Streamlit
  st.image(img, use_column_width=True)

# Plot the first card
plot_key_indicator_card(100, 'Sales', 'Today\'s sales', 'green')

# Plot the second card
plot_key_indicator_card(50, 'Visitors', 'Today\'s website visitors', 'blue')

# Plot the third card
plot_key_indicator_card(20, 'Leads', 'Today\'s generated leads', 'yellow')


import streamlit as st

# Set the title of your dashboard
st.title("Key Indicators Dashboard")

# Include Bootstrap CSS via a CDN
st.markdown("""
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    """, unsafe_allow_html=True)

# Create a container div to arrange the cards horizontally
st.markdown("""
    <div class="container">
    """, unsafe_allow_html=True)

# Create a row to hold all four cards in a single line
st.markdown("""
    <div class="row">
    """, unsafe_allow_html=True)

# Create four Bootstrap cards to display key indicators
for i in range(4):
    st.markdown(f"""
        <div class="col-md-3">
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">Key Indicator {i + 1}</h5>
                    <p class="card-text">The key indicator score is {5 + i}</p>
                </div>
            </div>
        </div>
        """, unsafe_allow_html=True)

# Close the row container
st.markdown("</div>", unsafe_allow_html=True)

# Close the container div
st.markdown("</div>", unsafe_allow_html=True)

