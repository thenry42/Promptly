import ollama
import asyncio
import os
import requests

# Get Ollama host from environment or default to localhost
OLLAMA_HOST = os.environ.get("OLLAMA_HOST", "http://localhost:11434")

# Ollama client
def ollama_client():
    client = ollama.Client(host=OLLAMA_HOST)
    return client

# Ollama simple generation
def ollama_generation(model, prompt):
    client = ollama_client()
    response = client.generate(model=model, prompt=prompt)
    return response

# Ollama chat (no streaming)
def ollama_chat_non_stream(model, prompt):
    client = ollama_client()
    response = client.chat(
        model=model,
        messages=[{'role': 'user', 'content': prompt}]
    )
    return response

# Ollama chat (streaming)
async def ollama_chat_stream(model, prompt):
    client = ollama_client()
    stream = client.chat(
        model=model,
        messages=[{'role': 'user', 'content': prompt}],
        stream=True
    )
    return stream

# Ollama list models
def ollama_list_models():
    client = ollama_client()
    models = client.list()
    return models

# Ollama show details of a model
def ollama_show_model(model):
    client = ollama_client()
    return client.show(model)
