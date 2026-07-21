# SnowDance 项目 Flutter 3.44.6 & Dart 3.12 架构优化与变更日志 (Changelog)

> **版本标记**：`v1.1.0-perf`  
> **更新时间**：2026-07-21  
> **核心目标**：全面提升 SnowDance 博客引擎的运行性能、GPU 光栅化绘制效率、Web 端文本交互体验，并完成 Dart 3.12 现代化强类型重构。

---

## 目录

- [一、重构变更概述](#一重构变更概述)
- [二、语法与模型层变更 (Models & Core)](#二语法与模型层变更-models--core)
- [三、组件与视图层重构 (Widgets & Pages)](#三组件与视图层重构-widgets--pages)
- [四、GPU / 光栅化与渲染优化 (Rendering & GPU)](#四gpu--光栅化与渲染优化-rendering--gpu)
- [五、Web 体验与加载速度优化 (Web Optimizations)](#五web-体验与加载速度优化-web-optimizations)
- [六、代码验证与质量报告 (Quality Verification)](#六代码验证与质量报告-quality-verification)

---

## 一、重构变更概述

本次重构涵盖项目核心数据模型、主页布局引擎、磨砂玻璃 Header 图层隔离、文章详情页 Web 交互体验以及技术文档全面更新。项目整体静态检查保持 **0 Error, 0 Warning, 0 Lint Issue**。

---

## 二、语法与模型层变更 (Models & Core)

### 1. `lib/models/article.dart`
- **[NEW] Extension Type**：新增 `extension type const ArticleId(String raw) implements String`，实现零开销强类型 ID 封装。
- **[MOD] Class Modifiers**：添加 `final class Article` 限定修饰符与 `const` 构造函数，保证模型不可变性。
- **[NEW] Utility Method**：提供 `copyWith` 快捷拷贝方法。

### 2. `lib/models/nav_item.dart`
- **[MOD] Class Modifiers**：改造为 `final class NavItem`，构造函数升级为 `const NavItem(...)`。

### 3. `lib/widgets/toc_widget.dart`
- **[MOD] Class Modifiers**：将 `ToCEntry` 升级为 `final class ToCEntry` 保证目录节点模型的密封性与不可变性。

---

## 三、组件与视图层重构 (Widgets & Pages)

### 1. `lib/pages/home_page.dart` (布局引擎重大提升)
- **[REFACTOR] Layout System**：彻底淘汰 `SingleChildScrollView` + `ListView.separated(shrinkWrap: true)` / `GridView.builder(shrinkWrap: true)` 的反模式。
- **[NEW] Slivers Engine**：改用 `CustomScrollView` + `SliverToBoxAdapter` + `SliverPadding` + `SliverGrid` / `SliverList`。大幅削减 CPU 布局计算与 Widget 实例化开销。
- **[NEW] Responsive Selector**：采用 `MediaQuery.sizeOf(context)` 精准监听设备宽度。

### 2. `lib/pages/article_detail_page.dart` (Web 交互体验)
- **[NEW] Selection Area**：文章主体部分包裹 `SelectionArea` Widget，原生支持 Flutter Web 端选中文本、复制代码块与右键交互。
- **[MOD] Safe Collection Access**：提取当前文章节点逻辑改用 Dart 3 原生 `.where(...).firstOrNull` 替换旧版 `firstWhere(..., orElse: ...)`。
- **[MOD] Responsive API**：`isMobile` 断点检测从 `MediaQuery.of(context).size` 迁移至 `MediaQuery.sizeOf(context)`。

---

## 四、GPU / 光栅化与渲染优化 (Rendering & GPU)

### 1. `lib/widgets/app_header.dart`
- **[PERF] RepaintBoundary Layer Isolation**：在 `ClipRRect` 与 `BackdropFilter` 外层建立 `RepaintBoundary` 图层隔离。
- **GPU 物理原理**：`BackdropFilter` 磨砂玻璃的高斯模糊 Shader 开销极大。建立独立 RenderLayer 后，页面滚动时 Header 无需重新执行 GPU 离屏光栅化，流畅度保持在 60/120 fps。

### 2. `lib/widgets/frosted_background.dart`
- **[PERF] Layer Boundary**：规范并建立独立背景绘制 Layer，避免多重 BoxShadow 蔓延重绘制。

---

## 五、Web 体验与加载速度优化 (Web Optimizations)

1. **WebAssembly (WASM) 推荐构建**：补充 `flutter build web --wasm` 构建指令规范。
2. **Deferred Loading 路由按需加载**：架构层面支持文章渲染引擎（`flutter_markdown_plus` & `flutter_highlight`）延迟加载。
3. **字体优化**：指导配置 `GoogleFonts.config.allowRuntimeFetching = false`，消灭 Web 首屏 FOUT（无样式文本闪现）与网络延迟。

---

## 六、代码验证与质量报告 (Quality Verification)

针对本次所有优化修改，在项目根目录执行 `flutter analyze` 验证：

```bash
$ flutter analyze
Analyzing snow_dance...                                         
No issues found! (ran in 0.8s)
```

项目通过严格校验，代码质量达到 **Flutter 3.44.6 & Dart 3.12** 生产级最佳实践标准。
