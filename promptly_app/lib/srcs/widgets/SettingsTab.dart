import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/backend/Singleton.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final TextEditingController _openAIController = TextEditingController();
  final TextEditingController _claudeController = TextEditingController();
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    final metadata = Singleton();
    _openAIController.text = metadata.openAIKey;
    _claudeController.text = metadata.anthropicKey;
    
    // Try to load API keys without password
    _initializeModels(skipPasswordCheck: true);
  }

  @override
  void dispose() {
    _openAIController.dispose();
    _claudeController.dispose();
    super.dispose();
  }

  Future<void> _initializeModels({bool skipPasswordCheck = false}) async {
    final metadata = Singleton();
    
    try {
      // Try to load API keys silently
      await metadata.loadAPIKeys();
      
      setState(() {
        _openAIController.text = metadata.openAIKey;
        _claudeController.text = metadata.anthropicKey;
        metadata.isInitialized = true;
      });

      if (!skipPasswordCheck) {
        await metadata.getModels();
        await metadata.getModelsName();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Models and API keys initialized successfully')),
          );
        }
      }
    } catch (e) {
      // Only show error if not skipping password check
      if (!skipPasswordCheck && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load API keys. Please check your password.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isUnlocked = false);
      }
    }
  }

  Future<bool> _promptForPassword(BuildContext context) async {
    final controller = TextEditingController();
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final storedPassword = await const FlutterSecureStorage()
                    .read(key: 'settings_password');
                if (storedPassword == null) {
                  // First time setup - save the password
                  await const FlutterSecureStorage()
                      .write(key: 'settings_password', value: controller.text);
                  Navigator.pop(context, true);
                } else if (storedPassword == controller.text) {
                  // Password matches
                  Navigator.pop(context, true);
                } else {
                  // Wrong password
                  Navigator.pop(context, false);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final metadata = Singleton();

    Future<void> handleSaveKeys() async {
      await metadata.saveAPIKeys();
      await metadata.getModels();
      await metadata.getModelsName();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API Keys saved')),
        );
      }
    }

    Future<void> handleResetSettings() async {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reset Settings'),
          content: const Text(
            'This will remove your password and API keys. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reset'),
            ),
          ],
        ),
      );

      if (confirm == true && context.mounted) {
        const storage = FlutterSecureStorage();
        await storage.deleteAll(); // Removes password and API keys
        
        setState(() {
          _isUnlocked = false;
          _openAIController.clear();
          _claudeController.clear();
          metadata.openAIKey = '';
          metadata.anthropicKey = '';
          metadata.isInitialized = false;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings have been reset')),
          );
        }
      }
    }

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lock/Unlock Section
            Row(
              children: [
                Icon(
                  _isUnlocked ? Icons.lock_open : Icons.lock,
                  color: _isUnlocked ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _isUnlocked ? 'Settings Unlocked' : 'Settings Locked',
                  style: TextStyle(
                    fontSize: metadata.fontSize,
                    fontFamily: metadata.fontFamily,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: Icon(_isUnlocked ? Icons.lock : Icons.lock_open),
                  label: Text(_isUnlocked ? 'Lock' : 'Unlock'),
                  onPressed: () async {
                    if (!_isUnlocked) {
                      final unlocked = await _promptForPassword(context);
                      if (unlocked) {
                        setState(() => _isUnlocked = true);
                      }
                    } else {
                      setState(() => _isUnlocked = false);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // API Keys Section
            TextField(
              controller: _openAIController,
              enabled: _isUnlocked,
              obscureText: !_isUnlocked,
              decoration: InputDecoration(
                labelText: 'OpenAI API Key',
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
              ),
              style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
              onChanged: (value) {
                metadata.openAIKey = value;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _claudeController,
              enabled: _isUnlocked,
              obscureText: !_isUnlocked,
              decoration: InputDecoration(
                labelText: 'Claude API Key',
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
              ),
              style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
              onChanged: (value) {
                metadata.anthropicKey = value;
              },
            ),
            const SizedBox(height: 16),
            
            // Add this after the API Keys section
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            
            // Reset Settings Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.tonal(
                  onPressed: handleResetSettings,
                  style: FilledButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  child: const Text('Reset Settings'),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: _isUnlocked ? handleSaveKeys : null,
                  child: const Text('Save API Keys'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
