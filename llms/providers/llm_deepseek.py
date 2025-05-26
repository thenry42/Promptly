import openai
import time

def check_deepseek(api_key):
    """ Check if the Deepseek API key is valid """
    try:
        res = []
        client = openai.OpenAI(api_key=api_key, base_url="https://api.deepseek.com")
        models = client.models.list()
        res = [model.id for model in models]
        if res is not None:
            return True
        else:
            return False
    except Exception as e:
        return False


def get_available_models_deepseek(api_key):
    """ Get the available models for the Deepseek API """
    res = []
    try:
        client = openai.OpenAI(api_key=api_key, base_url="https://api.deepseek.com")
        models = client.models.list()
        res = [model.id for model in models]
    except Exception as e:
        return []
    return res


def deepseek_chat(model, message, api_key):
    """ Send a chat request to Deepseek and get the response WITHOUT streaming """
    try:
        client = openai.OpenAI(api_key=api_key, base_url="https://api.deepseek.com")
        
        # Filter out 'id' field from messages to prevent API errors
        filtered_messages = []
        for msg in message:
            filtered_msg = {
                "role": msg["role"],
                "content": msg["content"]
            }
            filtered_messages.append(filtered_msg)
            
        response = client.chat.completions.create(
            model=model,
            messages=filtered_messages,
            stream=False
        )
        return response.choices[0].message.content
    except Exception as e:
        return "Error: " + str(e)


def get_deepseek_streaming(model, message, api_key):
    """Get a streaming response from the specified LLM provider and model."""
    try:
        client = openai.OpenAI(api_key=api_key, base_url="https://api.deepseek.com")
        
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
        error_msg = f"Error with Deepseek streaming: {str(e)}"
        print(error_msg)  # Log the error
        yield error_msg
