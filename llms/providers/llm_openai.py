import openai
import time


def check_openai(api_key):
    """ Check if the OpenAI API key is valid """
    if not api_key:
        return False
        
    try:
        client = openai.OpenAI(api_key=api_key, timeout=5.0)  # Add timeout
        models = client.models.list()
        return True if [model.id for model in models] else False
    except Exception as e:
        print(f"OpenAI API check error: {str(e)}")
        return False


def get_available_models_openai(api_key):
    """ Get the available models for the OpenAI API """
    if not api_key:
        return []
        
    try:
        client = openai.OpenAI(api_key=api_key, timeout=5.0)  # Add timeout
        models = client.models.list()
        # Filter to include only GPT models for better performance
        gpt_models = [model.id for model in models if 
                     "gpt" in model.id.lower() or 
                     "dall-e" in model.id.lower() or
                     "dall-3" in model.id.lower()]
        return gpt_models
    except Exception as e:
        print(f"OpenAI list models error: {str(e)}")
        return []


def openai_chat(model, messages, api_key):
    """ Send a chat request to OpenAI and get the response WITHOUT streaming """
    if not api_key:
        return "Error: OpenAI API key is missing"
    
    try:
        start_time = time.time()
        client = openai.OpenAI(api_key=api_key, timeout=60.0)  # 60 second timeout
        
        # Format messages properly for OpenAI
        formatted_messages = []
        for msg in messages:
            if msg.get("role") and msg.get("content"):
                formatted_messages.append({
                    "role": msg["role"],
                    "content": msg["content"]
                })
        
        # Set reasonable defaults to improve performance
        response = client.chat.completions.create(
            model=model,
            messages=formatted_messages,
            stream=False,
            temperature=0.7,
            max_tokens=1024,
            timeout=60  # 60 seconds timeout
        )
        
        elapsed = time.time() - start_time
        print(f"OpenAI API call completed in {elapsed:.2f} seconds")
        
        return response.choices[0].message.content
    except openai.APITimeoutError:
        return "Error: The request to OpenAI timed out. Please try again."
    except openai.APIConnectionError:
        return "Error: Failed to connect to OpenAI API. Please check your internet connection."
    except openai.AuthenticationError:
        return "Error: Authentication with OpenAI failed. Please check your API key."
    except openai.RateLimitError:
        return "Error: OpenAI rate limit exceeded. Please try again later."
    except Exception as e:
        return f"Error: {str(e)}"


def get_openai_streaming(model, message, api_key):
    """Get a streaming response from the specified LLM provider and model."""
    try:
        client = openai.OpenAI(api_key=api_key)
        
        # Filter out 'id' field from messages to prevent API errors
        filtered_messages = []
        for msg in message:
            filtered_msg = {
                "role": msg["role"],
                "content": msg["content"]
            }
            filtered_messages.append(filtered_msg)
        
        stream = client.chat.completions.create(
            model=model,
            messages=filtered_messages,
            stream=True
        )
        
        # Internal buffering mechanism for smoother streaming
        buffer = ""
        min_yield_size = 5  # Only yield when we have at least 5 characters
        last_yield_time = time.time()
        max_buffer_time = 0.1  # Yield at least every 100ms even if buffer is small
        
        # Process each chunk with buffering logic
        for chunk in stream:
            if chunk.choices[0].delta.content:
                buffer += chunk.choices[0].delta.content
            current_time = time.time()
            time_since_last_yield = current_time - last_yield_time
            
            # Yield when buffer reaches threshold OR if max time has passed since last yield
            if len(buffer) >= min_yield_size or time_since_last_yield >= max_buffer_time:
                yield buffer
                buffer = ""
                last_yield_time = current_time
        
        # Yield any remaining text in buffer
        if buffer:
            yield buffer

    except Exception as e:
        error_msg = f"Error with OpenAI streaming: {str(e)}"
        print(error_msg)  # Log the error
        yield error_msg