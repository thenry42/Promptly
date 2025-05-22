import sys
import time
import importlib
import streamlit as st
import concurrent.futures
from typing import List, Dict, Any
from .providers.llm_ollama import check_ollama, get_available_models_ollama, ollama_chat
from .providers.llm_deepseek import check_deepseek, get_available_models_deepseek, deepseek_chat
from .providers.llm_mistral import check_mistral, get_available_models_mistral, mistral_chat
from .providers.llm_anthropic import check_anthropic, get_available_models_anthropic, anthropic_chat
from .providers.llm_openai import check_openai, get_available_models_openai, openai_chat
from .providers.llm_gemini import check_gemini, get_available_models_gemini, gemini_chat


def get_provider_state(provider, api_keys):
    """Check if a provider is available with the given API key."""
    try:
        if provider == "Ollama":
            return get_available_models_ollama(api_keys["ollama"]) is not None
        if provider == "Deepseek":
            return len(api_keys["deepseek"]) > 0
        if provider == "Mistral":
            return len(api_keys["mistral"]) > 0
        if provider == "Anthropic":
            return len(api_keys["anthropic"]) > 0
        if provider == "OpenAI":
            return len(api_keys["openai"]) > 0
        if provider == "Gemini":
            return len(api_keys["gemini"]) > 0
    except Exception:
        return False
    return False


@st.cache_data(ttl=300)  # Cache provider availability for 5 minutes
def get_available_providers(api_keys):
    """Get a list of available providers based on API keys."""
    providers = ["OpenAI", "Anthropic", "Gemini", "Mistral", "Deepseek", "Ollama"]
    available_providers = []
    
    # Use multithreading to check providers concurrently
    with concurrent.futures.ThreadPoolExecutor() as executor:
        # Create a future for each provider check
        future_to_provider = {
            executor.submit(get_provider_state, provider, api_keys): provider
            for provider in providers
        }
        
        # Process results as they complete
        for future in concurrent.futures.as_completed(future_to_provider):
            provider = future_to_provider[future]
            try:
                is_available = future.result()
                if is_available:
                    available_providers.append(provider)
            except Exception as e:
                print(f"Error checking provider {provider}: {str(e)}")
    
    return available_providers


def get_available_models(provider, api_keys):
    """Get available models for the specified provider."""
    try:
        if provider == "Ollama":
            return get_available_models_ollama(api_keys["ollama"])
        if provider == "Deepseek":
            return get_available_models_deepseek(api_keys["deepseek"])
        if provider == "Mistral":
            return get_available_models_mistral(api_keys["mistral"])
        if provider == "Anthropic":
            return get_available_models_anthropic(api_keys["anthropic"])
        if provider == "OpenAI":
            return get_available_models_openai(api_keys["openai"])
        if provider == "Gemini":
            return get_available_models_gemini(api_keys["gemini"])
    except Exception as e:
        print(f"Error getting models for {provider}: {str(e)}")
    return []


@st.cache_data(ttl=15, show_spinner=False)  # Further reduced TTL to 15 seconds
def get_llm_response(provider, model, messages, api_keys, chat_id=None):
    """Get a response from the specified LLM provider and model with caching."""
    # Extract chat_id from session state if not provided
    if chat_id is None and 'active_chat_id' in st.session_state:
        chat_id = st.session_state.active_chat_id
    
    # Create a request identifier based on the last user message
    request_id = None
    for msg in reversed(messages):
        if msg["role"] == "user" and "id" in msg:
            request_id = f"{chat_id}_{msg['id']}"
            break
    
    # Create a cache-friendly representation of messages
    cache_messages = []
    for msg in messages:
        if msg["role"] != "system":  # Exclude system messages from the cache key
            cache_messages.append({
                "role": msg["role"],
                "content": msg["content"]
            })
    
    # Get API key
    api_key = api_keys[provider.lower()]
    
    # Time the response
    start_time = time.time()
    
    try:
        # Get response from appropriate provider
        if provider == "Ollama":
            response = ollama_chat(model, messages, api_key)
        elif provider == "Deepseek":
            response = deepseek_chat(model, messages, api_key)
        elif provider == "Mistral":
            response = mistral_chat(model, messages, api_key)
        elif provider == "Anthropic":
            response = anthropic_chat(model, messages, api_key)
        elif provider == "OpenAI":
            response = openai_chat(model, messages, api_key)
        elif provider == "Gemini":
            response = gemini_chat(model, messages, api_key)
        else:
            return f"Error: Unknown provider {provider}"
        
        # Log response time for performance monitoring
        elapsed_time = time.time() - start_time
        print(f"{provider} ({model}) response time: {elapsed_time:.2f} seconds")
        
        return response
    except Exception as e:
        error_message = f"Error: {str(e)}"
        print(f"LLM error with {provider} ({model}): {error_message}")
        return error_message


def get_llm_response_streaming(provider, model, messages, api_keys):
    """Get a streaming response from the specified LLM provider and model."""
    return []
