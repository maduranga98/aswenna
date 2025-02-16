import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/features/auth/profileCompltion.dart';
import 'package:aswenna/features/auth/welcomPage.dart';
import 'package:aswenna/features/auth/login.dart';
import 'package:aswenna/features/home%20page/homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  static const _animationDuration = Duration(seconds: 2);
  static const _loadingDelay = Duration(seconds: 3);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  Future<void> _loadData() async {
    try {
      await Future.delayed(_loadingDelay);
      if (!mounted) return;

      // Get current auth state
      final User? currentUser = _auth.currentUser;
      final prefs = await SharedPreferences.getInstance();

      if (currentUser == null) {
        // No user is signed in
        final isFirstTime = !(prefs.getBool('hasSeenWelcome') ?? false);
        if (isFirstTime) {
          // First time user
          await prefs.setBool('hasSeenWelcome', true);
          _navigateToPage(const WelcomePage());
        } else {
          // Returning user but needs to login
          _navigateToPage(const LoginPage());
        }
        return;
      }

      // User is signed in, check if profile is complete
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists || !_isProfileComplete(userDoc.data())) {
        // Profile incomplete, navigate to profile completion
        _navigateToPage(const ProfileCompletion());
        return;
      }

      // Update local user data
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        await _updateLocalUserData(userData);
      }

      // Navigate to home page
      _navigateToPage(const HomePage());
    } catch (e) {
      print('Error in auth check: $e');
      // In case of error, default to login page
      _navigateToPage(const LoginPage());
    }
  }

  bool _isProfileComplete(Map<String, dynamic>? userData) {
    if (userData == null) return false;

    final requiredFields = [
      'firstName',
      'lastName',
      'address',
      'mobileNumber',
      'nicNumber',
      'district',
      'dso',
    ];

    return requiredFields.every(
      (field) =>
          userData[field] != null && userData[field].toString().isNotEmpty,
    );
  }

  Future<void> _updateLocalUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    // Update shared preferences
    await prefs.setString(
      'name',
      '${userData['firstName']} ${userData['lastName']}',
    );
    await prefs.setString('address', userData['address'] ?? '');
    await prefs.setString('id', userData['nicNumber'] ?? '');
    await prefs.setString('mob1', userData['mobileNumber'] ?? '');
    await prefs.setString('mob2', userData['alternativeMobile'] ?? '');
    await prefs.setString('district', userData['district'] ?? '');
    await prefs.setString('dso', userData['dso'] ?? '');
    await prefs.setBool('isRegistered', true);
    await prefs.setBool('isLoggedOut', false);

    // Update global userData map
    setState(() {
      userData.addAll({
        'name': '${userData['firstName']} ${userData['lastName']}',
        'address': userData['address'] ?? '',
        'id': userData['nicNumber'] ?? '',
        'mob1': userData['mobileNumber'] ?? '',
        'mob2': userData['alternativeMobile'] ?? '',
        'district': userData['district'] ?? '',
        'dso': userData['dso'] ?? '',
        'isRegistered': 'true',
        'isLoggedOut': 'false',
        'docId': _auth.currentUser?.uid ?? '',
      });
    });
  }

  void _navigateToPage(Widget page) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder:
                (context, child) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 40),
                    _buildLoadingIndicator(),
                  ],
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Opacity(
      opacity: _fadeAnimation.value,
      child: Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          width: 200,
          height: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Opacity(
      opacity: _fadeAnimation.value,
      child: const Column(
        children: [
          Text(
            'Aswenna',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Loading...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
