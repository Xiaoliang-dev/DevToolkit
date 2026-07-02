import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _showAnimations = true;
  String _defaultTab = 'home';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final theme = prefs.getString('theme_mode') ?? 'system';
      _themeMode = _parseThemeMode(theme);
      _showAnimations = prefs.getBool('show_animations') ?? true;
      _defaultTab = prefs.getString('default_tab') ?? 'home';
    });
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      default:
        value = 'system';
    }
    await prefs.setString('theme_mode', value);
    setState(() => _themeMode = mode);
  }

  Future<void> _saveAnimations(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_animations', value);
    setState(() => _showAnimations = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Appearance'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    _themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : _themeMode == ThemeMode.light
                            ? Icons.light_mode
                            : Icons.brightness_auto,
                  ),
                  title: const Text('Theme'),
                  subtitle: Text(_themeMode == ThemeMode.dark
                      ? 'Dark'
                      : _themeMode == ThemeMode.light
                          ? 'Light'
                          : 'System default'),
                  trailing: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto),
                        label: Text('Auto'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {_themeMode},
                    onSelectionChanged: (set) {
                      if (set.isNotEmpty) {
                        _saveThemeMode(set.first);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.animation),
                  title: const Text('Animations'),
                  subtitle: const Text('Enable transition animations'),
                  value: _showAnimations,
                  onChanged: _saveAnimations,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.developer_mode,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: const Text('DevToolkit'),
                  subtitle: const Text('Version 1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('License'),
                  subtitle: const Text('MIT License'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showLicense(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code_outlined),
                  title: const Text('Source Code'),
                  subtitle: const Text('View on GitHub'),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () => _openGitHub(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Platform Info'),
          Card(
            child: Column(
              children: [
                _buildInfoTile('Platform', _getPlatform()),
                const Divider(height: 1),
                _buildInfoTile('Framework', 'Flutter 3.24+'),
                const Divider(height: 1),
                _buildInfoTile('Dart SDK', '3.5+'),
                const Divider(height: 1),
                _buildInfoTile('Material Design', 'v3'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Made with Flutter',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _getPlatform() {
    if (Theme.of(context).platform == TargetPlatform.android) return 'Android';
    if (Theme.of(context).platform == TargetPlatform.iOS) return 'iOS';
    if (Theme.of(context).platform == TargetPlatform.macOS) return 'macOS';
    if (Theme.of(context).platform == TargetPlatform.windows) return 'Windows';
    if (Theme.of(context).platform == TargetPlatform.linux) return 'Linux';
    return 'Web';
  }

  void _showLicense() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('MIT License'),
        content: const SingleChildScrollView(
          child: Text(
            'Copyright (c) 2024 DevToolkit\n\n'
            'Permission is hereby granted, free of charge, to any person obtaining a copy '
            'of this software and associated documentation files (the "Software"), to deal '
            'in the Software without restriction, including without limitation the rights '
            'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
            'copies of the Software, and to permit persons to whom the Software is '
            'furnished to do so, subject to the following conditions:\n\n'
            'The above copyright notice and this permission notice shall be included in all '
            'copies or substantial portions of the Software.\n\n'
            'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR '
            'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, '
            'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openGitHub() async {
    final uri = Uri.parse('https://github.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
