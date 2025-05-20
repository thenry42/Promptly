import streamlit as st
from llms.llm import get_available_providers, get_available_models, get_llm_response
import time
import gc
import psutil
import os
from history.history import load_chats, save_chats, add_message

# Set page configuration with dark theme - MUST be first Streamlit command
st.set_page_config(
    page_title="Promptly",
    page_icon="💬",
    layout="wide",
    initial_sidebar_state="auto",
    menu_items={
        'About': "# Promptly\nA streamlined chat interface for various AI models."
    }
)

# Add caching for expensive operations
@st.cache_data(ttl=300)  # Cache available providers for 5 minutes
def cached_get_available_providers(api_keys):
    return get_available_providers(api_keys)

@st.cache_data(ttl=300)  # Cache available models for 5 minutes
def cached_get_available_models(provider, api_keys):
    return get_available_models(provider, api_keys)

@st.cache_data(ttl=60)  # Cache chat history for 1 minute
def cached_load_chats():
    """Cached version of load_chats to reduce disk I/O"""
    return load_chats()

def clean_memory():
    """Perform garbage collection to free memory"""
    gc.collect()

@st.cache_data(ttl=5)  # Cache chat rendering for 5 seconds
def render_message(role, content):
    """Render a chat message with appropriate styling"""
    return {"role": role, "content": content}

@st.cache_data(ttl=3)  # Cache the chat header rendering for 3 seconds
def render_chat_header(provider, model):
    """Render the chat header with styling"""
    return f"<h3 style='color:#FAFAFA; background-color:#484955; padding:10px; border-radius:10px'>{provider} - {model}</h3>"

# Cache the chat list data with shorter TTL to reduce stale data issues
@st.cache_data(ttl=1)  # Reduce TTL even further to 1 second to prevent stale data
def get_chat_list_data():
    """Get the list of chats data without any UI elements"""
    # Make a deep copy of the data to avoid modifying the original
    chat_items = [(chat_id, chat_data.copy()) for chat_id, chat_data in st.session_state.chats.items()]
    # Sort the items to ensure consistent ordering - first by chat_id if it contains numbers
    def sort_key(item):
        chat_id = item[0]
        # Extract number from chat_id if exists (e.g., chat_5 -> 5)
        import re
        match = re.search(r'(\d+)', chat_id)
        if match:
            return int(match.group(1))
        return chat_id
    return sorted(chat_items, key=sort_key)

# New function to handle chat selection without forcing a rerun
def select_chat(chat_id):
    """Select a chat without forcing a complete rerun"""
    # If we're switching from a chat that's currently processing
    if st.session_state.processing and st.session_state.processing_chat_id != chat_id:
        # Store the processing state in the chat being switched from
        previous_chat_id = st.session_state.processing_chat_id
        if previous_chat_id in st.session_state.chats:
            # Don't reset processing - let the currently processing chat complete its work
            # This prevents duplicate responses
            pass
    
    # Update the active chat
    st.session_state.active_chat_id = chat_id
    # Clear the chat list cache to ensure fresh data
    get_chat_list_data.clear()

