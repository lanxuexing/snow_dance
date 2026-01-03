import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snow_dance/widgets/responsive_layout.dart';
import 'package:snow_dance/widgets/search_overlay.dart';
import 'package:snow_dance/core/config/app_config.dart';
import 'package:snow_dance/core/theme/theme_provider.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background.withOpacity(0.7),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  if (ResponsiveLayout.isMobile(context)) ...[
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Logo
                  InkWell(
                    onTap: () => context.go('/'),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.bolt, color: Colors.black, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'SnowDance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Nav Items (Desktop)
                  if (!ResponsiveLayout.isMobile(context)) ...[
                    ...AppConfig.navItems.map((item) => 
                      _buildNavItem(context, item.title, item.route)
                    ),
                  ],
                  const SizedBox(width: 24),
                  // Search Button
                  _buildSearchButton(context),
                  const SizedBox(width: 12),
                  // Dark Mode Toggle
                  IconButton(
                    icon: Icon(
                      Provider.of<ThemeProvider>(context).isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                    onPressed: () {
                      Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => context.go(route),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    
    return InkWell(
      onTap: () => showSearchOverlay(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12, 
          vertical: 8
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).dividerColor.withOpacity(0.05),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 18),
            if (!isMobile) ...[
              const SizedBox(width: 8),
              const Text(
                'Search',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(width: 16),
              const Text(
                '⌘ K',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
