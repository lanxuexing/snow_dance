<div align="center">

# ❄️ SnowDance

A premium, high-performance blog engine built with Flutter Web.
Featuring glassmorphism UI, advanced Markdown rendering, and fully automated GitHub Pages deployment.

[![GitHub Release Date](https://img.shields.io/github/release-date/lanxuexing/snow_dance.svg?style=flat-square)](https://github.com/lanxuexing/snow_dance/releases)
[![GitHub repo size](https://img.shields.io/github/repo-size/lanxuexing/snow_dance.svg?style=flat-square)](https://github.com/lanxuexing/snow_dance)
[![GitHub Stars](https://img.shields.io/github/stars/lanxuexing/snow_dance.svg?style=flat-square)](https://github.com/lanxuexing/snow_dance/stargazers)
[![CI/CD](https://github.com/lanxuexing/snow_dance/actions/workflows/deploy.yml/badge.svg)](https://github.com/lanxuexing/snow_dance/actions)
[![GitHub license](https://img.shields.io/github/license/lanxuexing/snow_dance.svg?style=flat-square)](https://github.com/lanxuexing/snow_dance/blob/main/LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat-square&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

[**简体中文**](./README.zh-CN.md) | English

## 🔗 Live Demo
Check out the live site: **[https://lanxuexing.github.io/snow_dance/](https://lanxuexing.github.io/snow_dance/)**

</div>

## ✨ Features

- **🎨 Premium UI/UX**
  - **Dynamic Spinning Snowflake Logo**: Hand-crafted vector snowflake with a smooth floating rotation animation and micro-glow interaction, integrated globally in the startup loader, app bar, and side drawer.
  - **Glassmorphism Design**: Frosted glass effects, subtle gradients, and dark mode support.
  - **Responsive Layout**: Adaptive sidebar and navigation for Desktop, Tablet, and Mobile.
  - **Global Smooth Inertial Scroll**: Mouse drag, trackpad gesture, and physics-based momentum bounds (`BouncingScrollPhysics`) across all platforms (macOS, Windows, Linux, and Web), making scrolling extremely fluid.
  - **Smooth Animations**: Refined transitions and micro-interactions using `flutter_animate`.

- **📝 Advanced Markdown Engine**
  - **Syntax Highlighting**: Code blocks with language detection and styling.
  - **Table of Contents**: Auto-generated ToC with scroll-spy (highlight active section).
  - **Hyperlinks & Smart Redirection**: Full support for clicking markdown links. External links open securely in a new browser tab, while internal routing path links are resolved locally via GoRouter to maintain the single-page application (SPA) experience.
  - **Collapsible Mobile Header**: "Page Overview" panel for quick navigation on small screens.
  - **Deep Linking**: Direct navigation to specific headings.

- **⚡ Performance & User Experience First**
  - **Instant Load & Local CanvasKit Hosting**: Decoupled custom `flutter_bootstrap.js` initialization that downloads CanvasKit directly from our server rather than unstable public unpkg.com CDNs, resolving black screen white-outs and removing the bulky loading rectangle box shadow.
  - **Instant Article Load**: Deprecated expensive runtime manifest scanning by caching the asset file paths directly in the models, shrinking load latency to zero.
  - **Background Full-Text Preloading**: Quietly streams and parses all Markdown articles once the app starts, providing an index of all article bodies for search without sacrificing initial rendering performance.
  - **Algolia-style Search Keyboard Navigation**: Overhauled search with full keyboard navigation (Arrows `↑`/`↓` to cycle focus, `Enter` to navigate, `Esc` to close), hover-sync highlighting, and sub-millisecond search matched against **titles**, **excerpts**, and **full-text contents**.
  - **Sidebar Scroll Offsets Retention**: Attached `PageStorageKey` to the sidebar scroll views to preserve and restore scroll positions across page rebuilds and router navigations.
  - **State Reuse Lifecycle Optimization**: Added article ID change detection and async refresh triggers inside `didUpdateWidget` to prevent loading hangs when swapping articles within GoRouter's route reuse context.
  - **PWA Support**: Installable as a progressive web app.

- **🤖 Automated DevOps**
  - **CI/CD Pipeline**: GitHub Actions workflow for multi-platform build & release.
  - **Auto Deployment**: Automatic deployment to **GitHub Pages**.
  - **Release Management**: Automated semantic release artifacts for Android, Linux, Windows, macOS, and Web.

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Stable channel)
- Dart SDK

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/snow_dance.git
   cd snow_dance
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run locally**
   ```bash
   # Debug mode (faster compilation, slower performance)
   flutter run -d chrome

   # Release mode (production performance, closer to live site)
   flutter run -d chrome --release
   ```

## ✍️ Content Management

Articles are managed as **Markdown files** located in `assets/articles/`.

### Directory Structure
```
assets/articles/
├── blog/           # General blog posts
│   ├── my-post.md
│   └── ...
├── docs/           # Documentation
└── ...
```

### Article Format
You can use **YAML Frontmatter** or standard metadata headers.

**Option 1: YAML Frontmatter (Recommended)**
```markdown
---
title: My Awesome Article
date: 2024-03-20
category: Tech
---

# Introduction
Your content here...
```

**Option 2: Legacy Header**
```markdown
# My Awesome Article

> Date: 2024-03-20
> Category: Tech

Your content here...
```

## 📦 Deployment & CI/CD

This project uses **GitHub Actions** for automated building and deployment.

### Workflow Triggers
- **Push to `main` branch**: Triggers build & deploy.
- **Push `v*` tag** (e.g., `v1.0.0`): Triggers build & release creation.
- **Pull Request**: Triggers build check (CI only, no deploy).

### GitHub Pages Setup
1. Go to repository **Settings** -> **Pages**.
2. Under **Build and deployment** / **Source**, select **GitHub Actions**.
3. Push a commit to `main` to trigger the first deployment.

### Artifacts
The following artifacts are automatically generated and attached to **GitHub Releases**:
- `web.tar.gz` (Web Build)
- `snow_dance_android.apk` (Android)
- `snow_dance_linux.tar.gz` (Linux)
- `snow_dance_windows.zip` (Windows)
- `snow_dance_macos.tar.gz` (macOS)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
