import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

// TO DO:
// Remake all that based on the backend files

class MarkdownMessage
{
  
}

/*
class MarkdownMessage extends StatelessWidget {
  final String message;
  final bool isUserMessage;

  const MarkdownMessage({
    super.key,
    required this.message,
    required this.isUserMessage,
  });

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
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: message,
      selectable: true,
      builders: {
        'code': CustomCodeBuilder(context),
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

class CustomCodeBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  CustomCodeBuilder(this.context);

  @override
  Widget? visitElementAfter(element, TextStyle? preferredStyle) {
    var language = '';

    // Extract the language from the class attribute
    if (element.attributes['class'] != null) {
      var languageClass = element.attributes['class'] as String;
      if (languageClass.startsWith('language-')) {
        language = languageClass.substring(9);
      }
    }

    // Use SelectableText.rich to render styled and selectable text
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText.rich(
          _buildHighlightedText(element.textContent, language),
          style: TextStyle(
            fontFamily: 'Menlo',
            fontSize: 13,
            height: 1.5,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
      ),
    );
  }

  /// Builds a highlighted TextSpan based on the content and detected language.
  TextSpan _buildHighlightedText(String text, String language) {
    // Use a mock highlighting function to apply styles
    final spans = _highlightSyntax(text, language);
    return TextSpan(children: spans);
  }
  
  List<TextSpan> _highlightSyntax(String text, String language) {
    // Define keywords and styles for the language
    final keywords = ['if', 'for', 'while', 'return', 'class', 'function'];
    final keywordStyle = TextStyle(color: Color(0xFFFF79C6), fontWeight: FontWeight.bold);
    final stringStyle = TextStyle(color: Color(0xFF50FA7B));
    final commentStyle = TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic);

    final spans = <TextSpan>[];

    // Tokenize text but retain spaces and symbols
    final tokens = RegExp(r'(\s+|[;,.()\[\]{}])').allMatches(text).toList();
    int lastIndex = 0;

    for (final match in tokens) {
      // Add the preceding text (before the match) as a span
      if (match.start > lastIndex) {
        final segment = text.substring(lastIndex, match.start);
        spans.add(_styleSegment(segment, keywords, keywordStyle, stringStyle, commentStyle));
      }

      // Add the matched delimiter as a span
      spans.add(TextSpan(text: match.group(0), style: const TextStyle(color: Colors.white)));

      // Update lastIndex to continue processing
      lastIndex = match.end;
    }

    // Add any remaining text after the last match
    if (lastIndex < text.length) {
      final segment = text.substring(lastIndex);
      spans.add(_styleSegment(segment, keywords, keywordStyle, stringStyle, commentStyle));
    }

    return spans;
  }

  TextSpan _styleSegment(
    String segment,
    List<String> keywords,
    TextStyle keywordStyle,
    TextStyle stringStyle,
    TextStyle commentStyle,
  ) {
    // Check for keywords
    if (keywords.contains(segment)) {
      return TextSpan(text: segment, style: keywordStyle);
    }

    // Check for strings (simplified)
    if (segment.startsWith('"') || segment.startsWith("'")) {
      return TextSpan(text: segment, style: stringStyle);
    }

    // Check for comments (basic single-line detection)
    if (segment.startsWith('//')) {
      return TextSpan(text: segment, style: commentStyle);
    }

    // Default: plain text
    return TextSpan(text: segment, style: const TextStyle(color: Colors.white));
  }
}
*/
