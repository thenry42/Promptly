# Handle the FastAPI app
from fastapi import FastAPI
from app.ollama_ import ollama_client
from app.anthropic_ import anthropic_list_models
from app.openai_ import openai_list_models
from app.mistral_ import mistral_list_models
from app.gemini_ import gemini_list_models
from app.deepseek_ import deepseek_list_models
from pydantic import BaseModel
import time
import ftfy  # You'll need to install this: pip install ftfy

app = FastAPI()

class OllamaChatCompletionRequest(BaseModel):
    model: str
    messages: list
    stream: bool = False

class OllamaRequest(BaseModel):
    model: str
    prompt: str

class AnthropicRequest(BaseModel):
    api_key: str
    model: str
    prompt: str

class OpenAIChatCompletionRequest(BaseModel):
    model: str
    messages: list
    api_key: str
    stream: bool = False

class MistralRequest(BaseModel):
    api_key: str
    model: str
    prompt: str

class GeminiRequest(BaseModel):
    api_key: str
    model: str
    prompt: str

class DeepSeekRequest(BaseModel):
    api_key: str
    model: str
    prompt: str

class MistralChatCompletionRequest(BaseModel):
    model: str
    messages: list
    api_key: str
    stream: bool = False

class AnthropicChatCompletionRequest(BaseModel):
    model: str
    messages: list
    api_key: str
    max_tokens: int = 4096
    stream: bool = False

class GeminiChatCompletionRequest(BaseModel):
    model: str
    messages: list
    api_key: str
    stream: bool = False

@app.get("/")
def read_root():
    return {"message": "Hello, World!"}

@app.get("/ollama/models/list")
def list_ollama_models():
    try:
        client = ollama_client()
        models = client.list()
        return models
    except Exception as e:
        return {"error": str(e)}

@app.get("/anthropic/models/list")
def list_anthropic_models(api_key: str):
    """Get list of available Anthropic models."""
    try:
        return anthropic_list_models(api_key)
    except Exception as e:
        return {"error": str(e)}

@app.get("/openai/models/list")
def list_openai_models(api_key: str):
    try:
        return openai_list_models(api_key)
    except Exception as e:
        return {"error": str(e)}

@app.get("/deepseek/models/list")
def list_deepseek_models(api_key: str):
    try:
        return deepseek_list_models(api_key)
    except Exception as e:
        return {"error": str(e)}

@app.get("/mistral/models/list")
def list_mistral_models(api_key: str):
    try:
        return mistral_list_models(api_key)
    except Exception as e:
        return {"error": str(e)}

@app.get("/gemini/models/list")
def list_gemini_models(api_key: str):
    try:
        return gemini_list_models(api_key)
    except Exception as e:
        return {"error": str(e)}

@app.post("/ollama/chat/completions")
def ollama_chat_completion(request: OllamaChatCompletionRequest):
    try:
        client = ollama_client()
        
        # Prepare the request for Ollama
        request_params = {
            "model": request.model,
            "messages": request.messages,
        }
        
        # Stream is not implemented here, but could be added later
        
        # Call Ollama API
        response = client.chat(**request_params)
        
        # Format response similar to OpenAI's format
        return {
            "id": response.get("id", ""),
            "object": "chat.completion",
            "created": response.get("created", 0),
            "model": request.model,
            "choices": [
                {
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": response.get("message", {}).get("content", "")
                    },
                    "finish_reason": "stop"
                }
            ],
            "usage": response.get("usage", {})
        }
    except Exception as e:
        return {"error": str(e)}

@app.post("/openai/chat/completions")
def openai_chat_completion(request: OpenAIChatCompletionRequest):
    try:
        from openai import OpenAI
        
        # Initialize OpenAI client with the API key
        client = OpenAI(api_key=request.api_key)
        
        # Prepare the request parameters
        params = {
            "model": request.model,
            "messages": request.messages,
        }
        
        # Call OpenAI API
        response = client.chat.completions.create(**params)
        
        # Convert the response to a dict
        # For the newer OpenAI client library, we need to convert the response object to a dict
        if hasattr(response, 'model_dump'):
            response_dict = response.model_dump()
        else:
            # For backwards compatibility with older versions
            import json
            response_dict = json.loads(json.dumps(response, default=lambda o: o.__dict__))
        
        return response_dict
    except Exception as e:
        import traceback
        traceback.print_exc()
        return {"error": str(e)}

class DeepSeekChatCompletionRequest(BaseModel):
    model: str
    messages: list
    api_key: str
    stream: bool = False

