import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:snow_dance/core/theme/app_theme.dart';
import 'package:highlight/highlight.dart' show highlight, Node;

String _universalClean(String text) {
  String decoded = text;
  try {
    decoded = Uri.decodeComponent(text);
  } catch (_) {}
  return decoded
      .toLowerCase()
      .replaceAll(RegExp(r'[\s\-\_\.\,\!\?\:\;\(\)\[\]\{\}\<\>\/\\\#\*\+\=\|\~\`\^\&\"\%]'), '')
      .replaceAll(RegExp(r'[\u3000-\u303F\uFF00-\uFFEF\u2000-\u206F]'), '');
}

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
          onTapLink: (text, href, title) async {
            if (href == null || href.isEmpty) return;

            // Handle in-page anchor links (e.g. #section-name or #案例-1主题状态与图标转换)
            if (href.startsWith('#')) {
              final rawAnchor = href.substring(1).trim();
              if (rawAnchor.isEmpty) return;

              final targetClean = _universalClean(rawAnchor);
              GlobalKey? targetKey = headingKeys[rawAnchor];

              if (targetKey == null) {
                for (final entry in headingKeys.entries) {
                  if (_universalClean(entry.key) == targetClean || entry.key.trim() == rawAnchor) {
                    targetKey = entry.value;
                    break;
                  }
                }
              }

              if (targetKey != null && targetKey.currentContext != null) {
                Scrollable.ensureVisible(
                  targetKey.currentContext!,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  alignment: 0.1,
                );
              }
              return;
            }

            // External links
            if (href.startsWith('http://') || href.startsWith('https://')) {
              final url = Uri.tryParse(href);
              if (url != null) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
              return;
            }

            // Internal relative app routes
            if (href.startsWith('/')) {
              context.go(href);
            }
          },
          builders: {
            'h1': HeadingBuilder(headingKeys),
            'h2': HeadingBuilder(headingKeys),
            'h3': HeadingBuilder(headingKeys),
            'h4': HeadingBuilder(headingKeys),
            'h5': HeadingBuilder(headingKeys),
            'h6': HeadingBuilder(headingKeys),
            'code': CodeBlockBuilder(isDark),
          },
          styleSheet: MarkdownStyleSheet(
            h1: AppTheme.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: isDark ? Colors.white : Colors.black,
            ),
            h2: AppTheme.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: isDark ? Colors.white : Colors.black,
            ),
            h3: AppTheme.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: isDark ? Colors.white : Colors.black,
            ),
            h4: AppTheme.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.5,
              color: isDark ? Colors.white : Colors.black,
            ),
            p: AppTheme.inter(
              fontSize: 16,
              height: 1.8,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
            pPadding: const EdgeInsets.only(bottom: 16),
            code: AppTheme.firaCode(
              fontSize: 14,
              backgroundColor: Colors.transparent,
              color: isDark ? const Color(0xFF00DC82) : const Color(0xFF059669),
            ),
            codeblockDecoration: const BoxDecoration(),
            codeblockPadding: EdgeInsets.zero,
            blockquote: AppTheme.inter(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
            blockquoteDecoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 4,
                ),
              ),
            ),
            blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            listBullet: AppTheme.inter(
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
  final Map<String, int> _visitedCounts = {};

  HeadingBuilder(this.headingKeys);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final text = element.textContent.trim();
    final count = _visitedCounts[text] = (_visitedCounts[text] ?? 0) + 1;
    final uniqueId = '${text}_$count';

    GlobalKey? key = headingKeys[uniqueId] ?? headingKeys[text];

    if (key == null) {
      final targetClean = _universalClean(text);
      for (final entry in headingKeys.entries) {
        if (_universalClean(entry.key) == targetClean || entry.key.trim() == text) {
          key = entry.value;
          break;
        }
      }
    }

    return KeyedSubtree(
      key: key,
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
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
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
              child: SelectableHighlightView(
                code.trimRight(),
                language: language ?? 'plaintext',
                theme: theme,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                textStyle: AppTheme.firaCode(
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
  final ValueNotifier<bool> _copied = ValueNotifier(false);

  @override
  void dispose() {
    _copied.dispose();
    super.dispose();
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.code));
    _copied.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _copied.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _copied,
      builder: (context, child) {
        final isCopied = _copied.value;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isCopied ? Icons.check_rounded : Icons.copy_rounded,
                key: ValueKey(isCopied),
                size: 15,
                color: isCopied ? const Color(0xFF00DC82) : (isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
            ),
            onPressed: _copy,
            tooltip: isCopied ? 'Copied!' : 'Copy code',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(7),
          ),
        );
      },
    );
  }
}

/// Highlight View using SelectableText.rich for full native text selection & copying support
class SelectableHighlightView extends StatelessWidget {
  final String source;
  final String? language;
  final Map<String, TextStyle> theme;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  SelectableHighlightView(
    String input, {
    super.key,
    this.language,
    this.theme = const {},
    this.padding,
    this.textStyle,
    int tabSize = 8,
  }) : source = input.replaceAll('\t', ' ' * tabSize);

  List<TextSpan> _convert(List<Node> nodes) {
    List<TextSpan> buildSpans(List<Node> nodeList) {
      final List<TextSpan> spans = [];
      for (final node in nodeList) {
        if (node.value != null) {
          spans.add(node.className == null
              ? TextSpan(text: node.value)
              : TextSpan(text: node.value, style: theme[node.className!]));
        } else if (node.children != null && node.children!.isNotEmpty) {
          final childrenSpans = buildSpans(node.children!);
          spans.add(TextSpan(
            children: childrenSpans,
            style: node.className == null ? null : theme[node.className!],
          ));
        }
      }
      return spans;
    }

    return buildSpans(nodes);
  }

  static const _rootKey = 'root';
  static const _defaultFontColor = Color(0xff000000);
  static const _defaultBackgroundColor = Color(0xffffffff);
  static const _defaultFontFamily = 'monospace';

  static final Map<String, List<Node>> _highlightNodeCache = {};
  static const int _maxCacheEntries = 200;

  static List<Node> _getOrParse(String source, String? language) {
    final key = '$language:$source';
    final cached = _highlightNodeCache[key];
    if (cached != null) {
      return cached;
    }
    if (_highlightNodeCache.length >= _maxCacheEntries) {
      _highlightNodeCache.remove(_highlightNodeCache.keys.first);
    }
    final parsed = highlight.parse(source, language: language);
    final nodes = parsed.nodes ?? const [];
    _highlightNodeCache[key] = nodes;
    return nodes;
  }

  @override
  Widget build(BuildContext context) {
    var style = TextStyle(
      fontFamily: _defaultFontFamily,
      color: theme[_rootKey]?.color ?? _defaultFontColor,
    );
    if (textStyle != null) {
      style = style.merge(textStyle);
    }

    final nodes = _getOrParse(source, language);

    return Container(
      color: theme[_rootKey]?.backgroundColor ?? _defaultBackgroundColor,
      padding: padding,
      child: SelectableText.rich(
        TextSpan(
          style: style,
          children: _convert(nodes),
        ),
      ),
    );
  }
}

