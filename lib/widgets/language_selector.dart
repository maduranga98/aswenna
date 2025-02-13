import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelector extends StatelessWidget {
  final bool isDark;

  const LanguageSelector({super.key, this.isDark = false});

  Future<void> _changeLanguage(
    BuildContext context,
    String languageCode,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lan', languageCode);
    userData['lan'] = languageCode;

    // Update the locale using the provider
    Provider.of<LocaleProvider>(
      context,
      listen: false,
    ).setLocale(Locale(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.language_outlined,
        color: isDark ? Colors.white70 : Colors.white,
      ),
      onSelected: (String code) => _changeLanguage(context, code),
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'si',
              child: Row(
                children: [
                  Text(
                    'අ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 12),
                  Text('සිංහල'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  Text(
                    'A',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 12),
                  Text('English'),
                ],
              ),
            ),
          ],
    );
  }
}
