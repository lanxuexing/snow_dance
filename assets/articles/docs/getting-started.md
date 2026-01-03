---
title: Getting Started with SnowDance
date: 2026-01-01
category: Docs
author: lanxuexing
excerpt: Learn how to set up and customize your SnowDance blog engine.
---

# Getting Started

Welcome to **SnowDance**, a premium blog engine built with Flutter Web. This guide will help you get up and running in minutes.

## 1. Installation

Clone the repository to your local machine:

```bash
git clone https://github.com/your-username/snow_dance.git
cd snow_dance
```

## 2. Install Dependencies

Ensure you have Flutter installed, then run:

```bash
flutter pub get
```

## 3. Adding Content

To add a new article, create a `.md` file in one of the subdirectories under `assets/articles/`:

- `assets/articles/blog/`: For general blog posts.
- `assets/articles/guide/`: For technical guides.
- `assets/articles/docs/`: For project documentation.

## 4. Customization

Edit `lib/core/config/app_config.dart` to change the site name, author information, and navigation links.

```dart
class AppConfig {
  static final List<NavItem> navItems = [
    NavItem(title: 'Docs', route: '/docs/getting-started'),
    // ...
  ];
}
```

Enjoy building beautiful blogs!
