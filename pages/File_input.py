import streamlit as st


def show_file_input():
    """Show a file input widget and handle the uploaded file."""
    st.header("File Input")
    uploaded_file = st.file_uploader('Upload a file', label_visibility="collapsed")
    if uploaded_file is not None:
        st.success(f"File {uploaded_file.name} uploaded successfully!")


show_file_input()