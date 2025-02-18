import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'srcs/backend/Colors.dart';
import 'srcs/widgets/TabView.dart'; // Updated import
import 'srcs/backend/Singleton.dart';
import 'srcs/backend/Chat.dart';
import 'srcs/backend/ChatMessage.dart';
import 'srcs/widgets/TabView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  var metadata = Singleton();

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    setWindowTitle('Promptly');
    setWindowMinSize(const Size(720, 720)); // 720, 720 safe
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
        child: TabView(), // Updated to use TabView
      ),
    );
  }
}
