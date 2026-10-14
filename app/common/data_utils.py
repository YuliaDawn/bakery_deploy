from snowflake.snowpark.session import Session
import pandas as pd
import os

import streamlit as st
import logging

logger = logging.getLogger("bakery")
@st.cache_resource(show_spinner=True)
def get_active_session() ->Session:
    """Create or get new Snowflake Session"""
    conn = st.connection(
        os.getenv("SNOWFLAKE_CONNECTION_NAME", "snowflake"), type="snowflake"
    )
    return conn.session()