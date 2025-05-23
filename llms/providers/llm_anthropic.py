import anthropic
import random
import time


def check_anthropic(api_key):
    """ Check if the Anthropic API key is valid """
    try:
        client = anthropic.Anthropic(api_key=api_key)
        models = client.models.list()
        res = [model.id for model in models]
        if res is not None:
            return True
        else:
            return False
    except Exception as e:
        return False


def get_available_models_anthropic(api_key):
    """ Get the available models for the Anthropic API """
    try:
        client = anthropic.Anthropic(api_key=api_key)
        models = client.models.list()
        return [model.id for model in models]
    except Exception as e:
        return []


def anthropic_chat(model, message, api_key):
    """ Send a chat request to Anthropic and get the response WITHOUT streaming """
    try:
        client = anthropic.Anthropic(api_key=api_key)
        
        # Filter out 'id' field from messages to prevent API errors
        filtered_messages = []
        for msg in message:
            filtered_msg = {
                "role": msg["role"],
                "content": msg["content"]
            }
            filtered_messages.append(filtered_msg)
        
        response = client.messages.create(
            max_tokens=4096,
            model=model,
            messages=filtered_messages,
            stream=False
        )
        return response.content[0].text
    except Exception as e:
        return "Error: " + str(e)


def get_anthropic_streaming(model, message, api_key):
    """Get a streaming response from the specified LLM provider and model."""
    try:
        client = anthropic.Anthropic(api_key=api_key)
        
        # Filter out 'id' field from messages to prevent API errors
        filtered_messages = []
        for msg in message:
            filtered_msg = {
                "role": msg["role"],
                "content": msg["content"]
            }
            filtered_messages.append(filtered_msg)
        
        stream = client.messages.create(
            max_tokens=4096,
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
            # Handle different types of chunks from Anthropic API
            if hasattr(chunk, 'type'):
                # Handle content block deltas (the main text chunks)
                if chunk.type == 'content_block_delta' and hasattr(chunk, 'delta'):
                    if hasattr(chunk.delta, 'text') and chunk.delta.text:
                        # Add to buffer instead of yielding directly
                        buffer += chunk.delta.text
                
                # Handle content block start events (could contain initial text)
                elif chunk.type == 'content_block_start' and hasattr(chunk, 'content_block'):
                    if hasattr(chunk.content_block, 'text') and chunk.content_block.text:
                        # Add to buffer instead of yielding directly
                        buffer += chunk.content_block.text
            
            # Check if we should yield the buffer contents
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
        error_msg = f"Error with Anthropic streaming: {str(e)}"
        print(error_msg)  # Log the error
        yield error_msg
