// filter_data_model.dart
import 'package:flutter/foundation.dart';

class FilterData {
  final String? sortBy;
  final String? district;
  final String? dso;
  final double? acres;
  final int? kg;
  final String? filterMethod;
  final String? paddyCode;
  final String? paddyVariety;
  final String? paddyColor;
  final String? paddyType;

  FilterData({
    this.sortBy,
    this.district,
    this.dso,
    this.acres,
    this.kg,
    this.filterMethod,
    this.paddyCode,
    this.paddyVariety,
    this.paddyColor,
    this.paddyType,
  });

  // Convert to a simple Map for Firestore filtering
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {};

    if (district != null) data['district'] = district;
    if (dso != null) data['dso'] = dso;
    if (paddyCode != null) data['paddyCode'] = paddyCode;
    if (paddyVariety != null) data['paddyVariety'] = paddyVariety;
    if (paddyColor != null) data['paddyColor'] = paddyColor;
    if (paddyType != null) data['paddyType'] = paddyType;
    if (acres != null) data['acres'] = acres;
    if (kg != null) data['kg'] = kg;

    return data;
  }

  // Convert to JSON-compatible Map for encoding/decoding
  Map<String, dynamic> toJson() {
    return {
      'sortBy': sortBy,
      'district': district,
      'dso': dso,
      'acres': acres,
      'kg': kg,
      'filterMethod': filterMethod,
      'paddyCode': paddyCode,
      'paddyVariety': paddyVariety,
      'paddyColor': paddyColor,
      'paddyType': paddyType,
    };
  }

  // Create a FilterData object from a JSON-compatible Map
  factory FilterData.fromJson(Map<String, dynamic> json) {
    return FilterData(
      sortBy: json['sortBy'],
      district: json['district'],
      dso: json['dso'],
      acres: json['acres'],
      kg: json['kg'],
      filterMethod: json['filterMethod'],
      paddyCode: json['paddyCode'],
      paddyVariety: json['paddyVariety'],
      paddyColor: json['paddyColor'],
      paddyType: json['paddyType'],
    );
  }

  @override
  String toString() {
    return 'FilterData(sortBy: $sortBy, district: $district, dso: $dso, acres: $acres, kg: $kg, filterMethod: $filterMethod, paddyCode: $paddyCode, paddyVariety: $paddyVariety, paddyColor: $paddyColor, paddyType: $paddyType)';
  }
}
