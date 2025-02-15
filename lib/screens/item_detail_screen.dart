import 'package:aswenna/data/model/hierarchy_model.dart';
import 'package:aswenna/data/model/item_model.dart';
import 'package:flutter/material.dart';

class ItemDetailScreen extends StatelessWidget {
  final ItemData item;
  final VariantData variant;
  final List<HierarchyItem> parentPath;

  const ItemDetailScreen({
    super.key,
    required this.item,
    required this.variant,
    required this.parentPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(variant.getLocalizedName(context))),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${item.getLocalizedName(context)}'),
            Text('Variant: ${variant.getLocalizedName(context)}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
