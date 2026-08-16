import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snow_dance/models/article.dart';
import 'package:snow_dance/core/config/app_config.dart';
import 'package:snow_dance/core/article_provider.dart';
import 'package:snow_dance/core/theme/app_theme.dart';
import 'package:snow_dance/core/theme/theme_provider.dart';
import 'package:snow_dance/widgets/snowflake_logo.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ArticleProvider>(context);
    final navItems = AppConfig.navItems;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.85),
                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.6),
              ],
            ),
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    ...navItems.map((item) {
                      // Extract category key from route (e.g., /blog/some-id -> blog)
                      final parts = item.route.split('/').where((p) => p.isNotEmpty).toList();
                      final categoryKey = parts.isNotEmpty ? parts[0].toLowerCase() : '';
                      
                      final categoryArticles = provider.articles
                          .where((a) => a.category.toLowerCase() == categoryKey)
                          .toList();

                      if (categoryArticles.isNotEmpty) {
                        return _buildExpandableNavItem(context, item.title, item.route, categoryArticles);
                      } else {
                        return _buildDrawerItem(context, item.title, item.route);
                      }
                    }),
                  ],
                ),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 12,
        left: 16,
        right: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SnowflakeLogo(
                size: 26,
                gradientColors: Theme.of(context).brightness == Brightness.dark
                    ? const [Color(0xFF00DC82), Color(0xFF36E4DA), Color(0xFF007A5E)]
                    : const [Color(0xFF00BD7E), Color(0xFF36E4DA), Color(0xFF009663)],
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? const [Color(0xFF00DC82), Color(0xFF36E4DA)]
                      : const [Color(0xFF00BD7E), Color(0xFF36E4DA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'SnowDance',
                  style: AppTheme.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  final Map<String, bool> _expansionStates = {};

  Widget _buildExpandableNavItem(BuildContext context, String title, String route, List<Article> categoryArticles) {
    final currentPath = GoRouterState.of(context).uri.toString();
    // Strict category segment match (e.g., /blog matches /blog/xxx but not /)
    final bool isCategorySelected = route != '/' && currentPath.startsWith(route);
    
    // Determine the current expansion state
    // If we haven't tracked it yet, default to whether the category is active
    final bool isExpanded = _expansionStates[title] ?? isCategorySelected;

    return Material(
      type: MaterialType.transparency,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isCategorySelected,
        onExpansionChanged: (expanded) {
          setState(() {
            _expansionStates[title] = expanded;
          });
        },
        trailing: const SizedBox.shrink(), // Hide default rotating icon
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                  style: AppTheme.outfit(
                    fontSize: 15,
                    fontWeight: isCategorySelected ? FontWeight.w600 : FontWeight.w500,
                    color: isCategorySelected ? Theme.of(context).colorScheme.primary : null,
                  ),
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
              size: 20,
              color: isCategorySelected ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
          ],
        ),
        leading: Icon(
          isCategorySelected ? Icons.folder_open : Icons.folder_outlined,
          size: 20,
          color: isCategorySelected ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
        childrenPadding: const EdgeInsets.only(left: 12),
        children: categoryArticles.map((article) {
          final articleRoute = '/${article.categoryPath}/${article.id}';
          final bool isArticleSelected = currentPath == articleRoute;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            dense: true,
            title: Text(
              article.title,
                style: AppTheme.outfit(
                  fontSize: 13,
                  color: isArticleSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  fontWeight: isArticleSelected ? FontWeight.w600 : FontWeight.normal,
                ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              context.go(articleRoute);
            },
          );
        }).toList(),
      ),
    ),
  );
}

  Widget _buildDrawerItem(BuildContext context, String title, String route) {
    final bool isSelected = GoRouterState.of(context).uri.toString() == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            context.go(route);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) 
                : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: AppTheme.outfit(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : null,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '主题模式',
                style: AppTheme.outfit(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              const _ThemeSegmentedControl(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '© 2026 SnowDance Engine',
            style: AppTheme.outfit(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSegmentedControl extends StatelessWidget {
  const _ThemeSegmentedControl();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final modes = [
      (ThemeMode.system, Icons.brightness_auto_outlined, 'System'),
      (ThemeMode.dark, Icons.dark_mode_outlined, 'Dark'),
      (ThemeMode.light, Icons.light_mode_outlined, 'Light'),
    ];

    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: modes.map((item) {
          final mode = item.$1;
          final icon = item.$2;
          final label = item.$3;
          final isSelected = themeProvider.themeMode == mode;

          return Expanded(
            child: GestureDetector(
              onTap: () => themeProvider.setThemeMode(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF282828) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 13,
                      color: isSelected
                          ? primaryColor
                          : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? primaryColor
                            : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
