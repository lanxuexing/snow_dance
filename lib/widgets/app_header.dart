import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background.withOpacity(0.2),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.05),
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
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF9333EA)], // Blue to Purple
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.snowflake, size: 24, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'SnowDance',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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
          style: GoogleFonts.outfit(
            fontSize: 15,
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 16, 
          vertical: 8
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).dividerColor.withOpacity(0.05),
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