@app.post("/deepseek/chat/completions")
def deepseek_chat_completion(request: DeepSeekChatCompletionRequest):
    try:
        from openai import OpenAI
        
        # Initialize OpenAI client with DeepSeek's base URL
        client = OpenAI(
            api_key=request.api_key,
            base_url="https://api.deepseek.com"
        )
        
        # Call DeepSeek API
        response = client.chat.completions.create(
            model=request.model,
            messages=request.messages,
            stream=request.stream
        )
        
        # Convert the response to a dict
        if hasattr(response, 'model_dump'):
            response_dict = response.model_dump()
        else:
            import json
            response_dict = json.loads(json.dumps(response, default=lambda o: o.__dict__))
        
        # Fix text encoding issues in the response
        if ('choices' in response_dict and 
            len(response_dict['choices']) > 0 and 
            'message' in response_dict['choices'][0] and 
            'content' in response_dict['choices'][0]['message']):
            
            # Get the content
            content = response_dict['choices'][0]['message']['content']
            
            # Fix text encoding using ftfy if content exists
            if content:
                fixed_content = ftfy.fix_text(content)
                response_dict['choices'][0]['message']['content'] = fixed_content
        
        return response_dict
    except Exception as e:
        import traceback
        traceback.print_exc()
        return {"error": str(e)}

@app.post("/mistral/chat/completions")
def mistral_chat_completion(request: MistralChatCompletionRequest):
    try:
        from mistralai import Mistral
        
        # Initialize Mistral client with API key
        client = Mistral(api_key=request.api_key)
        
        # Prepare the request parameters
        params = {
            "model": request.model,
            "messages": request.messages,
        }
        
        # Call Mistral API
        response = client.chat.complete(**params)
        
        # Print the response for debugging
        print("Raw Mistral response:", response)
        
        # Safely handle the usage info
        usage_info = {}
        if hasattr(response, 'usage'):
            try:
                # Try to access as a dictionary
                if isinstance(response.usage, dict):
                    usage_info = response.usage
                # Try to access as an object with attributes
                elif hasattr(response.usage, 'prompt_tokens'):
                    usage_info = {
                        'prompt_tokens': response.usage.prompt_tokens,
                        'completion_tokens': response.usage.completion_tokens,
                        'total_tokens': response.usage.total_tokens
                    }
            except Exception as usage_error:
                print(f"Error processing usage info: {usage_error}")
                # Provide default values if there's an error
                usage_info = {
                    'prompt_tokens': 0,
                    'completion_tokens': 0,
                    'total_tokens': 0
                }
        
        # Convert the response to a format similar to OpenAI's
        formatted_response = {
            "id": getattr(response, "id", f"mistral-{int(time.time())}"),
            "object": "chat.completion",
            "created": int(time.time()),
            "model": request.model,
            "choices": [
                {
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": response.choices[0].message.content
                    },
                    "finish_reason": "stop"
                }
            ],
            "usage": usage_info
        }
        
        return formatted_response
    except Exception as e:
        import traceback
        traceback.print_exc()
        return {"error": str(e)}

@app.post("/anthropic/chat/completions")
def anthropic_chat_completion(request: AnthropicChatCompletionRequest):
    try:
        from anthropic import Anthropic
        
        # Initialize Anthropic client with API key
        client = Anthropic(api_key=request.api_key)
        
        # Make the API call to Anthropic
        response = client.messages.create(
            model=request.model,
            max_tokens=request.max_tokens,
            messages=request.messages,
        )
        
        # Convert the response to a dictionary if possible
        try:
            import json
            response_dict = json.loads(json.dumps(response, default=lambda o: o.__dict__))
            print("Serialized response:", response_dict)
            
            # Format as OpenAI-like response
            formatted_response = {
                "id": response_dict.get("id", f"anthropic-{int(time.time())}"),
                "object": "chat.completion",
                "created": int(time.time()),
                "model": request.model,
                "choices": [
                    {
                        "index": 0,
                        "message": {
                            "role": "assistant",
                            "content": response_dict.get("content", [{}])[0].get("text", "")
                        },
                        "finish_reason": "stop"
                    }
                ],
                "usage": response_dict.get("usage", {})
            }
            
            return formatted_response
        except Exception as serialize_error:
            print(f"Error serializing response: {serialize_error}")
            
            # Fallback to accessing specific properties directly
            return {
                "id": getattr(response, "id", f"anthropic-{int(time.time())}"),
                "object": "chat.completion",
                "created": int(time.time()),
                "model": request.model,
                "choices": [
                    {
                        "index": 0,
                        "message": {
                            "role": "assistant",
                            "content": response.content[0].text
                        },
                        "finish_reason": "stop"
                    }
                ],
                "usage": {}  # Omit usage info rather than causing an error
            }
        
    except Exception as e:
        import traceback
        traceback.print_exc()
        return {"error": str(e)}

@app.post("/gemini/chat/completions")
def gemini_chat_completion(request: GeminiChatCompletionRequest):
    try:
        from google import genai
        
        # Initialize Gemini client with API key
        client = genai.Client(api_key=request.api_key)
        
        # Format messages for Gemini API
        contents = []
        for message in request.messages:
            role = message.get("role", "").lower()
            content = message.get("content", "")
            
            # Add the message content to the contents list
            contents.append(content)
        
        # Generate content using the model specified in the request
        response = client.models.generate_content(
            model=request.model,
            contents=contents
        )
        
        # Return in the format expected by frontend
        return {
            "id": f"gemini-{int(time.time())}",
            "object": "chat.completion",
            "created": int(time.time()),
            "model": request.model,
            "choices": [
                {
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": response.text
                    },
                    "finish_reason": "stop"
                }
            ]
        }
    except Exception as e:
        import traceback
        traceback.print_exc()
        return {"error": str(e)}