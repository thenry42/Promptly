// settings_dialog.dart
import 'package:flutter/material.dart';
import '../backend/MetaData.dart' as myMetadata; // MetaData already exists in Dart

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final _openAIController = TextEditingController();
  final _anthropicController = TextEditingController();
  bool _obscureOpenAI = true;
  bool _obscureAnthropic = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingKeys();
  }

  Future<void> _loadExistingKeys() async {
    try {
      await myMetadata.MetaData.getKeysFromStorage();
      final metadata = myMetadata.MetaData();
      
      setState(() {
        if (metadata.openAIKey != null) {
          _openAIController.text = metadata.openAIKey!;
        }
        if (metadata.anthropicKey != null) {
          _anthropicController.text = metadata.anthropicKey!;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading API keys')),
        );
      }
    }
  }

  Future<void> _saveKeys() async {
    setState(() => _isSaving = true);
    
    try {
      await myMetadata.MetaData.saveKeys(
        openAIKey: _openAIController.text.isNotEmpty ? _openAIController.text : null,
        anthropicKey: _anthropicController.text.isNotEmpty ? _anthropicController.text : null,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving API keys')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _openAIController.dispose();
    _anthropicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'API Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // OpenAI API Key
            Text(
              'OpenAI API Key',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _openAIController,
              decoration: InputDecoration(
                hintText: 'Enter OpenAI API key',
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _isSaving ? null : () async {
                        _openAIController.clear();
                        await myMetadata.MetaData.deleteKeys(openAI: true);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _obscureOpenAI ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: _isSaving ? null : () {
                        setState(() {
                          _obscureOpenAI = !_obscureOpenAI;
                        });
                      },
                    ),
                  ],
                ),
              ),
              obscureText: _obscureOpenAI,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 20),
            
            // Anthropic API Key
            Text(
              'Anthropic API Key',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _anthropicController,
              decoration: InputDecoration(
                hintText: 'Enter Anthropic API key',
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _isSaving ? null : () async {
                        _anthropicController.clear();
                        await myMetadata.MetaData.deleteKeys(anthropic: true);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _obscureAnthropic ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: _isSaving ? null : () {
                        setState(() {
                          _obscureAnthropic = !_obscureAnthropic;
                        });
                      },
                    ),
                  ],
                ),
              ),
              obscureText: _obscureAnthropic,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 20),
            
            // Save Button
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveKeys,
                child: _isSaving 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    )
                  : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
