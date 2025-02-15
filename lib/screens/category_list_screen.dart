import 'package:aswenna/data/managers/category_manager.dart';
import 'package:aswenna/data/model/category_model.dart';
import 'package:aswenna/screens/sub_category_screen.dart';
import 'package:flutter/material.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = CategoryManager.getCategories();

    return Scaffold(
      appBar: AppBar(title: Text('Categories'), elevation: 0),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(context, categories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryData category) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(category.icon ?? Icons.folder_outlined),
        title: Text(category.getLocalizedName(context)),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => SubCategoryScreen(
                    category: category,
                    parentPath: [category],
                  ),
            ),
          );
        },
      ),
    );
  }
}
