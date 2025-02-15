import 'package:aswenna/data/model/category_model.dart';
import 'package:aswenna/features/auth/login.dart';
import 'package:aswenna/widgets/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:aswenna/data/managers/category_manager.dart';
import 'package:aswenna/screens/sub_category_screen.dart';
import 'package:aswenna/core/utils/color_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildMenuCard({
    required String title,
    required String imagePath,
    required String categoryPath,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        final categories = CategoryManager.getCategories();
        final category = categories.firstWhere(
          (cat) => cat.dbPath.toLowerCase() == categoryPath.toLowerCase(),
          orElse:
              () => CategoryData(
                nameEn: title,
                nameSi: title,
                dbPath: categoryPath,
                subCategories: [],
              ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => SubCategoryScreen(
                  category: category,
                  parentPath: [category],
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/img/$imagePath.webp',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/img/placeholder.webp',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withOpacity(0.0),
                        AppColors.primary.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Category Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: AppColors.surface, size: 18),
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.surface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Color(0xFF3A5067), // Slightly lighter shade of primary
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to Aswenna',
                  style: TextStyle(
                    color: AppColors.surface,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Your Agriculture Marketplace',
                    style: TextStyle(
                      color: AppColors.surface,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', height: 32),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.harvest,
              style: const TextStyle(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.surface),
        actions: [LanguageSelector()],
      ),
      drawer: _buildDrawer(context, localization),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildListDelegate([
                _buildMenuCard(
                  title: localization.land,
                  imagePath: 'lands',
                  categoryPath: 'lands',
                  icon: Icons.landscape,
                ),
                _buildMenuCard(
                  title: localization.harvest,
                  imagePath: 'harvest',
                  categoryPath: 'harvest',
                  icon: Icons.agriculture,
                ),
                _buildMenuCard(
                  title: localization.culitivation,
                  imagePath: 'harvest',
                  categoryPath: 'cultivation',
                  icon: Icons.eco,
                ),
                _buildMenuCard(
                  title: localization.animals,
                  imagePath: 'animals',
                  categoryPath: 'animal_control_and _productions',
                  icon: Icons.pets,
                ),
                _buildMenuCard(
                  title: localization.productions,
                  imagePath: 'productions',
                  categoryPath: 'processed_productions',
                  icon: Icons.inventory_2,
                ),
                _buildMenuCard(
                  title: localization.vehicle,
                  imagePath: 'vehicles',
                  categoryPath: 'vehicles',
                  icon: Icons.local_shipping,
                ),
                _buildMenuCard(
                  title: localization.transport,
                  imagePath: 'transport',
                  categoryPath: 'transport',
                  icon: Icons.delivery_dining,
                ),
                _buildMenuCard(
                  title: localization.machineries,
                  imagePath: 'machineries',
                  categoryPath: 'machineries',
                  icon: Icons.precision_manufacturing,
                ),
                _buildMenuCard(
                  title: localization.agriEquipment,
                  imagePath: 'equipments',
                  categoryPath: 'agricultural_equipment',
                  icon: Icons.handyman,
                ),
                _buildMenuCard(
                  title: localization.fertilizers,
                  imagePath: 'fertilizers',
                  categoryPath: 'fertilizer',
                  icon: Icons.water_drop,
                ),
                _buildMenuCard(
                  title: localization.agrochems,
                  imagePath: 'chems',
                  categoryPath: 'agrochemicals',
                  icon: Icons.science,
                ),
                _buildMenuCard(
                  title: localization.market,
                  imagePath: 'market',
                  categoryPath: 'foreign_market',
                  icon: Icons.storefront,
                ),
                _buildMenuCard(
                  title: localization.advice,
                  imagePath: 'advice',
                  categoryPath: 'advice',
                  icon: Icons.lightbulb,
                ),
                _buildMenuCard(
                  title: localization.info,
                  imagePath: 'info',
                  categoryPath: 'information',
                  icon: Icons.info,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations localization) {
    return Drawer(
      child: Container(
        color: AppColors.primary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Image.asset('assets/profile.png'),
                ),
              ),
              accountName: Text(
                userData['name'] ?? '',
                style: const TextStyle(
                  color: AppColors.surface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                userData['id'] ?? '',
                style: TextStyle(color: AppColors.surface.withOpacity(0.9)),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.shopping_bag_outlined,
              title: localization.purchased,
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.sell_outlined,
              title: localization.sold,
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.contact_support_outlined,
              title: localization.contactUs,
              onTap: () {},
            ),
            _buildDrawerItem(
              icon: Icons.language_outlined,
              title: localization.language,
              trailing: LanguageSelector(isDark: true),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                color: AppColors.surface.withOpacity(0.1),
                thickness: 1,
              ),
            ),
            _buildDrawerItem(
              icon: Icons.logout_outlined,
              title: localization.signOut,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('isLogout', 'true');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.surface.withOpacity(0.8)),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.surface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
