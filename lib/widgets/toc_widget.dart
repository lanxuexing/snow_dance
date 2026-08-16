import 'package:flutter/material.dart';

final class ToCEntry {
  final String title;
  final int level;
  final GlobalKey key;
  final String id;

  const ToCEntry({
    required this.title,
    required this.level,
    required this.key,
    String? id,
  }) : id = id ?? title;
}

class TableOfContents extends StatelessWidget {
  final List<ToCEntry> entries;
  final Function(ToCEntry) onTap;
  final String? activeId;
  final String title;

  const TableOfContents({
    super.key, 
    required this.entries, 
    required this.onTap,
    this.activeId,
    this.title = 'On this page',
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ),
        ...entries.map((entry) => _ToCItem(
          entry: entry, 
          onTap: onTap,
          isActive: entry.id == activeId || entry.title == activeId,
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
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isHighlighted = _isHovered || widget.isActive;
 
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () => widget.onTap(widget.entry),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: EdgeInsets.only(
              left: (widget.entry.level - 1) * 12.0 + 8,
              right: 12,
              top: 6,
              bottom: 6,
            ),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? primaryColor.withValues(alpha: 0.08)
                  : (_isHovered ? Theme.of(context).dividerColor.withValues(alpha: 0.04) : Colors.transparent),
              borderRadius: BorderRadius.circular(6),
              border: Border(
                left: BorderSide(
                  color: widget.isActive ? primaryColor : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
            child: Text(
              widget.entry.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
                color: isHighlighted 
                    ? primaryColor 
                    : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
