import 'package:flutter/material.dart';

class SettingsDialog extends StatefulWidget {
  final VoidCallback onSettingsChanged;
  
  const SettingsDialog({super.key, required this.onSettingsChanged});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {

  @override
  void initState() {
    super.initState();
  }

  void _saveSettings() {
    widget.onSettingsChanged(); // Notify parent
    Navigator.of(context).pop(); // Close dialog
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Settings"),
      content: TextButton(
          onPressed: _saveSettings,
          child: const Text("Save"),
        ),
    );
  }
}
