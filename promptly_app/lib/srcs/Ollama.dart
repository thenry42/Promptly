import 'Chat.dart';
import 'package:flutter/foundation.dart';
import 'package:ollama_dart/ollama_dart.dart';

List<Model> ollamaModels = [];

Future<List<Model>> getOllamaModels() async { 
  try {
    final client = OllamaClient();
    final response = await client.listModels();

    // Convert to List of Maps with name and type
    final List<Model> modelList = response.models!.toList();
        
    // Clear existing list and add new models
    ollamaModels.clear();
    ollamaModels.addAll(modelList);    
    return ollamaModels;
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching models: $e');
    }
    return ollamaModels;
  }
}

Future<String> generateOllamaCompletion({
  required String model,
  required String prompt,
  required List<ChatMessage> messageList,
}) async {

  final client = OllamaClient();
  var newModel = model.replaceFirst('ollama:', '');

  try {

    final messages = messageList.map((msg) => Message(
      role: msg.sender == 'User' ? MessageRole.user : MessageRole.assistant,
      content: msg.message,
    )).toList();

    /*
    // THE USER MESSAGE IS ALREADY ADDED IN THE MESSAGE LIST
    messages.add(Message(
      role: MessageRole.user,
      content: prompt,
    ));
    */

    final generatedResponse = await client.generateChatCompletion(
      request: GenerateChatCompletionRequest(
        model: newModel,
        messages: messages,
      ),
    );
    
    return generatedResponse.message.content;
  } catch (e) {
    if (kDebugMode) {
      print('Error generating completion: $e');
    }
    return 'FATAL ERROR';
  }
}
