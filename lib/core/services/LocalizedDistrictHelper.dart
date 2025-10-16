import 'package:aswenna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:aswenna/data/constants/list_data.dart';
import 'package:aswenna/data/constants/converters/connectors.dart';

class LocalizedDistrictHelper {
  /// Get localized district name from English database value
  static String getLocalizedDistrict(BuildContext context, String? districtEn) {
    if (districtEn == null || districtEn.isEmpty) return '';

    final localizations = AppLocalizations.of(context)!;

    // Get the districts map
    final districtsMap = districtsSet(localizations);

    // The district map structure has English keys and localized values
    // So we can directly look up the English district to get the localized name
    return districtsMap[districtEn.toLowerCase()] ?? districtEn;
  }

  /// Get localized DSO name from English database values
  static String getLocalizedDSO(
    BuildContext context,
    String? districtEn,
    String? dsoEn,
  ) {
    if (districtEn == null ||
        districtEn.isEmpty ||
        dsoEn == null ||
        dsoEn.isEmpty) {
      return '';
    }

    final localizations = AppLocalizations.of(context)!;

    // Get the DSO map for this district
    final dsoMap = districtToDSOConnector(
      localizations,
      districtEn.toLowerCase(),
    );

    // Look up the DSO code to get the localized name
    return dsoMap[dsoEn] ?? dsoEn;
  }

  /// Format district and DSO for display
  static String formatLocation(
    BuildContext context,
    Map<String, dynamic>? item,
  ) {
    if (item == null) return '';

    // If the item already has localized values, use those
    if (item.containsKey('districtLocalized') &&
        item['districtLocalized'] != null) {
      String districtDisplay = item['districtLocalized'];
      String dsoDisplay =
          item.containsKey('dsoLocalized') && item['dsoLocalized'] != null
          ? item['dsoLocalized']
          : getLocalizedDSO(context, item['district'], item['dso']);

      return '$districtDisplay - $dsoDisplay';
    }

    // Otherwise, convert English values to localized
    String districtDisplay = getLocalizedDistrict(context, item['district']);
    String dsoDisplay = getLocalizedDSO(context, item['district'], item['dso']);

    return '$districtDisplay - $dsoDisplay';
  }

  /// Convert English district/DSO to localized for the current app language
  static Map<String, String> convertToLocalized(
    BuildContext context,
    String? districtEn,
    String? dsoEn,
  ) {
    Map<String, String> result = {};

    if (districtEn != null) {
      result['districtEn'] = districtEn;
      result['districtLocalized'] = getLocalizedDistrict(context, districtEn);
    }

    if (districtEn != null && dsoEn != null) {
      result['dsoEn'] = dsoEn;
      result['dsoLocalized'] = getLocalizedDSO(context, districtEn, dsoEn);
    }

    return result;
  }

  /// Extract district and DSO information from a filter string
  static Map<String, String?> extractFromFilterString(String filterString) {
    Map<String, String?> result = {
      'districtEn': null,
      'districtLocalized': null,
      'dsoEn': null,
      'dsoLocalized': null,
      'sortBy': 'all',
    };

    // Parse district values
    if (filterString.contains('district:')) {
      result['districtEn'] = _extractValue(filterString, 'district:');
    }

    if (filterString.contains('districtLocalized:')) {
      result['districtLocalized'] = _extractValue(
        filterString,
        'districtLocalized:',
      );
    }

    // Parse DSO values
    if (filterString.contains('dso:')) {
      result['dsoEn'] = _extractValue(filterString, 'dso:');
    }

    if (filterString.contains('dsoLocalized:')) {
      result['dsoLocalized'] = _extractValue(filterString, 'dsoLocalized:');
    }

    // Parse sort value
    if (filterString.contains('sortBy:')) {
      result['sortBy'] = _extractValue(filterString, 'sortBy:') ?? 'all';
    }

    return result;
  }

  // Helper method to extract values from filter string
  static String? _extractValue(String source, String key) {
    final start = source.indexOf(key) + key.length;
    if (start < key.length) return null;

    final end = source.indexOf(',', start);
    if (end == -1) return source.substring(start).trim();

    return source.substring(start, end).trim();
  }
}
