import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/widgets/districtFilter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ItemsAddPage extends StatefulWidget {
  final String mainName, firstLName, secondLName, lan, tabName;
  final String mainNameE, firstLNameE, secondLNameE, tabNameE;

  const ItemsAddPage({
    super.key,
    required this.mainName,
    required this.firstLName,
    required this.secondLName,
    required this.lan,
    required this.tabName,
    required this.mainNameE,
    required this.firstLNameE,
    required this.secondLNameE,
    required this.tabNameE,
  });

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

  String? selectedDistrict, selectedDso;
  List<File?> selectedImages = List.filled(5, null);
  List<String> imageUrls = List.filled(5, '');
  bool isUploading = false;
  String statusMessage = "";

  @override
  void dispose() {
    priceController.dispose();
    kgController.dispose();
    acresController.dispose();
    perchesController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  Widget _buildImageGrid() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Images (up to 5)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: 5,
            itemBuilder: (context, index) {
              bool hasImage = selectedImages[index] != null;

              return GestureDetector(
                onTap: () => pickImage(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          hasImage
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Image or Add Icon
                      Center(
                        child:
                            hasImage
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.file(
                                    selectedImages[index]!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_rounded,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Add Image',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                      // Remove Button
                      if (hasImage)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImages[index] = null;
                                imageUrls[index] = '';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
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
            SizedBox(height: 12),
            Text(
              statusMessage,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> pickImage(int index) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality:
            100, // We'll let flutter_image_compress handle the compression
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
      print('Error processing image: $e');
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

  Future<String?> uploadImage(File imageFile, String imageName) async {
    try {
      setState(() {
        statusMessage = "Uploading image...";
        isUploading = true;
      });

      final ref = FirebaseStorage.instance
          .ref()
          .child('images')
          .child('$imageName.webp');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/webp'),
      );

      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      return url;
    } catch (e) {
      setState(() {
        statusMessage = "Error uploading image: $e";
      });
      return null;
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<void> uploadImages() async {
    int uploadedCount = 0;
    setState(() {
      statusMessage = "Uploading images...";
      isUploading = true;
    });

    try {
      for (int i = 0; i < selectedImages.length; i++) {
        if (selectedImages[i] != null) {
          final url = await uploadImage(
            selectedImages[i]!,
            'image_${DateTime.now().millisecondsSinceEpoch}_$i',
          );
          if (url != null) {
            imageUrls[i] = url;
            uploadedCount++;
            setState(() {
              statusMessage = "Uploaded $uploadedCount images";
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        statusMessage = "Error uploading images: $e";
      });
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Widget _buildImageSelector(int index) {
    return GestureDetector(
      onTap: () => pickImage(index),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child:
            selectedImages[index] != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(selectedImages[index]!, fit: BoxFit.cover),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 32,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Image ${index + 1}',
                      style: TextStyle(color: AppColors.primary, fontSize: 14),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isMultiline = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: isMultiline ? 5 : 1,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white30),
        filled: true,
        fillColor: AppColors.primary.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isMultiline ? 16 : 12,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
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
                    if (widget.mainNameE != 'land') ...[
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
                              label: AppLocalizations.of(context)!.rs,
                              hint: 'Enter price',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
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
                    ],
                    SizedBox(height: 16),
                    _buildInputField(
                      controller: detailsController,
                      label: AppLocalizations.of(context)!.otherdetails,
                      hint: 'Enter additional details',
                      isMultiline: true,
                    ),
                    SizedBox(height: 24),
                    DistrictFilter(
                      onSelectionChanged: (district, dso) {
                        setState(() {
                          selectedDistrict = district;
                          selectedDso = dso;
                        });
                      },
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            isUploading
                                ? null
                                : () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    // Upload images first
                                    await uploadImages();
                                    // Then save data to Firestore
                                    // ... rest of your save logic
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            isUploading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                  'Save',
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
          ],
        ),
      ),
    );
  }
}
