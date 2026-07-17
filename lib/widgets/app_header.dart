import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snow_dance/widgets/responsive_layout.dart';
import 'package:snow_dance/widgets/search_overlay.dart';
import 'package:snow_dance/widgets/snowflake_logo.dart';
import 'package:snow_dance/core/config/app_config.dart';
import 'package:snow_dance/core/theme/theme_provider.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    String currentLocation = '/';
    try {
      currentLocation = GoRouterState.of(context).uri.path;
    } catch (_) {
      // Fallback for tests or contexts without GoRouter
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.2),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveLayout.isMobile(context) ? 16 : 24,
              ),
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
                        const SnowflakeLogo(size: 26),
                        const SizedBox(width: 10),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF00DC82), Color(0xFF36E4DA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'SnowDance',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Nav Items (Desktop)
                  if (!ResponsiveLayout.isMobile(context)) ...[
                    ...AppConfig.navItems.map((item) => 
                      _buildNavItem(context, item.title, item.route, currentLocation)
                    ),
                  ],
                  const SizedBox(width: 24),
                  // Search Button
                  _buildSearchButton(context),
                  const SizedBox(width: 12),
                  // Theme Mode Selector
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      IconData themeIcon;
                      switch (themeProvider.themeMode) {
                        case ThemeMode.light:
                          themeIcon = Icons.light_mode_outlined;
                          break;
                        case ThemeMode.dark:
                          themeIcon = Icons.dark_mode_outlined;
                          break;
                        case ThemeMode.system:
                          themeIcon = Icons.brightness_6_outlined;
                          break;
                      }
                      return PopupMenuButton<ThemeMode>(
                        icon: Icon(themeIcon),
                        tooltip: '选择主题模式',
                        onSelected: (ThemeMode mode) {
                          themeProvider.setThemeMode(mode);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: ThemeMode.light,
                            child: Row(
                              children: [
                                const Icon(Icons.light_mode_outlined, size: 18),
                                const SizedBox(width: 8),
                                Text('浅色模式', style: GoogleFonts.outfit(fontSize: 14)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: ThemeMode.dark,
                            child: Row(
                              children: [
                                const Icon(Icons.dark_mode_outlined, size: 18),
                                const SizedBox(width: 8),
                                Text('深色模式', style: GoogleFonts.outfit(fontSize: 14)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: ThemeMode.system,
                            child: Row(
                              children: [
                                const Icon(Icons.brightness_6_outlined, size: 18),
                                const SizedBox(width: 8),
                                Text('跟随系统', style: GoogleFonts.outfit(fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      );
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

  Widget _buildNavItem(BuildContext context, String title, String route, String currentLocation) {
    final bool isActive = route == '/' ? currentLocation == '/' : currentLocation.startsWith(route);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => context.go(route),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    
    return InkWell(
      onTap: () => showSearchOverlay(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 16, 
          vertical: 8
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 18),
            if (!isMobile) ...[
              const SizedBox(width: 8),
              Text(
                'Search',
                style: GoogleFonts.outfit(fontSize: 14),
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
