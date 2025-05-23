import streamlit as st
import time

# Import modules from our refactored structure
from ui.components import (
    display_messages, 
    render_chat_header, 
    render_model_selection, 
    render_sidebar,
    apply_theme
)
from state.state_manager import (
    initialize_session_state,
    create_new_chat,
    select_chat,
    delete_chat,
    start_chat,
    add_user_message,
    process_assistant_response,
    get_visible_messages,
    clean_memory
)
from llms.llm import (
    get_available_providers,
    get_available_models,
    cached_llm_response,
    get_llm_response_streaming
)
from history.history import save_chats

# Set up Streamlit page configuration
st.set_page_config(
    page_title="Promptly",
    page_icon="💬",
    layout="wide",
    initial_sidebar_state="auto",
    menu_items={
        'About': "# Promptly\nA streamlined chat interface for various AI models."
    }
)

# Apply custom CSS theme
apply_theme()

# Define cached versions of provider and model lookup functions
@st.cache_data(ttl=300)
def cached_get_available_providers(api_keys):
    """Cached version of get_available_providers to reduce API calls"""
    return get_available_providers(api_keys)


@st.cache_data(ttl=300)
def cached_get_available_models(provider, api_keys):
    """Cached version of get_available_models to reduce API calls"""
    return get_available_models(provider, api_keys)


def handle_new_chat():
    """Handle the creation of a new chat"""
    chat_id = create_new_chat()
    # Clear relevant caches
    cached_get_available_providers.clear()
    cached_get_available_models.clear()
    # Force a rerun to show the new chat
    st.rerun()


def handle_select_chat(chat_id):
    """Handle the selection of a chat"""
    select_chat(chat_id)
    # Force a rerun to show the selected chat
    st.rerun()


def handle_delete_chat(chat_id):
    """Handle the deletion of a chat"""
    delete_chat(chat_id)
    # Force a rerun to refresh the UI
    st.rerun()


def handle_start_chat(provider, model):
    """Handle starting a new chat with a selected provider and model"""
    start_chat(provider, model)
    # Force a rerun to show the chat interface
    st.rerun()


