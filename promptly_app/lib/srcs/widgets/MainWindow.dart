import 'package:flutter/material.dart';
import 'ChatPanel.dart';
import 'LeftPanel.dart';

class MainWindow extends StatelessWidget {
  const MainWindow({super.key});

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
          child: const Row(
            children: [
              Expanded(
                flex: 1,
                child: LeftPanel(),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: ChatPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
