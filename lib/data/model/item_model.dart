import 'hierarchy_model.dart';

class ItemData extends HierarchyItem {
  final bool hasBuySell;
  final List<VariantData>? variants;
  final double? price;
  final int? quantity;
  final String? unit;
  final String? description;
  final Map<String, dynamic>? location;
  final String? type;

  ItemData({
    required super.nameEn,
    required super.nameSi,
    required super.dbPath,
    this.hasBuySell = true,
    this.variants,
    this.price,
    this.quantity,
    this.unit,
    this.description,
    this.location,
    this.type,
  });

  factory ItemData.fromFirestore(Map<String, dynamic> data) {
    return ItemData(
      nameEn: data['nameEn'],
      nameSi: data['nameSi'],
      dbPath: data['dbPath'],
      price: data['price']?.toDouble(),
      quantity: data['quantity'],
      unit: data['unit'],
      description: data['description'],
      location: data['location'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nameEn': nameEn,
      'nameSi': nameSi,
      'dbPath': dbPath,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'description': description,
      'location': location,
      'type': type,
    };
  }
}

class VariantData extends HierarchyItem {
  VariantData({
    required super.nameEn,
    required super.nameSi,
    required super.dbPath,
  });
}
