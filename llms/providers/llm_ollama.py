import ollama
import time
import requests


def check_ollama(port):
    """
    Check if Ollama is running and accessible on the specified port.
    Returns True if available, False otherwise.
    """
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
    """
    Get available Ollama models.
    Returns a list of model names or empty list if error occurs.
    """
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
    """
    Send a chat request to Ollama and get the response.
    Handles errors and timeouts gracefully.
    """
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
