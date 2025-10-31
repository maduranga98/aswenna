// ignore_for_file: use_build_context_synchronously

import 'package:aswenna/core/services/firestore_service.dart';
import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/l10n/app_localizations.dart';
import 'package:aswenna/providers/items_provider.dart';
import 'package:aswenna/widgets/LocalizedDistrictFilter.dart';
import 'package:aswenna/widgets/paddySelector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ItemsAddPage extends StatefulWidget {
  final List<String> paths;

  const ItemsAddPage({super.key, required this.paths});
  @override
  State<ItemsAddPage> createState() => _ItemsAddPageState();
}

class _ItemsAddPageState extends State<ItemsAddPage> {
  final _formKey = GlobalKey<FormState>();
  final priceController = TextEditingController();
  final kgController = TextEditingController();
  final acresController = TextEditingController();
  final perchesController = TextEditingController();
  final detailsController = TextEditingController();
  final qunatityController = TextEditingController();
  final lengthController = TextEditingController();
  final diameterController = TextEditingController();
  final thicknessController = TextEditingController();
  final heightController = TextEditingController();
  final packetController = TextEditingController();
  final piecesInaPacketController = TextEditingController();
  final nameController = TextEditingController();

  String? selectedDistrictEn, selectedDistrictLocalized;
  String? selectedDsoEn, selectedDsoLocalized;
  List<File?> selectedImages = List.filled(5, null);
  List<String> imageUrls = List.filled(5, '');
  bool isUploading = false;
  String statusMessage = "";
  String? selectedPaddyCode;
  String? selectedPaddyColor;
  String? selectedPaddyType;
  String? selectedPaddyVariety;
  final FirestoreService _firestoreService = FirestoreService();
  bool isSaving = false;

  @override
  void dispose() {
    priceController.dispose();
    kgController.dispose();
    acresController.dispose();
    perchesController.dispose();
    detailsController.dispose();
    qunatityController.dispose();
    super.dispose();
  }

