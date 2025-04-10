from google import genai

def gemini_client(api_key):
    """Create a Gemini client with the given API key."""
    client = genai.Client(api_key=api_key)
    return client

def gemini_list_models(api_key):
    """List available Gemini models."""
    client = gemini_client(api_key)
    models = client.models.list()
    return models
