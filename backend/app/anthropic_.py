import anthropic

def anthropic_client(api_key):
    """Create an Anthropic client with the given API key."""
    client = anthropic.Anthropic(api_key=api_key)
    return client

def anthropic_list_models(api_key):
    """List available Anthropic models."""
    client = anthropic_client(api_key)
    models = client.models.list()
    return models
