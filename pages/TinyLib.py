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

    # Need to Summarize each chapter separately


    # Generate a summary for each chapter in a loop to get the target length of each chapter
    # target_len_chapter = word_in_chapter / 15
    # target_len_chapter = 2500 / nb_chapters

    
    # Create input for the LLM
    book_content = "\n\n".join([f"## {title}\n{content}" for title, content in chapters])
    
    # Calculate total word count
    total_words = sum(len(content.split()) for _, content in chapters)
    target_summary_words = max(total_words // 15, 3000)  # Summary 15x smaller than original, minimum 3000 words
    
    default_prompt = f"""You are a helpful assistant that summarizes books. 

CRITICAL LENGTH REQUIREMENT: Your summary must be EXACTLY {target_summary_words} words (±10% words tolerance).

STRUCTURE GUIDELINES:
- Divide your summary into sections or chapters
- Use chapter titles as section headers
- Separate chapters with horizontal rules (---)

CONTENT GUIDELINES:
- Focus on main themes, key events, and important character developments
- Keep the original book's tone and style
- Write in the same language as the book content
- Don't invent anything not in the book
- Use markdown formatting (italic, bold) for readability

LENGTH CONTROL TECHNIQUES:
- For longer content: Focus on major plot points, skip minor details
- For shorter content: Include character motivations, detailed descriptions, subplot summaries
- Monitor your word count as you write each section

WORD COUNT TRACKING:
- Target: {target_summary_words} words total
- Check your progress after each section
"""
    
    st.info(f"The original text is approximately {total_words} words. The summary will be about {target_summary_words} words.")
    
    # Let the user edit the prompt
    if 'edited_prompt' not in st.session_state:
        st.session_state.edited_prompt = default_prompt
    
    # Store the current default for comparison
    st.session_state.default_prompt = default_prompt
    
    # Always show the default prompt as editable
    st.subheader("Prompt")
    st.info("You can edit the prompt below to customize how the summary is generated:")
    
    # Let user edit the prompt
    edited_prompt = st.text_area("Edit Prompt", value=st.session_state.edited_prompt, height=300)
    st.session_state.edited_prompt = edited_prompt
    
    # Button to reset to default
    if st.button("Reset to Default Prompt"):
        st.session_state.edited_prompt = default_prompt
        st.experimental_rerun()
    
    # Store the book content separately
    if 'book_content' not in st.session_state:
        st.session_state.book_content = book_content
    
    # Initialize summary state and stop flag
    if 'summary' not in st.session_state:
        st.session_state.summary = None
    
    # Display current summary if exists
    if st.session_state.summary:
        st.markdown("### Current Summary (Last Generated)")
        with st.expander("View Current Summary", expanded=False):
            st.write(st.session_state.summary)
        
        summary_words = len(st.session_state.summary.split())
        st.info(f"Current summary: {summary_words} words")
    
    generate_clicked = st.button("Generate Summary with LLM")
    
    # Button to generate summary
    if generate_clicked:
        # Show loading indicator
        with st.spinner("Processing summary with LLM..."):
            # Improved iterative refinement with adaptive prompts
            max_attempts = 3
            attempt = 0
            
            while attempt < max_attempts:
                st.info(f"Generating summary... (Attempt {attempt + 1}/{max_attempts})")
                
                # Use the edited prompt for first attempt, adaptive prompts for refinements
                if attempt == 0:
                    # First attempt - use the edited prompt with full book content
                    current_prompt = f"{st.session_state.edited_prompt}\n\nHere is the book content:\n{st.session_state.book_content}"
                else:
                    # Refinement attempts - optimize based on summary length
                    previous_word_count = len(st.session_state.summary.split())
                    
                    if previous_word_count > target_summary_words:
                        # Summary is too long - send only the summary for trimming
                        st.info("📝 Trimming existing summary (more efficient - no need to re-read book)")
                        adaptive_prompt = create_adaptive_prompt(
                            chapters, 
                            target_summary_words, 
                            attempt=attempt,
                            previous_summary=st.session_state.summary,
                            previous_word_count=previous_word_count
                        )
                        current_prompt = adaptive_prompt  # Only the summary, not the book content
                    else:
                        # Summary is too short - generate fresh with full content
                        st.info("📚 Generating new summary with full book content (summary too short)")
                        adaptive_prompt = create_adaptive_prompt(
                            chapters, 
                            target_summary_words, 
                            attempt=attempt,
                            previous_summary=None,  # Don't include previous summary for fresh generation
                            previous_word_count=previous_word_count
                        )
                        current_prompt = adaptive_prompt + f"\n\nHere is the book content:\n{st.session_state.book_content}"
                
                # Call the LLM API with the current prompt
                try:
                    response = generate_book_summary_gemini(current_prompt, st.secrets["api_keys"]["gemini"])
                    st.session_state.summary = response
                    
                    # Check the length of the summary
                    summary_words = len(st.session_state.summary.split())
                    
                    # Tighter tolerance for exact targeting
                    tolerance = 0.1
                    min_words = int(target_summary_words * (1 - tolerance))
                    max_words = int(target_summary_words * (1 + tolerance))
                    
                    if min_words <= summary_words <= max_words:
                        # Success!
                        accuracy = abs(summary_words - target_summary_words) / target_summary_words * 100
                        st.success(f"Summary generated successfully! ({summary_words} words, target: {target_summary_words}, accuracy: {100-accuracy:.1f}%)")
                        break
                    else:
                        if attempt == max_attempts - 1:
                            # Last attempt, show what we got
                            st.warning(f"Best result after {max_attempts} attempts: {summary_words} words (target: {target_summary_words})")
                        else:
                            # Continue with next attempt
                            if summary_words > max_words:
                                st.info(f"Summary too long ({summary_words} words). Applying targeted reduction... (Attempt {attempt+2}/{max_attempts})")
                            else:
                                st.info(f"Summary too short ({summary_words} words). Applying targeted expansion... (Attempt {attempt+2}/{max_attempts})")
                    
                    attempt += 1
                        
                except Exception as e:
                    st.error(f"Error generating summary: {str(e)}")
                    break
            
            # Display final messages with helpful feedback
            if st.session_state.summary:
                final_summary_words = len(st.session_state.summary.split())
                if not (min_words <= final_summary_words <= max_words):
                    st.info("💡 **Tips for better results:**")
                    st.info("• Try adjusting the target word count (currently based on 1/15th of original)")
                    st.info("• Modify the prompt to emphasize specific aspects you want covered")
                    st.info("• Consider the book's complexity - technical books may need different approaches")
    
    # Display and allow download if summary exists (always available)
    if st.session_state.summary:
        st.markdown("### Final Summary")
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


def create_adaptive_prompt(chapters, target_words, attempt=0, previous_summary=None, previous_word_count=None):
    """
    Create an adaptive prompt based on content characteristics and previous attempts.
    
    Args:
        chapters: List of (title, content) tuples
        target_words: Target word count for summary
        attempt: Current attempt number (0 for first attempt)
        previous_summary: Previous summary if this is a refinement
        previous_word_count: Word count of previous summary
    
    Returns:
        str: Optimized prompt for the LLM
    """
    avg_words_per_chapter = target_words // len(chapters)
    
    # Analyze content characteristics
    total_chars = sum(len(content) for _, content in chapters)
    avg_chars_per_word = total_chars / sum(len(content.split()) for _, content in chapters)
    
    # Determine content complexity
    if avg_chars_per_word > 6:
        complexity = "high"  # Technical or complex vocabulary
    elif avg_chars_per_word > 5:
        complexity = "medium"
    else:
        complexity = "low"  # Simple vocabulary
    
    # Base prompt with adaptive elements
    if attempt == 0:
        # First attempt - comprehensive instructions
        prompt = f"""You are an expert book summarizer. Create a summary that is EXACTLY {target_words} words.

CRITICAL REQUIREMENTS:
✓ EXACT word count: {target_words} words (not approximately, but exactly)
✓ Structure: {len(chapters)} chapter sections of ~{avg_words_per_chapter} words each
✓ Use chapter titles as headers with markdown formatting

WRITING STRATEGY (for {complexity} complexity content):"""
        
        if complexity == "high":
            prompt += f"""
- Simplify technical concepts while preserving meaning
- Focus on key insights and main arguments
- Use clear, accessible language"""
        elif complexity == "medium":
            prompt += f"""
- Balance detail with conciseness
- Include important context and relationships
- Maintain original tone and style"""
        else:
            prompt += f"""
- Preserve storytelling elements and emotional tone
- Include character development and plot progression
- Keep engaging narrative flow"""
        
        prompt += f"""

SECTION BREAKDOWN:
- Each chapter section: exactly {avg_words_per_chapter} words
- Include main themes, key events, character development
- Separate sections with "---"

QUALITY CHECKS:
- Count words as you write each section
- Verify total = {target_words} words
- Ensure balanced coverage across all chapters

Remember: EXACTLY {target_words} words total."""
        
    else:
        # Refinement attempt - focused corrections
        if previous_word_count > target_words:
            excess = previous_word_count - target_words
            prompt = f"""REFINEMENT TASK: Reduce summary from {previous_word_count} to EXACTLY {target_words} words.

REDUCTION TARGETS (remove {excess} words total):
- Cut {excess // len(chapters)} words per chapter section
- Remove: Redundant phrases, minor details, excessive adjectives
- Preserve: Core plot, main themes, character arcs

STRATEGY:
1. Go through each section systematically
2. Identify non-essential content to remove
3. Ensure each section hits ~{avg_words_per_chapter} words
4. Final count must be exactly {target_words} words

PREVIOUS SUMMARY TO REVISE:
{previous_summary}"""
        else:
            missing = target_words - previous_word_count
            prompt = f"""REFINEMENT TASK: Expand summary from {previous_word_count} to EXACTLY {target_words} words.

EXPANSION TARGETS (add {missing} words total):
- Add {missing // len(chapters)} words per chapter section
- Include: Character motivations, scene details, thematic depth
- Maintain: Existing structure and quality

STRATEGY:
1. Identify areas needing more detail
2. Add meaningful content (not filler)
3. Ensure each section reaches ~{avg_words_per_chapter} words
4. Final count must be exactly {target_words} words

PREVIOUS SUMMARY TO EXPAND:
{previous_summary}"""
    
    return prompt


def create_strategy_prompt(chapters, target_words, strategy_type):
    """
    Create prompts for different summarization strategies.
    
    Args:
        chapters: List of (title, content) tuples
        target_words: Target word count
        strategy_type: "concise", "detailed", or "academic"
    
    Returns:
        str: Strategy-specific prompt
    """
    avg_words_per_chapter = target_words // len(chapters)
    
    base_requirements = f"""You are an expert book summarizer. Create a summary that is EXACTLY {target_words} words.

CRITICAL REQUIREMENTS:
✓ EXACT word count: {target_words} words
✓ Structure: {len(chapters)} chapter sections of ~{avg_words_per_chapter} words each
✓ Use chapter titles as headers with markdown formatting
✓ Separate sections with "---"
"""
    
    if strategy_type == "concise":
        return base_requirements + f"""
CONCISE STRATEGY:
- Focus ONLY on major plot points and key events
- Minimal character details (names and primary roles only)
- Skip subplots and minor details
- Use clear, direct language
- Prioritize main narrative arc

WRITING APPROACH:
- Each chapter: {avg_words_per_chapter} words covering essential plot progression
- Eliminate: Descriptions, backstory, minor characters
- Include: Core conflicts, resolutions, major turning points"""

    elif strategy_type == "detailed":
        return base_requirements + f"""
DETAILED STRATEGY:
- Include character development and motivations
- Cover important subplots and relationships
- Add context and world-building details
- Use descriptive, engaging language
- Preserve emotional tone and atmosphere

WRITING APPROACH:
- Each chapter: {avg_words_per_chapter} words with rich detail
- Include: Character arcs, setting descriptions, relationship dynamics
- Maintain: Original style and emotional depth"""

    elif strategy_type == "academic":
        return base_requirements + f"""
ACADEMIC STRATEGY:
- Emphasize themes, symbols, and literary analysis
- Use formal, analytical language
- Focus on structure and narrative techniques
- Include cultural/historical context when relevant
- Discuss character development in analytical terms

WRITING APPROACH:
- Each chapter: {avg_words_per_chapter} words with analytical depth
- Include: Thematic analysis, literary devices, significance
- Tone: Scholarly but accessible"""
    
    return base_requirements


# Initialize session state variables
if 'generate_summary' not in st.session_state:
    st.session_state.generate_summary = False

show_file_input()