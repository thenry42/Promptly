import ollama
import time
import requests


def check_ollama(port):
    """ Check if Ollama is running and accessible on the specified port """
    if not port:
        return False
        
    try:
        # Use a short timeout for the connection check
        client = ollama.Client(host=f"http://localhost:{port}")
        models = client.list()
        return bool(models and models.get("models"))
    except (requests.exceptions.ConnectionError, ConnectionRefusedError):
        print(f"Ollama connection error: Could not connect to localhost:{port}")
        return False
    except Exception as e:
        print(f"Ollama check error: {str(e)}")
        return False


def get_available_models_ollama(port):
    """ Get available Ollama models """
    if not port:
        return []
        
    try:
        client = ollama.Client(host=f"http://localhost:{port}")
        models = client.list()
        
        if not models or not models.get("models"):
            return []
            
        return [model["model"] for model in models["models"]]
    except Exception as e:
        print(f"Ollama list models error: {str(e)}")
        return []


def ollama_chat(model, messages, port):
    """ Send a chat request to Ollama and get the response WITHOUT streaming """
    if not port:
        return "Error: Ollama port is not specified"
        
    try:
        start_time = time.time()
        client = ollama.Client(host=f"http://localhost:{port}")
        
        # Format messages for Ollama if needed
        formatted_messages = []
        for msg in messages:
            if msg.get("role") and msg.get("content"):
                formatted_messages.append({
                    "role": msg["role"],
                    "content": msg["content"]
                })
        
        # Set a timeout for the response
        response = client.chat(
            model=model, 
            messages=formatted_messages,
            stream=False,
            options={
                "num_predict": 1024,  # Limit token generation
                "temperature": 0.7
            },
        )
        
        elapsed = time.time() - start_time
        print(f"Ollama API call completed in {elapsed:.2f} seconds")
        
        return response.message.content
    except requests.exceptions.Timeout:
        return "Error: The request to Ollama timed out. Please try again."
    except requests.exceptions.ConnectionError:
        return "Error: Failed to connect to Ollama. Please check if Ollama is running."
    except Exception as e:
        return f"Error: {str(e)}"


def get_ollama_streaming(model, message, port):
    """Get a streaming response from the specified LLM provider and model."""
    try:
        client = ollama.Client(host=f"http://localhost:{port}")
        
        # Filter out 'id' field from messages to prevent API errors
        filtered_messages = []
        for msg in message:
            filtered_msg = {
                "role": msg["role"],
                "content": msg["content"]
            }
            filtered_messages.append(filtered_msg)
        
        stream = client.chat(
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
            if "message" in chunk and "content" in chunk["message"]:
                buffer += chunk["message"]["content"]
            elif "response" in chunk:
                buffer += chunk["response"]
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
        error_msg = f"Error with Ollama streaming: {str(e)}"
        print(error_msg)  # Log the error
        yield error_msg