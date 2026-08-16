import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00DC82); // Dark theme primary (vibrant emerald)
  static const Color lightPrimaryColor = Color(0xFF059669); // Light theme primary (Emerald 600, high contrast & soothing)
  static const Color secondaryColor = Color(0xFF007A5E);
  static const Color lightSecondaryColor = Color(0xFF0D9488);
  static const Color darkBgColor = Color(0xFF020420);
  static const Color lightBgColor = Color(0xFFF9FAFB);


  static const List<String> fontFallbacks = [
    'NotoSansSC',
    'PingFang SC',
    'Microsoft YaHei',
    'Hiragino Sans GB',
    'WenQuanYi Micro Hei',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Helvetica',
    'Arial',
    'sans-serif',
  ];

  static TextStyle outfit({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    ).copyWith(fontFamilyFallback: fontFallbacks);
  }

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      fontStyle: fontStyle,
    ).copyWith(fontFamilyFallback: fontFallbacks);
  }

  static TextStyle firaCode({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    Color? backgroundColor,
    double? height,
  }) {
    return GoogleFonts.firaCode(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      backgroundColor: backgroundColor,
      height: height,
    ).copyWith(fontFamilyFallback: fontFallbacks);
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    final isDark = brightness == Brightness.dark;

    TextStyle withFallback(TextStyle? style, {FontWeight? weight, double? size, Color? color}) {
      return GoogleFonts.inter(
        textStyle: style,
        fontSize: size ?? style?.fontSize,
        fontWeight: weight ?? style?.fontWeight,
        color: color ?? style?.color,
      ).copyWith(fontFamilyFallback: fontFallbacks);
    }

    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ).copyWith(fontFamilyFallback: fontFallbacks),
      displayMedium: GoogleFonts.outfit(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ).copyWith(fontFamilyFallback: fontFallbacks),
      displaySmall: GoogleFonts.outfit(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ).copyWith(fontFamilyFallback: fontFallbacks),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ).copyWith(fontFamilyFallback: fontFallbacks),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ).copyWith(fontFamilyFallback: fontFallbacks),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ).copyWith(fontFamilyFallback: fontFallbacks),
      titleLarge: withFallback(base.titleLarge, size: 20, weight: FontWeight.w600),
      titleMedium: withFallback(base.titleMedium, size: 16, weight: FontWeight.w600),
      titleSmall: withFallback(base.titleSmall, size: 14, weight: FontWeight.w600),
      bodyLarge: withFallback(base.bodyLarge, size: 16),
      bodyMedium: withFallback(base.bodyMedium, size: 14),
      bodySmall: withFallback(base.bodySmall, size: 12),
      labelLarge: withFallback(base.labelLarge, size: 14, weight: FontWeight.w600),
      labelMedium: withFallback(base.labelMedium, size: 12),
      labelSmall: withFallback(base.labelSmall, size: 11),
    );
  }

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Color(0xFF111111),
      surfaceContainer: Color(0xFF1A1A1A),
      surfaceContainerHigh: Color(0xFF222222),
    ),
    scaffoldBackgroundColor: darkBgColor,
    textTheme: _buildTextTheme(Brightness.dark),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A1A1A),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    pageTransitionsTheme: _pageTransitionsTheme,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: lightPrimaryColor,
      secondary: lightSecondaryColor,
      surface: Colors.white,
      surfaceContainer: Color(0xFFF3F4F6),
      surfaceContainerHigh: Color(0xFFE5E7EB),
    ),
    scaffoldBackgroundColor: lightBgColor,
    textTheme: _buildTextTheme(Brightness.light),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    pageTransitionsTheme: _pageTransitionsTheme,
  );

  static const PageTransitionsTheme _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: PureFadePageTransitionsBuilder(),
      TargetPlatform.windows: PureFadePageTransitionsBuilder(),
      TargetPlatform.linux: PureFadePageTransitionsBuilder(),
    },
  );
}

class PureFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const PureFadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}
