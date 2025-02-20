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
      claude = Anthropic(apiKey: metadata.anthropicKey!, model: model);
      icon = const AssetImage('assets/images/anthropic.png');
    } else if (type == "Ollama") {
      vicugna = Ollama(model: modelName);
      icon = const AssetImage('assets/images/ollama.png');
    } else if (type == "OpenAI") {
      gepeto = OpenAI(apiKey: metadata.openAIKey!, model: modelName);
      icon = const AssetImage('assets/images/openai.png');
    } else {
      debugPrint("Error: Unknown model [0]");
    }
  }

  // METHODS ----------------------------------------------

  void addChatMessage(ChatMessage chat_message) {
    messages.add(chat_message);
    // Save after each new message
    Singleton().saveChats();
  }

  void removeChatMessage(ChatMessage chat_message) {
    messages.remove(chat_message);
  }

  Future<void> generateMessageRequest({required Singleton metadata}) async {
    final index = metadata.selectedChatIndex;
    final messageList = metadata.chatList[metadata.selectedChatIndex].messages;
    final maxTokens = metadata.chatList[metadata.selectedChatIndex].max_output_tokens;

    ChatMessage? response;
    try {
      if (type == "Anthropic") {
        response = await claude.generateAnthropicMessageRequest(messageList: messageList, maxTokens: maxTokens!);
      } else if (type == "Ollama") {
        response = await vicugna.generateOllamaMessageRequest(messageList: messageList, maxTokens: maxTokens!);
      } else if (type == "OpenAI") {
        response = await gepeto.generateOpenAIMessageRequest(messageList: messageList, maxTokens: maxTokens!);
      } else {
        debugPrint("Error: Unknown model [1]");
        return;
      }

      if (response != null) {
        metadata.chatList[index].addChatMessage(response);
        // Save after AI response
        metadata.saveChats();
      }
    } catch (e) {
      debugPrint("Error generating message: $e");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelName': modelName,
      'type': type,
      'isSelected': isSelected,
      'isSendingRequest': isSendingRequest,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'max_output_tokens': max_output_tokens,
      'support_tool_calling': support_tool_calling,
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    Chat chat = Chat(
      id: json['id'],
      modelName: json['modelName'],
      type: json['type'],
      isSelected: json['isSelected'],
    );
    
    chat.isSendingRequest = json['isSendingRequest'] ?? false;
    chat.max_output_tokens = json['max_output_tokens'];
    chat.support_tool_calling = json['support_tool_calling'];
    
    // Load messages
    if (json['messages'] != null) {
      chat.messages = (json['messages'] as List)
          .map((msgJson) => ChatMessage.fromJson(msgJson))
          .toList();
    }
    
    return chat;
  }
}
