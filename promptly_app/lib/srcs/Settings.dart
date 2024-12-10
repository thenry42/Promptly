import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/OpenAI.dart';
import 'package:promptly_app/srcs/Anthropic.dart';

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
                    MouseRegion(
                      cursor: SystemMouseCursors.click, // Set cursor to hand on hover
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the settings dialog
                          _showApiKeysDialog(context); // Open the API Keys dialog
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainer, // No background color, allows hover effect
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                          textStyle: const TextStyle(
                            fontSize: 16,
                          )
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.key), // Leading icon
                            SizedBox(width: 20),
                            Text('API Keys'), // Title text
                          ],
                        ),
                      ),
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
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          title: const Center(child: Text('API Key Setup')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(child: Text(
                'Enter API keys below. These keys will not persist after the session.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey),
                  textAlign: TextAlign.justify,
              )),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 50,
                child: TextField(
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
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 300,
                height: 50,
                child: TextField(
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
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // Close dialog
                  style: TextButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                  child: Icon(Icons.cancel, color: Theme.of(context).colorScheme.onSurface),
                ),
                TextButton(
                  onPressed: () async {
                    await getOpenAIModels();
                    Navigator.of(context).pop(); // Close dialog
                  },
                  style: TextButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                  child: Icon(Icons.check, color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
