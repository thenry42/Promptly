import ollama

def query_ollama(prompt):
    # Create a chat stream with the specified model
    stream = ollama.chat(
        model='llama3.1',  # Specify the model you want to use
        messages=[{'role': 'user', 'content': prompt}],  # Use the user prompt
        stream=True,  # Enable streaming
    )

    # Print the streamed response
    for chunk in stream:
        # Print each chunk's content without a newline, and flush the output
        print(chunk['message']['content'], end='', flush=True)

if __name__ == "__main__":
    # Example prompt to send to the Ollama model
    user_prompt = "Why is the sky blue?"

    # Query the Ollama API and print the response
    print("Response from Ollama:", end=' ')
    query_ollama(user_prompt)