def show_chat():
    """Show the main chat interface"""
    # Initialize the session state
    initialize_session_state()
    
    # Run garbage collection periodically
    if st.session_state.get('chat_counter', 0) % 5 == 0:
        clean_memory()
    
    # Check if we need to rerun due to deletion
    if st.session_state.deleted_chat:
        st.session_state.deleted_chat = False
        st.rerun()
    
    # Sidebar for chat management
    with st.sidebar:
        render_sidebar(
            st.session_state.chats,
            st.session_state.active_chat_id,
            handle_select_chat,
            handle_new_chat,
            handle_delete_chat
        )
    
    # Main content area
    if st.session_state.active_chat_id is None:
        st.title("Welcome to Promptly")
        st.info("Create a new chat to get started!")
        return
    
    # Get the active chat data
    active_chat = st.session_state.chats[st.session_state.active_chat_id]
    
    # If chat hasn't started, show provider/model selection
    if not active_chat["chat_started"]:
        # Get available providers
        with st.spinner("Loading available providers..."):
            available_providers = cached_get_available_providers(st.session_state.api_keys)
        
        # Render model selection UI
        render_model_selection(
            active_chat,
            available_providers,
            lambda provider: cached_get_available_models(provider, st.session_state.api_keys),
            handle_start_chat
        )
    
    # If chat has started, show the chat interface
    else:
        # Display chat header
        st.markdown(render_chat_header(active_chat['selected_provider'], active_chat['selected_model']), unsafe_allow_html=True)
        st.write("")

        # Message container for better scrolling
        message_container = st.container()
        
        # First display all existing messages
        with message_container:
            # Get all messages except the one being processed (if streaming)
            messages_to_display = get_visible_messages(active_chat)
            # If we're processing a streaming response, don't display the last assistant message here
            # since it will be displayed in the streaming section
            if st.session_state.processing and st.session_state.processing_chat_id == st.session_state.active_chat_id:
                if st.session_state.app_settings.get('use_streaming', False):
                    # Filter out any potential incomplete assistant message at the end (last message should be user)
                    messages_to_display = [msg for msg in messages_to_display 
                                          if not (msg["role"] == "assistant" and 
                                                 msg == messages_to_display[-1])]
            
            # Display all the messages
            display_messages(messages_to_display)

        # Process the assistant's response if needed
        if st.session_state.processing and st.session_state.processing_chat_id == st.session_state.active_chat_id:
            with st.chat_message("assistant"):
                # Display different UI based on streaming setting
                use_streaming = st.session_state.app_settings.get('use_streaming', False)
                
                if use_streaming:
                    # For streaming, use a placeholder that can be updated with new content
                    response_placeholder = st.empty()
                    
                    # Check if we have a user message to respond to
                    if active_chat["messages"] and active_chat["messages"][-1]["role"] == "user":
                        # Show initial thinking state
                        response_placeholder.markdown("_Thinking..._")
                        
                        # Get the latest user message
                        last_user_msg = active_chat["messages"][-1]
                        
                        try:
                            # Create a unique response ID
                            response_id = f"{st.session_state.processing_chat_id}_{last_user_msg['id']}"
                            
                            # Skip if we've already processed this response
                            if response_id in st.session_state.completed_responses:
                                st.session_state.processing = False
                                st.session_state.processing_chat_id = None
                                st.rerun()
                                return
                            
                            # Initialize response text
                            current_response = ""
                            
                            # Get streaming response generator
                            streaming_generator = get_llm_response_streaming(
                                active_chat["selected_provider"],
                                active_chat["selected_model"],
                                active_chat["messages"],
                                st.session_state.api_keys
                            )
                            
                            # Process each chunk
                            for chunk in streaming_generator:
                                # Add new chunk to current response
                                current_response += chunk
                                # Update the placeholder with current content (use markdown for formatting)
                                response_placeholder.markdown(current_response)
                                # Small delay to ensure UI updates properly
                                time.sleep(0.01)  # 10ms delay to allow UI to refresh
                            
                            # Add the complete response to chat history
                            message_id = time.time()
                            active_chat["messages"].append({
                                "role": "assistant", 
                                "content": current_response, 
                                "id": message_id
                            })
                            
                            # Mark this response as completed
                            st.session_state.completed_responses.add(response_id)
                            
                            # Save to persistent storage
                            save_chats(st.session_state.chats, st.session_state.chat_counter)
                            
                            # Reset processing state
                            st.session_state.processing = False
                            st.session_state.processing_chat_id = None
                            
                            # We don't need to rerun here since we've already displayed the content
                            
                        except Exception as e:
                            # Handle errors
                            error_message = f"Error: Failed to get streaming response. {str(e)}"
                            response_placeholder.markdown(error_message)
                            
                            # Add error message to chat history
                            message_id = time.time()
                            active_chat["messages"].append({
                                "role": "assistant", 
                                "content": error_message, 
                                "id": message_id
                            })
                            
                            # Mark as completed
                            st.session_state.completed_responses.add(response_id)
                            
                            # Save to persistent storage
                            save_chats(st.session_state.chats, st.session_state.chat_counter)
                            
                            # Reset processing state
                            st.session_state.processing = False
                            st.session_state.processing_chat_id = None
                            
                            # Log the error
                            print(f"Streaming error: {str(e)}")
                else:
                    # For non-streaming, use the standard spinner approach
                    with st.spinner("Thinking..."):
                        # Process the response
                        success = process_assistant_response()
                        if success:
                            # Force a rerun to display the new message
                            st.rerun()
        
        # Chat input for new messages
        if prompt := st.chat_input("Type your message here..."):
            # Check if we're already processing a message
            if st.session_state.processing:
                # Show a warning if trying to send a message while processing another
                st.warning("Please wait for the current message to be processed before sending another.")
                return
                
            # Add the user message
            add_user_message(prompt)
            # Force a rerun to display the new message and start processing
            st.rerun()


def main():
    """Main entry point for the application"""
    show_chat()


if __name__ == "__main__":
    main()