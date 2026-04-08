import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vesper_flutter/core/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: 'AI & TRANSCRIPTION'),
          ListTile(
            leading: Icon(PhosphorIcons.key()),
            title: const Text('Groq API Key'),
            subtitle: const Text('Required for summarization and action items'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(PhosphorIcons.translate()),
            title: const Text('Transcription Mode'),
            subtitle: const Text('On-device (Default)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          _SectionHeader(title: 'APPEARANCE'),
          ListTile(
            leading: Icon(PhosphorIcons.palette()),
            title: const Text('Theme'),
            subtitle: const Text('System'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(PhosphorIcons.textT()),
            title: const Text('Font Size'),
            subtitle: const Text('Medium'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          _SectionHeader(title: 'SUPPORT'),
          ListTile(
            leading: Icon(PhosphorIcons.coffee(), color: Colors.orange),
            title: const Text('Buy me a coffee'),
            subtitle: const Text('Support Vesper development'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // Open Ko-Fi link
            },
          ),
          ListTile(
            leading: Icon(PhosphorIcons.githubLogo()),
            title: const Text('GitHub Repository'),
            subtitle: const Text('Vesper is open source'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {},
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Vesper v1.0.0',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
