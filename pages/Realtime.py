import streamlit as st

# Remove caching from the main page function to avoid conflicts with page config
def show_realtime():
    st.header("Realtime")
    st.write("This page allows users to interact with the AI in real-time.")

show_realtime()