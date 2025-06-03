import os
import json
import streamlit as st


def ensure_data_directory():
    """Ensure the data directory and history file exist"""
    os.makedirs("data", exist_ok=True)
    if not os.path.exists("data/history.json"):
        with open("data/history.json", "w") as f:
            json.dump({"chats": {}, "chat_counter": 0}, f, indent=2)


@st.cache_data(ttl=60)
def load_history():
    """ Load chat history from JSON file and cache it for 1 minute """
    ensure_data_directory()
    if os.path.exists("data/history.json"):
        with open("data/history.json", "r") as f:
            return json.load(f)
    else:
        return {}


def save_history(history):
    """ Save chat history to JSON file and clear the cache """
    ensure_data_directory()
    with open("data/history.json", "w") as f:
        json.dump(history, f, indent=2)
    load_history.clear()


def save_chats(chats, chat_counter):
    """ Save the current chats and chat counter to history """
    history = {
        "chats": chats,
        "chat_counter": chat_counter
    }
    save_history(history)


def load_chats():
    """Load saved chats and chat counter from history"""
    history = load_history()
    return history.get("chats", {}), history.get("chat_counter", 0)


def add_message(chat_id, message, chats):
    """Add a message to a specific chat and save the updated chats"""
    if chat_id in chats:
        chats[chat_id]["messages"].append(message)
        save_chats(chats, len(chats))
    return chats


def show_history():
    """ Display the chat history in Streamlit UI """
    st.header("Conversation History")
    chats_data = get_cached_chat_history()
    display_chat_history(chats_data)


@st.cache_data(ttl=30)
def get_cached_chat_history():
    """ Cached function to get chat history data and cache it for 30s """
    chats, _ = load_chats()
    return chats


def display_chat_history(chats):
    """ Display function for chat history - cannot be cached """
    if not chats:
        st.info("No saved conversations found.")
        return
    for chat_id, chat_data in chats.items():
        st.subheader(chat_data.get("title", f"Chat {chat_id}"))
        for message in chat_data.get("messages", []):
            if message["role"] != "system":
                role_display = f"**{message['role'].capitalize()}:**"
                st.write(f"{role_display} {message['content']}")
        st.divider()
