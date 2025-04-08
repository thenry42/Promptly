import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/services/Singleton.dart';
import 'ChatMessage.dart';

class Chat
{
  // ATTRIBUTES -------------------------------------------

  int id;
  AssetImage? icon;
  String modelName; 
  String type;
  
  bool isHovered = false;
  bool isSelected = false;
  bool isSendingRequest = false;
  List <ChatMessage> messages = [];

  int? max_output_tokens = 1024;
  bool? support_tool_calling;

  // CONSTRUCTOR ------------------------------------------

  Chat({required this.id, required this.modelName, required this.type, isSelected}); 

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
