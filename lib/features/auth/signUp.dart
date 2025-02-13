import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/features/home%20page/homepage.dart';
import 'package:aswenna/widgets/districtFilter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobi1Controller = TextEditingController();
  final TextEditingController mobi2Controller = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedDistrict;
  String? selectedDSO;
  bool _isLoading = false;

  void _handleDistrictSelection(String? district, String? dso) {
    setState(() {
      selectedDistrict = district;
      selectedDSO = dso;
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required String hintText,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          labelStyle: const TextStyle(color: Colors.white),
          prefixIcon: Icon(icon, color: Colors.white),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Future<void> _saveUserData() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (selectedDistrict == null || selectedDSO == null) {
      Fluttertoast.showToast(
        msg: "Please select district and DSO",
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc();

      final userDataMap = {
        'name': nameController.text,
        'address': addressController.text,
        'id': idController.text,
        'mob1': mobi1Controller.text,
        'mob2': mobi2Controller.text.isEmpty ? '' : mobi2Controller.text,
        'district': selectedDistrict!,
        'dso': selectedDSO!,
        'fcmToken': '',
        'isRegistered': true,
        'isLoggedOut': false,
        'language': '',
        'docId': docRef.id,
      };

      // Save to Firebase
      await docRef.set(userDataMap);

      // Update global userData map
      userData.clear(); // Clear existing data
      userData.addAll(
        Map.fromEntries(
          userDataMap.entries.map((e) => MapEntry(e.key, e.value.toString())),
        ),
      );

      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isRegistered', true);

      Fluttertoast.showToast(
        msg: "Registration successful!",
        backgroundColor: Colors.green,
      );

      // Navigate to home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error saving user data: $e');
      Fluttertoast.showToast(
        msg: "Registration failed. Please try again.",
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    localization.register,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please fill in your details',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: nameController,
                          labelText: localization.name,
                          hintText: 'Enter your full name',
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localization.required;
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: addressController,
                          labelText: localization.address,
                          hintText: 'Enter your address',
                          icon: Icons.home_outlined,
                          keyboardType: TextInputType.streetAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localization.required;
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: idController,
                          labelText: localization.id,
                          hintText: 'Enter your NIC number',
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localization.required;
                            }
                            final numberRegex = RegExp(r'^[0-9]+$');
                            if (!numberRegex.hasMatch(value)) {
                              return 'Only numbers allowed';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: mobi1Controller,
                          labelText: localization.mob1,
                          hintText: 'Enter your primary mobile number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localization.required;
                            }
                            if (value.length != 10) {
                              return 'Mobile number must be 10 digits';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: mobi2Controller,
                          labelText: localization.mob2,
                          hintText:
                              'Enter your secondary mobile number (optional)',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                value.length != 10) {
                              return 'Mobile number must be 10 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DistrictFilter(
                          onSelectionChanged: _handleDistrictSelection,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveUserData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child:
                                _isLoading
                                    ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.primary,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      localization.register,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),
                      ],
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
