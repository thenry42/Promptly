import streamlit as st
from ui.components import render_chat_header
import ebooklib
from ebooklib import epub
from bs4 import BeautifulSoup
import re
import tempfile
import os


render_chat_header()


def show_file_input():
    """Show a file input widget and handle the uploaded file."""
    st.header("TinyLib")
    uploaded_file = st.file_uploader('Upload an EPUB/epub file', label_visibility="collapsed")
    if uploaded_file is not None:
        st.success(f"File {uploaded_file.name} uploaded successfully!")
        chapters = extract_chapters(uploaded_file)
        if chapters:
            st.subheader("Edit Book Contents")
            
            # Store chapters in session state for persistence
            if 'chapters' not in st.session_state:
                st.session_state.chapters = chapters
            
            edited_chapters = []
            chapters_to_remove = []
            
            st.write("Select chapters to include and edit their titles:")
            
            # Edit the book title
            if 'book_title' not in st.session_state:
                st.session_state.book_title = "Unknown"
            book_title = st.text_input("Book Title", value=st.session_state.book_title)
            st.session_state.book_title = book_title

            # Edit the book author
            if 'book_author' not in st.session_state:
                st.session_state.book_author = "Unknown"
            book_author = st.text_input("Book Author", value=st.session_state.book_author)
            st.session_state.book_author = book_author

            for i, (title, content) in enumerate(st.session_state.chapters):
                col1, col2 = st.columns([4, 1])
                
                with col1:
                    new_title = st.text_input(f"Chapter {i+1} Title", value=title, key=f"title_{i}")
                
                with col2:
                    include = st.checkbox("Include", value=True, key=f"include_{i}")
                    if not include:
                        chapters_to_remove.append(i)
                
                with st.expander(f"Preview: {title}"):
                    st.write(content[:500] + "..." if len(content) > 500 else content)
                
                edited_chapters.append((new_title, content))
            
            # Remove chapters marked for removal
            final_chapters = [chapter for i, chapter in enumerate(edited_chapters) if i not in chapters_to_remove]
            
            if st.button("Generate Summary"):
                if final_chapters:
                    st.session_state.final_chapters = final_chapters
                    st.session_state.generate_summary = True
                else:
                    st.error("Please include at least one chapter for summary.")
            
            # Generate summary if requested
            if st.session_state.get('generate_summary', False):
                generate_book_summary(st.session_state.final_chapters)
                st.session_state.generate_summary = False


def generate_book_summary(chapters):
    """
    Generate a summary of the book based on selected chapters and desired length.
    
    Args:
        chapters: List of (title, content) tuples for included chapters
        length: Desired summary length
    """
    st.subheader("Book Summary")
    
    # Create input for the LLM
    book_content = "\n\n".join([f"## {title}\n{content}" for title, content in chapters])
    
    # Calculate total word count
    total_words = sum(len(content.split()) for _, content in chapters)
    target_summary_words = total_words // 15  # Summary 15x smaller than original
    
    prompt = f"""
    Please summarize the following book content into approximately {target_summary_words} words.
    This should be about 15 times shorter than the original text.
    Focus on the main themes, key events, and important character developments.
    
    {book_content}
    """
    
    # Here you would call your LLM API with the prompt
    # For now, we'll just display a placeholder
    st.info(f"The original text is approximately {total_words} words. The summary will be about {target_summary_words} words.")
    
    st.text_area("LLM Prompt", prompt, height=200)
    
    # Placeholder for the summary
    st.write("Summary will appear here after processing by an LLM.")


def extract_chapters(file):
    """
    Extract chapters and their titles from an EPUB file.
    
    Args:
        file: The uploaded EPUB file.
    
    Returns:
        list: A list of tuples (chapter_title, chapter_content)
    """
    try:
        # Save the uploaded file temporarily
        with tempfile.NamedTemporaryFile(delete=False, suffix='.epub') as temp_file:
            temp_file.write(file.read())
            temp_path = temp_file.name
        
        # Load the EPUB book from the temporary file
        book = epub.read_epub(temp_path)
        
        chapters = []
        
        # Get the chapters
        for item in book.get_items():
            if item.get_type() == ebooklib.ITEM_DOCUMENT:
                # Parse HTML content
                soup = BeautifulSoup(item.get_content(), 'html.parser')
                
                # Extract text content
                text = soup.get_text()
                text = re.sub(r'\s+', ' ', text).strip()
                
                # Try to find a title
                title_tag = soup.find(['h1', 'h2', 'h3', 'h4', 'title'])
                title = title_tag.get_text().strip() if title_tag else f"Chapter {len(chapters) + 1}"
                
                if text:  # Only add if there's content
                    chapters.append((title, text))
        
        # Clean up the temporary file
        os.unlink(temp_path)
        
        return chapters
    except Exception as e:
        st.error(f"Error processing EPUB file: {str(e)}")
        return []


# Initialize session state variables
if 'generate_summary' not in st.session_state:
    st.session_state.generate_summary = False

show_file_input()