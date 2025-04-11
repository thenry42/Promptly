<div align="center">
  <img src="promptly-logo.png" alt="Promptly Logo" width="200"/>
</div>

<div align="center">
  <p>
    <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker"/>
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
    <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python"/>
    <img src="https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white" alt="OpenAI"/>
    <img src="https://img.shields.io/badge/Ollama-412991?style=for-the-badge&logo=llama&logoColor=white" alt="Ollama"/>
    <img src="https://img.shields.io/badge/Anthropic-412991?style=for-the-badge&logo=anthropic&logoColor=white" alt="Anthropic"/>
    <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
    <img src="https://img.shields.io/badge/DeepSeek-412991?style=for-the-badge&logo=deepseek&logoColor=white" alt="DeepSeek"/>
    <img src="https://img.shields.io/badge/Mistral-412991?style=for-the-badge&logo=mistral&logoColor=white" alt="Mistral"/>
    <img src="https://img.shields.io/badge/Gemini-412991?style=for-the-badge&logo=gemini&logoColor=white" alt="Gemini"/>
  </p>
</div>

# What is Promptly ?

Promptly is a flutter app that allows you to chat with LLMs from multiple providers in a single place.

## Overview

This simple project provides a convenient way to communicate with various AI language models from OpenAI, Anthropic, and Ollama, etc - all from one application. Simply configure your API keys and start chatting with your preferred AI assistants.

## Features

- Multiple AI provider support for chat & text generation
- Easy API key configuration (keys are encrypted and stored locally using the flutter SecureStorage package)
- Chat history is automatically saved between app launches

## Roadmap

- [x] Add support for OpenAI models
- [x] Add support for Anthropic models
- [x] Add support for Ollama (most models work out of the box)
- [x] Add support for DeepSeek models
- [x] Add support for Mistral models
- [x] Add support for Gemini models
- [ ] Ship the app on Mac, Linux, and Windows
- [ ] Add support for tool calling
- [ ] Add support for image input
- [ ] Add support for audio generation
- [ ] Add support for image generation

## Getting Started (Development Installation)

> This app is currently in development on Linux (Nobara 40). I'm working on adding support for other platforms, but it's not ready yet. I have not tested the app on any other platforms.

### Install Flutter & Docker

1. Install [Flutter/Dart](https://docs.flutter.dev/get-started/install)
2. Run `flutter doctor` and install the missing dependencies for your device if any.
3. Install [Docker](https://docs.docker.com/get-docker/)
4. Run `make build` to build the Docker containers

### Install Promptly

1. Clone the repository

```bash
git clone https://github.com/thenry42/Promptly.git
cd Promptly
```

2. Install dependencies

```bash
cd frontend && flutter pub get
```

3. Run the application

```bash
cd .. && ./run.sh
```

> **Note:** You can add the desktop file to your applications menu to start the application faster. You need to adjust the Exec path to match your local path.

## Configuration

To use this application, you'll need to provide API keys for the LLM services you want to access:

1. Create an account with your preferred LLM providers (OpenAI, Anthropic, etc.)
2. Generate API keys from each provider's dashboard
3. Add the API keys to the application's configuration

## Privacy & Security

- All API keys are encrypted at rest using the flutter FlutterSecureStorage package
- All data is stored locally on the device
- Conversations may be processed by the respective LLM providers according to their privacy policies
- I cannot guarantee any misuses of API usage by the application. I personally use it at my own risk and so should you. I haven't add any issue so far but I would recommend to add API credits by small amounts to avoid any issues (recharge credits 5$ by 5$). Google does not provide that safety net, that's why I'm not using it.

## Licence

This project is licensed under the Unlicense. See the [LICENSE](LICENSE) file for details. Obviously, the licence only applies to the code I wrote, not the logos or materials that belong to their respective owners.

## Acknowledgements

- [OpenAI](https://openai.com)
- [Anthropic](https://anthropic.com)
- [Ollama](https://ollama.com)
- [DeepSeek](https://deepseek.com)
- [Mistral](https://mistral.ai)
- [Gemini](https://gemini.google.com)

## Disclaimer

This project is not affiliated with OpenAI, Anthropic, Ollama, DeepSeek, Mistral, Gemini. It is a single person project that also happens to be my first Flutter project. I personally use it as a tool to help me with my work and it's a good project for my portfolio. I do not claim to own any of the logos (or anything else for that matter) used in this project. All logos are property of their respective owners. Don't come after me with legal threats, nobody ain't got time for that. If you have any suggestions or feedback, please feel free to open an issue ! :smile: