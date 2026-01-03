import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';

class MarkdownViewer extends StatelessWidget {
  final String content;
  final Map<String, GlobalKey> headingKeys;

  const MarkdownViewer({
    super.key,
    required this.content,
    required this.headingKeys,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: SelectionArea(
        child: MarkdownBody(
          data: content,
          selectable: false, // Performance: Handle selection via parent SelectionArea
          builders: {
            'h1': HeadingBuilder(headingKeys),
            'h2': HeadingBuilder(headingKeys),
            'h3': HeadingBuilder(headingKeys),
            'h4': HeadingBuilder(headingKeys),
            'code': CodeBlockBuilder(isDark),
          },
          styleSheet: MarkdownStyleSheet(
            h1: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: isDark ? Colors.white : Colors.black,
            ),
            h2: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: isDark ? Colors.white : Colors.black,
            ),
            h3: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: isDark ? Colors.white : Colors.black,
            ),
            h4: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: isDark ? Colors.white : Colors.black,
            ),
            p: GoogleFonts.inter(
              fontSize: 16,
              height: 1.8,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
            pPadding: const EdgeInsets.only(bottom: 16),
            code: GoogleFonts.firaCode(
              fontSize: 14,
              backgroundColor: Colors.transparent,
              color: isDark ? const Color(0xFF00DC82) : const Color(0xFF007A5E),
            ),
            codeblockDecoration: const BoxDecoration(),
            codeblockPadding: EdgeInsets.zero,
            blockquote: GoogleFonts.inter(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
            blockquoteDecoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 4,
                ),
              ),
            ),
            blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            listBullet: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class HeadingBuilder extends MarkdownElementBuilder {
  final Map<String, GlobalKey> headingKeys;

  HeadingBuilder(this.headingKeys);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = element.textContent;
    final key = headingKeys[text];

    return Container(
      key: key,
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        text,
        style: preferredStyle,
      ),
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  final bool isDark;

  CodeBlockBuilder(this.isDark);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final language = element.attributes['class']?.replaceFirst('language-', '');
    final code = element.textContent;

    // Use multiline detection for code blocks
    final isBlock = code.contains('\n');

    if (!isBlock) {
      return null; // Let default builder handle inline code
    }

    // 1. Prepare theme and extract background
    final baseTheme = isDark ? atomOneDarkTheme : atomOneLightTheme;
    final Map<String, TextStyle> theme = Map.from(baseTheme);
    
    // Extract background color from theme root
    final bgColor = theme['root']?.backgroundColor ?? 
        (isDark ? const Color(0xFF282C34) : const Color(0xFFFAFAFA));

    // 2. Make HighlightView's internal background transparent so our Container handles it
    if (theme.containsKey('root')) {
      theme['root'] = theme['root']!.copyWith(backgroundColor: Colors.transparent);
    }

    return Container(
      width: double.infinity, // Force full width for the background
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              // Allow code to be as wide as it needs to be for horizontal scrolling, 
              // but the container background will be double.infinity wide.
              constraints: const BoxConstraints(minWidth: 800), 
              child: HighlightView(
                code.trimRight(),
                language: language ?? 'plaintext',
                theme: theme,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                textStyle: GoogleFonts.firaCode(
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _CopyButton(code: code),
          ),
        ],
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  final String code;
  const _CopyButton({required this.code});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _copied ? Icons.check : Icons.copy_rounded,
        size: 16,
        color: _copied ? Colors.green : Colors.grey,
      ),
      onPressed: _copy,
      tooltip: 'Copy code',
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(8),
    );
  }
}
