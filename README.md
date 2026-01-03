# ❄️ SnowDance

**English** | [简体中文](./README.zh-CN.md)

**SnowDance** is a premium, high-performance blog engine built with **Flutter Web**. It features a modern glassmorphism aesthetic, responsive design, and a powerful Markdown rendering engine optimized for technical writing.

## ✨ Features

- **🎨 Premium UI/UX**
  - **Glassmorphism Design**: Frosted glass effects, subtle gradients, and dark mode support.
  - **Responsive Layout**: Adaptive sidebar and navigation for Desktop, Tablet, and Mobile.
  - **Smooth Animations**: Refined transitions and micro-interactions using `flutter_animate`.

- **📝 Advanced Markdown Engine**
  - **Syntax Highlighting**: Code blocks with language detection and styling.
  - **Table of Contents**: Auto-generated ToC with scroll-spy (highlight active section).
  - **Collapsible Mobile Header**: "Page Overview" panel for quick navigation on small screens.
  - **Deep Linking**: Direct navigation to specific headings.

- **⚡ Performance First**
  - **Lazy Loading**: Skeleton screens (`ArticleSkeleton`) for perceived performance.
  - **Deferred Rendering**: Optimization for long articles to prevent UI freezes.
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
