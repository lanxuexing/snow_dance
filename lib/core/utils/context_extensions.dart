import 'package:flutter/material.dart';

/// Flutter 3.44+ 官方推荐的 BuildContext 语义扩展
/// 简化主题、颜色、响应式尺寸与状态的获取，提升代码可读性与性能
extension BuildContextX on BuildContext {
  /// 主题相关快捷访问
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// 性能优化的 MediaQuery 细粒度监听 API (Flutter 3.10+)
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get screenPadding => MediaQuery.paddingOf(this);
  Orientation get orientation => MediaQuery.orientationOf(this);
  double get devicePixelRatio => MediaQuery.devicePixelRatioOf(this);

  /// 响应式断点判断
  bool get isMobile => screenWidth < 800;
  bool get isDesktop => screenWidth >= 800;
}
