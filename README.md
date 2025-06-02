<div align="center">
   <img src="assets/logo.png" alt="Promptly Logo" width="500">
</div>

<div align="center">
  <p>
    <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python"/>
    <img src="https://img.shields.io/badge/Streamlit-FF4500?style=for-the-badge&logo=streamlit&logoColor=white" alt="Streamlit"/>
    <img src="https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white" alt="OpenAI"/>
    <img src="https://img.shields.io/badge/Ollama-412991?style=for-the-badge&logo=llama&logoColor=white" alt="Ollama"/>
    <img src="https://img.shields.io/badge/Anthropic-412991?style=for-the-badge&logo=anthropic&logoColor=white" alt="Anthropic"/>
    <img src="https://img.shields.io/badge/DeepSeek-412991?style=for-the-badge&logo=deepseek&logoColor=white" alt="DeepSeek"/>
    <img src="https://img.shields.io/badge/Mistral-412991?style=for-the-badge&logo=mistral&logoColor=white" alt="Mistral"/>
    <img src="https://img.shields.io/badge/Gemini-412991?style=for-the-badge&logo=gemini&logoColor=white" alt="Gemini"/>
  </p>
</div>

# Promptly - Optimized Chat Interface for Multiple AI Models

Promptly is an optimized Streamlit application that provides a unified chat interface for multiple AI models and providers.

## Features

- **Multi-Provider Support**: Interact with various AI providers including OpenAI, Anthropic, Mistral, Ollama, DeepSeek, and Gemini
- **Multiple Chat Sessions**: Create and manage multiple chat sessions with different models
- **Persistent Conversations**: Chat history is saved between sessions for seamless continuation
- **Responsive UI**: Clean and user-friendly interface with optimized rendering

## Getting Started

### Prerequisites

- Python 3.8+
- API keys for the LLM providers you want to use

### Installation

1. Clone the repository
2. Install dependencies:

```
pip install -r requirements.txt
```

### Running the Application

For the best performance, use the provided script:

```bash
./run.sh
```

Or run directly with Streamlit (as long as you have all the dependencies installed):

```bash
streamlit run Chat.py
```

### Optional: Create a Desktop Shortcut

1. Adjust the `Exec` and `Icon` paths in the `promptly.desktop` file to match your installation.
2. Copy the `promptly.desktop` file to your `~/.local/share/applications` directory.
3. Run `chmod +x ~/.local/share/applications/promptly.desktop` to make the file executable.
4. Reboot (probably not necessary, but just in case)
5. The app should now be available in your applications menu, and you can run it from there and pin it to your desktop dashboard.
6. If you want to see the commands running in the terminal, you can put `Terminal=true` in the `promptly.desktop` file.

### Configuration

1. Go to the "Settings" page
2. Enter your API keys for the providers you want to use
3. Save the settings

## Usage Tips for Optimal Performance

- Keep chat history reasonable in size for better performance
- For local models (Ollama), ensure your system has adequate resources
- Use the "New Chat" button to start fresh conversations
- Save API keys for faster startup in future sessions

## License

This project is licensed under the UNLICENSE. See the [LICENSE](LICENSE) file for details.

## Disclaimer

This project is not affiliated with OpenAI, Anthropic, Ollama, DeepSeek, Mistral, Gemini. It is a single person project. I personally use it as a tool to help me with my work and it's a good project for my portfolio. I do not claim to own any of the logos (or anything else for that matter) used in this project. All logos are property of their respective owners. Don't come after me with legal threats, nobody ain't got time for that. If you have any suggestions or feedback, please feel free to open an issue ! :smile:
