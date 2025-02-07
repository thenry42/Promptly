import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/backend/Anthropic.dart';
import 'package:promptly_app/srcs/backend/Ollama.dart';
import 'package:promptly_app/srcs/backend/OpenAI.dart';
import 'package:promptly_app/srcs/backend/Singleton.dart';
import 'ChatMessage.dart';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropicsdk;

class Chat
{
  // ATTRIBUTES -------------------------------------------

  int id;
  late Icon icon;
  String modelName;
  
  String type;
  late Anthropic claude;
  late Ollama vicugna;
  late OpenAI gepeto;
  
  bool isHovered = false;
  bool isSelected = false;
  bool isSendingRequest = false;
  List <ChatMessage> messages = [];

  int? max_output_tokens = 1024;
  bool? support_tool_calling;

  // CONSTRUCTOR ------------------------------------------

  Chat({required this.id, required this.modelName, required this.type, isSelected}) {
    var metadata = Singleton();
    if (type == "Anthropic") {
      anthropicsdk.Model model = anthropicsdk.Model.modelId(modelName);
      claude = Anthropic(apiKey: metadata.anthropicKey!, model: model);
    } else if (type == "Ollama") {
      vicugna = Ollama(model: modelName);
    } else if (type == "OpenAI") {
      gepeto = OpenAI(apiKey: metadata.openAIKey!, model: modelName);
    } else {
      debugPrint("Error: Unknown model [0]");
    }
  }

  // METHODS ----------------------------------------------

  void addChatMessage(ChatMessage chat_message) {
    messages.add(chat_message);
  }

  void removeChatMessage(ChatMessage chat_message) {
    messages.remove(chat_message);
  }

  Future<void> generateMessageRequest({required Singleton metadata}) async {
    
    final index = metadata.selectedChatIndex;
    final messageList = metadata.chatList[metadata.selectedChatIndex].messages;
    final maxTokens = metadata.chatList[metadata.selectedChatIndex].max_output_tokens;

    if (type == "Anthropic") {
      ChatMessage response = await claude.generateAnthropicMessageRequest(messageList: messageList, maxTokens: maxTokens!);
      metadata.chatList[index].addChatMessage(response);
    } else if (type == "Ollama") {
      ChatMessage response = await vicugna.generateOllamaMessageRequest(messageList: messageList, maxTokens: maxTokens!);
      metadata.chatList[index].addChatMessage(response);
    } else if (type == "OpenAI") {
      ChatMessage response = await gepeto.generateOpenAIMessageRequest(messageList: messageList, maxTokens: maxTokens!);
      metadata.chatList[index].addChatMessage(response);
    } else {
      debugPrint("Error: Unknown model [1]");
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
