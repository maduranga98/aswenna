import 'package:aswenna/core/services/firestore_service.dart';
import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ItemPurchasePage extends StatefulWidget {
  final String documentId;
  final List<String> pathSegments;
  final Map<String, dynamic> itemData;
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
  final _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _buyerNameController = TextEditingController();
  final _buyerContactController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isProcessing = false;
  int _remainingQuantity = 0;

  @override
  void initState() {
    super.initState();
    _remainingQuantity = widget.currentQuantity;
    // Initialize with 1 as default purchase quantity
    _quantityController.text = '1';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _buyerNameController.dispose();
    _buyerContactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Validates if the purchase quantity is valid
  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a quantity';
    }

    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid number';
    }

    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }

    if (quantity > widget.currentQuantity) {
      return 'Cannot exceed available quantity (${widget.currentQuantity})';
    }

    return null;
  }

  // Updates the quantity in Firestore
  Future<void> _processPurchase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final purchaseQuantity = int.parse(_quantityController.text);
      final updatedQuantity = widget.currentQuantity - purchaseQuantity;

      // Create a map for the purchase transaction record
      final purchaseData = {
        'itemId': widget.documentId,
        'quantity': purchaseQuantity,
        'buyerName': _buyerNameController.text,
        'buyerContact': _buyerContactController.text,
        'notes': _notesController.text,
        'purchaseDate': FieldValue.serverTimestamp(),
        'itemData': {
          'title': widget.itemData['title'] ?? '',
          'price': widget.itemData['price'],
          'district': widget.itemData['district'],
          'dso': widget.itemData['dso'],
        },
      };

      // Start a batch write
      final batch = FirebaseFirestore.instance.batch();

      // 1. Update the item quantity
      final itemDocRef = FirebaseFirestore.instance.doc(
        widget.pathSegments.join('/') + '/' + widget.documentId,
      );

      // Update the item document with new quantity
      batch.update(itemDocRef, {'kg': updatedQuantity});

      // 2. Create a purchase record (optional)
      final purchaseCollectionRef = FirebaseFirestore.instance.collection(
        'purchases',
      );

      batch.set(purchaseCollectionRef.doc(), purchaseData);

      // Commit the batch
      await batch.commit();

      // Update local state
      setState(() {
        _remainingQuantity = updatedQuantity;
        _isProcessing = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase completed successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Return to previous screen with update signal
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing purchase: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
      ),
      body: _isProcessing
          ? _buildLoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Information Card
                    _buildItemInfoCard(),

                    const SizedBox(height: 24),

                    // Purchase Information Form
                    Text(
                      'Purchase Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quantity Field
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
                        // Optional: Update a preview of remaining quantity
                        final purchaseQuantity = int.tryParse(value) ?? 0;
                        if (purchaseQuantity <= widget.currentQuantity) {
                          setState(() {
                            _remainingQuantity =
                                widget.currentQuantity - purchaseQuantity;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 8),

                    // Remaining Quantity Indicator
                    Text(
                      'Remaining after purchase: $_remainingQuantity kg',
                      style: TextStyle(
                        color: _remainingQuantity < 5
                            ? Colors.orange
                            : AppColors.textLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Buyer Name Field
                    TextFormField(
                      controller: _buyerNameController,
                      decoration: InputDecoration(
                        labelText: 'Buyer Name',
                        hintText: 'Enter buyer\'s name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: AppColors.primary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter buyer name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Buyer Contact Field
                    TextFormField(
                      controller: _buyerContactController,
                      decoration: InputDecoration(
                        labelText: 'Contact Number',
                        hintText: 'Enter buyer\'s contact number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter contact number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Notes Field
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Enter any additional notes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.note, color: AppColors.primary),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // Purchase Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _processPurchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Complete Purchase',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildItemInfoCard() {
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
                  "${widget.itemData['district'] ?? ''}-${widget.itemData['dso'] ?? ''}",
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
            if (widget.itemData['kg'] != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Available Quantity:",
                    style: TextStyle(fontSize: 14, color: AppColors.textLight),
                  ),
                  Text(
                    "${widget.itemData['kg']} kg",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (widget.itemData['paddyVariety'] != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Variety:",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                    Text(
                      "${widget.itemData['paddyVariety']}",
                      style: TextStyle(fontSize: 14, color: AppColors.text),
                    ),
                  ],
                ),
            ],

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
                  "Rs. ${widget.itemData['price'] ?? 'N/A'}",
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
}
