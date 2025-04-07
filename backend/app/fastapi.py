# Handle the FastAPI app
from fastapi import FastAPI
from app.ollama_ import ollama_client
from pydantic import BaseModel

app = FastAPI()

class CompletionRequest(BaseModel):
    model: str
    prompt: str

@app.get("/")
def read_root():
    return {"message": "Hello, World!"}

@app.get("/models")
def list_models():
    try:
        client = ollama_client()
        models = client.list()
        return models
    except Exception as e:
        return {"error": str(e)}

@app.post("/completion")
def completion(request: CompletionRequest):
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