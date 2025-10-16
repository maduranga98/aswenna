import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/features/home%20page/homepage.dart';
import 'package:aswenna/l10n/app_localizations.dart';
import 'package:aswenna/widgets/districtFilter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileCompletion extends StatefulWidget {
  const ProfileCompletion({super.key});

  @override
  State<ProfileCompletion> createState() => _ProfileCompletionState();
}

class _ProfileCompletionState extends State<ProfileCompletion> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _mobileController = TextEditingController();
  final _altMobileController = TextEditingController();
  final _nicController = TextEditingController();
  bool _isLoading = false;
  String? _selectedDistrict;
  String? _selectedDSO;

  void _handleDistrictSelection(String? district, String? dso) {
    setState(() {
      _selectedDistrict = district;
      _selectedDSO = dso;
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isOptional = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label + (isOptional ? ' (Optional)' : ''),
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: isOptional ? null : (validator ?? _defaultValidator),
      ),
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _saveProfileData() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDistrict == null || _selectedDSO == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your district and DSO'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user found');

      // Create user profile data
      final userData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'address': _addressController.text.trim(),
        'mobileNumber': _mobileController.text.trim(),
        'alternativeMobile': _altMobileController.text.trim(),
        'nicNumber': _nicController.text.trim(),
        'district': _selectedDistrict,
        'dso': _selectedDSO,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile completed successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please provide your personal information',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Personal Information
                  _buildTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    hintText: 'Enter your first name',
                    icon: Icons.person_outline,
                  ),
                  _buildTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    hintText: 'Enter your last name',
                    icon: Icons.person_outline,
                  ),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    hintText: 'Enter your address',
                    icon: Icons.home_outlined,
                    keyboardType: TextInputType.streetAddress,
                  ),
                  _buildTextField(
                    controller: _nicController,
                    label: 'NIC Number',
                    hintText: 'Enter your NIC number',
                    icon: Icons.badge_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'NIC number is required';
                      }
                      // Add NIC validation logic here
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _mobileController,
                    label: 'Mobile Number',
                    hintText: 'Enter your mobile number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Mobile number is required';
                      }
                      if (value.length != 10) {
                        return 'Mobile number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _altMobileController,
                    label: 'Alternative Mobile',
                    hintText: 'Enter alternative mobile number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    isOptional: true,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          value.length != 10) {
                        return 'Mobile number must be 10 digits';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // District Filter
                  DistrictFilter(onSelectionChanged: _handleDistrictSelection),

                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfileData,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            )
                          : const Text(
                              'Complete Profile',
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
        ),
      ),
    );
  }
}
