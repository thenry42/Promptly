import sys
import time
import importlib
import streamlit as st
import concurrent.futures
from typing import List, Dict, Any, Optional, Tuple, Callable


# Import provider modules
from .providers.llm_ollama import check_ollama, get_available_models_ollama, ollama_chat, get_ollama_streaming
from .providers.llm_deepseek import check_deepseek, get_available_models_deepseek, deepseek_chat, get_deepseek_streaming
from .providers.llm_mistral import check_mistral, get_available_models_mistral, mistral_chat, get_mistral_streaming
from .providers.llm_anthropic import check_anthropic, get_available_models_anthropic, anthropic_chat, get_anthropic_streaming
from .providers.llm_openai import check_openai, get_available_models_openai, openai_chat, get_openai_streaming
from .providers.llm_gemini import check_gemini, get_available_models_gemini, gemini_chat, get_gemini_streaming

# Define provider mappings for cleaner code
PROVIDER_CONFIGS = {
    "Ollama": {
        "key_name": "ollama",
        "check_func": check_ollama,
        "models_func": get_available_models_ollama,
        "chat_func": ollama_chat,
        "streaming_func": get_ollama_streaming,
        "requires_key": False,  # Ollama just needs a port, not an API key
    },
    "Deepseek": {
        "key_name": "deepseek",
        "check_func": check_deepseek,
        "models_func": get_available_models_deepseek,
        "chat_func": deepseek_chat,
        "streaming_func": get_deepseek_streaming,
        "requires_key": True,
    },
    "Mistral": {
        "key_name": "mistral",
        "check_func": check_mistral,
        "models_func": get_available_models_mistral,
        "chat_func": mistral_chat,
        "streaming_func": get_mistral_streaming,
        "requires_key": True,
    },
    "Anthropic": {
        "key_name": "anthropic",
        "check_func": check_anthropic,
        "models_func": get_available_models_anthropic,
        "chat_func": anthropic_chat,
        "streaming_func": get_anthropic_streaming,
        "requires_key": True,
    },
    "OpenAI": {
        "key_name": "openai",
        "check_func": check_openai,
        "models_func": get_available_models_openai,
        "chat_func": openai_chat,
        "streaming_func": get_openai_streaming,
        "requires_key": True,
    },
    "Gemini": {
        "key_name": "gemini",
        "check_func": check_gemini,
        "models_func": get_available_models_gemini,
        "chat_func": gemini_chat,
        "streaming_func": get_gemini_streaming,
        "requires_key": True,
    }
}


def get_provider_state(provider: str, api_keys: Dict[str, str]) -> bool:
    """
    Check if a provider is available with the given API key.
    
    Args:
        provider: Name of the provider to check
        api_keys: Dictionary of API keys
        
    Returns:
        bool: True if provider is available, False otherwise
    """
    try:
        if provider not in PROVIDER_CONFIGS:
            return False
            
        config = PROVIDER_CONFIGS[provider]
        key_name = config["key_name"]
        
        # For providers requiring a key, check if key exists
        if config["requires_key"] and not api_keys.get(key_name):
            return False
            
        # For Ollama specifically, check if models are available
        if provider == "Ollama":
            return get_available_models_ollama(api_keys[key_name]) is not None
            
        # For others, just check if the API key is provided
        return len(api_keys[key_name]) > 0
    except Exception as e:
        print(f"Error checking provider {provider}: {str(e)}")
        return False


@st.cache_data(ttl=300)
def get_available_providers(api_keys: Dict[str, str]) -> List[str]:
    """
    Get a list of available providers based on API keys.
    
    Args:
        api_keys: Dictionary of API keys
        
    Returns:
        List[str]: List of available provider names
    """
    providers = list(PROVIDER_CONFIGS.keys())
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


def get_available_models(provider: str, api_keys: Dict[str, str]) -> List[str]:
    """
    Get available models for the specified provider.
    
    Args:
        provider: Name of the provider
        api_keys: Dictionary of API keys
        
    Returns:
        List[str]: List of available model names
    """
    try:
        if provider not in PROVIDER_CONFIGS:
            return []
            
        config = PROVIDER_CONFIGS[provider]
        key_name = config["key_name"]
        models_func = config["models_func"]
        
        return models_func(api_keys[key_name])
    except Exception as e:
        print(f"Error getting models for {provider}: {str(e)}")
        return []