def show_chat():
    # Initialize chat state variables if they don't exist
    if 'chats' not in st.session_state:
        # Load chats from persistent storage with caching
        chats, chat_counter = cached_load_chats()
        st.session_state.chats = chats
        st.session_state.chat_counter = chat_counter
        
        # Ensure all messages have IDs
        for chat_id, chat_data in st.session_state.chats.items():
            for i, message in enumerate(chat_data.get("messages", [])):
                if "id" not in message:
                    # Create a stable ID based on position and content hash
                    import hashlib
                    content_hash = hashlib.md5(message.get("content", "").encode()).hexdigest()
                    message["id"] = f"{i}_{content_hash}"
                    
    if 'active_chat_id' not in st.session_state:
        st.session_state.active_chat_id = next(iter(st.session_state.chats)) if st.session_state.chats else None
    
    # Initialize processing tracking
    if 'processing' not in st.session_state:
        st.session_state.processing = False
        st.session_state.processing_chat_id = None
    elif 'processing_chat_id' not in st.session_state:
        # Make sure we have a processing_chat_id if processing is True
        if st.session_state.processing:
            st.session_state.processing_chat_id = st.session_state.active_chat_id
        else:
            st.session_state.processing_chat_id = None
            
    # Add completion tracking to prevent duplicate responses
    if 'completed_responses' not in st.session_state:
        st.session_state.completed_responses = set()
    
    if 'deleted_chat' not in st.session_state:
        st.session_state.deleted_chat = False
    
    # Check if we need to rerun due to deletion
    if st.session_state.deleted_chat:
        st.session_state.deleted_chat = False
        st.rerun()
    
    # Run garbage collection periodically
    if st.session_state.get('chat_counter', 0) % 5 == 0:
        clean_memory()
    
    # Sidebar for chat management - no caching here since it contains widgets
    with st.sidebar:
        render_sidebar()
    
    # Main content area - display active chat or prompt to create one
    if st.session_state.active_chat_id is None:
        st.title("Welcome to Promptly")
        st.info("Create a new chat to get started!")
        return
    
    # Get the active chat data
    active_chat = st.session_state.chats[st.session_state.active_chat_id]
    
    # If chat hasn't started, show provider/model selection
    if not active_chat["chat_started"]:
        render_model_selection(active_chat)
    
    # If chat has started, show the chat interface
    else:
        # Display chat header with selected model - original style with dark theme compatibility
        st.markdown(render_chat_header(active_chat['selected_provider'], active_chat['selected_model']), unsafe_allow_html=True)
        st.write("")

        # Use container for messages to improve scrolling performance
        message_container = st.container()
        
        with message_container:
            # Get messages data and display them
            messages = get_visible_messages(active_chat)
            display_messages(messages)

        # If we're currently processing a message, show the spinner
        if st.session_state.processing and st.session_state.processing_chat_id == st.session_state.active_chat_id:
            with st.chat_message("assistant"):
                with st.spinner("Thinking..."):
                    try:
                        # Check if we have a user message to respond to
                        if not active_chat["messages"] or active_chat["messages"][-1]["role"] != "user":
                            st.session_state.processing = False
                            st.session_state.processing_chat_id = None
                            st.rerun()
                            return
                            
                        # Create a unique response ID based on the last user message
                        last_user_msg = active_chat["messages"][-1]
                        response_id = f"{st.session_state.processing_chat_id}_{last_user_msg['id']}"
                        
                        # Skip if we've already processed this response
                        if response_id in st.session_state.completed_responses:
                            st.session_state.processing = False
                            st.session_state.processing_chat_id = None
                            st.rerun()
                            return
                        
                        # Track response time
                        start_time = time.time()
                        
                        # Get response from the selected LLM
                        response = get_llm_response(
                            active_chat["selected_provider"], 
                            active_chat["selected_model"], 
                            active_chat["messages"], 
                            st.session_state.api_keys
                        )
                        
                        # Calculate response time
                        response_time = time.time() - start_time
                        
                        # Add assistant response to history
                        message_id = time.time()  # Use timestamp as a unique message ID
                        active_chat["messages"].append({"role": "assistant", "content": response, "id": message_id})
                        
                        # Mark this response as completed to prevent duplicates
                        st.session_state.completed_responses.add(response_id)
                        
                        # Save to persistent storage
                        save_chats(st.session_state.chats, st.session_state.chat_counter)
                        # Clear relevant caches
                        cached_load_chats.clear()
                        get_chat_list_data.clear()  # Clear chat list cache to refresh sidebar
                        get_visible_messages.clear()  # Clear message cache to update chat
                        
                        # Log response time (for debugging)
                        print(f"LLM response time: {response_time:.2f} seconds")
                        
                    except Exception as e:
                        # Handle errors gracefully
                        error_message = f"Error: Failed to get response from {active_chat['selected_provider']} - {active_chat['selected_model']}. {str(e)}"
                        message_id = time.time()  # Use timestamp as a unique message ID
                        
                        # Create a unique response ID for error handling
                        if active_chat["messages"] and active_chat["messages"][-1]["role"] == "user":
                            last_user_msg = active_chat["messages"][-1]
                            response_id = f"{st.session_state.processing_chat_id}_{last_user_msg['id']}"
                            
                            # Only add error message if we haven't processed this response yet
                            if response_id not in st.session_state.completed_responses:
                                active_chat["messages"].append({"role": "assistant", "content": error_message, "id": message_id})
                                st.session_state.completed_responses.add(response_id)
                                
                                # Save to persistent storage since we had an error
                                save_chats(st.session_state.chats, st.session_state.chat_counter)
                        
                        # Clear relevant caches
                        cached_load_chats.clear()
                        get_chat_list_data.clear()
                        get_visible_messages.clear()
                        
                        # Log the error
                        print(f"Error in LLM response: {str(e)}")
                    finally:
                        # Set processing to False ONLY for the current processing_chat_id
                        if st.session_state.processing_chat_id == st.session_state.active_chat_id:
                            st.session_state.processing = False
                            st.session_state.processing_chat_id = None
                        # Force a rerun to display the new message
                        st.rerun()
                    
        # Chat input for new messages
        if prompt := st.chat_input("Type your message here..."):
            # Check if we're already processing a message
            if st.session_state.processing:
                # Show a warning if trying to send a message while processing another
                st.warning("Please wait for the current message to be processed before sending another.")
                return
                
            # Create message ID
            message_id = time.time()  # Use timestamp as a unique message ID
            # Add user message to history
            active_chat["messages"].append({"role": "user", "content": prompt, "id": message_id})
            
            # Keep the completed responses set from growing too large (limit to last 100)
            if len(st.session_state.completed_responses) > 100:
                # Convert to list, keep the most recent 50 items, convert back to set
                completed_list = list(st.session_state.completed_responses)
                st.session_state.completed_responses = set(completed_list[-50:])
            
            # Save to persistent storage
            save_chats(st.session_state.chats, st.session_state.chat_counter)
            # Clear relevant caches
            cached_load_chats.clear()
            get_chat_list_data.clear()  # Clear chat list cache to refresh sidebar
            get_visible_messages.clear()  # Clear message cache to update chat
            # Set processing to True
            st.session_state.processing = True
            st.session_state.processing_chat_id = st.session_state.active_chat_id
            # Force a rerun to display the new message and start processing
            st.rerun()

