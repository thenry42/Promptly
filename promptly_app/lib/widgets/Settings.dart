import 'package:flutter/material.dart';
import 'package:promptly_app/services/OpenAI.dart';
import 'package:promptly_app/services/Anthropic.dart';

class SettingsDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: const Center(child: Text('Settings')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.key),
                  title: const Text('API Keys'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the settings dialog
                    _showApiKeysDialog(context); // Open the API Keys dialog
                  },
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
                child: Icon(Icons.cancel, color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Displays the API Key management dialog.
  static void _showApiKeysDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('API Key Setup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter API keys below. These keys will not persist after the session.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'OpenAI API Key',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  OPEN_AI_API_KEY = value; // Update OpenAI key
                },
                controller: TextEditingController(text: OPEN_AI_API_KEY),
                obscureText: true,
                obscuringCharacter: '•',
                expands: false,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Claude API Key',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  ANTHROPIC_API_KEY = value; // Update Claude key
                },
                controller: TextEditingController(text: ANTHROPIC_API_KEY),
                obscureText: true,
                obscuringCharacter: '•',
                expands: false,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await getOpenAIModels();
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
