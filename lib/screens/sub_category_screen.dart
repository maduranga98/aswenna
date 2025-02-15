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

  @override
  Widget build(BuildContext context) {
    List<dynamic> items = [];
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
    if (category is CategoryData) {
      items = (category as CategoryData).subCategories;
    } else if (category is SubCategoryData) {
      items =
          (category as SubCategoryData).items ??
          []; // Provide empty list if null
    } else if (category is DeepCategoryData) {
      items =
          (category as DeepCategoryData).items ??
          []; // Provide empty list if null
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(category.getLocalizedName(context)),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildItemCard(context, item);
        },
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, dynamic item) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(item.getLocalizedName(context)),
        trailing: Icon(Icons.chevron_right),
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
      ),
    );
  }
}
