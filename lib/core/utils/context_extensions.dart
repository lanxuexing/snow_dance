import 'package:flutter/material.dart';

/// Flutter 3.47+ & Dart 3.13 现代语义扩展与细粒度监听
/// 细化 MediaQuery 订阅粒度，彻底消除因键盘/窗口微变触发的全量 Widget 树重建
extension BuildContextX on BuildContext {
  // --- 主题与色彩系统 (Theme & Color Tokens) ---
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;
  Color get primaryColor => colorScheme.primary;
  Color get surfaceColor => colorScheme.surface;
  Color get cardColor => theme.cardTheme.color ?? colorScheme.surface;
  Color get dividerColor => theme.dividerColor;

  // --- 高性能细粒度 MediaQuery 监听 (Fine-grained API) ---
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get screenPadding => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  Orientation get orientation => MediaQuery.orientationOf(this);
  double get devicePixelRatio => MediaQuery.devicePixelRatioOf(this);

  // --- 现代响应式断点 (Pattern / Range Breakpoints) ---
  bool get isMobile => screenWidth < 800;
  bool get isTablet => screenWidth >= 800 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 800;
  bool get isWideDesktop => screenWidth >= 1440;

  // --- 快捷交互操作 ---
  void unfocus() => FocusScope.of(this).unfocus();
}
