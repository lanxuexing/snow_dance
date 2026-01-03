import 'package:snow_dance/models/nav_item.dart';

class AppConfig {
  static final List<NavItem> navItems = [
    NavItem(title: 'Docs', route: '/docs'),
    NavItem(title: 'Guide', route: '/guide'),
    NavItem(title: 'Ecosystem', route: '/ecosystem'),
    NavItem(title: 'Blog', route: '/blog'),
  ];
  
  static const String authorName = 'lanxuexing';
  static const String authorAvatar = 'https://avatars.githubusercontent.com/u/20652750';
}