# Modify the sidebar render function to use the session state directly
def render_sidebar():
    """Render the sidebar with chat list"""
    st.title("Chat Management")
    
    # Create a new chat button
    if st.button("New Chat", use_container_width=True, type="secondary"):
        # Create a new unique chat ID
        new_chat_id = f"chat_{st.session_state.chat_counter}"
        # Initialize the new chat
        st.session_state.chats[new_chat_id] = {
            "chat_started": False,
            "messages": [],
            "selected_provider": None,
            "selected_model": None,
            "title": "Unknown"
        }
        # Set the new chat as active
        st.session_state.active_chat_id = new_chat_id
        # Increment the counter
        st.session_state.chat_counter += 1
        # Save to persistent storage
        save_chats(st.session_state.chats, st.session_state.chat_counter)
        # Clear relevant caches
        cached_load_chats.clear()
        get_chat_list_data.clear()  # Clear chat list cache
        get_visible_messages.clear()  # Clear message cache if it exists
        st.rerun()
    
    # Display existing chats
    if not st.session_state.chats:
        st.info("No chats yet. Create a new chat to get started!")
        return
    
    # Get cached data
    chat_items = get_chat_list_data()
    
    # Use the data in UI components (not cached)
    for chat_id, chat_data in chat_items:
        col1, col2 = st.columns([4, 1])
        
        # Chat title and selection - modified to use callback
        with col1:
            button_color = "primary" if st.session_state.active_chat_id == chat_id else "secondary"
            # Use on_click with a callback function instead of rerunning directly
            if st.button(chat_data["title"], key=f"select_{chat_id}", use_container_width=True, type=button_color, on_click=select_chat, args=(chat_id,)):
                pass  # The callback handles the state change
        
        # Delete button
        with col2:
            # Create a closure for each chat_id to ensure proper callback behavior
            def create_delete_callback(chat_id_to_delete):
                def delete_chat_callback():
                    # Remove the chat
                    if chat_id_to_delete in st.session_state.chats:
                        del st.session_state.chats[chat_id_to_delete]
                        # If this was the active chat, set active to None or next available
                        if st.session_state.active_chat_id == chat_id_to_delete:
                            st.session_state.active_chat_id = next(iter(st.session_state.chats)) if st.session_state.chats else None
                        # Save to persistent storage
                        save_chats(st.session_state.chats, st.session_state.chat_counter)
                        # Clear all relevant caches
                        cached_load_chats.clear()
                        get_chat_list_data.clear()
                        # We can directly clear this function
                        get_visible_messages.clear()
                        # Force garbage collection
                        clean_memory()
                        # Set deletion flag to trigger rerun in a controlled manner
                        st.session_state.deleted_chat = True
                return delete_chat_callback
            
            # Create a unique key for the button to avoid duplication
            delete_button_key = f"delete_{chat_id}_{id(chat_data)}"
            if st.button("🗑️", key=delete_button_key, help="Delete this chat", on_click=create_delete_callback(chat_id)):
                pass  # The callback handles the deletion

