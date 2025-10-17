import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? docId;
  final String userId;
  final String title;
  final String description;
  final double price;
  final String category; // 'harvest' or 'lands'
  final String type; // 'Paddy', 'Mud Lands', etc.
  final String subType; // 'Improved', 'Suwadel', etc.
  final String listingType; // 'selling' or 'buying'
  final String categoryPath; // 'harvest/Paddy/Improved/selling'
  final String? imageUrl;
  final double? quantity;
  final String? unit; // 'kg', 'acre', etc.
  final String? district;
  final String? dso;
  final String status; // 'active', 'deleted'
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final Map<String, dynamic>? additionalData;

  Product({
    this.docId,
    required this.userId,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.type,
    required this.subType,
    required this.listingType,
    required this.categoryPath,
    this.imageUrl,
    this.quantity,
    this.unit,
    this.district,
    this.dso,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.additionalData,
  });

  /// Convert Firestore map to Product
  factory Product.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Product(
      docId: docId ?? map['docId'],
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      type: map['type'] ?? '',
      subType: map['subType'] ?? '',
      listingType: map['listingType'] ?? '',
      categoryPath: map['categoryPath'] ?? '',
      imageUrl: map['imageUrl'],
      quantity: map['quantity'] != null ? (map['quantity']).toDouble() : null,
      unit: map['unit'],
      district: map['district'],
      dso: map['dso'],
      status: map['status'] ?? 'active',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      deletedAt: map['deletedAt'] != null
          ? (map['deletedAt'] as Timestamp).toDate()
          : null,
      additionalData: map,
    );
  }

  /// Convert Product to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'type': type,
      'subType': subType,
      'listingType': listingType,
      'categoryPath': categoryPath,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'unit': unit,
      'district': district,
      'dso': dso,
      'status': status,
    };
  }

  /// Create copy with modifications
  Product copyWith({
    String? docId,
    String? userId,
    String? title,
    String? description,
    double? price,
    String? category,
    String? type,
    String? subType,
    String? listingType,
    String? categoryPath,
    String? imageUrl,
    double? quantity,
    String? unit,
    String? district,
    String? dso,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return Product(
      docId: docId ?? this.docId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      type: type ?? this.type,
      subType: subType ?? this.subType,
      listingType: listingType ?? this.listingType,
      categoryPath: categoryPath ?? this.categoryPath,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      district: district ?? this.district,
      dso: dso ?? this.dso,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  String toString() {
    return 'Product(docId: $docId, title: $title, price: $price, category: $category)';
  }
}
