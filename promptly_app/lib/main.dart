import 'package:flutter/material.dart';
import 'screens/llm_interaction_page.dart';
import 'package:markdown_widget/markdown_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Promptly',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LLMInteractionPage(),
    );
  }
}
