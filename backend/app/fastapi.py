# Handle the FastAPI app
from fastapi import FastAPI
from app.ollama_ import ollama_client
from app.anthropic_ import anthropic_list_models
from pydantic import BaseModel

app = FastAPI()

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
def list_openai_models():
    return {"message": "OpenAI models list"}

@app.get("/deepseek/models/list")
def list_deepseek_models():
    return {"message": "DeepSeek models list"}

@app.get("/mistral/models/list")
def list_mistral_models():
    return {"message": "Mistral models list"}

@app.get("/gemini/models/list")
def list_gemini_models():
    return {"message": "Gemini models list"}

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
