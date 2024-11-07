from flask import Flask, request, jsonify
from flask_cors import CORS
import ollama

app = Flask(__name__)
CORS(app)  # Allow CORS for all domains

@app.route('/api/chat', methods=['POST'])
def chat():
    data = request.json
    user_prompt = data.get('message')

    # Create a chat stream with the specified model
    stream = ollama.chat(
        model='llama3.1',  # Specify the model you want to use
        messages=[{'role': 'user', 'content': user_prompt}],  # Use the user prompt
        stream=True,  # Enable streaming
    )

    # Collect the response chunks
    response_content = ""
    for chunk in stream:
        response_content += chunk['message']['content']

    # Return the response as JSON
    return jsonify({'response': response_content})

if __name__ == "__main__":
    app.run(debug=True)