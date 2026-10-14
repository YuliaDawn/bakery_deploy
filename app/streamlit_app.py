import streamlit as st
import altair as alt
import pandas as pd

from common.data_utils import get_active_session
import logging

logger = logging.getLogger("bakery")
# Page settings
st.set_page_config(page_title='Bakery Order Summary', layout='wide')
st.title('Bakery Daily Production Summary')
st.write('Daily total order quantity by baked good type')

session = get_active_session()
db_name = "BAKERY_DB"
schema_name = "ORDERS"
table = "SUMMARY_ORDERS"

table_fqn = f"{db_name}.{schema_name}.{table}"

# Connect to Snowflake and query the SUMMARY_ORDERS table
df = session.table(table_fqn).to_pandas()

# Make sure the quantity column is numeric, and format the date as a clean string
df['TOTAL_QUANTITY'] = pd.to_numeric(df['TOTAL_QUANTITY'])
df['DELIVERY_DATE'] = pd.to_datetime(df['DELIVERY_DATE']).dt.strftime('%Y-%m-%d')

# Build a stacked bar chart: x=delivery date, y=quantity, color=baked good type
chart = alt.Chart(df).mark_bar().encode(
    x=alt.X('DELIVERY_DATE:O', title='DELIVERY_DATE', axis=alt.Axis(labelAngle=0)),
    y=alt.Y('TOTAL_QUANTITY:Q'),
    color=alt.Color('BAKED_GOOD_TYPE:N'),
    tooltip=['BAKED_GOOD_TYPE:N', 'DELIVERY_DATE:O', 'TOTAL_QUANTITY:Q']
).properties(height=500)

# Render the chart on the page
st.altair_chart(chart, use_container_width=True)
