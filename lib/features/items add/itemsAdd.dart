// ignore_for_file: use_build_context_synchronously

import 'package:aswenna/core/services/firestore_service.dart';
import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/l10n/app_localizations.dart';
import 'package:aswenna/widgets/LocalizedDistrictFilter.dart';
import 'package:aswenna/widgets/paddySelector.dart';
import 'package:flutter/material.dart';
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
    if (!_formKey.currentState!.validate()) return;

    if (selectedDistrictEn == null || selectedDsoEn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select district and DSO'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Upload images first
      final uploadedImageUrls = await uploadImages();

      // Prepare data for Firestore
      Map<String, dynamic> itemData = {
        // English values for database queries
        'district': selectedDistrictEn,
        'dso': selectedDsoEn,

        // Localized values for display (optional but recommended)
        'districtLocalized': selectedDistrictLocalized,
        'dsoLocalized': selectedDsoLocalized,

        'details': detailsController.text.trim(),
        'date': DateTime.now().toIso8601String(),
      };

      // Add image URLs
      for (int i = 0; i < uploadedImageUrls.length; i++) {
        itemData['image${i + 1}URL'] = uploadedImageUrls[i];
      }

      // Add Paddy details if applicable
      if (widget.paths.contains('paddy_seeds') &&
              widget.paths.contains('improved') ||
          widget.paths.contains('improved')) {
        if (selectedPaddyCode == null ||
            selectedPaddyColor == null ||
            selectedPaddyType == null ||
            selectedPaddyVariety == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select all paddy details'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() {
            isSaving = false;
          });
          return;
        }

        itemData['paddyCode'] = selectedPaddyCode;
        itemData['paddyColor'] = selectedPaddyColor;
        itemData['paddyType'] = selectedPaddyType;
        itemData['paddyVariety'] = selectedPaddyVariety;
      }

      // Add specific fields based on category
      if (widget.paths.contains('lands')) {
        itemData['acres'] = acresController.text.trim();
        itemData['perches'] = perchesController.text.trim();
        itemData['price'] = priceController.text.trim();
      } else if (widget.paths.contains('harvest')) {
        itemData['kg'] = kgController.text.trim();
        itemData['price'] = priceController.text.trim();
      } else {
        // Default case
        itemData['price'] = priceController.text.trim();
      }

      // Save to Firestore
      await _firestoreService.addItem(
        pathSegments: widget.paths,
        itemData: itemData,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item added successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving item: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
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
            color: AppColors.accent, // Using accent color for better visibility
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
    return Scaffold(
      backgroundColor: AppColors.background.withValues(alpha: 0.5),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.addItems,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                              label: AppLocalizations.of(context)!.kg,
                              hint: 'Enter weight in kg',
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
                              hint: 'Enter price for a kg',
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
                              label: AppLocalizations.of(context)!.acres,
                              hint: 'Enter acres',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildInputField(
                              controller: perchesController,
                              label: AppLocalizations.of(context)!.perches,
                              hint: 'Enter perches',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        controller: priceController,
                        label: AppLocalizations.of(context)!.price,
                        hint: 'Enter price',
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('medicine')) ...[
                      _buildInputField(
                        controller: qunatityController,
                        label: AppLocalizations.of(context)!.quantity,
                        hint: 'Enter Quantity',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        controller: priceController,
                        label: AppLocalizations.of(context)!.unitPrice,
                        hint: 'Enter unit price',
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('medicine')) ...[
                      _buildInputField(
                        controller: qunatityController,
                        label: AppLocalizations.of(context)!.quantity,
                        hint: 'Enter Quantity',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        controller: priceController,
                        label: AppLocalizations.of(context)!.unitPrice,
                        hint: 'Enter unit price',
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('equipments')) ...[
                      _buildInputField(
                        controller: qunatityController,
                        label: AppLocalizations.of(context)!.quantity,
                        hint: 'Enter Quantity',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        controller: priceController,
                        label: AppLocalizations.of(context)!.unitPrice,
                        hint: 'Enter unit price',
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('eggs')) ...[
                      _buildInputField(
                        controller: qunatityController,
                        label: AppLocalizations.of(context)!.quantity,
                        hint: 'Enter Quantity',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        controller: priceController,
                        label: AppLocalizations.of(context)!.eggprice,
                        hint: 'Enter unit price',
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('beecolony')) ...[
                      _buildInputField(
                        controller: qunatityController,
                        label: AppLocalizations.of(context)!.colonyquantity,
                        hint: 'Enter Quantity',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        controller: priceController,
                        label: AppLocalizations.of(context)!.colonyprice,
                        hint: 'Enter unit price',
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('beecolony')) ...[
                      _buildInputField(
                        controller: qunatityController,
                        label: AppLocalizations.of(context)!.colonyquantity,
                        hint: 'Enter Quantity',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        controller: priceController,
                        label: AppLocalizations.of(context)!.colonyprice,
                        hint: 'Enter unit price',
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('honey')) ...[
                      _buildInputField(
                        controller: qunatityController,
                        label: AppLocalizations.of(
                          context,
                        )!.honeybottlesquantity,
                        hint: 'Enter Quantity',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      _buildInputField(
                        controller: priceController,
                        label: AppLocalizations.of(context)!.honeybottlesprice,
                        hint: 'Enter unit price',
                        keyboardType: TextInputType.number,
                      ),
                    ] else if (widget.paths.contains('seed_grain')) ...[
                      _buildInputField(
                        controller: kgController,
                        label: AppLocalizations.of(context)!.kg,
                        hint: 'Enter unit price',
                        keyboardType: TextInputType.number,
                      ),
                      _buildInputField(
                        controller: priceController,
                        label: AppLocalizations.of(context)!.priceForOnekg,
                        hint: 'Enter unit price',
                        keyboardType: TextInputType.number,
                      ),
                    ] else ...[
                      _buildInputField(
                        controller: priceController,
                        label: AppLocalizations.of(context)!.price,
                        hint: 'Enter price',
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    SizedBox(height: 16),

                    // Details field for all categories
                    _buildInputField(
                      controller: detailsController,
                      label: AppLocalizations.of(context)!.otherdetails,
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
                                AppLocalizations.of(context)!.addItems,
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
