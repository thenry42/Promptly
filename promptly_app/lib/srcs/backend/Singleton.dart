import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Chat.dart';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropicsdk;
import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'package:dart_openai/dart_openai.dart' as openai;

class Singleton {

  // ATTRIBUTES -------------------------------------------

  String? anthropicKey;
  String? openAIKey;
  List<Chat> chatList = [];
  late List<anthropicsdk.Model> anthropic_models = [];
  late List<ollama.Model> ollama_models = [];
  late List<openai.OpenAIModelModel> openai_models = [];
  late List<String> modelsName = [];
  int selectedChatIndex = 0;
  final List<VoidCallback> _chatSelectionListeners = [];

  double fontSize = 20;
  String fontFamily = 'roboto';

  // CONSTRUCTOR ------------------------------------------

  static final Singleton _instance = Singleton._internal();
  factory Singleton() {
    return _instance;
  } 
  Singleton._internal();

  // METHODS ----------------------------------------------

  Future<void> getAnthropicModels() async {
    // For the time being, the list of Anthropic model is hard-coded
    // TO DO: Fetch the list of models from the json file
    List<anthropicsdk.Model> models = const [
      anthropicsdk.Model.modelId('claude-3-5-sonnet-latest'),
      anthropicsdk.Model.modelId('claude-3-5-haiku-latest'),
      anthropicsdk.Model.modelId('claude-3-opus-latest'),
    ];
    anthropic_models = models;
  }

  Future<void> getOllamaModels() async {
    try {

      final client = ollama.OllamaClient();
      final response = await client.listModels();
      ollama_models = response.models!.toList();

    } catch (e) {
      if (kDebugMode) {
        print('Error fetching ollama models: $e');
      }
    }
  }

  Future<void> getOpenAIModels() async {
    try {
      
      openai.OpenAI.apiKey = openAIKey!;
      openai_models = await openai.OpenAI.instance.model.list();

    } catch (e) {
      if (kDebugMode) {
        print('Error fetching openAI models: $e');
      }
    }
  }

  Future<void> getModels() async {
    await getAnthropicModels();
    await getOllamaModels();
    await getOpenAIModels();
  }

  Future<void> getModelsName() async {
    for (int i = 0; i < anthropic_models.length; i++) {
      modelsName.add(anthropic_models[i].value.toString());
    }
    for (int i = 0; i < ollama_models.length; i++) {
      modelsName.add(ollama_models[i].model!);
    }
    for (int i = 0; i < openai_models.length; i++) {
      modelsName.add(openai_models[i].id);
    }
  }

  Future<void> getAPIKeys() async {
    if (openAIKey == null || anthropicKey == null) {
      await dotenv.load();
      openAIKey = dotenv.env['OPEN_AI_API_KEY'];
      anthropicKey = dotenv.env['ANTHROPIC_API_KEY'];
    }
  }

  void addChat(Chat chat) {
    chatList.add(chat);
  }

  void removeChat(Chat chat) {
    chatList.remove(chat);
  }

  void addChatSelectionListener(VoidCallback listener) {
    _chatSelectionListeners.add(listener);
  }

  void removeChatSelectionListener(VoidCallback listener) {
    _chatSelectionListeners.remove(listener);
  }

  void setSelectedChatIndex(int index) {
    selectedChatIndex = index;
    // Notify all listeners when chat selection changes
    for (final listener in _chatSelectionListeners) {
      listener();
    }
  }
}