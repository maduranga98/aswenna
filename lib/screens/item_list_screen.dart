import 'package:aswenna/core/services/firestore_service.dart';
import 'package:aswenna/core/utils/color_utils.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          widget.item.getLocalizedName(context),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom:
            widget.item.hasBuySell
                ? PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.accent,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withOpacity(0.7),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.sell, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                localization.sell,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_cart, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                localization.buy,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                backgroundColor: AppColors.accent,
                child: const Icon(Icons.add, color: Colors.white),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.filter,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  'all',
                  AppLocalizations.of(context)!.all,
                  Icons.all_inclusive,
                ),
                _buildFilterChip(
                  context,
                  'price_low',
                  AppLocalizations.of(context)!.priceLow,
                  Icons.arrow_downward,
                ),
                _buildFilterChip(
                  context,
                  'price_high',
                  AppLocalizations.of(context)!.priceHigh,
                  Icons.arrow_upward,
                ),
                _buildFilterChip(
                  context,
                  'newest',
                  AppLocalizations.of(context)!.newest,
                  Icons.new_releases,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? AppColors.accent : AppColors.textLight,
        ),
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.accent.withOpacity(0.1),
        side: BorderSide(
          color:
              isSelected
                  ? AppColors.accent
                  : AppColors.textLight.withOpacity(0.3),
          width: 1,
        ),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.accent : AppColors.textLight,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        elevation: 0,
        pressElevation: 0,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.accent.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              '${itemData.price} ${itemData.unit}',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (itemData.description != null &&
                              itemData.description!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              itemData.description!,
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Quantity Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            itemData.quantity.toString(),
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.of(context)!.available,
                            style: TextStyle(
                              color: AppColors.success.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Location and Date
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Location not specified',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '2 days ago', // Format the actual date
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
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
