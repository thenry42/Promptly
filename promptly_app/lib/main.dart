import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'srcs/backend/Colors.dart';
import 'srcs/widgets/MainWindow.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    setWindowTitle('Promptly');
    setWindowMinSize(const Size(960, 540));
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
      theme: ThemeData(colorScheme: AppTheme.myColorScheme),
      home: const SafeArea(
        child: MainWindow(),
      ),
    );
  }
}
