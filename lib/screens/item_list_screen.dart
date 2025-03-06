import 'package:aswenna/core/services/firestore_service.dart';
import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/data/model/filterdata_model.dart';
import 'package:aswenna/data/model/hierarchy_model.dart';
import 'package:aswenna/data/model/item_model.dart';
import 'package:aswenna/features/items%20add/itemsAdd.dart';
import 'package:aswenna/features/items%20view/item_view.dart';
import 'package:aswenna/widgets/filterBottomSheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

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
  final _firestoreService = FirestoreService();
  late TabController _tabController;

  // Filtering options
  String _selectedFilter = 'all';
  String? _selectedDistrict;
  String? _selectedDSO;
  FilterData? _activeFilter;

  // Pagination variables for both tabs
  bool _isLoadingSell = false;
  bool _hasMoreItemsSell = true;
  List<DocumentSnapshot> _itemsSell = [];
  DocumentSnapshot? _lastDocumentSell;

  bool _isLoadingBuy = false;
  bool _hasMoreItemsBuy = true;
  List<DocumentSnapshot> _itemsBuy = [];
  DocumentSnapshot? _lastDocumentBuy;

  final int _pageSize = 10;
  final ScrollController _scrollControllerSell = ScrollController();
  final ScrollController _scrollControllerBuy = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initialize TabController with 2 tabs (sell and buy)
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Load initial items for the first tab (sell)
    _loadInitialItems('sell');

    // Add scroll listeners for pagination
    _scrollControllerSell.addListener(() {
      if (_scrollControllerSell.position.pixels >=
              _scrollControllerSell.position.maxScrollExtent * 0.8 &&
          !_isLoadingSell &&
          _hasMoreItemsSell) {
        _loadMoreItems('sell');
      }
    });

    _scrollControllerBuy.addListener(() {
      if (_scrollControllerBuy.position.pixels >=
              _scrollControllerBuy.position.maxScrollExtent * 0.8 &&
          !_isLoadingBuy &&
          _hasMoreItemsBuy) {
        _loadMoreItems('buy');
      }
    });
  }

  void _handleTabChange() {
    // Load items for the buy tab when switching to it for the first time
    if (_tabController.index == 1 && _itemsBuy.isEmpty && !_isLoadingBuy) {
      _loadInitialItems('buy');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollControllerSell.dispose();
    _scrollControllerBuy.dispose();
    super.dispose();
  }

  List<String> _getPathSegments(String type) {
    final List<String> pathSegments =
        widget.parentPath.map((item) => item.dbPath).toList();

    // Add the current item's dbPath and type
    // pathSegments.add(widget.item.dbPath);
    pathSegments.add(type);

    return pathSegments;
  }

  Future<void> _loadInitialItems(String type) async {
    setState(() {
      if (type == 'sell') {
        _isLoadingSell = true;
        _itemsSell = [];
        _lastDocumentSell = null;
      } else {
        _isLoadingBuy = true;
        _itemsBuy = [];
        _lastDocumentBuy = null;
      }
    });

    try {
      final pathSegments = _getPathSegments(type);
      final snapshot = await _firestoreService.getItemsPaginated(
        pathSegments,
        pageSize: _pageSize,
        filters: _buildFilters(),
        orderBy: _getOrderByField(),
        descending: _getOrderDirection(),
      );

      setState(() {
        if (type == 'sell') {
          _itemsSell = snapshot.docs;
          if (snapshot.docs.isNotEmpty) {
            _lastDocumentSell = snapshot.docs.last;
          }
          _hasMoreItemsSell = snapshot.docs.length >= _pageSize;
          _isLoadingSell = false;
        } else {
          _itemsBuy = snapshot.docs;
          if (snapshot.docs.isNotEmpty) {
            _lastDocumentBuy = snapshot.docs.last;
          }
          _hasMoreItemsBuy = snapshot.docs.length >= _pageSize;
          _isLoadingBuy = false;
        }
      });
    } catch (e) {
      setState(() {
        if (type == 'sell') {
          _isLoadingSell = false;
        } else {
          _isLoadingBuy = false;
        }
      });
      _showErrorSnackbar('Error loading items: $e');
    }
  }

  Future<void> _loadMoreItems(String type) async {
    if ((type == 'sell' && (!_hasMoreItemsSell || _isLoadingSell)) ||
        (type == 'buy' && (!_hasMoreItemsBuy || _isLoadingBuy))) {
      return;
    }

    setState(() {
      if (type == 'sell') {
        _isLoadingSell = true;
      } else {
        _isLoadingBuy = true;
      }
    });

    try {
      final pathSegments = _getPathSegments(type);
      final snapshot = await _firestoreService.getItemsPaginated(
        pathSegments,
        lastDocument: type == 'sell' ? _lastDocumentSell : _lastDocumentBuy,
        pageSize: _pageSize,
        filters: _buildFilters(),
        orderBy: _getOrderByField(),
        descending: _getOrderDirection(),
      );

      setState(() {
        if (type == 'sell') {
          if (snapshot.docs.isNotEmpty) {
            _itemsSell.addAll(snapshot.docs);
            _lastDocumentSell = snapshot.docs.last;
          }
          _hasMoreItemsSell = snapshot.docs.length >= _pageSize;
          _isLoadingSell = false;
        } else {
          if (snapshot.docs.isNotEmpty) {
            _itemsBuy.addAll(snapshot.docs);
            _lastDocumentBuy = snapshot.docs.last;
          }
          _hasMoreItemsBuy = snapshot.docs.length >= _pageSize;
          _isLoadingBuy = false;
        }
      });
    } catch (e) {
      setState(() {
        if (type == 'sell') {
          _isLoadingSell = false;
        } else {
          _isLoadingBuy = false;
        }
      });
      _showErrorSnackbar('Error loading more items: $e');
    }
  }

  Map<String, dynamic>? _buildFilters() {
    Map<String, dynamic> filters = {};

    if (_selectedDistrict != null) {
      filters['district'] = _selectedDistrict;
    }

    if (_selectedDSO != null) {
      filters['dso'] = _selectedDSO;
    }

    if (_activeFilter != null) {
      // Add other filter conditions from FilterData
      if (_activeFilter!.paddyCode != null) {
        filters['paddyCode'] = _activeFilter!.paddyCode;
      }
      if (_activeFilter!.paddyVariety != null) {
        filters['paddyVariety'] = _activeFilter!.paddyVariety;
      }
      if (_activeFilter!.paddyColor != null) {
        filters['paddyColor'] = _activeFilter!.paddyColor;
      }
      if (_activeFilter!.paddyType != null) {
        filters['paddyType'] = _activeFilter!.paddyType;
      }
    }

    return filters.isEmpty ? null : filters;
  }

  String? _getOrderByField() {
    switch (_selectedFilter) {
      case 'price_low':
      case 'price_high':
        return 'price';
      case 'newest':
        return 'createdAt';
      default:
        return 'createdAt';
    }
  }

  bool _getOrderDirection() {
    switch (_selectedFilter) {
      case 'price_low':
        return false; // Ascending
      case 'price_high':
        return true; // Descending
      case 'newest':
        return true; // Descending
      default:
        return true; // Default to newest first
    }
  }

  void _showFilterBottomSheet() {
    final type = _tabController.index == 0 ? 'sell' : 'buy';
    final pathSegments = _getPathSegments(type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FilterBottomSheet(
            paths: pathSegments,
            selectedFilter: _selectedFilter,
            onFilterChanged: (value) {
              // Parse the filter string
              setState(() {
                _selectedFilter = value;

                // Parse the filter data
                if (value.contains('district:')) {
                  _selectedDistrict = _extractValue(value, 'district:');
                }
                if (value.contains('dso:')) {
                  _selectedDSO = _extractValue(value, 'dso:');
                }

                // Reload with new filters
                _loadInitialItems('sell');
                if (_tabController.index == 1 || !_itemsBuy.isEmpty) {
                  _loadInitialItems('buy');
                }
              });
            },
          ),
    );
  }

  String? _extractValue(String source, String key) {
    final start = source.indexOf(key) + key.length;
    if (start < key.length) return null;

    final end = source.indexOf(',', start);
    if (end == -1) return source.substring(start).trim();

    return source.substring(start, end).trim();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  Future<void> _navigateToAddItem() async {
    final type = _tabController.index == 0 ? 'sell' : 'buy';
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemsAddPage(paths: _getPathSegments(type)),
      ),
    );

    // Refresh the list if an item was added
    if (result == true) {
      _loadInitialItems(type);
    }
  }

  Future<void> _viewItemDetails(DocumentSnapshot document) async {
    final type = _tabController.index == 0 ? 'sell' : 'buy';
    final data = document.data() as Map<String, dynamic>;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ItemViewPage(
              documentId: document.id,
              pathSegments: _getPathSegments(type),
              mainNameE: widget.parentPath.first.nameEn,
              secondNameE: widget.item.nameEn,
              itemData: data,
            ),
      ),
    );

    // Refresh if item was deleted or updated
    if (result == true) {
      _loadInitialItems(type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      // Modify the AppBar in the build method to include the filter row under TabBar
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
        // Remove the filter button from actions
        bottom:
            widget.item.hasBuySell
                ? PreferredSize(
                  preferredSize: const Size.fromHeight(
                    100,
                  ), // Increased height to accommodate filter row
                  child: Column(
                    children: [
                      // TabBar
                      Container(
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

                      // Filter Row
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: AppColors.background,
                        child: InkWell(
                          onTap: _showFilterBottomSheet,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.secondary.withOpacity(0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.05),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.filter_list,
                                  color: AppColors.accent,
                                  size: 20,
                                ),
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
                      ),
                    ],
                  ),
                )
                : null,
      ),
      body:
          widget.item.variants != null && widget.item.variants!.isNotEmpty
              ? _buildVariantsList(context)
              : TabBarView(
                controller: _tabController,
                children: [_buildTabContent('sell'), _buildTabContent('buy')],
              ),
      floatingActionButton:
          widget.item.hasBuySell
              ? FloatingActionButton(
                onPressed: _navigateToAddItem,
                backgroundColor: AppColors.accent,
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
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
        // Add active filters if available
        if (_selectedDistrict != null ||
            _selectedDSO != null ||
            _activeFilter != null) {
          List<String> activeFilters = [];

          if (_selectedDistrict != null) {
            activeFilters.add(_selectedDistrict!);
          }

          if (_selectedDSO != null) {
            activeFilters.add(_selectedDSO!);
          }

          if (_activeFilter != null) {
            if (_activeFilter!.paddyCode != null) {
              activeFilters.add("Code: ${_activeFilter!.paddyCode}");
            }
            if (_activeFilter!.paddyVariety != null) {
              activeFilters.add("Variety: ${_activeFilter!.paddyVariety}");
            }
            if (_activeFilter!.paddyColor != null) {
              activeFilters.add("Color: ${_activeFilter!.paddyColor}");
            }
            if (_activeFilter!.paddyType != null) {
              activeFilters.add("Type: ${_activeFilter!.paddyType}");
            }
          }

          if (activeFilters.isNotEmpty) {
            return activeFilters.join(', ');
          }
        }

        return localization.all;
    }
  }

  Widget _buildTabContent(String type) {
    final isLoadingItems = type == 'sell' ? _isLoadingSell : _isLoadingBuy;
    final hasMoreItems = type == 'sell' ? _hasMoreItemsSell : _hasMoreItemsBuy;
    final items = type == 'sell' ? _itemsSell : _itemsBuy;
    final scrollController =
        type == 'sell' ? _scrollControllerSell : _scrollControllerBuy;

    if (isLoadingItems && items.isEmpty) {
      return _buildLoadingIndicator();
    }

    if (items.isEmpty) {
      return _buildEmptyState(type);
    }

    return Column(
      children: [
        // Filter indicator
        if (_selectedDistrict != null ||
            _selectedDSO != null ||
            _activeFilter != null)
          _buildActiveFilters(),

        // Items list
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: items.length + (hasMoreItems ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == items.length) {
                return isLoadingItems
                    ? _buildLoadingIndicator()
                    : SizedBox.shrink();
              }

              return _buildItemCard(items[index]);
            },
          ),
        ),
      ],
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
            // Navigate to variant details
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

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Icon(Icons.filter_alt_outlined, size: 16, color: AppColors.primary),
          SizedBox(width: 8),
          Text(
            'Filtered by:',
            style: TextStyle(color: AppColors.textLight, fontSize: 13),
          ),
          SizedBox(width: 8),
          if (_selectedDistrict != null) _buildFilterChip(_selectedDistrict!),
          if (_selectedDSO != null) _buildFilterChip(_selectedDSO!),
          Spacer(),
          IconButton(
            icon: Icon(Icons.clear, size: 16, color: AppColors.textLight),
            onPressed: () {
              setState(() {
                _selectedDistrict = null;
                _selectedDSO = null;
                _activeFilter = null;
                _loadInitialItems('sell');
                if (_tabController.index == 1 || !_itemsBuy.isEmpty) {
                  _loadInitialItems('buy');
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: AppColors.primary, fontSize: 12),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(color: AppColors.textLight, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'sell' ? Icons.sell_outlined : Icons.shopping_cart_outlined,
            size: 64,
            color: AppColors.textLight.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            type == 'sell'
                ? 'Be the first to add an item for sale'
                : 'No buy requests available',
            style: TextStyle(color: AppColors.textLight, fontSize: 16),
          ),
          SizedBox(height: 24),
          if (widget.item.hasBuySell)
            ElevatedButton.icon(
              onPressed: _navigateToAddItem,
              icon: Icon(Icons.add),
              label: Text(
                type == 'sell' ? 'Add Item for Sale' : 'Add Buy Request',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemCard(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    String? imageUrl;

    // Find the first available image
    for (int i = 1; i <= 5; i++) {
      if (data['image${i}URL'] != null &&
          data['image${i}URL'].toString().isNotEmpty) {
        imageUrl = data['image${i}URL'];
        break;
      }
    }

    // Format timestamp
    String formattedDate = 'Recently';
    if (data['createdAt'] != null) {
      try {
        final timestamp = data['createdAt'] as Timestamp;
        final dateTime = timestamp.toDate();
        formattedDate = DateFormat('MMM d').format(dateTime);
      } catch (e) {
        // Use default if formatting fails
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.secondary.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewItemDetails(document),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemHeader(data, formattedDate),
              const SizedBox(height: 12),
              _buildItemContent(data, imageUrl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemHeader(Map<String, dynamic> data, String formattedDate) {
    return Row(
      children: [
        Icon(Icons.location_on, size: 16, color: AppColors.primary),
        SizedBox(width: 8),
        Text(
          "${data["district"] ?? ''}-${data["dso"] ?? ''}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.text,
            fontSize: 14,
          ),
        ),
        Spacer(),
        Icon(
          Icons.calendar_today_outlined,
          size: 14,
          color: AppColors.textLight,
        ),
        SizedBox(width: 4),
        Text(
          formattedDate,
          style: TextStyle(color: AppColors.textLight, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildItemContent(Map<String, dynamic> data, String? imageUrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item image
        _buildItemImage(imageUrl),
        SizedBox(width: 12),

        // Item details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show different content based on item type
              if (data['acres'] != null) ...[
                // Land listing
                Text(
                  "Acres: ${data['acres']} - Perches: ${data['perches'] ?? '0'}",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.text,
                  ),
                ),
              ] else if (data['kg'] != null) ...[
                // Harvest listing
                Text(
                  "Quantity: ${data['kg']} kg",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.text,
                  ),
                ),

                if (data['paddyVariety'] != null)
                  Text(
                    "Variety: ${data['paddyVariety']}",
                    style: TextStyle(fontSize: 13, color: AppColors.textLight),
                  ),
              ],

              // Show price for all items
              SizedBox(height: 8),
              Text(
                "Rs. ${data['price'] ?? 'N/A'}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              // Item description (truncated)
              if (data['details'] != null &&
                  data['details'].toString().isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  data['details'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: AppColors.textLight),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemImage(String? imageUrl) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          imageUrl != null && imageUrl.isNotEmpty
              ? _buildSafeNetworkImage(imageUrl)
              : Container(
                color: AppColors.primary.withValues(alpha: 0.1),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: AppColors.primary.withValues(alpha: 0.5),
                    size: 24,
                  ),
                ),
              ),
    );
  }

  Widget _buildSafeNetworkImage(String imageUrl) {
    // Log the image URL for debugging
    print('Loading image: $imageUrl');

    // Check if URL is valid
    bool isValidUrl = Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false;
    if (!isValidUrl) {
      print('Invalid image URL format: $imageUrl');
      return _buildImageError();
    }

    // Handle different URL protocols
    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      print('URL needs http/https protocol: $imageUrl');
      // Try adding https if missing
      imageUrl = 'https://' + imageUrl.replaceAll(RegExp(r'^(\/\/|:\/\/)'), '');
      print('Modified URL: $imageUrl');
    }

    try {
      // Direct Image.network with timeout and better error handling
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return _buildImagePlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildImagePlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return _buildImageError();
        },
        // Add cacheWidth for performance
        cacheWidth: 200,
        // Set a reasonable timeout
        cacheHeight: 200,
      );
    } catch (e) {
      print('Exception while loading image: $e');
      return _buildImageError();
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.primary.withValues(alpha: 0.5),
          size: 24,
        ),
      ),
    );
  }
}