  // Image selection and processing functions
  Future<void> pickImage(int index) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 100,
      );

      if (image != null) {
        File imageFile = File(image.path);

        setState(() {
          statusMessage = "Processing image...";
          isUploading = true;
        });

        File processedFile = await processImage(imageFile);

        setState(() {
          selectedImages[index] = processedFile;
          statusMessage = "Image ${index + 1} selected and processed";
          isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "Error processing image: $e";
        isUploading = false;
      });
    }
  }

  Future<File> processImage(File imageFile) async {
    try {
      // Compress and convert image
      final compressedFile = await compressAndFormatImage(imageFile);
      return compressedFile;
    } catch (e) {
      return imageFile;
    }
  }

  Future<File> compressAndFormatImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.webp';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      format: CompressFormat.webp,
      quality: 85,
      minWidth: 1024,
      minHeight: 1024,
    );

    if (result == null) {
      throw Exception('Image compression failed');
    }

    return File(result.path);
  }

  // Upload images to Firebase Storage
  Future<List<String>> uploadImages() async {
    List<String> urls = [];
    setState(() {
      statusMessage = "Uploading images...";
      isUploading = true;
    });

    try {
      for (int i = 0; i < selectedImages.length; i++) {
        if (selectedImages[i] != null) {
          String path = widget.paths.join('/');
          final url = await _firestoreService.uploadImage(
            selectedImages[i]!,
            path,
          );
          if (url.isNotEmpty) {
            urls.add(url);
            setState(() {
              statusMessage = "Uploaded ${urls.length} images";
            });
          }
        }
      }
      return urls;
    } catch (e) {
      setState(() {
        statusMessage = "Error uploading images: $e";
      });
      return [];
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  // Save item to Firestore
  Future<void> saveItem() async {
    // Step 1: Validate form
    if (!_formKey.currentState!.validate()) return;

    // Step 2: Validate location selection
    if (!_validateLocationSelection()) return;

    // Step 3: Validate category-specific requirements
    if (!_validateCategoryRequirements()) return;

    // Step 4: Set loading state
    setState(() => isSaving = true);

    try {
      List<String> uploadedImageUrls = [];

      // Step 5: Upload images only if path contains 'sell'
      if (widget.paths.contains('sell')) {
        uploadedImageUrls = await uploadImages();
        if (uploadedImageUrls.isEmpty) {
          _showError('Please select at least one image');
          setState(() => isSaving = false);
          return;
        }
      }

      // Step 6: Build complete item data
      final itemData = _buildItemData(uploadedImageUrls);

      // Step 7: Save via ItemsProvider (already integrated in main.dart)
      final docId = await context.read<ItemsProvider>().addItem(
        pathSegments: widget.paths,
        itemData: itemData,
      );

      // Step 8: Handle success/failure
      if (docId != null && docId.isNotEmpty) {
        _showSuccess('Item added successfully');
        if (mounted) Navigator.pop(context, true);
      } else {
        _showError('Failed to save item. Please try again.');
      }
    } on FirebaseException catch (e) {
      _showError('Firebase error: ${e.message ?? "Unknown error"}');
    } catch (e) {
      _showError('Error saving item: $e');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  /// Validates that both district and DSO are selected
  bool _validateLocationSelection() {
    if (selectedDistrictEn == null || selectedDsoEn == null) {
      _showError('Please select both district and DSO');
      return false;
    }
    return true;
  }

  /// Validates all category-specific required fields
  bool _validateCategoryRequirements() {
    // Validate paddy details if applicable
    if ((widget.paths.contains('paddy_seeds') ||
            widget.paths.contains('improved')) &&
        selectedPaddyCode == null) {
      _showError('Please select all paddy details');
      return false;
    }

    // Validate price is entered for all categories
    if (priceController.text.trim().isEmpty) {
      _showError('Please enter a price');
      return false;
    }

    // Category-specific field validations
    if (widget.paths.contains('lands')) {
      if (acresController.text.trim().isEmpty &&
          perchesController.text.trim().isEmpty) {
        _showError('Please enter acres or perches');
        return false;
      }
    } else if (widget.paths.contains('harvest')) {
      if (kgController.text.trim().isEmpty) {
        _showError('Please enter weight in kg');
        return false;
      }
    }

    return true;
  }

  Map<String, dynamic> _buildItemData(List<String> imageUrls) {
    final now = DateTime.now();

    final itemData = <String, dynamic>{
      // Location data (used for filtering in ItemListScreen)
      'district': selectedDistrictEn,
      'dso': selectedDsoEn,
      'districtLocalized': selectedDistrictLocalized,
      'dsoLocalized': selectedDsoLocalized,

      // Common fields
      'details': detailsController.text.trim(),
      'price': priceController.text.trim(),
      'quantity': qunatityController.text.trim(),

      //special fields
      'kg': kgController.text.trim(),
      'acres': acresController.text.trim(),
      'perches': perchesController.text.trim(),
      'length': lengthController.text.trim(),
      'diameter': diameterController.text.trim(),
      'thickness': thicknessController.text.trim(),
      'height': heightController.text.trim(),
      'packet': packetController.text.trim(),
      'piecesInaPacket': piecesInaPacketController.text.trim(),
      'name': nameController.text.trim(),
      // Timestamps for sorting and filtering
      'date': now.toIso8601String(),
      'createdAt': now.millisecondsSinceEpoch,
      'updatedAt': now.millisecondsSinceEpoch,

      // Path information (critical for ProductProvider queries)
      'pathSegments': widget.paths,
      'collectionPath': widget.paths.join("/"),
    };

    // Add image URLs (image1URL, image2URL, etc.)
    for (int i = 0; i < imageUrls.length; i++) {
      itemData['image${i + 1}URL'] = imageUrls[i];
    }

    // Add paddy details if applicable
    _addPaddyDetails(itemData);

    // Add category-specific fields based on product type
    _addCategorySpecificFields(itemData);

    return itemData;
  }

  /// Adds paddy variety details when product is paddy seeds
  void _addPaddyDetails(Map<String, dynamic> itemData) {
    if ((widget.paths.contains('paddy_seeds') ||
            widget.paths.contains('improved')) &&
        selectedPaddyCode != null) {
      itemData.addAll({
        'paddyCode': selectedPaddyCode,
        'paddyColor': selectedPaddyColor,
        'paddyType': selectedPaddyType,
        'paddyVariety': selectedPaddyVariety,
      });
    }
  }

  /// Used by ProductProvider to filter and display relevant product information
  void _addCategorySpecificFields(Map<String, dynamic> itemData) {
    if (widget.paths.contains('lands')) {
      itemData['acres'] = acresController.text.trim();
      itemData['perches'] = perchesController.text.trim();
    } else if (widget.paths.contains('harvest')) {
      itemData['kg'] = kgController.text.trim();
    } else if (widget.paths.contains('paddy_seeds') &&
        widget.paths.contains('improved')) {
      // Paddy details already added via _addPaddyDetails()
    } else if (widget.paths.contains('agricultural_equipment')) {
      _addEquipmentFields(itemData);
    } else if (widget.paths.contains('confectionery')) {
      itemData['packets'] = qunatityController.text.trim();
      itemData['piecesPerPacket'] = piecesInaPacketController.text.trim();
    }
  }

  // Handles equipment-specific fields for different equipment types
  void _addEquipmentFields(Map<String, dynamic> itemData) {
    if (widget.paths.contains('wire')) {
      itemData.addAll({
        'length': lengthController.text.trim(),
        'weight': kgController.text.trim(),
        'quantity': qunatityController.text.trim(),
      });
    } else if (widget.paths.contains('gi_pipe')) {
      itemData.addAll({
        'length': lengthController.text.trim(),
        'diameter': diameterController.text.trim(),
        'weight': kgController.text.trim(),
        'quantity': qunatityController.text.trim(),
      });
    } else if (widget.paths.contains('cover_nets')) {
      itemData.addAll({
        'height': heightController.text.trim(),
        'length': lengthController.text.trim(),
        'quantity': qunatityController.text.trim(),
      });
    } else if (widget.paths.contains('polythene')) {
      itemData.addAll({
        'length': lengthController.text.trim(),
        'height': heightController.text.trim(),
        'thickness': thicknessController.text.trim(),
        'quantity': qunatityController.text.trim(),
      });
    }
  }

  /// Displays error snackbar with consistent styling and behavior
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Displays success snackbar with consistent styling and behavior
  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Build the image grid
  Widget _buildImageGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_photo_alternate,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Upload Images',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                '(${selectedImages.where((img) => img != null).length}/5)',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: 5,
            itemBuilder: (context, index) {
              bool hasImage = selectedImages[index] != null;
              bool isUploading =
                  this.isUploading && selectedImages[index] != null;

              return GestureDetector(
                onTap: () => !isUploading ? pickImage(index) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: hasImage
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasImage
                          ? AppColors.accent
                          : Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background
                      if (hasImage)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            selectedImages[index]!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),

                      // Upload Overlay
                      if (isUploading)
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.accent,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Uploading...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Empty State
                      if (!hasImage)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: AppColors.accent,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image ${index + 1}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Remove Button
                      if (hasImage && !isUploading)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImages[index] = null;
                                imageUrls[index] = '';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (statusMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.accent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusMessage,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Build input fields for text values
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isMultiline = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced label with better visibility
        Text(
          label,
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        // Enhanced TextFormField with better contrast
        StatefulBuilder(
          builder: (context, setState) {
            return Focus(
              onFocusChange: (hasFocus) => setState(() {}),
              child: Builder(
                builder: (context) {
                  final isFocused = Focus.of(context).hasFocus;
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isFocused
                          ? [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: TextFormField(
                      controller: controller,
                      maxLines: isMultiline ? 5 : 1,
                      keyboardType: keyboardType,
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 15,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.accent,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.error,
                            width: 1.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.error,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isMultiline ? 16 : 12,
                        ),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter $label';
                        }
                        return null;
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background.withValues(alpha: 0.5),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          l10n.addItems,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.paths.contains('sell'))
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: _buildImageGrid(),
              ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Path indicator
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_open,
                            color: AppColors.primary.withValues(alpha: 0.7),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.paths.join(' > '),
                              style: TextStyle(
                                color: AppColors.primary.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // District and DSO selector
                    LocalizedDistrictFilter(
                      onSelectionChanged:
                          (districtEn, districtLocalized, dsoEn, dsoLocalized) {
                            setState(() {
                              selectedDistrictEn = districtEn;
                              selectedDistrictLocalized = districtLocalized;
                              selectedDsoEn = dsoEn;
                              selectedDsoLocalized = dsoLocalized;
                            });
                          },
                    ),
                    SizedBox(height: 16),

                    // Paddy selector for improved paddy
                    if (widget.paths.contains('paddy_seeds') &&
                            widget.paths.contains('improved') ||
                        widget.paths.contains('improved'))
                      PaddySelector(
                        onSelectionComplete: (code, color, type, variety) {
                          setState(() {
                            selectedPaddyCode = code;
                            selectedPaddyColor = color;
                            selectedPaddyType = type;
                            selectedPaddyVariety = variety;
                          });
                        },
                      ),

                    // Different fields based on category
                    if (widget.paths.contains('harvest') ||
                        widget.paths.contains('paddy_seeds')) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              controller: kgController,
                              label: l10n.kg,
                              hint: l10n.hintKg,

                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildInputField(
                              controller: priceController,
                              label: AppLocalizations.of(
                                context,
                              )!.priceForOnekg,
                              hint: l10n.hintkgPrice,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ] else if (widget.paths.contains('lands')) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              controller: acresController,
                              label: l10n.acres,
                              hint: l10n.hintarcs,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildInputField(
                              controller: perchesController,
                              label: l10n.perches,
                              hint: l10n.hintperches,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        controller: priceController,
                        label: l10n.price,
                        hint: l10n.hintlandPrice,
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('medicine')) ...[
                      _buildInputField(
                        controller: nameController,
                        label: l10n.itemname,
                        hint: l10n.hintitemname,
                        keyboardType: TextInputType.text,
                      ),
                      _buildInputField(
                        controller: qunatityController,
                        label: l10n.quantity,
                        hint: l10n.hintquantity,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        controller: priceController,
                        label: l10n.unitPrice,
                        hint: l10n.hintunitprice,
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('equipments')) ...[
                      _buildInputField(
                        controller: nameController,
                        label: l10n.itemname,
                        hint: l10n.hintitemname,
                        keyboardType: TextInputType.text,
                      ),
                      _buildInputField(
                        controller: qunatityController,
                        label: l10n.quantity,
                        hint: l10n.hintquantity,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        controller: priceController,
                        label: l10n.unitPrice,
                        hint: l10n.hintunitprice,
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('eggs')) ...[
                      _buildInputField(
                        controller: qunatityController,
                        label: l10n.quantity,
                        hint: 'Enter Quantity',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        controller: priceController,
                        label: l10n.eggprice,
                        hint: 'Enter unit price',
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('feed')) ...[
                      _buildInputField(
                        controller: kgController,
                        label: l10n.kg,
                        hint: l10n.hintKg,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        controller: priceController,
                        label: l10n.priceForOnekg,
                        hint: l10n.hintpricefor1kg,
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('beecolony')) ...[
                      _buildInputField(
                        controller: qunatityController,
                        label: l10n.colonyquantity,
                        hint: l10n.hintcolony,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        controller: priceController,
                        label: l10n.colonyprice,
                        hint: l10n.hintcolonyprice,
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('honey')) ...[
                      _buildInputField(
                        controller: qunatityController,
                        label: l10n.honeybottlesquantity,
                        hint: l10n.hinthoneybottlequantity,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        controller: priceController,
                        label: l10n.honeybottlesprice,
                        hint: l10n.hintpriceofahoneybottle,
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('seed_grain')) ...[
                      _buildInputField(
                        controller: kgController,
                        label: l10n.kg,
                        hint: l10n.hintKg,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        controller: priceController,
                        label: l10n.priceForOnekg,
                        hint: l10n.hintkgPrice,
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('seed_grain')) ...[
                      _buildInputField(
                        controller: kgController,
                        label: l10n.kg,
                        hint: l10n.hintKg,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        controller: priceController,
                        label: l10n.priceForOnekg,
                        hint: l10n.hintkgPrice,
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('animal_control')) ...[
                      if (widget.paths.contains('milk')) ...[
                        _buildInputField(
                          controller: qunatityController,
                          label: l10n.numberofliters,
                          hint: l10n.hintliters,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.priceforaliter,
                          hint: l10n.hintliterprice,
                          keyboardType: TextInputType.number,
                        ),
                      ] else if (widget.paths.contains('feeds')) ...[
                        _buildInputField(
                          controller: kgController,
                          label: l10n.kg,
                          hint: l10n.hintKg,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.price,
                          hint: l10n.hintpricefor1kg,
                          keyboardType: TextInputType.number,
                        ),
                      ] else if (widget.paths.contains('grown_cattle') ||
                          widget.paths.contains('grown_buffalo') ||
                          widget.paths.contains('grown_goat') ||
                          widget.paths.contains('grown_pigs') ||
                          widget.paths.contains('grown_rabbits') ||
                          widget.paths.contains('grown_sheep')) ...[
                        _buildInputField(
                          controller: kgController,
                          label: l10n.lifeweight,
                          hint: l10n.hintliveweight,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: qunatityController,
                          label: l10n.animalquantity,
                          hint: l10n.hintanimalquantity,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.animalprice,
                          hint: l10n.hintpriceofaanimal,
                          keyboardType: TextInputType.number,
                        ),
                      ] else if (widget.paths.contains('equipments') ||
                          widget.paths.contains('accessories')) ...[
                        _buildInputField(
                          controller: nameController,
                          label: l10n.itemname,
                          hint: l10n.hintitemname,
                          keyboardType: TextInputType.text,
                        ),
                        _buildInputField(
                          controller: qunatityController,
                          label: l10n.quantity,
                          hint: l10n.hintquantity,
                          keyboardType: TextInputType.text,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.unitPrice,
                          hint: l10n.hintunitprice,
                          keyboardType: TextInputType.text,
                        ),
                      ] else if (widget.paths.contains(
                        'medicine_vitamins',
                      )) ...[
                        _buildInputField(
                          controller: nameController,
                          label: l10n.itemname,
                          hint: l10n.hintitemname,
                          keyboardType: TextInputType.text,
                        ),
                        _buildInputField(
                          controller: qunatityController,
                          label: l10n.quantity,
                          hint: l10n.quantity,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.unitPrice,
                          hint: l10n.unitPrice,
                          keyboardType: TextInputType.number,
                        ),
                      ] else ...[
                        _buildInputField(
                          controller: qunatityController,
                          label: l10n.quantity,
                          hint: l10n.hintanimalquantity,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.animalprice,
                          hint: l10n.hintpriceofaanimal,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ] else if (widget.paths.contains('fertilizer')) ...[
                      if (widget.paths.contains('liquid_fertilizer') ||
                          widget.paths.contains('single_fertilizer')) ...[
                        _buildInputField(
                          controller: qunatityController,
                          label: l10n.quantity,
                          hint: l10n.hintliters,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.price,
                          hint: l10n.hintliterprice,
                          keyboardType: TextInputType.number,
                        ),
                      ] else ...[
                        _buildInputField(
                          controller: kgController,
                          label: l10n.kg,
                          hint: l10n.hintKg,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.priceForOnekg,
                          hint: l10n.hintkgPrice,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ] else if (widget.paths.contains(
                      'seeds_plants_and_planting_material',
                    )) ...[
                      if (widget.paths.contains('paddy_seeds')) ...[
                        _buildInputField(
                          controller: qunatityController,
                          label: l10n.numberofbushal,
                          hint: l10n.hintbusal,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.priceofbushal,
                          hint: l10n.hintbusalprice,
                          keyboardType: TextInputType.number,
                        ),
                      ] else if (widget.paths.contains('seed_grain') ||
                          widget.paths.contains('seed_fruit') ||
                          widget.paths.contains('seed_vegetables')) ...[
                        _buildInputField(
                          controller: kgController,
                          label: l10n.kg,
                          hint: l10n.hintKg,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: qunatityController,
                          label: l10n.quantity,
                          hint: l10n.hintquantity,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.priceForOnekg,
                          hint: l10n.hintkgPrice,
                          keyboardType: TextInputType.number,
                        ),
                      ] else if (widget.paths.contains('plants')) ...[
                        _buildInputField(
                          controller: qunatityController,
                          label: l10n.plantsQuantity,
                          hint: l10n.hintplantsQuantity,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.plantsQuantity,
                          hint: l10n.hintplantsQuantity,
                          keyboardType: TextInputType.number,
                        ),
                      ] else if (widget.paths.contains('planting_parts')) ...[
                        _buildInputField(
                          controller: qunatityController,
                          label: l10n.quantity,
                          hint: l10n.hintquantity,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.price,
                          hint: l10n.hintprice,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ] else if (widget.paths.contains(
                      'agricultural_equipment',
                    )) ...[
                      if (widget.paths.contains('wire')) ...[
                        _buildInputField(
                          controller: priceController,
                          label: l10n.priceofawirerool,
                          hint: l10n.hintpriceofaroll,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: lengthController,
                          label: l10n.lengthofaroll,
                          hint: l10n.hintlengthofaroll,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: kgController,
                          label: l10n.weightofaroll,
                          hint: l10n.hintweightofaroll,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: qunatityController,
                          label: l10n.numberofrolls,
                          hint: l10n.hintnumberofrolls,
                          keyboardType: TextInputType.number,
                        ),
                      ] else if (widget.paths.contains('gi_pipe')) ...[
                        _buildInputField(
                          controller: lengthController,
                          label: l10n.lengthofapipe,
                          hint: l10n.hintpipelength,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: diameterController,
                          label: l10n.diameterofapipe,
                          hint: l10n.hintdiameter,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: kgController,
                          label: l10n.weightofapipe,
                          hint: l10n.hintpipeweight,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: qunatityController,
                          label: l10n.numberofpipe,
                          hint: l10n.hintnumberofpipes,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.unitPrice,
                          hint: l10n.hintpipeprice,
                          keyboardType: TextInputType.number,
                        ),
                      ] else if (widget.paths.contains('cover_nets')) ...[
                        _buildInputField(
                          controller: heightController,
                          label: l10n.highofamesh,
                          hint: l10n.hintheightofamesh,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: lengthController,
                          label: l10n.lengthofaroll,
                          hint: l10n.hintlengthofaroll,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: qunatityController,
                          label: l10n.numberofrolls,
                          hint: l10n.hintnumberofrolls,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.priceofaroll,
                          hint: l10n.hintpriceofaroll,
                          keyboardType: TextInputType.number,
                        ),
                      ] else if (widget.paths.contains('polythene')) ...[
                        _buildInputField(
                          controller: lengthController,
                          label: l10n.lengthofaroll,
                          hint: l10n.hintlengthofaroll,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: heightController,
                          label: l10n.heightofaroll,
                          hint: l10n.hinthightofaroll,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: thicknessController,
                          label: l10n.thickness,
                          hint: l10n.hintthickness,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: qunatityController,
                          label: l10n.numberofrolls,
                          hint: l10n.hintnumberofrolls,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.priceofaroll,
                          hint: l10n.hintpriceofaroll,
                          keyboardType: TextInputType.number,
                        ),
                      ] else ...[
                        _buildInputField(
                          controller: qunatityController,
                          label: l10n.quantity,
                          hint: l10n.hintquantity,
                          keyboardType: TextInputType.number,
                        ),
                        _buildInputField(
                          controller: priceController,
                          label: l10n.unitPrice,
                          hint: l10n.hintunitprice,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ] else if (widget.paths.contains('confectionery')) ...[
                      _buildInputField(
                        controller: qunatityController,
                        label: l10n.packet,
                        hint: l10n.hintpacket,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        controller: piecesInaPacketController,
                        label: l10n.pieces,
                        hint: l10n.hintpieces,
                        keyboardType: TextInputType.number,
                      ),

                      //   _buildInputField(
                      //   controller: qunatityController,
                      //   label: l10n.numberofrolls,
                      //   hint: l10n.hintnumberofrolls,
                      //   keyboardType: TextInputType.number,
                      // ),
                      _buildInputField(
                        controller: priceController,
                        label: l10n.packetprice,
                        hint: l10n.hintprice,
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains("other") ||
                        widget.paths.contains("other")) ...[
                      _buildInputField(
                        controller: nameController,
                        label: l10n.itemname,
                        hint: l10n.hintitemname,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        controller: qunatityController,
                        label: l10n.quantity,
                        hint: l10n.hintquantity,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        controller: priceController,
                        label: l10n.unitPrice,
                        hint: l10n.hintunitprice,
                        keyboardType: TextInputType.number,
                      ),
                    ] else ...[
                      _buildInputField(
                        controller: qunatityController,
                        label: l10n.quantity,
                        hint: l10n.quantity,
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        controller: priceController,
                        label: l10n.price,
                        hint: l10n.price,
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    SizedBox(height: 16),

                    // Details field for all categories
                    _buildInputField(
                      controller: detailsController,
                      label: l10n.otherdetails,
                      hint: 'Enter item details',
                      isMultiline: true,
                    ),

                    SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : saveItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isSaving
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                l10n.addItems,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
