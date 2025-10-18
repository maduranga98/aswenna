import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  late Future<DocumentSnapshot> _userProfileFuture;
  bool _isEditing = false;
  bool _isLoading = false;

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _altMobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _nicController = TextEditingController();
  String? _selectedDistrict;
  String? _selectedDSO;
  String? _profileImageUrl;
  File? _selectedImage;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final user = _auth.currentUser;
    if (user != null) {
      _userProfileFuture = _firestore.collection('users').doc(user.uid).get();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _altMobileController.dispose();
    _addressController.dispose();
    _nicController.dispose();
    super.dispose();
  }

  /// Pick image from gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// Upload image to Firebase Storage
  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage.ref().child(
        'profile_images/${user.uid}/profile.jpg',
      );

      await ref.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));

      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      _showErrorSnackBar('Failed to upload image');
      return null;
    }
  }

  /// Update user profile
  Future<void> _updateProfile(Map<String, dynamic> userData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      setState(() => _isLoading = true);

      // Upload image if selected
      if (_selectedImage != null) {
        final imageUrl = await _uploadProfileImage(_selectedImage!);
        if (imageUrl != null) {
          userData['profileImageUrl'] = imageUrl;
          _profileImageUrl = imageUrl;
        }
      }

      // Update in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      _showSuccessSnackBar('Profile updated successfully!');
      setState(() {
        _isEditing = false;
        _selectedImage = null;
      });

      // Reload profile
      _loadUserProfile();
    } catch (e) {
      _showErrorSnackBar('Failed to update profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Initialize form with user data
  void _initializeForm(Map<String, dynamic> userData) {
    _firstNameController.text = userData['firstName'] ?? '';
    _lastNameController.text = userData['lastName'] ?? '';
    _emailController.text = userData['email'] ?? '';
    _mobileController.text = userData['mobileNumber'] ?? '';
    _altMobileController.text = userData['alternativeMobile'] ?? '';
    _addressController.text = userData['address'] ?? '';
    _nicController.text = userData['nicNumber'] ?? '';
    _selectedDistrict = userData['district'];
    _selectedDSO = userData['dso'];
    _profileImageUrl = userData['profileImageUrl'];
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Build profile header with image
  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    final profileImageUrl = _profileImageUrl ?? userData['profileImageUrl'];
    final fullName =
        '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Profile Image
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : profileImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(
                          profileImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.white.withValues(alpha: 0.2),
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        color: Colors.white.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
              ),
              // Edit button on image
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            fullName.isEmpty ? 'User Profile' : fullName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Email
          if (userData['email'] != null)
            Text(
              userData['email'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
    );
  }

  /// Build text field for editing
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled && _isEditing,
        style: TextStyle(
          color: enabled && _isEditing
              ? Colors.white
              : Colors.white.withValues(alpha: 0.6),
        ),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: _isEditing ? validator : null,
      ),
    );
  }

  /// Build info row (read-only view)
  Widget _buildInfoRow({
    required String label,
    required String? value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value?.isEmpty ?? true ? 'Not provided' : value!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build stats section
  Widget _buildStatsSection(Map<String, dynamic> userData) {
    final totalListings = userData['totalListings'] ?? 0;
    final avgRating = userData['avgRating'] ?? 0.0;
    final reviewCount = userData['reviewCount'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Total Listings
          Column(
            children: [
              Text(
                totalListings.toString(),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Listings',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          // Average Rating
          Column(
            children: [
              Row(
                children: [
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.star, color: AppColors.accent, size: 18),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Rating',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          // Reviews Count
          Column(
            children: [
              Text(
                reviewCount.toString(),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Reviews',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: user == null
            ? const Center(
                child: Text(
                  'Please log in to view your profile',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : FutureBuilder<DocumentSnapshot>(
                future: _userProfileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading profile: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text(
                        'Profile not found',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;

                  if (_isEditing && _firstNameController.text.isEmpty) {
                    _initializeForm(userData);
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile Header
                        _buildProfileHeader(userData),
                        const SizedBox(height: 20),

                        // Stats Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildStatsSection(userData),
                        ),
                        const SizedBox(height: 20),

                        // Content Section
                        if (!_isEditing)
                          // Read-Only View
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  label: 'Email',
                                  value: userData['email'],
                                  icon: Icons.email,
                                ),
                                _buildInfoRow(
                                  label: 'Mobile Number',
                                  value: userData['mobileNumber'],
                                  icon: Icons.phone,
                                ),
                                _buildInfoRow(
                                  label: 'Alternative Mobile',
                                  value: userData['alternativeMobile'],
                                  icon: Icons.phone_android,
                                ),
                                _buildInfoRow(
                                  label: 'Address',
                                  value: userData['address'],
                                  icon: Icons.location_on,
                                ),
                                _buildInfoRow(
                                  label: 'NIC Number',
                                  value: userData['nicNumber'],
                                  icon: Icons.badge,
                                ),
                                _buildInfoRow(
                                  label: 'District',
                                  value: userData['district'],
                                  icon: Icons.map,
                                ),
                                _buildInfoRow(
                                  label: 'DSO',
                                  value: userData['dso'],
                                  icon: Icons.business,
                                ),
                              ],
                            ),
                          )
                        else
                          // Editing View
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _firstNameController,
                                    label: 'First Name',
                                    icon: Icons.person,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'First name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  _buildTextField(
                                    controller: _lastNameController,
                                    label: 'Last Name',
                                    icon: Icons.person,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Last name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  _buildTextField(
                                    controller: _mobileController,
                                    label: 'Mobile Number',
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Mobile number is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  _buildTextField(
                                    controller: _altMobileController,
                                    label: 'Alternative Mobile',
                                    icon: Icons.phone_android,
                                    keyboardType: TextInputType.phone,
                                  ),
                                  _buildTextField(
                                    controller: _addressController,
                                    label: 'Address',
                                    icon: Icons.location_on,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Address is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  _buildTextField(
                                    controller: _nicController,
                                    label: 'NIC Number',
                                    icon: Icons.badge,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'NIC number is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),

                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          child: Row(
                            children: [
                              if (!_isEditing)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() => _isEditing = true);
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit Profile'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      backgroundColor: AppColors.accent,
                                      foregroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                // Save Button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _updateProfile({
                                                'firstName':
                                                    _firstNameController.text
                                                        .trim(),
                                                'lastName': _lastNameController
                                                    .text
                                                    .trim(),
                                                'mobileNumber':
                                                    _mobileController.text
                                                        .trim(),
                                                'alternativeMobile':
                                                    _altMobileController.text
                                                        .trim(),
                                                'address': _addressController
                                                    .text
                                                    .trim(),
                                                'nicNumber': _nicController.text
                                                    .trim(),
                                              });
                                            }
                                          },
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppColors.primary,
                                                  ),
                                            ),
                                          )
                                        : const Icon(Icons.check),
                                    label: const Text('Save Changes'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      backgroundColor: AppColors.accent,
                                      foregroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 12),
                              // Cancel/Close Button
                              SizedBox(
                                width: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_isEditing) {
                                      setState(() => _isEditing = false);
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Icon(
                                    _isEditing ? Icons.close : Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
