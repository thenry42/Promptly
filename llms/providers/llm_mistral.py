import mistralai
import time


def check_mistral(api_key):
    """ Check if the Mistral API key is valid """
    try:
        client = mistralai.Mistral(api_key=api_key)
        models = client.models.list()
        res = [model.id for model in models.data]
        if res is not None:
            return True
        else:
            return False
    except Exception as e:
        return False


def get_available_models_mistral(api_key):
    """ Get the available models for the Mistral API """
    res = []
    try:
        client = mistralai.Mistral(api_key=api_key)
        models = client.models.list()
        res = [model.id for model in models.data]
    except Exception as e:
        return []
    return res


def mistral_chat(model, message, api_key):
    """ Send a chat request to Mistral and get the response WITHOUT streaming """
    try:
        # Filter out 'id' field from messages to prevent API errors
        filtered_messages = []
        for msg in message:
            filtered_msg = {
                "role": msg["role"],
                "content": msg["content"]
            }
            filtered_messages.append(filtered_msg)
            
        with mistralai.Mistral(api_key=api_key) as mistral:
            response = mistral.chat.complete(
                model=model,
                messages=filtered_messages,
            )
            return response.choices[0].message.content
    except Exception as e:
        return "Error: " + str(e)


def get_mistral_streaming(model, message, api_key):
    """Get a streaming response from the specified LLM provider and model."""
    try:
        # Filter out 'id' field from messages to prevent API errors
        filtered_messages = []
        for msg in message:
            filtered_msg = {
                "role": msg["role"],
                "content": msg["content"]
            }
            filtered_messages.append(filtered_msg)
        
        with mistralai.Mistral(api_key=api_key) as mistral:
            stream = mistral.chat.stream(
                model=model,
                messages=filtered_messages,
            )
        
            # Internal buffering mechanism for smoother streaming
            buffer = ""
            min_yield_size = 5  # Only yield when we have at least 5 characters
            last_yield_time = time.time()
            max_buffer_time = 0.1  # Yield at least every 100ms even if buffer is small

            with stream as event_stream:
                for event in event_stream:
                    if event.data.choices[0].delta.content:
                        buffer += event.data.choices[0].delta.content

                    current_time = time.time()
                    time_since_last_yield = current_time - last_yield_time
                
                    # Yield when buffer reaches threshold OR if max time has passed since last yield
                    if len(buffer) >= min_yield_size or time_since_last_yield >= max_buffer_time:
                        yield buffer
                        buffer = ""
                        last_yield_time = current_time 
                
                # Yield any remaining text in buffer after loop completes
                if buffer:
                    yield buffer

    except Exception as e:
        error_msg = f"Error with Mistral streaming: {str(e)}"
        print(error_msg)  # Log the error
        yield error_msg