import 'package:flutter/material.dart';
import 'ChatPanel.dart';
import 'LeftPanel.dart';

class MainWindow extends StatelessWidget {
  const MainWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 2560,
            minWidth: 960,
            maxHeight: 1440,
            minHeight: 540,
          ),
          child: Card(
            elevation: 8,
            color: Theme.of(context).colorScheme.surfaceContainer,
            margin: const EdgeInsets.all(16), // Cleaner way to add spacing
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: LeftPanel(),
                ),
                VerticalDivider(width: 16), // Divider for spacing
                Expanded(
                  flex: 4,
                  child: ChatPanel(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
