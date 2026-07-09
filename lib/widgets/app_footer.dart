import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1000;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 16 : 32, 
        horizontal: isMobile ? 16 : 24
      ),
      margin: EdgeInsets.only(top: isMobile ? 32 : 60),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.05))), // Subtler border
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(context, FontAwesomeIcons.xTwitter, 'https://twitter.com', isMobile),
                  SizedBox(width: isMobile ? 16 : 24),
                  _buildSocialIcon(context, FontAwesomeIcons.github, 'https://github.com/lanxuexing/snow_dance', isMobile),
                  SizedBox(width: isMobile ? 16 : 24),
                  _buildSocialIcon(context, FontAwesomeIcons.discord, 'https://discord.com', isMobile),
                ],
              ),
              SizedBox(height: isMobile ? 8 : 16),
              Text(
                '© 2026 SnowDance Engine. Built with Flutter Web.',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12, // Smaller font
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5), // Lighter color
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  Widget _buildSocialIcon(BuildContext context, FaIconData icon, String url, bool isMobile) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      borderRadius: BorderRadius.circular(50),
      child: Opacity(
        opacity: 0.7,
        child: Container(
          padding: EdgeInsets.all(isMobile ? 6 : 8),
          child: FaIcon(
            icon,
            size: isMobile ? 16 : 20,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}
