import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snow_dance/core/article_provider.dart';
import 'package:snow_dance/core/theme/theme_provider.dart';
import 'package:snow_dance/main.dart';

void main() {
  testWidgets('App load and smoke test', (WidgetTester tester) async {
    // Set a desktop viewport size to avoid RenderFlex layout overflow in test environment
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ArticleProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider(initialSavedTheme: 'dark')),
        ],
        child: const MyApp(),
      ),
    );

    // Allow initial frame and staggered animation delay timers to fire
    await tester.pump(const Duration(seconds: 1));

    // Verify that the title 'SnowDance' is rendered.
    expect(find.text('SnowDance'), findsWidgets);

    // Unmount app and pump a frame to clear all timers cleanly
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
