import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snow_dance/widgets/app_header.dart';
import 'package:snow_dance/widgets/app_drawer.dart';
import 'package:snow_dance/widgets/responsive_layout.dart';
import 'package:snow_dance/widgets/search_overlay.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK): () {
          showSearchOverlay(context);
        },
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK): () {
          showSearchOverlay(context);
        },
      },
      child: Focus(
        autofocus: true,
        child: ResponsiveLayout(
          mobile: Scaffold(
            appBar: const AppHeader(),
            drawer: const AppDrawer(),
            body: child,
          ),
          desktop: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Column(
              children: [
                const AppHeader(),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
