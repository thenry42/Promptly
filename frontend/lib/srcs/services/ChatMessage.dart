import 'package:flutter/foundation.dart';

class ChatMessage
{
  // ATTRIBUTES -------------------------------------------

  final String sender;
  final String message;
  final DateTime timestamp;
  final String rawMessage;
  
  bool useCustomMarkdown = true;  // Default to custom markdown
  bool useRaw = false;
  bool usePlainText = false;

  // CONSTRUCTOR ------------------------------------------

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.rawMessage
  }) {
    // Always default to custom markdown (code) mode regardless of sender
    useCustomMarkdown = true;
    useRaw = false;
    usePlainText = false;
  }

  // METHODS ----------------------------------------------

  void setFormat(String format) {
    useCustomMarkdown = false;
    useRaw = false;
    usePlainText = false;

    switch (format) {
      case 'custom':
        useCustomMarkdown = true;
        break;
      case 'raw':
        useRaw = true;
        break;
      case 'plain':
        usePlainText = true;
        break;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'rawMessage': rawMessage,
      'useCustomMarkdown': useCustomMarkdown,
      'useRaw': useRaw,
      'usePlainText': usePlainText,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'],
      message: json['message'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      rawMessage: json['rawMessage'],
    )
    // Force custom markdown to be true by default, ignoring saved values
    ..useCustomMarkdown = true
    ..useRaw = false
    ..usePlainText = false;
  }
}