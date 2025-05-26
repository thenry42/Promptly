import streamlit as st
import gc
import time
import hashlib
from typing import Dict, List, Any, Tuple, Optional, Callable

from history.history import load_chats, save_chats, add_message
from llms.llm import cached_llm_response, get_llm_response_streaming


def initialize_session_state() -> None:
    """Initialize all required session state variables if they don't exist."""
    # Initialize API keys
    if 'api_keys' not in st.session_state:
        st.session_state.api_keys = {
            'openai': st.secrets.get("api_keys", {}).get("openai", ""),
            'anthropic': st.secrets.get("api_keys", {}).get("anthropic", ""),
            'gemini': st.secrets.get("api_keys", {}).get("gemini", ""),
            'mistral': st.secrets.get("api_keys", {}).get("mistral", ""),
            'deepseek': st.secrets.get("api_keys", {}).get("deepseek", ""),
            'ollama': st.secrets.get("api_keys", {}).get("ollama", "11434")
        }
    
    # Initialize app settings
    if 'app_settings' not in st.session_state:
        st.session_state.app_settings = {
            'use_streaming': st.secrets.get("app_settings", {}).get("use_streaming", False)
        }
    
    # Initialize chat state
    if 'chats' not in st.session_state:
        # Load chats from persistent storage
        chats, chat_counter = load_chats()
        st.session_state.chats = chats
        st.session_state.chat_counter = chat_counter
        
        # Ensure all messages have IDs
        for chat_id, chat_data in st.session_state.chats.items():
            for i, message in enumerate(chat_data.get("messages", [])):
                if "id" not in message:
                    # Create a stable ID based on position and content hash
                    content_hash = hashlib.md5(message.get("content", "").encode()).hexdigest()
                    message["id"] = f"{i}_{content_hash}"
    
    # Initialize active chat
    if 'active_chat_id' not in st.session_state:
        st.session_state.active_chat_id = next(iter(st.session_state.chats)) if st.session_state.chats else None
    
    # Initialize processing state
    if 'processing' not in st.session_state:
        st.session_state.processing = False
        st.session_state.processing_chat_id = None
    elif 'processing_chat_id' not in st.session_state:
        # Make sure we have a processing_chat_id if processing is True
        if st.session_state.processing:
            st.session_state.processing_chat_id = st.session_state.active_chat_id
        else:
            st.session_state.processing_chat_id = None
    
    # Initialize response tracking
    if 'completed_responses' not in st.session_state:
        st.session_state.completed_responses = set()
    
    # Initialize deletion tracking
    if 'deleted_chat' not in st.session_state:
        st.session_state.deleted_chat = False


def clean_memory() -> None:
    """Perform garbage collection to free memory."""
    gc.collect()


def create_new_chat() -> str:
    """
    Create a new chat in the session state.
    
    Returns:
        str: The ID of the newly created chat
    """
    # Create a new unique chat ID
    new_chat_id = f"chat_{st.session_state.chat_counter}"
    
    # Initialize the new chat
    st.session_state.chats[new_chat_id] = {
        "chat_started": False,
        "messages": [],
        "selected_provider": None,
        "selected_model": None,
        "title": "New Chat"
    }
    
    # Set the new chat as active
    st.session_state.active_chat_id = new_chat_id
    
    # Increment the counter
    st.session_state.chat_counter += 1
    
    # Save to persistent storage
    save_chats(st.session_state.chats, st.session_state.chat_counter)
    
    return new_chat_id


def select_chat(chat_id: str) -> None:
    """
    Select a chat as the active chat.
    
    Args:
        chat_id: The ID of the chat to select
    """
    # If we're switching from a chat that's currently processing
    if st.session_state.processing and st.session_state.processing_chat_id != chat_id:
        # Don't reset processing - let the currently processing chat complete its work
        pass
    
    # Update the active chat
    st.session_state.active_chat_id = chat_id


def delete_chat(chat_id: str) -> None:
    """
    Delete a chat from the session state.
    
    Args:
        chat_id: The ID of the chat to delete
    """
    # Remove the chat
    if chat_id in st.session_state.chats:
        del st.session_state.chats[chat_id]
        
        # If this was the active chat, set active to None or next available
        if st.session_state.active_chat_id == chat_id:
            st.session_state.active_chat_id = next(iter(st.session_state.chats)) if st.session_state.chats else None
        
        # Save to persistent storage
        save_chats(st.session_state.chats, st.session_state.chat_counter)
        
        # Force garbage collection
        clean_memory()
        
        # Set deletion flag to trigger rerun
        st.session_state.deleted_chat = True


