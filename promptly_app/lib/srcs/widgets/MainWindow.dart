import 'package:flutter/material.dart';
import 'ChatPanel.dart';
import 'LeftPanel.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  bool _isLeftPanelVisible = true;

  void _toggleLeftPanel() {
    setState(() {
      _isLeftPanelVisible = !_isLeftPanelVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isLeftPanelVisible ? MediaQuery.of(context).size.width * 0.2 : 0,
                child: _isLeftPanelVisible 
                    ? LeftPanel(
                        onNewChat: () {
                          // Handle new chat
                        },
                        onSettings: () {
                          // Handle settings
                        },
                      )
                    : null,
              ),
              if (_isLeftPanelVisible == true) const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: ChatPanel(
                  onTogglePanel: _toggleLeftPanel,
                  isPanelVisible: _isLeftPanelVisible,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
