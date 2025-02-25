# What is Promptly ?

Promptly is a flutter app that allows you to chat with LLMs from multiple providers in a single place.

## Overview

This simple project provides a convenient way to communicate with various AI language models from OpenAI, Anthropic, and Ollama - all from one application. Simply configure your API keys and start chatting with your preferred AI assistants.

## Features

- Multiple provider support (OpenAI, Anthropic, Ollama)
- Easy API key configuration (keys are encrypted and stored locally using the flutter SecureStorage package)
- Chat history is automatically saved between app launches

## Roadmap

- [x] Add support for OpenAI (gpt-4o, chatgpt-4o-latest, gpt-4o-mini, o1-mini, gpt-4o-realtime-preview, gpt-4o-mini-realtime-preview)
- [x] Add support for Anthropic (claude-3-5-sonnet-latest, claude-3-7-sonnet-latest, claude-3-5-haiku-latest, claude-3-opus-latest)
- [x] Add support for Ollama (most models work out of the box)
- [ ] Add support for DeepSeek
- [ ] Ship the app on Mac, Linux, and Windows
- [ ] Add support for tool calling
- [ ] Add support for image input
- [ ] Add support for audio generation
- [ ] Add support for image generation

## Getting Started (Development Installation)

> Note: This app is currently in development on Linux (Nobara 40). I'm working on adding support for other platforms, but it's not ready yet. I have not tested the app on any other platforms.

1. Clone the repository
2. Run `cd promptly_app`
3. Run `flutter pub get`
4. Run `flutter run`

## Configuration

To use this application, you'll need to provide API keys for the LLM services you want to access:

1. Create an account with your preferred LLM providers (OpenAI, Anthropic, etc.)
2. Generate API keys from each provider's dashboard
3. Add the API keys to the application's configuration

## Privacy & Security

- All API keys are encrypted at rest using the flutter FlutterSecureStorage package
- All data is stored locally on the device
- Conversations may be processed by the respective LLM providers according to their privacy policies

## Licence

This project is licensed under the Unlicense. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [OpenAI](https://openai.com)
- [Anthropic](https://anthropic.com)
- [Ollama](https://ollama.com)

## Disclaimer

This project is not affiliated with OpenAI, Anthropic, or Ollama. It is a single person project that also happens to be my first Flutter project. I do not claim to own any of the logos (or anything else for that matter) used in this project. All logos are property of their respective owners. Don't come after me with legal threats, nobody ain't got time for that. If you have any suggestions or feedback, please feel free to open an issue ! :smile: