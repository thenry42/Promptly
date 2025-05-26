import streamlit as st
from typing import List, Dict, Any, Callable
from pathlib import Path
import base64


def render_message(role: str, content: str) -> Dict[str, str]:
    """
    Render a chat message with appropriate styling.
    
    Args:
        role: The role of the message sender (user or assistant)
        content: The message content
        
    Returns:
        Dict: A dictionary with role and content
    """
    return {"role": role, "content": content}


@st.cache_data(ttl=3)
def render_chat_header(provider: str, model: str) -> str:
    """
    Render the chat header with styling.
    
    Args:
        provider: The name of the provider
        model: The name of the model
        
    Returns:
        str: HTML-formatted header
    """
    return f"<h3 style='color:#FAFAFA; background-color:#484955; padding:10px; border-radius:10px'>{provider} - {model}</h3>"


def display_messages(messages: List[Dict[str, Any]], exclude_last_assistant: bool = False) -> None:
    """
    Display a list of chat messages in the UI.
    
    Args:
        messages: List of message dictionaries with role, content, and id
        exclude_last_assistant: If True, exclude the last assistant message (used during streaming)
    """
    # Filter messages if needed
    messages_to_show = messages.copy()
    
    if exclude_last_assistant and messages_to_show:
        # Remove the last message if it's from assistant
        if messages_to_show[-1]["role"] == "assistant":
            messages_to_show = messages_to_show[:-1]
    
    for message in messages_to_show:
        if message["role"] != "system":
            with st.chat_message(message["role"]):
                st.markdown(message["content"])


def render_model_selection(
    active_chat: Dict[str, Any], 
    available_providers: List[str],
    get_models_func: Callable[[str], List[str]],
    on_start_chat: Callable[[str, str], None]
) -> None:
    """
    Render the model selection UI for starting a new chat.
    
    Args:
        active_chat: The active chat data
        available_providers: List of available providers
        get_models_func: Function to get models for a provider
        on_start_chat: Callback function when starting a chat
    """
    st.title("Create New Chat")
    
    try:
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
            # Get available models for the selected provider
            with st.spinner(f"Loading {provider} models..."):
                models = get_models_func(provider)
            
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
            
            # Only show the button if provider and model are selected
            if provider and model:
                if st.button("Start Chat", type="primary"):
                    on_start_chat(provider, model)
                    
    except Exception as e:
        st.error(f"Error loading providers: {str(e)}")


def render_sidebar(
    chats: Dict[str, Any],
    active_chat_id: str,
    on_select_chat: Callable[[str], None],
    on_new_chat: Callable[[], None],
    on_delete_chat: Callable[[str], None]
) -> None:
    """
    Render the sidebar with chat list and management buttons.
    
    Args:
        chats: Dictionary of all chats
        active_chat_id: ID of the active chat
        on_select_chat: Callback when selecting a chat
        on_new_chat: Callback when creating a new chat
        on_delete_chat: Callback when deleting a chat
    """
    st.markdown("""
    <h1 style='text-align: center;'>LLM Chats</h1>
    """, unsafe_allow_html=True)
    
    # Create a new chat button
    if st.button("New Chat", use_container_width=True, type="secondary"):
        on_new_chat()
    
    # Display existing chats
    if not chats:
        st.info("No chats yet. Create a new chat to get started!")
        return
    
    # Sort chats to ensure consistent ordering
    def sort_key(item):
        chat_id = item[0]
        # Extract number from chat_id if exists (e.g., chat_5 -> 5)
        import re
        match = re.search(r'(\d+)', chat_id)
        if match:
            return int(match.group(1))
        return chat_id
        
    chat_items = sorted(chats.items(), key=sort_key)
    
    # Display chat list
    for chat_id, chat_data in chat_items:
        col1, col2 = st.columns([4, 1])
        
        # Chat title and selection
        with col1:
            button_color = "primary" if active_chat_id == chat_id else "secondary"
            if st.button(chat_data["title"], key=f"select_{chat_id}", use_container_width=True, type=button_color):
                on_select_chat(chat_id)
        
        # Delete button
        with col2:
            if st.button("🗑️", key=f"delete_{chat_id}", help="Delete this chat"):
                on_delete_chat(chat_id)


def apply_theme() -> None:
    """Apply custom CSS styling to the app."""
    st.markdown("""
    <style>
    .stButton button {
        border-radius: 8px;
    }

    /* Minimal styling for dark theme compatibility */
    div[data-testid="stChatMessageContent"] p {
        color: #FAFAFA;
    }
    </style>
    """, unsafe_allow_html=True)


def render_chat_header():
    # Function to convert image to base64
    def img_to_base64(img_path):
        with open(img_path, "rb") as img_file:
            return base64.b64encode(img_file.read()).decode('utf-8')
    
    # Get the base64 encoded image
    img_path = Path("assets/logo.png")
    img_base64 = img_to_base64(img_path)
    # CSS to add the centered logo to the sidebar header
    css = f"""
    <style>
        [data-testid="stSidebarHeader"] {{
            background-image: url("data:image/png;base64,{img_base64}");
            background-repeat: no-repeat;
            background-position: center 10px;  /* Center horizontally, 10px from top */
            background-size: 100px auto;
            padding-top: 60px;  /* Adjust as needed to create space under the logo */
        }}
    </style>
    """
    # Insert CSS at the beginning of your app
    st.markdown(css, unsafe_allow_html=True)