def start_chat(provider: str, model: str) -> None:
    """
    Start a new chat with the selected provider and model.
    
    Args:
        provider: The selected provider
        model: The selected model
    """
    active_chat = st.session_state.chats[st.session_state.active_chat_id]
    
    # Update chat data
    active_chat["chat_started"] = True
    active_chat["selected_provider"] = provider
    active_chat["selected_model"] = model
    active_chat["messages"] = []
    active_chat["title"] = f"{provider} - {model}"
    
    # Save to persistent storage
    save_chats(st.session_state.chats, st.session_state.chat_counter)


def add_user_message(message: str) -> None:
    """
    Add a user message to the active chat.
    
    Args:
        message: The message content
    """
    if not message:
        return
        
    active_chat = st.session_state.chats[st.session_state.active_chat_id]
    
    # Create message ID
    message_id = time.time()  # Use timestamp as a unique message ID
    
    # Add user message to history
    active_chat["messages"].append({"role": "user", "content": message, "id": message_id})
    
    # Keep the completed responses set from growing too large
    if len(st.session_state.completed_responses) > 100:
        # Convert to list, keep the most recent 50 items, convert back to set
        completed_list = list(st.session_state.completed_responses)
        st.session_state.completed_responses = set(completed_list[-50:])
    
    # Save to persistent storage
    save_chats(st.session_state.chats, st.session_state.chat_counter)
    
    # Set processing state
    st.session_state.processing = True
    st.session_state.processing_chat_id = st.session_state.active_chat_id


def process_assistant_response() -> bool:
    """
    Process the assistant's response to the last user message.
    
    Returns:
        bool: True if processing was successful, False otherwise
    """
    if not st.session_state.processing:
        return False
    
    if st.session_state.processing_chat_id != st.session_state.active_chat_id:
        return False
    
    active_chat = st.session_state.chats[st.session_state.active_chat_id]
    
    try:
        # Check if we have a user message to respond to
        if not active_chat["messages"] or active_chat["messages"][-1]["role"] != "user":
            st.session_state.processing = False
            st.session_state.processing_chat_id = None
            return False
            
        # Create a unique response ID based on the last user message
        last_user_msg = active_chat["messages"][-1]
        response_id = f"{st.session_state.processing_chat_id}_{last_user_msg['id']}"
        
        # Skip if we've already processed this response
        if response_id in st.session_state.completed_responses:
            st.session_state.processing = False
            st.session_state.processing_chat_id = None
            return False
        
        # Get the full response at once (non-streaming)
        response = cached_llm_response(
            active_chat["selected_provider"], 
            active_chat["selected_model"], 
            active_chat["messages"], 
            st.session_state.api_keys
        )
        
        # Add assistant response to history
        message_id = time.time()  # Use timestamp as a unique message ID
        active_chat["messages"].append({"role": "assistant", "content": response, "id": message_id})
        
        # Mark this response as completed to prevent duplicates
        st.session_state.completed_responses.add(response_id)
        
        # Save to persistent storage
        save_chats(st.session_state.chats, st.session_state.chat_counter)
        
        return True
        
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
        
        # Log the error
        print(f"Error in LLM response: {str(e)}")
        return False
    finally:
        # Set processing to False ONLY for the current processing_chat_id
        if st.session_state.processing_chat_id == st.session_state.active_chat_id:
            st.session_state.processing = False
            st.session_state.processing_chat_id = None


def get_chat_list_data() -> List[Tuple[str, Dict]]:
    """
    Get the list of chats data without any UI elements.
    
    Returns:
        List[Tuple[str, Dict]]: List of (chat_id, chat_data) tuples
    """
    # Make a deep copy of the data to avoid modifying the original
    chat_items = [(chat_id, chat_data.copy()) for chat_id, chat_data in st.session_state.chats.items()]
    
    # Sort the items to ensure consistent ordering
    def sort_key(item):
        chat_id = item[0]
        # Extract number from chat_id if exists (e.g., chat_5 -> 5)
        import re
        match = re.search(r'(\d+)', chat_id)
        if match:
            return int(match.group(1))
        return chat_id
        
    return sorted(chat_items, key=sort_key)


def get_visible_messages(active_chat: Dict[str, Any]) -> List[Dict[str, Any]]:
    """
    Get the visible messages from the chat.
    
    Args:
        active_chat: The active chat data
        
    Returns:
        List[Dict[str, Any]]: List of visible messages
    """
    MAX_VISIBLE_MESSAGES = 20
    messages = active_chat.get("messages", [])
    if len(messages) > MAX_VISIBLE_MESSAGES:
        return messages[-MAX_VISIBLE_MESSAGES:]
    return messages 