def get_llm_response(
    provider: str, 
    model: str, 
    messages: List[Dict[str, Any]], 
    api_keys: Dict[str, str], 
    chat_id: Optional[str] = None
) -> str:
    """
    Get a response from the specified LLM provider and model.
    
    Args:
        provider: Name of the provider
        model: Name of the model
        messages: List of message dictionaries
        api_keys: Dictionary of API keys
        chat_id: Optional chat ID for caching
        
    Returns:
        str: The LLM response text
    """
    # Extract chat_id from session state if not provided
    if chat_id is None and 'active_chat_id' in st.session_state:
        chat_id = st.session_state.active_chat_id
    
    # Get API key
    if provider not in PROVIDER_CONFIGS:
        return f"Error: Unknown provider {provider}"
        
    config = PROVIDER_CONFIGS[provider]
    key_name = config["key_name"]
    chat_func = config["chat_func"]
    api_key = api_keys[key_name]
    
    # Time the response
    start_time = time.time()
    
    try:
        # Get response from provider
        response = chat_func(model, messages, api_key)
        
        # Log response time for performance monitoring
        elapsed_time = time.time() - start_time
        print(f"{provider} ({model}) response time: {elapsed_time:.2f} seconds")
        
        return response
    except Exception as e:
        error_message = f"Error: {str(e)}"
        print(f"LLM error with {provider} ({model}): {error_message}")
        return error_message


# Add a cached version for use from the UI
@st.cache_data(ttl=15, show_spinner=False)
def cached_llm_response(
    provider: str, 
    model: str, 
    messages: List[Dict[str, Any]], 
    api_keys: Dict[str, str], 
    chat_id: Optional[str] = None
) -> str:
    """
    Cached version of get_llm_response to improve performance.
    
    This function has the same parameters as get_llm_response but includes caching.
    """
    return get_llm_response(provider, model, messages, api_keys, chat_id)


def get_llm_response_streaming(
    provider: str, 
    model: str, 
    messages: List[Dict[str, Any]], 
    api_keys: Dict[str, str]
) -> List[str]:
    """
    Get a streaming response from the specified LLM provider and model.
    
    Args:
        provider: Name of the provider
        model: Name of the model
        messages: List of message dictionaries
        api_keys: Dictionary of API keys
        
    Returns:
        List[str]: List of response chunks
    """
    # For now, implement a basic simulation of streaming
    # In a real implementation, we would use the streaming APIs of each provider
    
    if provider not in PROVIDER_CONFIGS:
        yield f"Error: Unknown provider {provider}"
        return
        
    config = PROVIDER_CONFIGS[provider]
    key_name = config["key_name"]
    streaming_func = config["streaming_func"]
    api_key = api_keys[key_name]
    
    try:
        # Get the full response first (this is a temporary solution)
        full_response = streaming_func(model, messages, api_key)
        
        # Break it into chunks to simulate streaming
        # In a real implementation, we would use the actual streaming APIs
        # This is just for demonstration purposes
        chunk_size = 10  # Characters per chunk
        
        for i in range(0, len(full_response), chunk_size):
            chunk = full_response[i:i+chunk_size]
            yield chunk
            time.sleep(0.05)  # Small delay to simulate streaming
            
    except Exception as e:
        error_message = f"Error: {str(e)}"
        print(f"LLM streaming error with {provider} ({model}): {error_message}")
        yield error_message


# Add a cached version for use from the UI
@st.cache_data(ttl=15, show_spinner=False)
def cached_get_llm_response_streaming(
    provider: str, 
    model: str, 
    messages: List[Dict[str, Any]], 
    api_keys: Dict[str, str]
):
    """
    Cached version of get_llm_response_streaming to improve performance.
    
    Note: We can't directly cache a generator, so we'll return the generator itself.
    """
    # Generators can't be cached directly, so we'll return the generator function
    return get_llm_response_streaming(provider, model, messages, api_keys)
