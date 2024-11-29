import 'package:flutter/material.dart';
import 'package:promptly_app/models/open_ai_list.dart';

String openAiKey = '';
String claudeKey = '';

class SettingsDialog {

  /// Displays the main settings dialog.
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
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
                const ListTile(
                  leading: Icon(Icons.color_lens),
                  title: Text('Theme'),
                ),
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Displays the API Key management dialog.
  static void _showApiKeysDialog(BuildContext context) {
    String tempOpenAiKey = openAiKey; // Local temporary storage for OpenAI key
    String tempClaudeKey = claudeKey; // Local temporary storage for Claude key

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
                  tempOpenAiKey = value; // Update OpenAI key
                },
                controller: TextEditingController(text: openAiKey),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Claude API Key',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  tempClaudeKey = value; // Update Claude key
                },
                controller: TextEditingController(text: claudeKey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save keys to session variables
                openAiKey = tempOpenAiKey;
                claudeKey = tempClaudeKey;

                debugPrint('OpenAI Key: $openAiKey');
                debugPrint('Claude Key: $claudeKey');

                getOpenAIModels();

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
