import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/backend/Anthropic.dart';
import 'package:promptly_app/srcs/backend/Ollama.dart';
import 'package:promptly_app/srcs/backend/OpenAI.dart';
import 'package:promptly_app/srcs/backend/Singleton.dart';
import 'ChatMessage.dart';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropicsdk;
import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'package:dart_openai/dart_openai.dart' as openai;

class Chat
{
  // ATTRIBUTES -------------------------------------------

  int id;
  String title;
  late Icon icon;
  Object model;
  bool isHovered = false;
  bool isSelected = false;
  bool isSendingRequest = false;
  List <ChatMessage> messages = [];

  int? max_output_tokens;
  bool? support_tool_calling;

  // CONSTRUCTOR ------------------------------------------

  Chat({required this.id, required this.title, required this.model}) {
    var metadata = Singleton();
    if (model == anthropicsdk.Model) {
      model = Anthropic(apiKey: metadata.anthropicKey!);
    } else if (model == ollama.Model) {
      model = Ollama();
    } else if (model == openai.OpenAIModelModel) {
      model = OpenAI(apiKey: metadata.openAIKey!);
    } else {
      debugPrint("Error: Unknown model");
    }
  }

  // METHODS ----------------------------------------------

  void addChatMessage(ChatMessage chat_message) {
    messages.add(chat_message);
  }

  void removeChatMessage(ChatMessage chat_message) {
    messages.remove(chat_message);
  }

  Future<void> generateMessageRequest() async {
    if (model == anthropicsdk.Model) {
      ChatMessage response = model.generateAnthropicMessageRequest();
      addChatMessage(response);
    } else if (model == ollama.Model) {
      ChatMessage response = model.generateOllamaMessageRequest();
      addChatMessage(response);
    } else if (model == openai.OpenAIModelModel) {
      ChatMessage response = model.generateOpenAIMessageRequest();
      addChatMessage(response);
    } else {
      debugPrint("Error: Unknown model");
    }
  }

  // TO DO:
  // SendMessage()
  // AutoScrollToBottom()
  // generateMessageRequest()
  // generateStreamRequest()
  // fetchModelDetails()
  // getModelIcon()

}