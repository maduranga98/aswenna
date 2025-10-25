import 'package:aswenna/core/services/firestore_service.dart';
import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/features/items%20view/item_view.dart';
import 'package:aswenna/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Myproductspage extends StatefulWidget {
  const Myproductspage({super.key});

  @override
  State<Myproductspage> createState() => _MyproductspageState();
}

class _MyproductspageState extends State<Myproductspage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Products',
          style: TextStyle(
            color: Colors.grey[900],
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('items')
            .where('userId', isEqualTo: uid)
            .where('deleted', isEqualTo: false)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          // Error State
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error loading products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Empty State
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No products yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start adding your products to see them here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Products List
          final products = snapshot.data!.docs;

          return Column(
            children: [
              // Header Stats
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${products.length} ${products.length == 1 ? 'Product' : 'Products'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),

              // Products Grid/List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final doc = products[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;

                    return _buildProductCard(context, docId, data);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final l10n = AppLocalizations.of(context)!;

    // Extract data with null safety
    final price = data['price']?.toString() ?? 'N/A';
    final district = data['district']?.toString() ?? '';
    final dso = data['dso']?.toString() ?? '';
    final details = data['details']?.toString() ?? '';
    final pathSegments = (data['pathSegments'] as List?)?.cast<String>() ?? [];
    final imageUrl = data['image1URL']?.toString() ?? '';

    // Get category name
    String categoryName = 'Product';
    if (pathSegments.isNotEmpty) {
      categoryName = pathSegments.last.replaceAll('_', ' ');
      categoryName = categoryName[0].toUpperCase() + categoryName.substring(1);
    }

    // Format date
    String formattedDate = 'Recently';
    if (data['createdAt'] != null) {
      try {
        final timestamp = data['createdAt'] as Timestamp;
        final date = timestamp.toDate();
        formattedDate = DateFormat('MMM d, yyyy').format(date);
      } catch (e) {
        print('Error formatting date: $e');
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigate to item view page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemViewPage(
                documentId: docId,
                mainNameE: pathSegments.isNotEmpty
                    ? pathSegments[0]
                    : 'Products',
                secondNameE: categoryName,
                imagelink1: imageUrl,
                district: district,
                dso: dso,
                price: price,
                details: details,
                itemData: data,
                pathSegments: pathSegments,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 100,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.primary.withValues(alpha: 0.5),
                              size: 32,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                                strokeWidth: 2,
                              ),
                            );
                          },
                        )
                      : Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary.withValues(alpha: 0.5),
                          size: 32,
                        ),
                ),
              ),

              SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                    // Price
                    Text(
                      'Rs. $price',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),

                    SizedBox(height: 6),

                    // Location
                    if (district.isNotEmpty || dso.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${district.isNotEmpty ? district : ''}'
                              '${district.isNotEmpty && dso.isNotEmpty ? ' - ' : ''}'
                              '${dso.isNotEmpty ? dso : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 4),

                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  // Delete Button
                  IconButton(
                    onPressed: () =>
                        _showDeleteConfirmation(context, docId, data),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 22,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  SizedBox(height: 4),

                  // View Button
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemViewPage(
                            documentId: docId,
                            mainNameE: pathSegments.isNotEmpty
                                ? pathSegments[0]
                                : 'Products',
                            secondNameE: categoryName,
                            imagelink1: imageUrl,
                            district: district,
                            dso: dso,
                            price: price,
                            details: details,
                            itemData: data,
                            pathSegments: pathSegments,
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Delete Product?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this product?',
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price: Rs. ${data['price'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  if (data['district'] != null || data['dso'] != null)
                    Text(
                      'Location: ${data['district'] ?? ''} ${data['dso'] ?? ''}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteProduct(docId);
    }
  }

  Future<void> _deleteProduct(String docId) async {
    if (_isDeleting) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _firestoreService.deleteItem(documentId: docId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Product deleted successfully'),
              ],
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Failed to delete product: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
}
