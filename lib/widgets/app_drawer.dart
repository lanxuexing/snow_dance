import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snow_dance/core/config/app_config.dart';
import 'package:snow_dance/core/article_provider.dart';
import 'package:snow_dance/core/theme/theme_provider.dart';

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
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
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
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 24,
        right: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  final Map<String, bool> _expansionStates = {};

  Widget _buildExpandableNavItem(BuildContext context, String title, String route, List categoryArticles) {
    final currentPath = GoRouterState.of(context).uri.toString();
    // Strict category segment match (e.g., /blog matches /blog/xxx but not /)
    final bool isCategorySelected = route != '/' && currentPath.startsWith(route);
    
    // Determine the current expansion state
    // If we haven't tracked it yet, default to whether the category is active
    final bool isExpanded = _expansionStates[title] ?? isCategorySelected;

    return Theme(
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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isCategorySelected ? FontWeight.bold : FontWeight.w500,
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
          final bool isArticleSelected = currentPath.contains(article.id);
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            dense: true,
            title: Text(
              article.title,
              style: TextStyle(
                fontSize: 13,
                color: isArticleSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontWeight: isArticleSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/${article.categoryPath}/${article.id}');
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, String route) {
    final bool isSelected = GoRouterState.of(context).uri.toString() == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1) 
              : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dark Mode',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Switch(
                value: Provider.of<ThemeProvider>(context).isDarkMode,
                onChanged: (value) {
                  Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '© 2026 SnowDance Engine',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
