import openai

def openai_client(api_key):
    """Create an OpenAI client with the given API key."""
    client = openai.OpenAI(api_key=api_key)
    return client

def openai_list_models(api_key):
    """List available OpenAI models."""
    client = openai_client(api_key)
    models = client.models.list()
    return models
