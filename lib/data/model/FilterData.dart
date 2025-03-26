// Update to your existing FilterData model class to support localized district/DSO values

class FilterData {
  final String? sortBy;

  // Original English values for database queries
  final String? district;
  final String? dso;

  // Localized values for display
  final String? districtLocalized;
  final String? dsoLocalized;

  // Other filter fields
  final String? paddyCode;
  final String? paddyVariety;
  final String? paddyColor;
  final String? paddyType;
  final double? acres;
  final int? kg;
  final String? filterMethod;

  FilterData({
    this.sortBy,
    this.district,
    this.dso,
    this.districtLocalized,
    this.dsoLocalized,
    this.paddyCode,
    this.paddyVariety,
    this.paddyColor,
    this.paddyType,
    this.acres,
    this.kg,
    this.filterMethod,
  });

  // Parse FilterData from filter string
  factory FilterData.fromString(String filterString) {
    // Extract values from filter string
    Map<String, dynamic> values = {};

    // Helper function to extract a value
    String? extractValue(String key) {
      if (!filterString.contains('$key:')) return null;

      final start = filterString.indexOf('$key:') + key.length + 1;
      if (start < key.length + 1) return null;

      final end = filterString.indexOf(',', start);
      if (end == -1) return filterString.substring(start).trim();

      return filterString.substring(start, end).trim();
    }

    // Extract sort value
    values['sortBy'] = extractValue('sortBy');

    // Extract district values
    values['district'] = extractValue('district');
    values['districtLocalized'] = extractValue('districtLocalized');

    // Extract DSO values
    values['dso'] = extractValue('dso');
    values['dsoLocalized'] = extractValue('dsoLocalized');

    // Extract other filter values
    values['paddyCode'] = extractValue('paddyCode');
    values['paddyVariety'] = extractValue('paddyVariety');
    values['paddyColor'] = extractValue('paddyColor');
    values['paddyType'] = extractValue('paddyType');

    // Parse numeric values
    if (filterString.contains('acres:')) {
      final acresStr = extractValue('acres');
      if (acresStr != null) {
        values['acres'] = double.tryParse(acresStr);
      }
    }

    if (filterString.contains('kg:')) {
      final kgStr = extractValue('kg');
      if (kgStr != null) {
        values['kg'] = int.tryParse(kgStr);
      }
    }

    values['filterMethod'] = extractValue('filterMethod');

    return FilterData(
      sortBy: values['sortBy'],
      district: values['district'],
      dso: values['dso'],
      districtLocalized: values['districtLocalized'],
      dsoLocalized: values['dsoLocalized'],
      paddyCode: values['paddyCode'],
      paddyVariety: values['paddyVariety'],
      paddyColor: values['paddyColor'],
      paddyType: values['paddyType'],
      acres: values['acres'],
      kg: values['kg'],
      filterMethod: values['filterMethod'],
    );
  }

  // Convert FilterData to a string representation
  String toString() {
    List<String> parts = [];

    if (sortBy != null) parts.add('sortBy: $sortBy');
    if (district != null) parts.add('district: $district');
    if (districtLocalized != null)
      parts.add('districtLocalized: $districtLocalized');
    if (dso != null) parts.add('dso: $dso');
    if (dsoLocalized != null) parts.add('dsoLocalized: $dsoLocalized');
    if (paddyCode != null) parts.add('paddyCode: $paddyCode');
    if (paddyVariety != null) parts.add('paddyVariety: $paddyVariety');
    if (paddyColor != null) parts.add('paddyColor: $paddyColor');
    if (paddyType != null) parts.add('paddyType: $paddyType');
    if (acres != null) parts.add('acres: $acres');
    if (kg != null) parts.add('kg: $kg');
    if (filterMethod != null) parts.add('filterMethod: $filterMethod');

    return parts.join(', ');
  }
}
