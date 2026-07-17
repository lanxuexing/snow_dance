<div align="center">

# ❄️ SnowDance

基于 Flutter Web 构建的高性能、高级感博客引擎。
拥有玻璃拟态 UI、强大的 Markdown 渲染及全自动 GitHub Pages 部署流程。 

[![GitHub Release Date](https://img.shields.io/github/release-date/lanxuexing/snow_dance.svg?style=flat-square)](https://github.com/lanxuexing/snow_dance/releases)
[![GitHub repo size](https://img.shields.io/github/repo-size/lanxuexing/snow_dance.svg?style=flat-square)](https://github.com/lanxuexing/snow_dance)
[![GitHub Stars](https://img.shields.io/github/stars/lanxuexing/snow_dance.svg?style=flat-square)](https://github.com/lanxuexing/snow_dance/stargazers)
[![CI/CD](https://github.com/lanxuexing/snow_dance/actions/workflows/deploy.yml/badge.svg)](https://github.com/lanxuexing/snow_dance/actions)
[![GitHub license](https://img.shields.io/github/license/lanxuexing/snow_dance.svg?style=flat-square)](https://github.com/lanxuexing/snow_dance/blob/main/LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat-square&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

[English](./README.md) | **简体中文**

## 🔗 在线演示
点击预览效果：**[https://lanxuexing.github.io/snow_dance/](https://lanxuexing.github.io/snow_dance/)**

</div>

## ✨ 核心特性

- **🎨 极致 UI/UX**
  - **动态旋转雪花 Logo**：全矢量绘制的高级感雪花图标，带悬浮慢速旋转与微拟态发光交互，全局应用于首屏加载器、标题栏及侧边抽屉中。
  - **玻璃拟态设计**：磨砂玻璃特效、细腻的渐变和深色模式支持。
  - **响应式布局**：完美适配桌面端、平板和移动端的侧边栏与导航。
  - **移动端专属排版优化**：微调了小屏设备上的正文边距（`16px`）、导航栏水平 Padding 和抽屉侧边栏 Header/Footer，最大化展示阅读正文，确保像素级的垂直垂线对齐。
  - **全局顺滑惯性滚动**：支持全平台（包含 macOS、Windows、Linux、Web 端）的鼠标拖拽、触控板手势以及自适应物理回弹（`BouncingScrollPhysics`），滚动丝滑无断触。
  - **流畅动画**：使用 `flutter_animate` 打造的精致转场与微交互体验。
  - **专属品牌标志资产 (Favicon)**：使用全新定制的 SnowDance 渐变霓虹科技雪花 Logo 覆盖替换了所有默认的 Flutter 图标，囊括浏览器页签（Favicon）、iOS Touch 快捷方式及 PWA 启动各规格图标。

- **📝 高级 Markdown 引擎**
  - **语法高亮**：代码块自动检测语言并高亮显示。
  - **自动目录 (ToC)**：支持滚动监听（Scroll-spy）的高亮目录。
  - **超链接点击与智能跳转**：支持点击 Markdown 文章内的超链接。外部网站链接采用安全新开标签页访问，站内路由链接自动通过 `GoRouter` 局部刷新，保持单页应用（SPA）流畅体验。
  - **移动端折叠导航**：在小屏幕上提供便捷的“本页总览”折叠面板。
  - **深度链接**：支持直接锚点跳转到特定章节。

- **⚡ 性能与体验优先**
  - **首屏秒开与 CanvasKit 本地托管**：重构并分离 `flutter_bootstrap.js` 以优化加载时机，强制由本站服务器提供 CanvasKit 资源，省去了访问国外 unpkg.com 的网络黑洞，极大缩短了首屏白屏时间，并移除了原先丑陋的加载大矩形阴影。
  - **多平台安全动态 SEO 插件**：利用 Dart 条件导入方案封装了 DOM 读写器，在文章切换时自适应改写 `<title>`、页头描述（Description）、关键词（Keywords）和社交分享所需的 Open Graph（`og:title` 等）卡片信息，同时保证 `flutter test` 在命令行 VM 环境下编译零报错。
  - **搜索引擎蜘蛛爬行引导**：在网站根目录统一部署了规范的 `robots.txt` 和符合 sitemaps.org 标准的 `sitemap.xml`，全部绑定了线上 GitHub Pages 正式生产域名（`https://lanxuexing.github.io/snow_dance/`），并附带 Schema.org 结构化 JSON-LD 数据脚本以提供 Google 富媒体搜索卡片支持。
  - **文章详情秒级打开**：在 `Article` 模型和 `ArticleProvider` 中废弃了每次读取都要执行的耗时 manifest 扫描，直接绑定真实文件相对路径直读，加载延迟降为零。
  - **后台静默全文预加载**：应用在启动完成后，会在后台默默拉取全量文章并解析其 Markdown 内容，在不影响 UI 绘制与首屏性能的同时，让全文检索拥有最完整的数据源。
  - **Algolia 风格键盘导航搜索**：拥有完全定制的 Algolia 检索面板，支持鼠标滑过高亮、键盘 `↓` `↑` 全向高亮控制、`Enter` 键回车直达、`Esc` 键退出，且支持在**文章标题**、**文章摘要**、**全文正文**中进行毫秒级的全文检索。
  - **左侧导航栏滚动持久化**：使用 `PageStorageKey` 机制在组件重建或文章路由切换时自动锁定与恢复导航栏的滚动状态，避免滚动条在切换时自动重置归零。
  - **路由状态监听按需懒加载**：在 `didUpdateWidget` 生命周期方法中，增加了对文章 ID 变动的监听和按需异步重新拉取的逻辑，彻底解决了在同类路由切换（如从一篇文章点击侧栏换到另一篇）时，由于 Widget 实例复用导致页面一直转圈 loading 的恶性 Bug。
  - **PWA 支持**：可作为渐进式 Web 应用安装到本地。

- **🤖 自动化 DevOps**
  - **CI/CD 流水线**：集成了 GitHub Actions 多平台构建与发布流程。
  - **自动部署**：构建后自动部署至 **GitHub Pages**。
  - **版本发布管理**：自动打包并发布 Android, Linux, Windows, macOS 和 Web 版本的 Release 产物。

## 🚀 快速开始

### 环境要求

- [Flutter SDK](https://flutter.cn/docs/get-started/install) (Stable channel)
- Dart SDK

### 安装步骤

1. **克隆仓库**
   ```bash
   git clone https://github.com/your-username/snow_dance.git
   cd snow_dance
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **本地运行**
   ```bash
   # Debug 模式 (编译快，性能一般)
   flutter run -d chrome

   # Release 模式 (生产级性能，使用最新的 WasmGC/Skwasm 渲染引擎)
   flutter run -d chrome --release --wasm
   ```

## ✍️ 内容管理

所有文章均以 **Markdown 文件** 形式存储在 `assets/articles/` 目录下。

### 目录结构
```
assets/articles/
├── blog/           # 通用博客文章
│   ├── my-post.md
│   └── ...
├── docs/           # 文档类内容
└── ...
```

### 文章格式
推荐使用 **YAML Frontmatter** 或标准元数据头。

**方案 1: YAML Frontmatter (推荐)**
```markdown
---
title: 我的精彩文章
date: 2024-03-20
category: Tech
---

# 简介
在这里开始你的正文...
```

**方案 2: 传统头部 (Legacy Header)**
```markdown
# My Awesome Article

> Date: 2024-03-20
> Category: Tech

在这里开始你的正文...
```

## 📦 部署与 CI/CD

本项目使用 **GitHub Actions** 进行自动构建和部署。

### 触发机制
- **推送到 `main` 分支**：触发构建 & 部署 Pages。
- **推送 `v*` 标签** (如 `v1.0.0`)：触发构建 & 发布 Release 产物。
- **Pull Request**：仅触发构建检查 (CI)，不执行部署。

### GitHub Pages 设置
1. 进入仓库 **Settings** -> **Pages**。
2. 在 **Build and deployment** / **Source** 中，选择 **GitHub Actions**。
3. 向 `main` 分支推送一次提交即可触发首次部署。

### 构建产物
以下产物会自动生成并上传至 **GitHub Releases**：
- `web.tar.gz` (Web 版)
- `snow_dance_android.apk` (Android 版)
- `snow_dance_linux.tar.gz` (Linux 版)
- `snow_dance_windows.zip` (Windows 版)
- `snow_dance_macos.tar.gz` (macOS 版)

## 📄 许可证

本项目基于 MIT 许可证开源 - 详情请参阅 LICENSE 文件。
