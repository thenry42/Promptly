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
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.normal,
        ),
        h1: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 20,
          height: 1.6,
          fontWeight: FontWeight.bold,
        ),
        h2: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 18,
          height: 1.6,
          fontWeight: FontWeight.bold,
        ),
        h3: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
          height: 1.6,
          fontWeight: FontWeight.bold,
        ),
        blockquote: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          fontSize: 14,
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
        code: TextStyle(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          color: Theme.of(context).colorScheme.onSurface,
          fontFamily: 'Menlo',
          fontSize: 13,
          height: 1.5,
        ),
        // List styles
        listBullet: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
        ),
        blockSpacing: 16.0,
        h1Padding: const EdgeInsets.only(top: 24, bottom: 12),
        h2Padding: const EdgeInsets.only(top: 20, bottom: 10),
        h3Padding: const EdgeInsets.only(top: 16, bottom: 8),
        blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

class CustomCodeBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(element, TextStyle? preferredStyle) {
    var language = '';

    if (element.attributes['class'] != null) {
      var languageClass = element.attributes['class'] as String;
      if (languageClass.startsWith('language-')) {
        language = languageClass.substring(9);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
              child: Text(
                language,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HighlightView(
              element.textContent,
              language: language.isEmpty ? 'plaintext' : language,
              theme: _customHighlightTheme,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(
                fontFamily: 'Menlo',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom syntax highlighting theme
  static final _customHighlightTheme = Map<String, TextStyle>.from(a11yDarkTheme)
    ..addAll({
      'root': TextStyle(
        backgroundColor: Colors.grey[850],
        color: Colors.grey[200],
      ),
      'keyword': const TextStyle(color: Color(0xFFFF79C6)),
      'string': const TextStyle(color: Color(0xFF50FA7B)),
      'comment': TextStyle(color: Colors.grey[500]),
      'number': const TextStyle(color: Color(0xFF8BE9FD)),
    });
}
