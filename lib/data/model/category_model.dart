import 'package:flutter/material.dart';
import 'hierarchy_model.dart';

class CategoryData extends HierarchyItem {
  final IconData? icon;
  final List<SubCategoryData> subCategories;

  CategoryData({
    required super.nameEn,
    required super.nameSi,
    required super.dbPath,
    this.icon,
    required this.subCategories,
  });
}

class SubCategoryData extends HierarchyItem {
  final List<dynamic>? items;
  final bool hasBuySell;

  SubCategoryData({
    required super.nameEn,
    required super.nameSi,
    required super.dbPath,
    this.items,
    this.hasBuySell = false,
  });
}

class DeepCategoryData extends HierarchyItem {
  final List<dynamic>? items; // Made items nullable

  DeepCategoryData({
    required super.nameEn,
    required super.nameSi,
    required super.dbPath,
    required this.items,
  });
}
