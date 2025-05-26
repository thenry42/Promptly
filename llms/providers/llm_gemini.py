from google import genai
import time


def check_gemini(api_key):
    """ Check if the Gemini API key is valid """
    try:
        client = genai.Client(api_key=api_key)
        models = client.models.list()
        res = [model.name for model in models]
        if res is not None:
            return True
        else:
            return False
    except Exception as e:
        return False


def get_available_models_gemini(api_key):
    """ Get the available models for the Gemini API """
    try:
        client = genai.Client(api_key=api_key)
        models = client.models.list()
        return [model.name for model in models]
    except Exception as e:
        return []


def gemini_chat(model, message, api_key):
    """ Send a chat request to Gemini and get the response WITHOUT streaming """
    try:
        client = genai.Client(api_key=api_key)

        # Prepare the content for Gemini
        # Convert the message history into a text representation
        conversation_text = ""
        for msg in message:
            role = msg["role"]
            content = msg["content"]
            
            # Format each message with a clear role indicator
            if role == "user":
                conversation_text += f"User: {content}\n\n"
            elif role == "assistant":
                conversation_text += f"Assistant: {content}\n\n"
        
        # Pass the formatted text to the Gemini API
        response = client.models.generate_content(
            model=model,
            contents=conversation_text,
        )
        return response.text
    except Exception as e:
        return "Error: " + str(e)


def get_gemini_streaming(model, message, api_key):
    """Get a streaming response from the specified LLM provider and model."""
    try:
        client = genai.Client(api_key=api_key)
        
        # Convert the message history into a text representation
        conversation_text = ""
        for msg in message:
            role = msg["role"]
            content = msg["content"]
            
            # Format each message with a clear role indicator
            if role == "user":
                conversation_text += f"User: {content}\n\n"
            elif role == "assistant":
                conversation_text += f"Assistant: {content}\n\n"
        
        # Create the streaming request using the API method
        stream = client.models.generate_content_stream(
            model=model,
            contents=conversation_text,
        )
        
        # Internal buffering mechanism for smoother streaming
        buffer = ""
        min_yield_size = 5  # Only yield when we have at least 5 characters
        last_yield_time = time.time()
        max_buffer_time = 0.1  # Yield at least every 100ms even if buffer is small
        
        # Process each chunk with buffering logic
        for chunk in stream:
            if hasattr(chunk, "text") and chunk.text:
                buffer += chunk.text
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
        error_msg = f"Error with Gemini streaming: {str(e)}"
        print(error_msg)  # Log the error
        yield error_msg 
