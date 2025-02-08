import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/backend/Singleton.dart';

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

    Singleton metadata = Singleton();

    return AlertDialog(
      title: Text("Settings", style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily)),
      content: TextButton(
          onPressed: _saveSettings,
          child: Text("Save", style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily)),
        ),
    );
  }
}
