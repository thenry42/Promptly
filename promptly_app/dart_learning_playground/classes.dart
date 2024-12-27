import 'package:flutter/material.dart';

class GLOBALS
{
  late String anthropicKey;
  late String openAIKey;

  static void getKeysFromStorage() {
    // Add your implementation here
  }
  
  static void getKeysFromUser() {
    // Add your implementation here
  }
}

class Chat
{
  late String title;
  late LLM llm;
  bool isHovered = false;
  bool isSelected = false;
  bool isSendingRequest = false;
}

class ChatMessage
{
  late final String sender;
  late final String message;
  late final bool useMarkdown;
  late final bool rawAnswer;
  late final DateTime timestamp;
}

abstract class LLM
{  
  late int    id;
  late String name;
  late String description;
  late Object model;
  late Icon icon;
  List<ChatMessage> messages = [];

  Future<String> generateResponse(String prompt) async {return '';}
  Future<void> fetchModelDetails() async {}
  Icon getIcon() {return const Icon(Icons.question_mark);}

}

class OLLAMA extends LLM
{

}

class ANTHROPIC extends LLM
{

}

class OPENAI extends LLM
{

}

class DATABASE
{

}

class AppTheme
{
  static const ColorScheme myColorScheme = ColorScheme.dark(
    surfaceContainer: Color(0xFF211F26),
    surfaceContainerHigh: Color(0xFF2B2930),
    surfaceContainerHighest: Color(0xFF36343B),
    onSurface: Color(0xFFE6E0E9),
    tertiary: Color(0xFFEFB8C8),
    onTertiary: Color(0xFF492532),
  );
}

class Encryption
{

}