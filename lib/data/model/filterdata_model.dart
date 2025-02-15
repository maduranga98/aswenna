class FilterData {
  final String? sortBy;
  final double? acres;
  final int? kg;
  final String? paddyColor;
  final String? paddyType;
  final String? paddyCode;
  final String? paddyVariety;

  FilterData({
    this.sortBy,
    this.acres,
    this.kg,
    this.paddyColor,
    this.paddyType,
    this.paddyCode,
    this.paddyVariety,
  });

  Map<String, dynamic> toMap() {
    return {
      if (sortBy != null) 'sortBy': sortBy,
      if (acres != null) 'acres': acres,
      if (kg != null) 'kg': kg,
      if (paddyColor != null) 'paddyColor': paddyColor,
      if (paddyType != null) 'paddyType': paddyType,
      if (paddyCode != null) 'paddyCode': paddyCode,
      if (paddyVariety != null) 'paddyVariety': paddyVariety,
    };
  }

  static FilterData fromMap(Map<String, dynamic> map) {
    return FilterData(
      sortBy: map['sortBy'] as String?,
      acres: map['acres'] as double?,
      kg: map['kg'] as int?,
      paddyColor: map['paddyColor'] as String?,
      paddyType: map['paddyType'] as String?,
      paddyCode: map['paddyCode'] as String?,
      paddyVariety: map['paddyVariety'] as String?,
    );
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
