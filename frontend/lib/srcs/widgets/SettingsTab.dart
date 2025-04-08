import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/services/Singleton.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  
  final TextEditingController _openAIController = TextEditingController();
  final TextEditingController _claudeController = TextEditingController();
  final TextEditingController _mistralController = TextEditingController();
  final TextEditingController _geminiController = TextEditingController();
  final TextEditingController _deepSeekController = TextEditingController();
  
  bool _isUnlocked = false;
  bool _showOpenAIKey = false;
  bool _showClaudeKey = false;
  bool _showMistralKey = false;
  bool _showGeminiKey = false;
  bool _showDeepSeekKey = false;

  @override
  void initState() {
    super.initState();
    final metadata = Singleton();
    _openAIController.text = metadata.openAIKey;
    _claudeController.text = metadata.anthropicKey;
    _mistralController.text = metadata.mistralKey;
    _geminiController.text = metadata.geminiKey;
    _deepSeekController.text = metadata.deepseekKey;

    // Try to load API keys without password
    _initializeModels(skipPasswordCheck: true);
  }

  @override
  void dispose() {
    _openAIController.dispose();
    _claudeController.dispose();
    _mistralController.dispose();
    _geminiController.dispose();
    _deepSeekController.dispose();
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
        _mistralController.text = metadata.mistralKey;
        _geminiController.text = metadata.geminiKey;
        _deepSeekController.text = metadata.deepseekKey;
        metadata.isInitialized = true;
      });

      if (!skipPasswordCheck) {
        await metadata.getModels();
        
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
          _mistralController.clear();
          _geminiController.clear();
          _deepSeekController.clear();
          metadata.openAIKey = '';
          metadata.anthropicKey = '';
          metadata.mistralKey = '';
          metadata.geminiKey = '';
          metadata.deepseekKey = '';
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
              obscureText: !_showOpenAIKey,
              decoration: InputDecoration(
                labelText: 'OpenAI API Key',
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
                suffixIcon: _isUnlocked ? IconButton(
                  icon: Icon(_showOpenAIKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showOpenAIKey = !_showOpenAIKey),
                ) : null,
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
              obscureText: !_showClaudeKey,
              decoration: InputDecoration(
                labelText: 'Claude API Key',
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
                suffixIcon: _isUnlocked ? IconButton(
                  icon: Icon(_showClaudeKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showClaudeKey = !_showClaudeKey),
                ) : null,
              ),
              style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
              onChanged: (value) {
                metadata.anthropicKey = value;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mistralController,
              enabled: _isUnlocked,
              obscureText: !_showMistralKey,
              decoration: InputDecoration(
                labelText: 'Mistral API Key',
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
                suffixIcon: _isUnlocked ? IconButton(
                  icon: Icon(_showMistralKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showMistralKey = !_showMistralKey),
                ) : null,
              ),
              style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
              onChanged: (value) {
                metadata.mistralKey = value;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _geminiController,
              enabled: _isUnlocked,
              obscureText: !_showGeminiKey,
              decoration: InputDecoration(
                labelText: 'Gemini API Key',
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
                suffixIcon: _isUnlocked ? IconButton(
                  icon: Icon(_showGeminiKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showGeminiKey = !_showGeminiKey),
                ) : null,
              ),
              style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
              onChanged: (value) {
                metadata.geminiKey = value;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deepSeekController,
              enabled: _isUnlocked,
              obscureText: !_showDeepSeekKey,
              decoration: InputDecoration(
                labelText: 'DeepSeek API Key',
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
                suffixIcon: _isUnlocked ? IconButton(
                  icon: Icon(_showDeepSeekKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showDeepSeekKey = !_showDeepSeekKey),
                ) : null,
              ),
              style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
              onChanged: (value) {
                metadata.deepseekKey = value;
              },
            ),
            const SizedBox(height: 32),
            
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
