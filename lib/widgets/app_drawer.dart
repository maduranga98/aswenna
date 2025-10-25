import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/features/user%20profile/UserProfilePage.dart';
import 'package:aswenna/l10n/app_localizations.dart';
import 'package:aswenna/screens/instruction_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<DocumentSnapshot> _userProfileFuture;

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

  /// Handle logout
  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _auth.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error logging out: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Build profile header section
  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    final fullName =
        '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
    final profileImageUrl = userData['profileImageUrl'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Profile Image and Name Row
          Row(
            children: [
              // Profile Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: profileImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          profileImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.white.withValues(alpha: 0.2),
                              child: Center(
                                child: Text(
                                  fullName.isEmpty
                                      ? '?'
                                      : fullName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        color: Colors.white.withValues(alpha: 0.2),
                        child: Center(
                          child: Text(
                            fullName.isEmpty ? '?' : fullName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // Name and Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isEmpty ? 'User' : fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Stats Row
                    Row(
                      children: [
                        // Listings
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${userData['totalListings'] ?? 0}',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Listings',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Rating
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${(userData['avgRating'] ?? 0.0).toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.star,
                                    color: AppColors.accent,
                                    size: 12,
                                  ),
                                ],
                              ),
                              Text(
                                'Rating',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // View Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfilePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Profile',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build drawer menu item
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.accent.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isActive
              ? AppColors.accent
              : Colors.white.withValues(alpha: 0.7),
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.8),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }

  /// Build section divider
  Widget _buildSectionDivider(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final localization = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: AppColors.primary,
      child: user == null
          ? Center(
              child: Text(
                'Not logged in',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
            )
          : FutureBuilder<DocumentSnapshot>(
              future: _userProfileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
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

                final userData = snapshot.data!.data() as Map<String, dynamic>;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Header
                      _buildProfileHeader(userData),

                      // Main Menu Section
                      _buildSectionDivider('MAIN'),
                      _buildMenuItem(
                        icon: Icons.home,
                        label: 'Home',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.shopping_bag,
                        label: 'My Listings',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/my-listings');
                        },
                      ),

                      _buildMenuItem(
                        icon: Icons.integration_instructions,
                        label: 'Instructions',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InstructionScreen(),
                            ),
                          );
                        },
                      ),

                      // // Account Section
                      // _buildSectionDivider('ACCOUNT'),
                      // _buildMenuItem(
                      //   icon: Icons.settings,
                      //   label: 'Settings',
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     Navigator.pushNamed(context, '/settings');
                      //   },
                      // ),
                      // _buildMenuItem(
                      //   icon: Icons.privacy_tip,
                      //   label: 'Privacy & Security',
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     Navigator.pushNamed(context, '/privacy');
                      //   },
                      // ),
                      // _buildMenuItem(
                      //   icon: Icons.help,
                      //   label: 'Help & Support',
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     Navigator.pushNamed(context, '/help');
                      //   },
                      // ),

                      // Support Section
                      _buildSectionDivider('SUPPORT'),
                      _buildMenuItem(
                        icon: Icons.info,
                        label: 'About App',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/about');
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.rate_review,
                        label: 'Rate Us',
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Redirecting to app store...'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                      ),

                      // Logout Button
                      _buildSectionDivider('SESSION'),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          onTap: _handleLogout,
                          leading: const Icon(
                            Icons.logout,
                            color: AppColors.error,
                            size: 22,
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                        ),
                      ),

                      // Bottom Padding
                      const SizedBox(height: 16),
                      // App Version
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Text(
                              'Aswenna',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'v1.0.0',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 10,
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
    );
  }
}
