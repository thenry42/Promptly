import openai


def check_deepseek(api_key):
    """ Check if the Deepseek API key is valid """
    try:
        res = []
        client = openai.OpenAI(api_key=api_key, base_url="https://api.deepseek.com")
        models = client.models.list()
        res = [model.id for model in models]
        if res is not None:
            return True
        else:
            return False
    except Exception as e:
        return False


def get_available_models_deepseek(api_key):
    """ Get the available models for the Deepseek API """
    res = []
    try:
        client = openai.OpenAI(api_key=api_key, base_url="https://api.deepseek.com")
        models = client.models.list()
        res = [model.id for model in models]
    except Exception as e:
        return []
    return res


def deepseek_chat(model, message, api_key):
    """ Send a chat request to Deepseek and get the response WITHOUT streaming """
    try:
        client = openai.OpenAI(api_key=api_key, base_url="https://api.deepseek.com")
        
        # Filter out 'id' field from messages to prevent API errors
        filtered_messages = []
        for msg in message:
            filtered_msg = {
                "role": msg["role"],
                "content": msg["content"]
            }
            filtered_messages.append(filtered_msg)
            
        response = client.chat.completions.create(
            model=model,
            messages=filtered_messages,
            stream=False
        )
        return response.choices[0].message.content
    except Exception as e:
        return "Error: " + str(e)


def get_deepseek_streaming(model, message, api_key):
    """Get a streaming response from the specified LLM provider and model."""
    return []
