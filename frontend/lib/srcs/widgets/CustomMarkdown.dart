import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:promptly_app/srcs/services/Singleton.dart';
import 'package:markdown/markdown.dart' as md;

// Custom Syntax for code blocks that preserves language
class CustomCodeBlockSyntax extends md.BlockSyntax {
  static final _pattern = RegExp(r'^```(.*)$');
  final RegExp _endPattern = RegExp(r'^```\s*$');
  
  @override
  RegExp get pattern => _pattern;
  
  @override
  bool canParse(md.BlockParser parser) {
    final match = pattern.firstMatch(parser.current.content);
    return match != null;
  }
  
  @override
  md.Node parse(md.BlockParser parser) {
    final match = pattern.firstMatch(parser.current.content);
    final language = match?.group(1)?.trim() ?? '';
    
    final codeLines = <String>[];
    parser.advance();
    
    while (!parser.isDone) {
      final line = parser.current.content;
      if (_endPattern.hasMatch(line)) {
        parser.advance();
        break;
      }
      codeLines.add(line);
      parser.advance();
    }
    
    final code = codeLines.join('\n');
    final element = md.Element('code', [md.Text(code)]);
    if (language.isNotEmpty) {
      element.attributes['class'] = 'language-$language';
    }
    
    return md.Element('pre', [element])
      ..attributes['data-language'] = language;
  }
}

// Custom markdown builder for code blocks
class CustomCodeBlockBuilder extends MarkdownElementBuilder {
  final double fontSize;
  final String fontFamily;
  
  CustomCodeBlockBuilder({
    required this.fontSize,
    required this.fontFamily,
  });
  
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String language = element.attributes['data-language'] ?? '';
    final String code = element.children!.first.textContent;
    
    return CodeBlockWidget(
      code: code,
      language: language,
      fontSize: fontSize,
      fontFamily: fontFamily,
    );
  }
}

// Widget to display code blocks with copy functionality
class CodeBlockWidget extends StatelessWidget {
  final String code;
  final String language;
  final double fontSize;
  final String fontFamily;
  
  const CodeBlockWidget({
    Key? key,
    required this.code,
    required this.language,
    required this.fontSize,
    required this.fontFamily,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language bar with copy button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language.isNotEmpty ? language : 'Code',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: fontSize * 0.9,
                    fontFamily: fontFamily,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Code copied to clipboard'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
          // Code content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SelectableText(
              code,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: fontSize,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Main custom markdown widget
class CustomMarkdownWidget extends StatelessWidget {
  final String data;
  
  const CustomMarkdownWidget({
    Key? key,
    required this.data,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final metadata = Singleton();
    
    // Create custom markdown syntax and builders
    final mdExtensions = [
      CustomCodeBlockSyntax(),
    ];
    
    final builders = {
      'pre': CustomCodeBlockBuilder(
        fontSize: metadata.fontSize,
        fontFamily: metadata.fontFamily,
      ),
    };
    
    return MarkdownBody(
      data: data,
      selectable: true,
      extensionSet: md.ExtensionSet(
        md.ExtensionSet.gitHubFlavored.blockSyntaxes,
        [
          ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
        ],
      ),
      builders: builders,
      styleSheet: MarkdownStyleSheet(
        code: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: metadata.fontSize,
          fontFamily: 'monospace',
          height: 1.5,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5),
        ),
        p: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: metadata.fontSize,
          fontFamily: metadata.fontFamily,
          height: 1.5,
        ),
        h1: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: metadata.fontSize * 1.5,
          fontFamily: metadata.fontFamily,
          height: 1.5,
          fontWeight: FontWeight.bold,
        ),
        h2: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: metadata.fontSize * 1.3,
          fontFamily: metadata.fontFamily,
          height: 1.5,
          fontWeight: FontWeight.bold,
        ),
        h3: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: metadata.fontSize * 1.2,
          fontFamily: metadata.fontFamily,
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        codeblockDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        tableColumnWidth: const FlexColumnWidth(),
        tableBorder: TableBorder.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
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

// Container widget for the custom markdown
class CustomMarkdownMessage extends StatelessWidget {
  final String message;

  const CustomMarkdownMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: CustomMarkdownWidget(data: message),
    );
  }
} 