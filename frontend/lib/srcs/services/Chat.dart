import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/services/Singleton.dart';
import 'ChatMessage.dart';

class Chat
{
  // ATTRIBUTES -------------------------------------------

  int id;
  late AssetImage icon;
  String modelName; 
  String type;
  
  bool isHovered = false;
  bool isSelected = false;
  bool isSendingRequest = false;
  List <ChatMessage> messages = [];

  int? max_output_tokens = 1024;
  bool? support_tool_calling;

  // CONSTRUCTOR ------------------------------------------

  Chat({required this.id, required this.modelName, required this.type, isSelected})
  {
    // Set the icon based on the provider type instead of model name
    switch (type) {
      case 'Gemini':
        icon = const AssetImage('assets/images/gemini.png');
        break;
      case 'Mistral':
        icon = const AssetImage('assets/images/mistral.png');
        break;
      case 'DeepSeek':
        icon = const AssetImage('assets/images/deepseek.png');
        break;
      case 'Ollama':
        icon = const AssetImage('assets/images/ollama.png');
        break;
      case 'OpenAI':
        icon = const AssetImage('assets/images/openai.png');
        break;
      case 'Anthropic':
        icon = const AssetImage('assets/images/anthropic.png');
        break;
      default:
        icon = const AssetImage('assets/images/error.png');
    }
    
    // Set isSelected if provided
    if (isSelected != null) {
      this.isSelected = isSelected;
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
    final maxTokens = metadata.chatList[metadata.selectedChatIndex].max_output_tokens ?? 4096;

    isSendingRequest = true;

    try {
      List<Map<String, String>> formattedMessages = [];
      for (var msg in messageList) {
        formattedMessages.add({
          'role': msg.sender.toLowerCase(),
          'content': msg.message,
        });
      }

      Map<String, dynamic> response;
      String content = "";

      if (type == "Ollama") {
        response = await metadata.backendService.ollamaCompletionRequest(
          modelName: modelName,
          messages: formattedMessages,
        );
      } 
      else if (type == "OpenAI") {
        final apiKey = metadata.openAIKey;
        
        if (apiKey.isEmpty) {
          throw Exception('OpenAI API key is not set');
        }
        
        response = await metadata.backendService.openaiCompletionRequest(
          modelName: modelName,
          messages: formattedMessages,
          apiKey: apiKey,
        );
      }
      else if (type == "DeepSeek") {
        final apiKey = metadata.deepseekKey;
        
        if (apiKey.isEmpty) {
          throw Exception('DeepSeek API key is not set');
        }
        
        response = await metadata.backendService.deepseekCompletionRequest(
          modelName: modelName,
          messages: formattedMessages,
          apiKey: apiKey,
        );

        print(response);
      }
      else if (type == "Mistral") {
        final apiKey = metadata.mistralKey;
        
        if (apiKey.isEmpty) {
          throw Exception('Mistral API key is not set');
        }
        
        response = await metadata.backendService.mistralCompletionRequest(
          modelName: modelName,
          messages: formattedMessages,
          apiKey: apiKey,
        );
        
        // Print the full response for debugging
        print("Full Mistral response: $response");
        
        // Check for error in response
        if (response.containsKey('error')) {
          throw Exception('Mistral API error: ${response['error']}');
        }
        
        // Extract content from Mistral response
        if (response.containsKey('choices') && 
            response['choices'] is List && 
            response['choices'].isNotEmpty) {
          
          final assistantMessage = response['choices'][0]['message'];
          if (assistantMessage != null && assistantMessage.containsKey('content')) {
            content = assistantMessage['content'];
          } else {
            throw Exception('Invalid Mistral response format: missing message content');
          }
        } else {
          throw Exception('Invalid Mistral response format: missing choices array');
        }
      }
      else if (type == "Anthropic") {
        final apiKey = metadata.anthropicKey;
        
        if (apiKey.isEmpty) {
          throw Exception('Anthropic API key is not set');
        }
        
        response = await metadata.backendService.anthropicCompletionRequest(
          modelName: modelName,
          messages: formattedMessages,
          apiKey: apiKey,
          maxTokens: maxTokens,
        );
        
        // Print the full response for debugging
        print("Full Anthropic response: $response");
        
        // Check for error in response
        if (response.containsKey('error')) {
          throw Exception('Anthropic API error: ${response['error']}');
        }
        
        // Extract content from Anthropic response
        if (response.containsKey('choices') && 
            response['choices'] is List && 
            response['choices'].isNotEmpty) {
          
          final assistantMessage = response['choices'][0]['message'];
          if (assistantMessage != null && assistantMessage.containsKey('content')) {
            content = assistantMessage['content'];
          } else {
            throw Exception('Invalid Anthropic response format: missing message content');
          }
        } else {
          throw Exception('Invalid Anthropic response format: missing choices array');
        }
      }
      else {
        throw Exception('Unsupported model provider: $type');
      }
      
      // We've extracted the content, now add it to the chat
      if (content.isNotEmpty) {
        addChatMessage(ChatMessage(
          sender: 'assistant',
          message: content,
          timestamp: DateTime.now(),
          rawMessage: response,
        ));
      } else {
        throw Exception('Failed to extract content from response');
      }
      
    } catch (e) {
      print('Error generating message request: $e');
      addChatMessage(ChatMessage(
        sender: 'system',
        message: 'Error: Could not generate a response. $e',
        timestamp: DateTime.now(),
        rawMessage: {'error': e.toString()},
      ));
    } finally {
      isSendingRequest = false;
      // Save chats after generating a message
      await metadata.saveChats(); 
    }
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
