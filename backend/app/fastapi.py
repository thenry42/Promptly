# Handle the FastAPI app
from fastapi import FastAPI
from app.ollama_ import ollama_client
from app.anthropic_ import anthropic_list_models
from app.openai_ import openai_list_models
from app.mistral_ import mistral_list_models
from app.gemini_ import gemini_list_models
from app.deepseek_ import deepseek_list_models
from pydantic import BaseModel

app = FastAPI()

class OllamaChatCompletionRequest(BaseModel):
    model: str
    messages: list
    max_tokens: int | None = None
    temperature: float = 0.7
    stream: bool = False

class OllamaRequest(BaseModel):
    model: str
    prompt: str

class AnthropicRequest(BaseModel):
    api_key: str
    model: str
    prompt: str

class OpenAIRequest(BaseModel):
    api_key: str
    model: str
    prompt: str

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

"""
@app.post("/completion")
def completion(request: OllamaRequest):
    try:
        client = ollama_client()
        response = client.chat(
            model = request.model,
            messages = [
                {"role": "user", "content": request.prompt}
            ]
        )
        return {"completion": response}
    except Exception as e:
        return {"error": str(e)}
"""
