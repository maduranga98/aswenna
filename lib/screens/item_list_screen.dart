import 'package:aswenna/core/services/firestore_service.dart';
import 'package:aswenna/data/model/hierarchy_model.dart';
import 'package:aswenna/data/model/item_model.dart';
import 'package:aswenna/features/items%20add/itemsAdd.dart';
import 'package:aswenna/screens/item_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemListScreen extends StatefulWidget {
  final ItemData item;
  final List<HierarchyItem> parentPath;

  const ItemListScreen({
    super.key,
    required this.item,
    required this.parentPath,
  });

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final firestoreService = FirestoreService();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.item.getLocalizedName(context)),
        centerTitle: true,
        elevation: 0,
        bottom:
            widget.item.hasBuySell
                ? TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sell),
                          SizedBox(width: 8),
                          Text(localization.sell),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart),
                          SizedBox(width: 8),
                          Text(localization.buy),
                        ],
                      ),
                    ),
                  ],
                )
                : null,
      ),
      body:
          widget.item.variants != null && widget.item.variants!.isNotEmpty
              ? _buildVariantsList(context)
              : _buildTabView(context),
      floatingActionButton:
          widget.item.hasBuySell
              ? FloatingActionButton(
                onPressed: () => _showAddItemDialog(context),
                child: Icon(Icons.add),
                backgroundColor: primaryColor,
              )
              : null,
    );
  }

  Widget _buildTabView(BuildContext context) {
    return Column(
      children: [
        _buildFilterSection(context),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildItemList(context, 'sell'),
              _buildItemList(context, 'buy'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.filter,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  'all',
                  AppLocalizations.of(context)!.all,
                ),
                _buildFilterChip(
                  context,
                  'price_low',
                  AppLocalizations.of(context)!.priceLow,
                ),
                _buildFilterChip(
                  context,
                  'price_high',
                  AppLocalizations.of(context)!.priceHigh,
                ),
                _buildFilterChip(
                  context,
                  'newest',
                  AppLocalizations.of(context)!.newest,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String value, String label) {
    final isSelected = _selectedFilter == value;
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        selectedColor: primaryColor.withOpacity(0.2),
        checkmarkColor: primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildVariantsList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: widget.item.variants!.length,
      itemBuilder: (context, index) {
        final variant = widget.item.variants![index];
        return _buildVariantCard(context, variant);
      },
    );
  }

  Widget _buildVariantCard(BuildContext context, VariantData variant) {
    final baseColor = Theme.of(context).primaryColor;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ItemDetailScreen(
                      item: widget.item,
                      variant: variant,
                      parentPath: widget.parentPath,
                    ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(0.1),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variant.getLocalizedName(context),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          variant.nameEn,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemList(BuildContext context, String type) {
    return FutureBuilder<QuerySnapshot>(
      future: _getItems(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '${AppLocalizations.of(context)!.error}: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final items = snapshot.data?.docs ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == 'sell'
                      ? Icons.sell_outlined
                      : Icons.shopping_cart_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  type == 'sell'
                      ? AppLocalizations.of(context)!.noItemsToSell
                      : AppLocalizations.of(context)!.noItemsToBuy,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
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

  Widget _buildItemCard(BuildContext context, ItemData itemData) {
    final baseColor = Theme.of(context).primaryColor;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.1),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            // Handle item tap
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${itemData.price} ${itemData.unit}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: baseColor,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${itemData.quantity} ${AppLocalizations.of(context)!.available}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (itemData.description != null &&
                    itemData.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      itemData.description!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<QuerySnapshot> _getItems(String type) {
    // Get the base path from parent items
    final basePaths = widget.parentPath.map((item) => item.dbPath).toList();

    // Add the type (sell/buy) to the path
    final paths = [...basePaths, type];

    print('Fetching items with paths: $paths'); // For debugging
    return firestoreService.getItems(paths);
  }

  void _showAddItemDialog(BuildContext context) {
    final isSellTab = _tabController.index == 0;
    final type = isSellTab ? 'sell' : 'buy';

    // Get the base paths from parent items
    final basePaths = widget.parentPath.map((item) => item.dbPath).toList();

    // Add the type (sell/buy) to the path
    final paths = [...basePaths, type];

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ItemsAddPage(paths: paths)),
    ).then((_) {
      // Refresh the list when returning from add page
      setState(() {
        // This will trigger a rebuild and reload the items
      });
    });
  }
}
