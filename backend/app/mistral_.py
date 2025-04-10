import mistralai

def mistral_client(api_key):
    """Create a Mistral client with the given API key."""
    client = mistralai.Mistral(api_key=api_key)
    return client

def mistral_list_models(api_key):
    """List available Mistral models."""
    client = mistral_client(api_key)
    models = client.models.list()
    return models
