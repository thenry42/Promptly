import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'srcs/backend/Colors.dart';
import 'srcs/widgets/MainWindow.dart';
import 'srcs/backend/Singleton.dart';
import 'srcs/backend/Chat.dart';
import 'srcs/backend/ChatMessage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint("Bonjour !");
  var metadata = Singleton();
  await metadata.getAPIKeys();
  await metadata.getModels();

  print(metadata.ollama_models[0].model);
  //print(metadata.anthropic_models);
  //print(metadata.openai_models);
  //print(metadata.openai_models.length);
  //print(metadata.openai_models[47].id);

  // Create an Anthropic chat
  //Chat chat = Chat(id: 0, modelName: metadata.anthropic_models[1].value.toString(), type: "Anthropic");
  //metadata.chatList.add(chat);

  // Create an Ollama chat
  Chat chat2 = Chat(id: 1, modelName: metadata.ollama_models[0].model!, type: "Ollama");
  metadata.chatList.add(chat2);

  // Create an OpenAI chat
  //Chat chat3 = Chat(id: 2, modelName: metadata.openai_models[47].id, type: "OpenAI");
  //metadata.chatList.add(chat3);

  // Create a chat message
  ChatMessage chat_message = ChatMessage(sender: "User", message: "why is the sky blue ?", timestamp: DateTime.now(), rawMessage: "Hello");
  chat2.addChatMessage(chat_message);

  // Generate a message request
  await chat2.generateMessageRequest();
  print(chat2.messages[0].message);
  print(chat2.messages[1].message);

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    setWindowTitle('Promptly');
    setWindowMinSize(const Size(480, 270));
    setWindowMaxSize(const Size(2560, 1440));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Promptly',
      theme: ThemeData(
        colorScheme: AppTheme.myColorScheme,
        scaffoldBackgroundColor: AppTheme.myColorScheme.surfaceContainer,
      ),
      home: const SafeArea(
        child: MainWindow(),
      ),
    );
  }
}
