import 'package:aswenna/core/services/firestore_service.dart';
import 'package:aswenna/data/model/hierarchy_model.dart';
import 'package:aswenna/data/model/item_model.dart';
import 'package:aswenna/screens/item_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemListScreen extends StatelessWidget {
  final ItemData item;
  final List<HierarchyItem> parentPath;
  final firestoreService = FirestoreService();

  ItemListScreen({super.key, required this.item, required this.parentPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.getLocalizedName(context)), elevation: 0),
      body: Column(
        children: [
          if (item.variants != null && item.variants!.isNotEmpty)
            Expanded(child: _buildVariantsList(context))
          else
            Expanded(child: _buildItemView(context)),
          if (item.hasBuySell) _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildVariantsList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: item.variants!.length,
      itemBuilder: (context, index) {
        final variant = item.variants![index];
        return Card(
          child: ListTile(
            title: Text(variant.getLocalizedName(context)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ItemDetailScreen(
                        item: item,
                        variant: variant,
                        parentPath: parentPath,
                      ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildItemView(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: _getItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = snapshot.data?.docs ?? [];
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final itemData = ItemData.fromFirestore(
              items[index].data() as Map<String, dynamic>,
            );
            return _buildItemCard(context, itemData);
          },
        );
      },
    );
  }

  Future<QuerySnapshot> _getItems() {
    final paths = parentPath.map((item) => item.dbPath).toList();
    print(firestoreService.getItems(paths));
    return firestoreService.getItems(paths);
  }

  Widget _buildItemCard(BuildContext context, ItemData itemData) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('${itemData.price} ${itemData.unit}'),
        subtitle: Text(itemData.description ?? ''),
        trailing: Text('${itemData.quantity} available'),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _navigateToSell(context),
              icon: Icon(Icons.sell),
              label: Text('Sell'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _navigateToBuy(context),
              icon: Icon(Icons.shopping_cart),
              label: Text('Buy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSell(BuildContext context) {
    // Implement sell navigation
  }

  void _navigateToBuy(BuildContext context) {
    // Implement buy navigation
  }
}
