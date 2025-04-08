import openai

BASE_URL = "https://api.deepseek.com"

def deepseek_client(api_key):
    """Create a DeepSeek client with the given API key."""
    client = openai.OpenAI(api_key=api_key, base_url=BASE_URL)
    return client

def deepseek_list_models(api_key):
    """List available DeepSeek models."""
    client = deepseek_client(api_key)
    models = client.models.list()
    return models