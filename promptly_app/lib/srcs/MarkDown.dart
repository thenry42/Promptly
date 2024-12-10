import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownMessage extends StatelessWidget {
  final String message;
  final bool isUserMessage;

  const MarkdownMessage({
    Key? key,
    required this.message,
    required this.isUserMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment:
            isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isUserMessage
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.tertiary,
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
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: message,
      selectable: true,
      builders: {
        'code': CustomCodeBuilder(),
      },
      styleSheet: MarkdownStyleSheet(
        // Text styles
        p: TextStyle(
          color: Theme.of(context).colorScheme.onTertiary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        h1: TextStyle(
          color: Theme.of(context).colorScheme.onTertiary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        h2: TextStyle(
          color: Theme.of(context).colorScheme.onTertiary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        h3: TextStyle(
          color: Theme.of(context).colorScheme.onTertiary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        blockquote: TextStyle(
          color: Theme.of(context).colorScheme.onTertiary,
          fontSize: 16,
          fontStyle: FontStyle.italic,
          height: 1,
        ),
        code: TextStyle(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          fontFamily: 'monospace',
          fontSize: 14,
          height: 1,
        ),
        // List styles
        listBullet: TextStyle(
          color: Theme.of(context).colorScheme.onTertiary,
          fontSize: 16,
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

class CustomCodeBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(element, TextStyle? preferredStyle) {
    var language = '';
    
    // Extract language from code fence if present
    if (element.attributes['class'] != null) {
      var languageClass = element.attributes['class'] as String;
      if (languageClass.startsWith('language-')) {
        language = languageClass.substring(9);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: HighlightView(
          // The original code
          element.textContent,
          // Specify language
          language: language.isEmpty ? 'plaintext' : language,
          // Use theme
          theme: a11yDarkTheme,
          // Padding
          padding: const EdgeInsets.all(12),
          // Text style
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
