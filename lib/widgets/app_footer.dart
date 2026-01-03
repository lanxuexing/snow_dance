import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      margin: const EdgeInsets.only(top: 60),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.05))), // Subtler border
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(context, FontAwesomeIcons.xTwitter, 'https://twitter.com'),
                  const SizedBox(width: 24),
                  _buildSocialIcon(context, FontAwesomeIcons.github, 'https://github.com/lanxuexing/snow_dance'),
                  const SizedBox(width: 24),
                  _buildSocialIcon(context, FontAwesomeIcons.discord, 'https://discord.com'),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '© 2026 SnowDance Engine. Built with Flutter Web.',
                style: TextStyle(
                  fontSize: 12, // Smaller font
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), // Lighter color
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  Widget _buildFooterItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(title,
          style: const TextStyle(fontSize: 14, color: Colors.grey)),
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon, String url) {
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
          padding: const EdgeInsets.all(8),
          child: FaIcon(
            icon,
            size: 20,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}
