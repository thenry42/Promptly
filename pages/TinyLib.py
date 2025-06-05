import streamlit as st
from ui.components import render_chat_header
import ebooklib
from ebooklib import epub
from bs4 import BeautifulSoup
import re
import tempfile
import os
import time
from llms.providers.llm_gemini import generate_book_summary_gemini


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
                
                with st.expander(f"Preview: {title}", expanded=True):
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


def generate_book_summary(chapters):
    """
    Generate a summary of the book based on selected chapters and desired length.
    
    Args:
        chapters: List of (title, content) tuples for included chapters
    """
    st.subheader("Book Summary")
    
    # Create input for the LLM
    book_content = "\n\n".join([f"## {title}\n{content}" for title, content in chapters])
    
    # Calculate total word count
    total_words = sum(len(content.split()) for _, content in chapters)
    target_summary_words = total_words // 20  # Summary 15x smaller than original
    
    default_prompt = f"""You are a helpful assistant that summarizes books. 
    Please summarize the following book content into approximately {target_summary_words} words.
    This should be about 20 times shorter than the original text.
    Focus on the main themes, key events, and important character developments.
    The summary should be in the same language as the book content.
    Keep the vibe of the book, don't be too formal.
    Don't invent anything that is not in the book.
    Generate the summary as a Markdown document with chapter titles and content.
    Try to follow the structure of the book (chapters, sections, etc.)
    Separate the chapters with a horizontal rule.
    Don't hesitate to use italic, bold, and others formatting to make the summary more readable.
    """
    
    st.info(f"The original text is approximately {total_words} words. The summary will be about {target_summary_words} words.")
    
    # Let the user edit the prompt
    if 'edited_prompt' not in st.session_state:
        st.session_state.edited_prompt = default_prompt
    
    edited_prompt = st.text_area("Edit Prompt (optional)", value=st.session_state.edited_prompt, height=230)
    st.session_state.edited_prompt = edited_prompt
    
    # Store the book content separately
    if 'book_content' not in st.session_state:
        st.session_state.book_content = book_content
    
    # Create full prompt with book content
    full_prompt = edited_prompt + f"\n\nHere is the book content:\n{st.session_state.book_content}"
    
    # Initialize summary state
    if 'summary' not in st.session_state:
        st.session_state.summary = None
    
    # Button to generate summary
    if st.button("Generate Summary with LLM"):
        # Show loading indicator
        with st.spinner("Processing summary with LLM..."):
            # Create a loop to regenerate the summary until it's within ±10% of target length
            max_attempts = 10
            attempt = 0
            current_prompt = full_prompt
            
            while attempt < max_attempts:
                # Call the LLM API with the current prompt
                response = generate_book_summary_gemini(current_prompt, st.secrets["api_keys"]["gemini"])
                st.session_state.summary = response
                
                # Check the length of the summary
                summary_words = len(st.session_state.summary.split())
                
                # Check if the summary is within ±10% of target length
                if summary_words > target_summary_words * 1.1:
                    # Too long, ask for shorter summary and include the previous summary
                    current_prompt = f"The previous summary was too long ({summary_words} words). Please make it shorter, closer to {target_summary_words} words.\n\nHere is your previous summary that needs to be shortened:\n{st.session_state.summary}\n\n{current_prompt}"
                    attempt += 1
                    if attempt < max_attempts:
                        st.info(f"Summary too long ({summary_words} words). Regenerating... (Attempt {attempt+1}/{max_attempts})")
                elif summary_words < target_summary_words * 0.9:
                    # Too short, ask for longer summary and include the previous summary
                    current_prompt = f"The previous summary was too short ({summary_words} words). Please make it longer, closer to {target_summary_words} words.\n\nHere is your previous summary that needs to be expanded:\n{st.session_state.summary}\n\n{current_prompt}"
                    attempt += 1
                    if attempt < max_attempts:
                        st.info(f"Summary too short ({summary_words} words). Regenerating... (Attempt {attempt+1}/{max_attempts})")
                else:
                    # Just right
                    st.success(f"Summary generated successfully! ({summary_words} words)")
                    break
            
            # Display final attempt message if we couldn't get within the target range
            if attempt == max_attempts and (summary_words > target_summary_words * 1.1 or summary_words < target_summary_words * 0.9):
                st.warning(f"After {max_attempts} attempts, the best summary is {summary_words} words (target was {target_summary_words})")
    
    # Display and allow download if summary exists
    if st.session_state.summary:
        st.markdown("### Generated Summary")
        st.write(st.session_state.summary)
        
        # Create data directory if it doesn't exist
        data_dir = "data"
        os.makedirs(data_dir, exist_ok=True)
        
        # Create a downloadable summary in the data directory
        summary_file = os.path.join(data_dir, "summary.md")
        with open(summary_file, "w") as f:
            f.write(st.session_state.summary)
        
        st.info(f"Summary saved to: {summary_file}")
        
        # Provide download button for the user
        st.download_button(
            label="Download Summary",
            data=st.session_state.summary,
            file_name="book_summary.md",
            mime="text/markdown"
        )


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