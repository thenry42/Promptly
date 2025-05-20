from google import genai


def check_gemini(api_key):
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
    try:
        client = genai.Client(api_key=api_key)
        models = client.models.list()
        return [model.name for model in models]
    except Exception as e:
        return []

def gemini_chat(model, message, api_key):
    try:
        client = genai.Client(api_key=api_key)

        gemini_content = []
        if message:
            # Convert the message history into a text representation that Gemini can understand
            conversation_text = ""
            for msg in message:
                role = msg["role"]
                content = msg["content"]
                
                # Format each message with a clear role indicator
                if role == "user":
                    conversation_text += f"User: {content}\n\n"
                elif role == "assistant":
                    conversation_text += f"Assistant: {content}\n\n"
            
            # Add the conversation history to the content
            gemini_content.append(conversation_text)


        response = client.models.generate_content(
            model=model,
            contents=gemini_content,
        )
        return response.text
    except Exception as e:
        return "Error: " + str(e)