# Cache the data
@st.cache_data(ttl=5)
def get_visible_messages(active_chat):
    """Get the visible messages from the chat with caching"""
    MAX_VISIBLE_MESSAGES = 20
    visible_messages = active_chat["messages"][-MAX_VISIBLE_MESSAGES:] if len(active_chat["messages"]) > MAX_VISIBLE_MESSAGES else active_chat["messages"]
    return visible_messages

# Don't cache the UI display
def display_messages(messages):
    """Display the message UI - this can't be cached as it contains widgets"""
    for message in messages:
        if message["role"] != "system":
            # Streamlit's chat_message doesn't support keys in this version
            with st.chat_message(message["role"]):
                rendered_message = render_message(message["role"], message["content"])
                st.markdown(rendered_message["content"])

# Remove caching from model selection since it contains widgets
def render_model_selection(active_chat):
    """Render the model selection UI"""
    st.title("Create New Chat")
    
    # Use cached function to get available providers
    try:
        with st.spinner("Loading available providers..."):
            available_providers = cached_get_available_providers(st.session_state.api_keys)
        
        if not available_providers:
            st.error("No AI providers available. Please check your API keys in Settings.")
            return
            
        provider = st.selectbox(
            "Select AI Provider",
            available_providers,
            index=None,
            placeholder="Select an AI provider",
            label_visibility="collapsed",
            accept_new_options=False
        )

        if provider:
            # Use cached function to get available models
            with st.spinner(f"Loading {provider} models..."):
                models = cached_get_available_models(provider, st.session_state.api_keys)
            
            if not models:
                st.error(f"No models available for {provider}. Please check your API key.")
                return
                
            model = st.selectbox(
                f"Select {provider} Model",
                models,
                index=None,
                placeholder="Select a model",
                label_visibility="collapsed"
            )
    except Exception as e:
        st.error(f"Error loading providers: {str(e)}")
        return

    def create_chat():
        # Hide the selection UI
        active_chat["chat_started"] = True
        active_chat["selected_provider"] = provider
        active_chat["selected_model"] = model
        active_chat["messages"] = []
        active_chat["title"] = f"{provider} - {model}"
        # Save to persistent storage
        save_chats(st.session_state.chats, st.session_state.chat_counter)
        # Clear relevant caches
        cached_load_chats.clear()
        get_chat_list_data.clear()  # Clear chat list cache
        get_visible_messages.clear()  # Clear message cache if it exists
    
    # Only show the button if provider and model are selected
    if provider and model:
        st.button("Start Chat", on_click=create_chat, type="primary")

# Apply custom dark theme CSS - keep this outside the main function
st.markdown("""
<style>
.stButton button {
    border-radius: 8px;
}

/* Removing the custom message container styling to revert to original appearance */
/* Keeping only minimal styling for dark theme compatibility */
div[data-testid="stChatMessageContent"] p {
    color: #FAFAFA;
}
</style>
""", unsafe_allow_html=True)

def main():
    # Initialize state from secrets if available
    if 'api_keys' not in st.session_state:
        st.session_state.api_keys = {
            'openai': st.secrets.get("api_keys", {}).get("openai", ""),
            'anthropic': st.secrets.get("api_keys", {}).get("anthropic", ""),
            'gemini': st.secrets.get("api_keys", {}).get("gemini", ""),
            'mistral': st.secrets.get("api_keys", {}).get("mistral", ""),
            'deepseek': st.secrets.get("api_keys", {}).get("deepseek", ""),
            'ollama': st.secrets.get("api_keys", {}).get("ollama", "11434")
        }

    # Show the chat interface on the main page
    show_chat()
            
if __name__ == "__main__":
    main()