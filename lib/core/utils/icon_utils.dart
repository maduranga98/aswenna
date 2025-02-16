// lib/core/utils/icon_utils.dart

import 'package:flutter/material.dart';

class CategoryIcons {
  static IconData getIconForCategory(String categoryPath) {
    final Map<String, IconData> iconMap = {
      'lands': Icons.landscape_outlined,
      'harvest': Icons.eco_outlined,
      'cultivation': Icons.yard_outlined,
      'seeds_plants_and_planting_material': Icons.local_florist_outlined,
      'animal_control': Icons.pets_outlined,
      'processed_productions': Icons.inventory_2_outlined,
      'service_providers': Icons.engineering_outlined,
      'vehicles': Icons.agriculture_outlined,
      'transport': Icons.local_shipping_outlined,
      'machineries': Icons.precision_manufacturing_outlined,
      'agricultural_equipment': Icons.build_outlined,
      'fertilizer': Icons.sanitizer_outlined,
      'agrochemicals': Icons.science_outlined,
      'foreign_market': Icons.storefront_outlined,
      'advice': Icons.tips_and_updates_outlined,
      'information': Icons.help_outline,
    };

    return iconMap[categoryPath.toLowerCase()] ?? Icons.folder_outlined;
  }
}
