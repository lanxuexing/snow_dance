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
  - **玻璃拟态设计**：磨砂玻璃特效、细腻的渐变和深色模式支持。
  - **响应式布局**：完美适配桌面端、平板和移动端的侧边栏与导航。
  - **流畅动画**：使用 `flutter_animate` 打造的精致转场与微交互体验。

- **📝 高级 Markdown 引擎**
  - **语法高亮**：代码块自动检测语言并高亮显示。
  - **自动目录 (ToC)**：支持滚动监听（Scroll-spy）的高亮目录。
  - **移动端折叠导航**：在小屏幕上提供便捷的“本页总览”折叠面板。
  - **深度链接**：支持直接锚点跳转到特定章节。

- **⚡ 性能优先**
  - **懒加载**：骨架屏 (`ArticleSkeleton`) 优化视觉加载体验。
  - **延迟渲染**：针对长文章的渲染优化，防止页面卡顿。
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

   # Release 模式 (生产级性能，接近上线效果)
   flutter run -d chrome --release
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
