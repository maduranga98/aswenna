import 'dart:typed_data';
import 'package:aswenna/core/services/firestore_service.dart';
import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  Map<String, dynamic>? ownerData;
  bool isLoadingOwner = false;
  List<String> imageUrls = [];
  int currentImageIndex = 0;
  bool isOwner = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _loadItemData();
    await _loadOwnerData();

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

  Future<void> _loadItemData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final docSnap = await _firestoreService.getItemById(
        documentId: widget.documentId!,
      );

      if (docSnap != null && docSnap.exists) {
        setState(() {
          itemData = docSnap.data() as Map<String, dynamic>;
          print(itemData);
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

  Future<void> _loadOwnerData() async {
    final userId = itemData['userId'] ?? widget.userId;
    if (userId == null) return;

    setState(() {
      isLoadingOwner = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          ownerData = userDoc.data();
        });
      }
    } catch (e) {
      print('Error loading owner data: $e');
    } finally {
      setState(() {
        isLoadingOwner = false;
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

  Widget _buildSafeNetworkImage(String imageUrl, {BoxFit fit = BoxFit.cover}) {
    bool isValidUrl = Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false;
    if (!isValidUrl) {
      return _buildImageError();
    }

    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      imageUrl = 'https://' + imageUrl.replaceAll(RegExp(r'^(\/\/|:\/\/)'), '');
    }

    try {
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
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(
                value: event == null
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
    );
  }

  ImageProvider _safeImageProvider(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://' + url.replaceAll(RegExp(r'^(\/\/|:\/\/)'), '');
    }

    try {
      return NetworkImage(url);
    } catch (e) {
      print('Error creating NetworkImage: $e');
      return MemoryImage(Uint8List.fromList([0, 0, 0, 0]));
    }
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerDetailsSection() {
    if (isLoadingOwner) {
      return Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              spreadRadius: 0,
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    if (ownerData == null) return SizedBox.shrink();

    final fullName =
        '${ownerData!['firstName'] ?? ''} ${ownerData!['lastName'] ?? ''}'
            .trim();
    final mobileNumber = ownerData!['mobileNumber'] ?? '';
    final alternativeMobile = ownerData!['alternativeMobile'] ?? '';
    final district = ownerData!['district'] ?? '';
    final dso = ownerData!['dso'] ?? '';
    final address = ownerData!['address'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Owner Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    Text(
                      'Contact information',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),
          Divider(height: 1, color: Colors.grey[200]),
          SizedBox(height: 20),

          // Owner Name
          _buildOwnerInfoRow(
            icon: Icons.account_circle_outlined,
            label: 'Name',
            value: fullName.isNotEmpty ? fullName : 'Not provided',
            iconColor: AppColors.primary,
          ),

          SizedBox(height: 16),

          // Mobile Number
          _buildOwnerInfoRow(
            icon: Icons.phone_outlined,
            label: 'Mobile Number',
            value: mobileNumber.isNotEmpty ? mobileNumber : 'Not provided',
            iconColor: Colors.green[700]!,
            onTap: mobileNumber.isNotEmpty
                ? () async {
                    final phoneUrl = 'tel:$mobileNumber';
                    if (await canLaunchUrl(Uri.parse(phoneUrl))) {
                      await launchUrl(Uri.parse(phoneUrl));
                    }
                  }
                : null,
          ),

          // Alternative Mobile (if available)
          if (alternativeMobile.isNotEmpty) ...[
            SizedBox(height: 16),
            _buildOwnerInfoRow(
              icon: Icons.phone_android_outlined,
              label: 'Alternative Mobile',
              value: alternativeMobile,
              iconColor: Colors.green[600]!,
              onTap: () async {
                final phoneUrl = 'tel:$alternativeMobile';
                if (await canLaunchUrl(Uri.parse(phoneUrl))) {
                  await launchUrl(Uri.parse(phoneUrl));
                }
              },
            ),
          ],

          // Location Info
          if (district.isNotEmpty || dso.isNotEmpty) ...[
            SizedBox(height: 20),
            Divider(height: 1, color: Colors.grey[200]),
            SizedBox(height: 16),

            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Colors.red[400],
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (address.isNotEmpty) ...[
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 6),
                  ],
                  Row(
                    children: [
                      if (district.isNotEmpty) ...[
                        Icon(Icons.place, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          district,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (district.isNotEmpty && dso.isNotEmpty) ...[
                        SizedBox(width: 8),
                        Text('•', style: TextStyle(color: Colors.grey[400])),
                        SizedBox(width: 8),
                      ],
                      if (dso.isNotEmpty)
                        Text(
                          dso,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOwnerInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: onTap != null ? Colors.grey[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            spreadRadius: 0,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Contact Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (ownerData != null && ownerData!['mobileNumber'] != null) {
                    final phoneUrl = 'tel:${ownerData!['mobileNumber']}';
                    if (await canLaunchUrl(Uri.parse(phoneUrl))) {
                      await launchUrl(Uri.parse(phoneUrl));
                    }
                  }
                },
                icon: Icon(Icons.phone_outlined, size: 20),
                label: Text(
                  'Contact Owner',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.grey[800],
            ),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.secondNameE,
          style: TextStyle(
            color: Colors.grey[900],
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IMAGE GALLERY SECTION
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
                                    builder: (_) =>
                                        _buildFullScreenGallery(index),
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

            // 2. PRODUCT DETAILS SECTION
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumb Navigation
                  Text(
                    '${widget.mainNameE} > ${widget.secondNameE}',
                    style: TextStyle(
                      color: AppColors.primary,
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

                  SizedBox(height: 24),

                  // ADDITIONAL FIELDS (name, kg, quantity, etc.)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (itemData['name'] != null &&
                            itemData['name'] != "") ...[
                          _buildDetailRow(l10n.itemname, itemData['name']),
                          SizedBox(height: 12),
                        ],
                        if (itemData['kg'] != null && itemData['kg'] != "") ...[
                          _buildDetailRow(l10n.kg, itemData['kg']),
                          SizedBox(height: 12),
                        ],
                        if (itemData['quantity'] != null &&
                            itemData['quantity'] != "") ...[
                          _buildDetailRow(l10n.quantity, itemData['quantity']),
                          SizedBox(height: 12),
                        ],
                        if (itemData['acres'] != null &&
                            itemData['acres'] != "") ...[
                          _buildDetailRow(l10n.acres, itemData['acres']),
                          SizedBox(height: 12),
                        ],
                        if (itemData['perches'] != null &&
                            itemData['perches'] != "") ...[
                          _buildDetailRow(l10n.perches, itemData['perches']),
                          SizedBox(height: 12),
                        ],
                        if (itemData['length'] != null &&
                            itemData['length'] != "") ...[
                          _buildDetailRow(l10n.length, itemData['length']),
                          SizedBox(height: 12),
                        ],
                        if (itemData['diameter'] != null &&
                            itemData['diameter'] != "") ...[
                          _buildDetailRow(l10n.diameter, itemData['diameter']),
                          SizedBox(height: 12),
                        ],
                        if (itemData['thickness'] != null &&
                            itemData['thickness'] != "") ...[
                          _buildDetailRow(
                            l10n.thickness,
                            itemData['thickness'],
                          ),
                          SizedBox(height: 12),
                        ],
                        if (itemData['height'] != null &&
                            itemData['height'] != "") ...[
                          _buildDetailRow(l10n.height, itemData['height']),
                          SizedBox(height: 12),
                        ],
                        if (itemData['packet'] != null &&
                            itemData['packet'] != "") ...[
                          _buildDetailRow(l10n.packet, itemData['packet']),
                          SizedBox(height: 12),
                        ],
                        if (itemData['piecesInaPacket'] != null &&
                            itemData['piecesInaPacket'] != "") ...[
                          _buildDetailRow(
                            l10n.pieces,
                            itemData['piecesInaPacket'],
                          ),
                        ],
                        // Price
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on_outlined,
                              color: Colors.green[700],
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${l10n.rs}: ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              itemData['price'] ?? widget.price ?? 'N/A',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // DETAILS SECTION
                  if (itemData['details'] != null &&
                      itemData['details'].toString().isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            itemData['details'] ?? widget.details ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],

                  // PADDY SPECIFIC DETAILS
                  if (itemData['paddyCode'] != null ||
                      itemData['paddyColor'] != null ||
                      itemData['paddyType'] != null) ...[
                    Container(
                      padding: EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.grass_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Paddy Information',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Grid of paddy details
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
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

                  // 3. OWNER DETAILS SECTION (LAST)
                  _buildOwnerDetailsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          ownerData != null && ownerData!['mobileNumber'] != null
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
        ),
      ],
    );
  }
}
