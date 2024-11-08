import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LLM Interaction',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LLMInteractionPage(),
    );
  }
}

class LLMInteractionPage extends StatefulWidget {
  const LLMInteractionPage({super.key});

  @override
  _LLMInteractionPageState createState() => _LLMInteractionPageState();
}

class _LLMInteractionPageState extends State<LLMInteractionPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';

  Future<void> _sendRequest() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'message': _controller.text}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _response = json.decode(response.body)['response'];
      });
    } else {
      setState(() {
        _response = 'Error: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LLM Interaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Enter your message'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendRequest,
              child: const Text('Send'),
            ),
            const SizedBox(height: 16),
            Text('Response: $_response'),
          ],
        ),
      ),
    );
  }
}

