import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const SettingsPage({super.key, required this.themeNotifier});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Supported languages
  final List<Map<String, String>> _languages = [
    {"code": "en_US", "name": "English (US)"},
    {"code": "en_GB", "name": "English (UK)"},
    {"code": "es_ES", "name": "Spanish"},
    {"code": "fr_FR", "name": "French"},
    {"code": "de_DE", "name": "German"},
  ];

  String _selectedLanguage = "en_US";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Speech Recognition Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedLanguage,
              items: _languages.map((language) {
                return DropdownMenuItem<String>(
                  value: language['code'],
                  child: Text(language['name']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                }
              },
              isExpanded: true,
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dark Mode',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: widget.themeNotifier.value == ThemeMode.dark,
                  onChanged: (bool value) {
                    setState(() {
                      widget.themeNotifier.value =
                          value ? ThemeMode.dark : ThemeMode.light;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
