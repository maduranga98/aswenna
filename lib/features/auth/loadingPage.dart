import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/features/auth/login.dart';
import 'package:aswenna/features/auth/welcomPage.dart';
import 'package:aswenna/features/home%20page/homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    await Future.delayed(_loadingDelay);
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    // Check if user is registered using getBool instead of containsKey
    final isRegistered = prefs.getBool('isRegistered') ?? false;
    if (!isRegistered) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomePage()),
      );
    }

    if (!mounted) return;

    // Use getBool() for boolean values
    final isLoggedOut = prefs.getBool('isLoggout') ?? false;

    // Update user data
    setState(() {
      userData.addAll({
        'name': prefs.getString('name') ?? '',
        'address': prefs.getString('address') ?? '',
        'id': prefs.getString('id') ?? '',
        'mob1': prefs.getString('mob1') ?? '',
        'mob2': prefs.getString('mob2') ?? '',
        'district': prefs.getString('district') ?? '',
        'dso': prefs.getString('dso') ?? '',
        'isRegistered': isRegistered.toString(), // Convert bool to string
        'isLoggout': isLoggedOut.toString(), // Convert bool to string
        'lan': prefs.getString('lan') ?? '',
        'docId': prefs.getString('docId') ?? '',
      });
    });

    if (!mounted) return;

    // Navigate based on login status
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => isLoggedOut ? const LoginPage() : const HomePage(),
      ),
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
        decoration: BoxDecoration(
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
      child: Column(
        children: const [
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
