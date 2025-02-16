import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/core/utils/icon_utils.dart';
import 'package:flutter/material.dart';
import 'package:aswenna/data/model/category_model.dart';
import 'package:aswenna/data/model/hierarchy_model.dart';
import 'package:aswenna/data/model/item_model.dart';
import 'package:aswenna/screens/item_list_screen.dart';

class SubCategoryScreen extends StatelessWidget {
  final dynamic category;
  final List<HierarchyItem> parentPath;

  const SubCategoryScreen({
    super.key,
    required this.category,
    required this.parentPath,
  });

  // Generate category-specific colors from our palette
  Color _generateColor(String text) {
    final List<Color> colors = [
      const Color(0xFF34495E), // Primary slate blue
      const Color(0xFF3A5067), // Lighter slate blue
      const Color(0xFF7E8C8D), // Steel grey
      const Color(0xFF2C3E50), // Dark slate
      // Warning orange
    ];

    final int index = text.length % colors.length;
    return colors[index];
  }

  IconData _getHeaderIcon() {
    if (category is CategoryData) {
      return CategoryIcons.getIconForCategory(category.dbPath);
    }
    return Icons.folder_outlined;
  }

  Widget _buildItemCard(BuildContext context, dynamic item) {
    final baseColor = _generateColor(item.nameEn);
    final bool isParentCategory =
        item is SubCategoryData || item is DeepCategoryData;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (item is ItemData) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ItemListScreen(
                        item: item,
                        parentPath: [...parentPath, item],
                      ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => SubCategoryScreen(
                        category: item,
                        parentPath: [...parentPath, item],
                      ),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withValues(alpha: 0.08),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [baseColor, baseColor.withValues(alpha: 0.9)],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon and Title Column
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isParentCategory
                                    ? Icons.folder
                                    : Icons.inventory,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.getLocalizedName(context),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  if (isParentCategory) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.nameEn,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 16,
                      ),
                    ],
                  ),
                ),
                // Info Section
                if (isParentCategory)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        if (item is SubCategoryData && item.items != null)
                          _buildInfoChip(
                            '${item.items?.length ?? 0} items',
                            baseColor.withValues(alpha: 0.1),
                            baseColor,
                          ),
                        if (item is SubCategoryData && item.hasBuySell)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _buildInfoChip(
                              'Buy/Sell Available',
                              const Color(0xFFD4B572).withValues(alpha: 0.1),
                              const Color(0xFFD4B572),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (category is SubCategoryData &&
        (category as SubCategoryData).hasBuySell &&
        (category as SubCategoryData).items == null) {
      return ItemListScreen(
        item: ItemData(
          nameEn: category.nameEn,
          nameSi: category.nameSi,
          dbPath: 'items',
          hasBuySell: true,
        ),
        parentPath: parentPath,
      );
    }

    List<dynamic> items = [];
    if (category is CategoryData) {
      items = (category as CategoryData).subCategories;
    } else if (category is SubCategoryData) {
      items = (category as SubCategoryData).items ?? [];
    } else if (category is DeepCategoryData) {
      items = (category as DeepCategoryData).items ?? [];
    }

    final headerColor = const Color(0xFF34495E); // Primary slate blue

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const SizedBox.shrink(), // Empty title
        centerTitle: true,
        elevation: 0,
        backgroundColor: headerColor,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // This ensures all icons are white
      ),
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    headerColor,
                    const Color(0xFF3A5067), // Lighter slate blue
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getHeaderIcon(),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.getLocalizedName(context),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category.nameEn,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFD4B572,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(
                                0xFFD4B572,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '${items.length} items available',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // List Section
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = items[index];
                return _buildItemCard(context, item);
              }, childCount: items.length),
            ),
          ),
        ],
      ),
    );
  }
}
