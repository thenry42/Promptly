import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'srcs/services/Colors.dart';
import 'srcs/widgets/TabView.dart'; // Updated import
import 'srcs/services/Singleton.dart';
import 'srcs/services/Chat.dart';
import 'srcs/services/ChatMessage.dart';
import 'srcs/widgets/TabView.dart';
import 'srcs/services/HttpRequest.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  var metadata = Singleton();

  await metadata.loadAPIKeys();
  await metadata.loadChats();
  await metadata.getModels();

  print(metadata.ollama_models);
  print(metadata.anthropic_models);
  print(metadata.openai_models);
  print(metadata.mistral_models);
  print(metadata.gemini_models);
  print(metadata.deepseek_models);

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    setWindowTitle('Promptly');
    setWindowMinSize(const Size(720, 720)); // 720, 720 safe
    setWindowMaxSize(const Size(2560, 1440));
    
    // Get screen size and set app to launch in full screen
    final screenSize = await getWindowInfo();
    setWindowFrame(Rect.fromLTWH(
      0, 
      0, 
      screenSize.frame.width, 
      screenSize.frame.height
    ));
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
        child: TabView(), // Updated to use TabView
      ),
    );
  }
}
