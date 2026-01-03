import 'package:flutter/material.dart';

class ToCEntry {
  final String title;
  final int level;
  final GlobalKey key;

  ToCEntry({required this.title, required this.level, required this.key});
}

class TableOfContents extends StatelessWidget {
  final List<ToCEntry> entries;
  final Function(ToCEntry) onTap;
  final String? activeId;

  const TableOfContents({
    super.key, 
    required this.entries, 
    required this.onTap,
    this.activeId,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...entries.map((entry) => _ToCItem(
          entry: entry, 
          onTap: onTap,
          isActive: entry.title == activeId,
        )),
      ],
    );
  }
}

class _ToCItem extends StatefulWidget {
  final ToCEntry entry;
  final Function(ToCEntry) onTap;
  final bool isActive;

  const _ToCItem({
    required this.entry, 
    required this.onTap,
    required this.isActive,
  });

  @override
  State<_ToCItem> createState() => _ToCItemState();
}

class _ToCItemState extends State<_ToCItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final isHighlighted = _isHovered || widget.isActive;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onTap(widget.entry),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            left: (widget.entry.level - 1) * 12.0 + 12,
            right: 12,
            top: 6, // Slightly reduced padding for text-only look
            bottom: 6,
          ),
          child: Text(
            widget.entry.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              color: isHighlighted 
                  ? primaryColor 
                  : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
}
