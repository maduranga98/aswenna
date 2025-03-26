import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/core/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class ItemPurchasePage extends StatefulWidget {
  final String? documentId;
  final List<String>? pathSegments;
  final Map<String, dynamic>? itemData;
  final int currentQuantity;

  const ItemPurchasePage({
    Key? key,
    required this.documentId,
    required this.pathSegments,
    required this.itemData,
    required this.currentQuantity,
  }) : super(key: key);

  @override
  State<ItemPurchasePage> createState() => _ItemPurchasePageState();
}

class _ItemPurchasePageState extends State<ItemPurchasePage> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Form controllers
  final _quantityController = TextEditingController();
  final _buyerNameController = TextEditingController();
  final _buyerContactController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  int _remainingQuantity = 0;

  // Payment method selection
  String _selectedPaymentMethod = 'Cash on Delivery';
  final List<String> _paymentMethods = [
    'Cash on Delivery',
    'Bank Transfer',
    'Mobile Payment',
  ];

  @override
  void initState() {
    super.initState();
    _remainingQuantity = widget.currentQuantity;

    // Set default quantity to 1
    _quantityController.text = '1';

    // Pre-fill user data if available
    _prefillUserData();
  }

  Future<void> _prefillUserData() async {
    if (_firestoreService.currentUserId != null) {
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_firestoreService.currentUserId)
                .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null) {
            setState(() {
              _buyerNameController.text = userData['name'] ?? '';
              _buyerContactController.text = userData['phone'] ?? '';
              _addressController.text = userData['address'] ?? '';
            });
          }
        }
      } catch (e) {
        // Silently fail, as this is just a convenience feature
        print('Error prefilling user data: $e');
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _buyerNameController.dispose();
    _buyerContactController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Calculate total price
  double _calculateTotal() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final price =
        double.tryParse(widget.itemData?['price']?.toString() ?? '0') ?? 0;
    return quantity * price;
  }

  // Validate quantity input
  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter quantity';
    }

    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid number';
    }

    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }

    if (quantity > widget.currentQuantity) {
      return 'Cannot exceed available quantity (${widget.currentQuantity} kg)';
    }

    return null;
  }

  // Process the purchase
  Future<void> _processPurchase() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final purchaseQuantity = int.parse(_quantityController.text);
      final updatedQuantity = widget.currentQuantity - purchaseQuantity;

      // Create purchase transaction data
      final purchaseData = {
        'itemId': widget.documentId,
        'quantity': purchaseQuantity,
        'totalPrice': _calculateTotal(),
        'buyerName': _buyerNameController.text,
        'buyerContact': _buyerContactController.text,
        'buyerAddress': _addressController.text,
        'notes': _notesController.text,
        'paymentMethod': _selectedPaymentMethod,
        'status': 'pending', // Initial status
        'purchaseDate': FieldValue.serverTimestamp(),
        'buyerId': _firestoreService.currentUserId,
        'sellerId': widget.itemData?['userId'],
        'itemData': {
          'title': widget.itemData?['title'] ?? '',
          'price': widget.itemData?['price'],
          'district': widget.itemData?['district'],
          'dso': widget.itemData?['dso'],
          'paddyVariety': widget.itemData?['paddyVariety'],
          'paddyCode': widget.itemData?['paddyCode'],
          'paddyType': widget.itemData?['paddyType'],
          'paddyColor': widget.itemData?['paddyColor'],
        },
      };

      // Start batch write
      final batch = FirebaseFirestore.instance.batch();

      // 1. Update item quantity
      if (widget.documentId != null && widget.pathSegments != null) {
        final itemPath =
            widget.pathSegments!.join('/') + '/' + widget.documentId!;
        final itemRef = FirebaseFirestore.instance.doc(itemPath);

        batch.update(itemRef, {'kg': updatedQuantity});

        // 2. Create purchase record
        final purchaseRef =
            FirebaseFirestore.instance.collection('purchases').doc();

        batch.set(purchaseRef, purchaseData);

        // 3. Add to user's purchases if user is logged in
        if (_firestoreService.currentUserId != null) {
          final userPurchaseRef =
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(_firestoreService.currentUserId)
                  .collection('purchases')
                  .doc();

          batch.set(userPurchaseRef, {
            ...purchaseData,
            'purchaseId': purchaseRef.id,
          });
        }

        // 4. Add notification for seller
        if (widget.itemData?['userId'] != null) {
          final notificationRef =
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.itemData!['userId'])
                  .collection('notifications')
                  .doc();

          batch.set(notificationRef, {
            'type': 'purchase',
            'title': 'New Purchase',
            'message':
                '${_buyerNameController.text} purchased ${purchaseQuantity}kg of your item',
            'purchaseId': purchaseRef.id,
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Commit all transactions
        await batch.commit();

        // Show success message and return
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase completed successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Return to previous screen with update signal
        Navigator.pop(context, true);
      } else {
        throw Exception('Missing document ID or path segments');
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing purchase: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method for order summary rows
  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textLight, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: isBold ? AppColors.primary : AppColors.text,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  // Building item details card
  Widget _buildItemDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.secondary.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with district and DSO
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  "${widget.itemData?['district'] ?? ''}-${widget.itemData?['dso'] ?? ''}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Item details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Available Quantity:",
                  style: TextStyle(fontSize: 14, color: AppColors.textLight),
                ),
                Text(
                  "${widget.currentQuantity} kg",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (widget.itemData?['paddyVariety'] != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Variety:",
                    style: TextStyle(fontSize: 14, color: AppColors.textLight),
                  ),
                  Text(
                    "${widget.itemData?['paddyVariety']}",
                    style: TextStyle(fontSize: 14, color: AppColors.text),
                  ),
                ],
              ),

            const SizedBox(height: 8),

            // Price information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Price:",
                  style: TextStyle(fontSize: 14, color: AppColors.textLight),
                ),
                Text(
                  "Rs. ${widget.itemData?['price'] ?? 'N/A'}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Loading indicator
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
            'Processing purchase...',
            style: TextStyle(color: AppColors.textLight, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Purchase Item',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? _buildLoadingIndicator()
              : _buildPurchaseForm(context, localization),
    );
  }

  Widget _buildPurchaseForm(
    BuildContext context,
    AppLocalizations localization,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item card with details
              _buildItemDetailsCard(),

              const SizedBox(height: 24),

              // Purchase details section
              Text(
                'Purchase Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 16),

              // Quantity field
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity (kg)',
                  hintText: 'Enter purchase quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.scale, color: AppColors.primary),
                  suffixText: 'kg',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _validateQuantity,
                onChanged: (value) {
                  // Update remaining quantity preview
                  final purchaseQuantity = int.tryParse(value) ?? 0;
                  if (purchaseQuantity <= widget.currentQuantity) {
                    setState(() {
                      _remainingQuantity =
                          widget.currentQuantity - purchaseQuantity;
                    });
                  }
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remaining after purchase: $_remainingQuantity kg',
                      style: TextStyle(
                        color:
                            _remainingQuantity < 5
                                ? Colors.orange
                                : AppColors.textLight,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Total: Rs. ${NumberFormat("#,##0.00").format(_calculateTotal())}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Buyer information section
              Text(
                'Buyer Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 16),

              // Buyer name field
              TextFormField(
                controller: _buyerNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.person, color: AppColors.primary),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Phone number field
              TextFormField(
                controller: _buyerContactController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Address field
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  hintText: 'Enter delivery address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.location_on, color: AppColors.primary),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter delivery address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Payment method section
              Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 16),

              // Payment method selection
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children:
                      _paymentMethods
                          .map(
                            (method) => RadioListTile<String>(
                              title: Text(method),
                              value: method,
                              groupValue: _selectedPaymentMethod,
                              activeColor: AppColors.primary,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              },
                            ),
                          )
                          .toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Notes field
              Text(
                'Additional Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any special instructions or notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.note, color: AppColors.primary),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Order summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      'Item Price',
                      'Rs. ${widget.itemData?['price'] ?? '0'}',
                    ),
                    _buildSummaryRow(
                      'Quantity',
                      '${_quantityController.text} kg',
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Total Amount',
                      'Rs. ${NumberFormat("#,##0.00").format(_calculateTotal())}',
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _processPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Complete Purchase',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
