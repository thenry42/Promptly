import 'package:flutter/material.dart';
import 'screens/llm_interaction_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LLM Interaction',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LLMInteractionPage(),
    );
  }
}
