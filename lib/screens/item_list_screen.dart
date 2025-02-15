import 'package:aswenna/core/services/firestore_service.dart';
import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/data/model/hierarchy_model.dart';
import 'package:aswenna/data/model/item_model.dart';
import 'package:aswenna/features/items%20add/itemsAdd.dart';
import 'package:aswenna/screens/item_detail_screen.dart';
import 'package:aswenna/widgets/filterBottomSheet.dart';
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
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.accent,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
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
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showFilterBottomSheet(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.filter_list, color: AppColors.accent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getFilterLabel(context),
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final basePaths = widget.parentPath.map((item) => item.dbPath).toList();
    final type = _tabController.index == 0 ? 'sell' : 'buy';
    final paths = [...basePaths, widget.item.dbPath, type];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FilterBottomSheet(
            paths: paths,
            selectedFilter: _selectedFilter,
            onFilterChanged: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
          ),
    );
  }

  String _getFilterLabel(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    switch (_selectedFilter) {
      case 'price_low':
        return localization.priceLow;
      case 'price_high':
        return localization.priceHigh;
      case 'newest':
        return localization.newest;
      default:
        return localization.all;
    }
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
                  color: baseColor.withValues(alpha: 0.1),
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
            color: AppColors.primary.withValues(alpha: 0.08),
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
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.2),
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
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.2),
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
                              color: AppColors.success.withValues(alpha: 0.8),
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
