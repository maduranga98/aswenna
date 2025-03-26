import 'dart:typed_data';

import 'package:aswenna/core/services/firestore_service.dart';
import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/features/items%20view/item_purchase_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemViewPage extends StatefulWidget {
  final String? documentId;
  final String mainNameE;
  final String secondNameE;
  final String? imagelink1;
  final String? imagelink2;
  final String? district;
  final String? dso;
  final String? arces;
  final String? perches;
  final String? price;
  final String? details;
  final String? date;
  final String? rates;
  final String? userId;
  final String? ownerId;
  final String? fcmToken;
  final Map<String, dynamic>? itemData;
  final List<String>? pathSegments;

  const ItemViewPage({
    super.key,
    this.documentId,
    required this.mainNameE,
    required this.secondNameE,
    this.imagelink1,
    this.imagelink2,
    this.district,
    this.dso,
    this.arces,
    this.perches,
    this.price,
    this.details,
    this.date,
    this.rates,
    this.userId,
    this.ownerId,
    this.fcmToken,
    this.itemData,
    this.pathSegments,
  });

  @override
  State<ItemViewPage> createState() => _ItemViewPageState();
}

class _ItemViewPageState extends State<ItemViewPage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool isLoading = false;
  bool isImageViewVisible = false;
  Map<String, dynamic> itemData = {};
  List<String> imageUrls = [];
  int currentImageIndex = 0;
  bool isOwner = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    if (widget.itemData != null) {
      setState(() {
        itemData = widget.itemData!;
        _extractImageUrls();
      });
    } else if (widget.documentId != null && widget.pathSegments != null) {
      _loadItemData();
    } else {
      setState(() {
        // Use the directly provided fields
        itemData = {
          'district': widget.district,
          'dso': widget.dso,
          'acres': widget.arces,
          'perches': widget.perches,
          'price': widget.price,
          'details': widget.details,
          'date': widget.date,
          'userId': widget.userId,
          'image1URL': widget.imagelink1,
          'image2URL': widget.imagelink2,
        };
        _extractImageUrls();
      });
    }

    // Check if current user is the owner
    if (widget.ownerId != null) {
      setState(() {
        isOwner = widget.ownerId == _firestoreService.currentUserId;
      });
    } else if (itemData['userId'] != null) {
      setState(() {
        isOwner = itemData['userId'] == _firestoreService.currentUserId;
      });
    }
  }

  Future<void> _navigateToPurchasePage() async {
    // Make sure we have a document ID and path segments
    if (widget.documentId == null || widget.pathSegments == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot process this purchase due to missing information',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Make sure the item has a quantity field
    final currentQuantity =
        int.tryParse(itemData['kg']?.toString() ?? '0') ?? 0;
    if (currentQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This item is out of stock'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Navigate to the purchase page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ItemPurchasePage(
              documentId: widget.documentId!,
              pathSegments: widget.pathSegments!,
              itemData: itemData,
              currentQuantity: currentQuantity,
            ),
      ),
    );

    // If the purchase was successful, refresh data or return to previous screen
    if (result == true) {
      // If you want to refresh the item data, you could do it here
      // Otherwise just pass the result back to the previous screen
      Navigator.pop(context, true);
    }
  }

  Future<void> _loadItemData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final docSnap = await _firestoreService.getItemById(
        pathSegments: widget.pathSegments!,
        documentId: widget.documentId!,
      );

      if (docSnap != null && docSnap.exists) {
        setState(() {
          itemData = docSnap.data() as Map<String, dynamic>;
          isOwner = itemData['userId'] == _firestoreService.currentUserId;
          _extractImageUrls();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading item: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _extractImageUrls() {
    imageUrls = [];
    for (int i = 1; i <= 5; i++) {
      String key = 'image${i}URL';
      if (itemData.containsKey(key) &&
          itemData[key] != null &&
          itemData[key].toString().isNotEmpty) {
        imageUrls.add(itemData[key]);
      }
    }

    // Handle the direct image links too
    if (imageUrls.isEmpty) {
      if (widget.imagelink1 != null && widget.imagelink1!.isNotEmpty) {
        imageUrls.add(widget.imagelink1!);
      }
      if (widget.imagelink2 != null && widget.imagelink2!.isNotEmpty) {
        imageUrls.add(widget.imagelink2!);
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Date not available';

    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr; // Return original if parsing fails
    }
  }

  // Future<void> _contactSeller() async {
  //   if (itemData['userId'] == _firestoreService.currentUserId) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('This is your own listing'),
  //         backgroundColor: AppColors.primary,
  //       ),
  //     );
  //     return;
  //   }

  //   // Check if we have phone number to contact
  //   if (itemData['phone'] != null && itemData['phone'].toString().isNotEmpty) {
  //     final phoneNumber = itemData['phone'].toString();
  //     final message =
  //         'Hello, I\'m interested in your ${widget.secondNameE} listing on Aswenna.';

  //     // Try to open WhatsApp first
  //     final whatsappUrl =
  //         'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}';
  //     if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
  //       await launchUrl(Uri.parse(whatsappUrl));
  //     } else {
  //       // Fallback to regular phone call
  //       final phoneUrl = 'tel:$phoneNumber';
  //       if (await canLaunchUrl(Uri.parse(phoneUrl))) {
  //         await launchUrl(Uri.parse(phoneUrl));
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Could not launch phone app'),
  //             backgroundColor: AppColors.error,
  //           ),
  //         );
  //       }
  //     }
  //   } else {
  //     // No phone number available
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('No contact information available'),
  //         backgroundColor: AppColors.error,
  //       ),
  //     );
  //   }
  // }

  Widget _buildSafeNetworkImage(String imageUrl, {BoxFit fit = BoxFit.cover}) {
    // Log the image URL for debugging

    // Check if URL is valid
    bool isValidUrl = Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false;
    if (!isValidUrl) {
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
        fit: fit,
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
        cacheWidth: 800,
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
          size: 32,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[800], size: 24),
        SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildFullScreenGallery(int initialIndex) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: _safeImageProvider(imageUrls[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: 'image_$index'),
                errorBuilder: (context, error, stackTrace) {
                  print('Error in gallery view: $error');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white70,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            itemCount: imageUrls.length,
            loadingBuilder:
                (context, event) => Center(
                  child: CircularProgressIndicator(
                    value:
                        event == null
                            ? 0
                            : event.cumulativeBytesLoaded /
                                (event.expectedTotalBytes ?? 1),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
            backgroundDecoration: BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: initialIndex),
            onPageChanged: (index) {
              setState(() {
                currentImageIndex = index;
              });
            },
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  if (imageUrls.length > 1)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${currentImageIndex + 1}/${imageUrls.length}',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          widget.mainNameE == 'Lands' ||
                  itemData['acres'] != null ||
                  widget.mainNameE == 'Harvest' ||
                  itemData['kg'] != null
              ? _buildBottomBar()
              : null,
    );
  }

  ImageProvider _safeImageProvider(String url) {
    // Validate and fix the URL if needed
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://' + url.replaceAll(RegExp(r'^(\/\/|:\/\/)'), '');
    }

    try {
      return NetworkImage(url);
    } catch (e) {
      print('Error creating NetworkImage: $e');
      // Return a transparent image as fallback
      return MemoryImage(Uint8List.fromList([0, 0, 0, 0]));
    }
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Contact seller button - only show if not owner's own listing
          // if (!isOwner) ...[
          //   Expanded(
          //     child: ElevatedButton.icon(
          //       onPressed: _contactSeller,
          //       icon: Icon(Icons.message_outlined),
          //       label: Text('Contact Seller'),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.blue[800],
          //         foregroundColor: Colors.white,
          //         padding: EdgeInsets.symmetric(vertical: 16),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //       ),
          //     ),
          //   ),
          //   SizedBox(width: 12),
          // ],
          // Purchase button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _processPurchase,
              icon: Icon(Icons.shopping_cart_outlined),
              label: Text('Purchase'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPurchase() async {
    // Check if we have kg information (required for purchases)
    if (itemData['kg'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This item cannot be purchased'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check if user is trying to buy their own item
    if (itemData['userId'] == _firestoreService.currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You cannot purchase your own listing'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check if user is logged in
    if (_firestoreService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to purchase items'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Check if there's available quantity
    final int availableQuantity = int.tryParse(itemData['kg'].toString()) ?? 0;
    if (availableQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This item is out of stock'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await _navigateToPurchasePage();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery Section
            Container(
              height: 300,
              width: double.infinity,
              child: Stack(
                children: [
                  imageUrls.isEmpty
                      ? Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 64,
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                      : PageView.builder(
                        itemCount: imageUrls.length,
                        onPageChanged: (index) {
                          setState(() {
                            currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => _buildFullScreenGallery(index),
                                ),
                              );
                            },
                            child: Hero(
                              tag: 'image_$index',
                              child: _buildSafeNetworkImage(
                                imageUrls[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),

                  // Image Counter Indicator
                  if (imageUrls.length > 1)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${currentImageIndex + 1}/${imageUrls.length}',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content Section
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumb Navigation
                  Text(
                    '${widget.mainNameE} > ${widget.secondNameE}',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Location and Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${itemData['district'] ?? ''} - ${itemData['dso'] ?? ''}',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Posted ${_formatDate(itemData['date']?.toString())}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  if (widget.mainNameE == 'Lands' ||
                      itemData['acres'] != null) ...[
                    SizedBox(height: 24),

                    // Property Details Card
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Property Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Size Information
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildDetailItem(
                                AppLocalizations.of(context)!.acres,
                                itemData['acres'] ?? widget.arces ?? 'N/A',
                                Icons.landscape_outlined,
                              ),
                              _buildDetailItem(
                                AppLocalizations.of(context)!.perches,
                                itemData['perches'] ?? widget.perches ?? 'N/A',
                                Icons.straighten_outlined,
                              ),
                            ],
                          ),

                          Divider(height: 32),

                          // Price
                          Row(
                            children: [
                              Icon(
                                Icons.monetization_on_outlined,
                                color: Colors.green[700],
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${AppLocalizations.of(context)!.rs}: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                itemData['price'] ?? widget.price ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else if (widget.mainNameE == 'Harvest' ||
                      itemData['kg'] != null) ...[
                    SizedBox(height: 24),

                    // Harvest Details Card
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Harvest Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Weight Information
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildDetailItem(
                                AppLocalizations.of(context)!.kg,
                                itemData['kg'] ?? 'N/A',
                                Icons.scale_outlined,
                              ),
                              if (itemData['paddyVariety'] != null)
                                _buildDetailItem(
                                  'Variety',
                                  itemData['paddyVariety'],
                                  Icons.grass_outlined,
                                ),
                            ],
                          ),

                          Divider(height: 32),

                          // Price
                          Row(
                            children: [
                              Icon(
                                Icons.monetization_on_outlined,
                                color: Colors.green[700],
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${AppLocalizations.of(context)!.rs}: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                itemData['price'] ?? widget.price ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Generic pricing card for other categories
                    SizedBox(height: 24),

                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.secondNameE} Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Price
                          Row(
                            children: [
                              Icon(
                                Icons.monetization_on_outlined,
                                color: Colors.green[700],
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${AppLocalizations.of(context)!.rs}: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                itemData['price'] ?? widget.price ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 24),

                  // Details Section
                  if (itemData['details'] != null &&
                      itemData['details'].toString().isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            itemData['details'] ?? widget.details ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],

                  // Paddy specific details
                  if (itemData['paddyCode'] != null ||
                      itemData['paddyColor'] != null ||
                      itemData['paddyType'] != null) ...[
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paddy Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Grid of paddy details
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              if (itemData['paddyCode'] != null)
                                _buildInfoChip('Code', itemData['paddyCode']),
                              if (itemData['paddyColor'] != null)
                                _buildInfoChip('Color', itemData['paddyColor']),
                              if (itemData['paddyType'] != null)
                                _buildInfoChip('Type', itemData['paddyType']),
                              if (itemData['paddyVariety'] != null)
                                _buildInfoChip(
                                  'Variety',
                                  itemData['paddyVariety'],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],

                  // Seller info (if available)
                  if (itemData['sellerName'] != null ||
                      itemData['phone'] != null) ...[
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seller Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),

                          if (itemData['sellerName'] != null)
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: Text(itemData['sellerName']),
                              contentPadding: EdgeInsets.zero,
                            ),

                          if (itemData['phone'] != null)
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                child: Icon(
                                  Icons.phone_outlined,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: Text(itemData['phone']),
                              contentPadding: EdgeInsets.zero,
                              onTap: () async {
                                final phoneUrl = 'tel:${itemData['phone']}';
                                if (await canLaunchUrl(Uri.parse(phoneUrl))) {
                                  await launchUrl(Uri.parse(phoneUrl));
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          widget.mainNameE == 'Lands' ||
                  itemData['acres'] != null ||
                  widget.mainNameE == 'Harvest' ||
                  itemData['kg'] != null
              ? _buildBottomBar()
              : null,
    );
  }
}
