import 'package:aswenna/data/model/category_model.dart';
import 'package:aswenna/data/model/hierarchy_model.dart';
import 'package:aswenna/data/model/item_model.dart';
import 'package:aswenna/screens/item_list_screen.dart';
import 'package:flutter/material.dart';

class SubCategoryScreen extends StatelessWidget {
  final dynamic category;
  final List<HierarchyItem> parentPath;

  const SubCategoryScreen({
    super.key,
    required this.category,
    required this.parentPath,
  });

  // Generate a consistent color based on string
  Color _generateColor(String text) {
    final List<Color> colors = [
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.deepOrange,
      Colors.green,
      Colors.pink,
      Colors.cyan,
    ];

    final int index = text.length % colors.length;
    return colors[index];
  }

  Widget _buildItemCard(BuildContext context, dynamic item) {
    final baseColor = _generateColor(item.nameEn);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
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
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [baseColor, baseColor.withOpacity(0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(0.3),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Navigation Arrow
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.getLocalizedName(context),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Secondary Title (if available)
                  if (item is SubCategoryData || item is DeepCategoryData)
                    Text(
                      item.nameEn,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  SizedBox(height: 8),
                  // Additional Info
                  Row(
                    children: [
                      if (item is SubCategoryData && item.items != null)
                        _buildInfoChip(
                          '${item.items?.length ?? 0} items',
                          Colors.white.withOpacity(0.2),
                        ),
                      if (item is SubCategoryData && item.hasBuySell)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _buildInfoChip(
                            'Buy/Sell Available',
                            Colors.white.withOpacity(0.2),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color backgroundColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
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

    final headerColor = _generateColor(category.nameEn);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(category.getLocalizedName(context)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: headerColor,
      ),
      body: CustomScrollView(
        slivers: [
          // Header Section with curved bottom
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(color: headerColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.getLocalizedName(context),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          category.nameEn,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildInfoChip(
                          '${items.length} items available',
                          Colors.white.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
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
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
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
