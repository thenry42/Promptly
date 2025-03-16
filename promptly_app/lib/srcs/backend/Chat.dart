import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/backend/Anthropic.dart';
import 'package:promptly_app/srcs/backend/Ollama.dart';
import 'package:promptly_app/srcs/backend/OpenAI.dart';
import 'package:promptly_app/srcs/backend/Singleton.dart';
import 'ChatMessage.dart';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropicsdk;
import 'package:dart_openai/dart_openai.dart' as openai;

class Chat
{
  // ATTRIBUTES -------------------------------------------

  int id;
  AssetImage icon;
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

  Chat({required this.id, required this.modelName, required this.type, isSelected}) : 
    icon = const AssetImage('assets/images/anthropic.png') {
    var metadata = Singleton();
    if (type == "Anthropic") {
      anthropicsdk.Model model = anthropicsdk.Model.modelId(modelName);
      claude = Anthropic(model: model);
      icon = const AssetImage('assets/images/anthropic.png');
    } else if (type == "Ollama") {
      vicugna = Ollama(model: modelName);
      icon = const AssetImage('assets/images/ollama.png');
    } else if (type == "OpenAI") {
      gepeto = OpenAI(model: modelName);
      icon = const AssetImage('assets/images/openai.png');
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

    // Save chats after generating a message
    await metadata.saveChats();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon.toString(),
      'modelName': modelName,
      'type': type,
      'isHovered': isHovered,
      'isSelected': isSelected,
      'isSendingRequest': isSendingRequest,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'max_output_tokens': max_output_tokens,
      'support_tool_calling': support_tool_calling,
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      modelName: json['modelName'],
      type: json['type'],
      isSelected: json['isSelected'],
    )..messages = (json['messages'] as List<dynamic>)
        .map((msgJson) => ChatMessage.fromJson(msgJson as Map<String, dynamic>))
        .toList();
  }
}
