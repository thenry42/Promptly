import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:promptly_app/srcs/services/Singleton.dart';

class MarkdownMessage extends StatelessWidget {
  final String message;

  const MarkdownMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableMarkdown(message: message),
          ),
        ],
      ),
    );
  }
}

class SelectableMarkdown extends StatelessWidget {
  final String message;

  const SelectableMarkdown({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final metadata = Singleton();

    return MarkdownBody(
      data: message,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        code: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: metadata.fontSize,
          fontFamily: metadata.fontFamily,
          height: 1.5,
          fontWeight: FontWeight.normal,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer, 
        ),
        p: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: metadata.fontSize,
          fontFamily: metadata.fontFamily,
          height: 1.5,
          fontWeight: FontWeight.normal,
        ),
        h1: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: metadata.fontSize + (metadata.fontSize / 4),
          fontFamily: metadata.fontFamily,
          height: 1.5,
          fontWeight: FontWeight.bold,
        ),
        h2: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: metadata.fontSize + (metadata.fontSize / 4),
          height: 1.5,
          fontWeight: FontWeight.bold,
        ),
        h3: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: metadata.fontSize + (metadata.fontSize / 4),
          height: 1.5,
          fontWeight: FontWeight.bold,
        ),
        blockquote: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          fontSize: metadata.fontSize,
          fontFamily: metadata.fontFamily,
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
        // List styles
        listBullet: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: metadata.fontSize,
        ),
        blockSpacing: 16.0,
        h1Padding: const EdgeInsets.only(top: 24, bottom: 12),
        h2Padding: const EdgeInsets.only(top: 20, bottom: 10),
        h3Padding: const EdgeInsets.only(top: 16, bottom: 8),
        blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        blockquoteDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        codeblockDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        tablePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tableColumnWidth: const FlexColumnWidth(),
        tableBorder: TableBorder.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
      ),
      onTapLink: (text, href, title) async {
        if (href != null) {
          final url = Uri.parse(href);
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        }
      },
    );
  }
}
