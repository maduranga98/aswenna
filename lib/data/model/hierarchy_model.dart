import 'package:aswenna/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class HierarchyItem {
  final String nameEn;
  final String nameSi;
  final String dbPath;

  HierarchyItem({
    required this.nameEn,
    required this.nameSi,
    required this.dbPath,
  });

  String getLocalizedName(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';
    return currentLocale == 'si' ? nameSi : nameEn;
  }
}
