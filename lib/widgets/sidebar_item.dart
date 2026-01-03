import 'package:flutter/material.dart';
import 'package:snow_dance/models/article.dart';

class SidebarItem extends StatefulWidget {
  final Article article;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarItem({
    super.key, 
    required this.article, 
    required this.isSelected, 
    required this.onTap,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine effective active state (hover or selected)
    final isActive = _isHovered || widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isActive 
                ? primaryColor.withOpacity(isDark ? 0.15 : 0.1) 
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isActive ? primaryColor : Colors.transparent,
                width: 3,
              ),
            ),
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
          ),
          child: Text(
            widget.article.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive 
                  ? primaryColor 
                  : (isDark ? Colors.grey[400] : Colors.grey[700]),
            ),
          ),
        ),
      ),
    );
  }
}
