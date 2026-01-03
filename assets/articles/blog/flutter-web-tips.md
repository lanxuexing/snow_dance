# Flutter Web 性能优化指南

> Date: 2024-12-15
> Category: Blog

Flutter Web 近年来在性能方面有了长足的进步，尤其是 CanvasKit 引擎的引入。但在开发大型博客或管理后台时，仍然需要一些技巧来保证流畅度。

## 1. 延迟加载资源

使用 `Deferred Loading` 可以显著减少初始包体积。

```dart
import 'config_page.dart' deferred as config;

// 使用时
await config.loadLibrary();
config.ConfigPage();
```

## 2. 图片优化

不要直接加载原始大图。使用缩略图，并根据屏幕密度加载不同尺寸的图片。

## 3. 避免不必要的重绘

尽可能使用 `const` 构造函数，并合理使用 `RepaintBoundary`。

### 总结
性能优化是一个持续的过程，建议定期使用 `Flutter DevTools` 进行分析。
