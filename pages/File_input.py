import streamlit as st

def show_file_input():
    st.header("File Input")
    uploaded_file = st.file_uploader('Upload a file', label_visibility="collapsed")
    if uploaded_file is not None:
        st.success(f"File {uploaded_file.name} uploaded successfully!")

show_file_input()