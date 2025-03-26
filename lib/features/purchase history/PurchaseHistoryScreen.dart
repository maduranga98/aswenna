import 'package:aswenna/core/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aswenna/core/services/firestore_service.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  final String?
  itemId; // Optional - if provided, shows purchases for a specific item

  const PurchaseHistoryScreen({Key? key, this.itemId}) : super(key: key);

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen>
    with SingleTickerProviderStateMixin {
  final _firestoreService = FirestoreService();
  late TabController _tabController;
  bool _isLoading = true;
  List<QueryDocumentSnapshot> _purchases = [];
  List<QueryDocumentSnapshot> _sales = [];

  @override
  void initState() {
    super.initState();

    // Initialize tab controller for purchases and sales
    _tabController = TabController(length: 2, vsync: this);

    // Load purchases data
    _loadPurchases();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load purchases for the current user
  Future<void> _loadPurchases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Only proceed if user is logged in
      if (_firestoreService.currentUserId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Query for purchases
      Query purchasesQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(_firestoreService.currentUserId)
          .collection('purchases')
          .orderBy('purchaseDate', descending: true);

      // Filter by item if an itemId is provided
      if (widget.itemId != null) {
        purchasesQuery = purchasesQuery.where(
          'itemId',
          isEqualTo: widget.itemId,
        );
      }

      final purchasesSnapshot = await purchasesQuery.get();

      // Query for sales
      Query salesQuery = FirebaseFirestore.instance
          .collection('users')
          .doc(_firestoreService.currentUserId)
          .collection('sales')
          .orderBy('purchaseDate', descending: true);

      // Filter by item if an itemId is provided
      if (widget.itemId != null) {
        salesQuery = salesQuery.where('itemId', isEqualTo: widget.itemId);
      }

      final salesSnapshot = await salesQuery.get();

      setState(() {
        _purchases = purchasesSnapshot.docs;
        _sales = salesSnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading purchases: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading purchase history: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          widget.itemId != null ? 'Item Transactions' : 'Transaction History',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.shopping_bag), text: 'Purchases'),
            Tab(icon: Icon(Icons.sell), text: 'Sales'),
          ],
        ),
      ),
      body:
          _isLoading
              ? _buildLoadingIndicator()
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildTransactionsList(_purchases, 'purchase'),
                  _buildTransactionsList(_sales, 'sale'),
                ],
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
            'Loading transactions...',
            style: TextStyle(color: AppColors.textLight, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    List<QueryDocumentSnapshot> transactions,
    String type,
  ) {
    if (transactions.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index].data() as Map<String, dynamic>;
        return _buildTransactionCard(transaction, type);
      },
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'purchase'
                ? Icons.shopping_bag_outlined
                : Icons.sell_outlined,
            size: 64,
            color: AppColors.textLight.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            type == 'purchase' ? 'No Purchases Yet' : 'No Sales Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8),
          Text(
            type == 'purchase'
                ? 'You haven\'t made any purchases yet'
                : 'You haven\'t made any sales yet',
            style: TextStyle(color: AppColors.textLight, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, String type) {
    final itemData = transaction['itemData'] as Map<String, dynamic>? ?? {};

    // Format the date
    String dateText = 'Date not available';
    if (transaction['purchaseDate'] != null) {
      try {
        final timestamp = transaction['purchaseDate'] as Timestamp;
        final dateTime = timestamp.toDate();
        dateText = DateFormat('MMM d, yyyy - h:mm a').format(dateTime);
      } catch (e) {
        print('Error formatting date: $e');
      }
    }

    // Get transaction status
    final status = transaction['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.secondary.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dateText,
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.capitalize(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            Divider(height: 24),

            // Item details
            Row(
              children: [
                // Item image or placeholder
                _buildItemImage(itemData['imageURL']),
                SizedBox(width: 12),

                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item title or variety
                      Text(
                        _getItemTitle(itemData),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 4),

                      // Location
                      if (itemData['district'] != null ||
                          itemData['dso'] != null)
                        Text(
                          "${itemData['district'] ?? ''} - ${itemData['dso'] ?? ''}",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textLight,
                          ),
                        ),

                      SizedBox(height: 4),

                      // Quantity and price
                      Row(
                        children: [
                          Text(
                            "${transaction['quantity'] ?? '0'} kg",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            " × Rs. ${itemData['price'] ?? '0'}",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Total amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                    Text(
                      "Rs. ${transaction['totalPrice']?.toStringAsFixed(2) ?? '0.00'}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16),

            // Contact information
            if (type == 'sale') ...[
              Text(
                "Buyer Information",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 8),
              _buildInfoRow(
                Icons.person,
                "Name",
                transaction['buyerName'] ?? 'Not provided',
              ),
              _buildInfoRow(
                Icons.phone,
                "Contact",
                transaction['buyerContact'] ?? 'Not provided',
              ),
            ] else if (type == 'purchase' &&
                transaction['sellerInfo'] != null) ...[
              Text(
                "Seller Information",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 8),
              _buildInfoRow(
                Icons.person,
                "Name",
                transaction['sellerInfo']['name'] ?? 'Not provided',
              ),
              _buildInfoRow(
                Icons.phone,
                "Contact",
                transaction['sellerInfo']['contact'] ?? 'Not provided',
              ),
            ],

            // Actions row - view details, etc.
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Navigate to transaction details
                  },
                  icon: Icon(Icons.visibility, size: 18),
                  label: Text("View Details"),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                if (type == 'sale' && status == 'pending') ...[
                  SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      // Update transaction status
                      _updateTransactionStatus(transaction, 'completed');
                    },
                    icon: Icon(Icons.check_circle, size: 18),
                    label: Text("Mark Completed"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage(String? imageUrl) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => _buildImageError(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildImagePlaceholder();
                },
              )
              : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.image,
          color: AppColors.primary.withOpacity(0.5),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.broken_image,
          color: AppColors.primary.withOpacity(0.5),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textLight),
          SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(fontSize: 13, color: AppColors.textLight),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: AppColors.text),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      default:
        return AppColors.textLight;
    }
  }

  String _getItemTitle(Map<String, dynamic> itemData) {
    if (itemData['title'] != null && itemData['title'].toString().isNotEmpty) {
      return itemData['title'];
    } else if (itemData['paddyVariety'] != null) {
      return itemData['paddyVariety'];
    } else {
      return 'Item';
    }
  }

  Future<void> _updateTransactionStatus(
    Map<String, dynamic> transaction,
    String newStatus,
  ) async {
    try {
      final String? transactionId = transaction['purchaseId'];

      if (transactionId == null) {
        throw Exception('Transaction ID not found');
      }

      // Update in purchases collection
      await FirebaseFirestore.instance
          .collection('purchases')
          .doc(transactionId)
          .update({'status': newStatus});

      // Update in user's sales collection
      if (_firestoreService.currentUserId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_firestoreService.currentUserId)
            .collection('sales')
            .doc(transactionId)
            .update({'status': newStatus});
      }

      // Update buyer's purchase record
      if (transaction['buyerId'] != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(transaction['buyerId'])
            .collection('purchases')
            .doc(transactionId)
            .update({'status': newStatus});
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transaction status updated to ${newStatus.capitalize()}',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh data
      _loadPurchases();
    } catch (e) {
      print('Error updating transaction status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

// Extension to capitalize string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
