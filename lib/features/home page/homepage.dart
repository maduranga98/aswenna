import 'package:aswenna/data/model/category_model.dart';
import 'package:aswenna/l10n/app_localizations.dart';
import 'package:aswenna/widgets/app_drawer.dart';
import 'package:aswenna/widgets/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:aswenna/data/managers/category_manager.dart';
import 'package:aswenna/screens/sub_category_screen.dart';
import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/core/services/ad_service.dart';
import 'package:aswenna/widgets/banner_ad_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final AdService _adService = AdService();
  bool _hasShownInterstitial = false;

  @override
  void initState() {
    super.initState();
    // Load interstitial ad for home page
    _adService.loadInterstitialAd(
      onAdLoaded: () {
        // Show interstitial ad after a short delay when page opens
        if (!_hasShownInterstitial && mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && !_hasShownInterstitial) {
              _adService.showInterstitialAd();
              _hasShownInterstitial = true;
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

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
          orElse: () => CategoryData(
            nameEn: title,
            nameSi: title,
            dbPath: categoryPath,
            subCategories: [],
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SubCategoryScreen(category: category, parentPath: [category]),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
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
                    return Image.asset('assets/images.webp', fit: BoxFit.cover);
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
                        AppColors.primary.withValues(alpha: 0.0),
                        AppColors.primary.withValues(alpha: 0.85),
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
                        color: AppColors.accent.withValues(alpha: 0.85),
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

  Widget _buildHeader(BuildContext context) {
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
                Text(
                  AppLocalizations.of(context)!.welcomeText,
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
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.marketPlace,
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
      // ✅ UPDATED: Using new AppDrawer with profile integration
      drawer: const AppDrawer(),
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
      // body: CustomScrollView(
      //   slivers: [
      //     SliverToBoxAdapter(child: _buildHeader(context)),
      //     SliverPadding(
      //       padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      //       sliver: SliverGrid(
      //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //           crossAxisCount: 2,
      //           childAspectRatio: 1.1,
      //           crossAxisSpacing: 16,
      //           mainAxisSpacing: 16,
      //         ),
      //         delegate: SliverChildListDelegate([
      //           _buildMenuCard(
      //             title: localization.land,
      //             imagePath: 'lands',
      //             categoryPath: 'lands',
      //             icon: Icons.landscape_outlined,
      //           ),
      //           _buildMenuCard(
      //             title: localization.harvest,
      //             imagePath: 'harvest',
      //             categoryPath: 'harvest',
      //             icon: Icons.eco_outlined,
      //           ),
      //           _buildMenuCard(
      //             title: localization.seeds,
      //             imagePath: 'seeds_plants_and_planting_material',
      //             categoryPath: 'seeds_plants_and_planting_material',
      //             icon: Icons.local_florist_outlined,
      //           ),
      //           _buildMenuCard(
      //             title: localization.animals,
      //             imagePath: 'farms',
      //             categoryPath: 'animal_control',
      //             icon: Icons.pets_outlined,
      //           ),
      //           _buildMenuCard(
      //             title: localization.productions,
      //             imagePath: 'productions',
      //             categoryPath: 'processed_productions',
      //             icon: Icons.inventory_2_outlined,
      //           ),
      //           _buildMenuCard(
      //             title: localization.labour,
      //             imagePath: 'service_providers',
      //             categoryPath: 'service_providers',
      //             icon: Icons.engineering_outlined,
      //           ),
      //           _buildMenuCard(
      //             title: localization.vehicle,
      //             imagePath: 'vehicles',
      //             categoryPath: 'vehicles',
      //             icon: Icons.agriculture_outlined,
      //           ),
      //           _buildMenuCard(
      //             title: localization.machineries,
      //             imagePath: 'machineries',
      //             categoryPath: 'machineries',
      //             icon: Icons.precision_manufacturing_outlined,
      //           ),
      //           _buildMenuCard(
      //             title: localization.agriEquipment,
      //             imagePath: 'equipments',
      //             categoryPath: 'agricultural_equipment',
      //             icon: Icons.build_outlined,
      //           ),
      //           _buildMenuCard(
      //             title: localization.fertilizers,
      //             imagePath: 'fertilizers',
      //             categoryPath: 'fertilizer',
      //             icon: Icons.sanitizer_outlined,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        icon: Icons.landscape_outlined,
                      ),
                      _buildMenuCard(
                        title: localization.harvest,
                        imagePath: 'harvest',
                        categoryPath: 'harvest',
                        icon: Icons.eco_outlined,
                      ),
                      _buildMenuCard(
                        title: localization.seeds,
                        imagePath: 'harvest',
                        categoryPath: 'seeds_plants_and_planting_material',
                        icon: Icons.local_florist_outlined,
                      ),
                      _buildMenuCard(
                        title: localization.animals,
                        imagePath: 'farms',
                        categoryPath: 'animal_control',
                        icon: Icons.pets_outlined,
                      ),
                      _buildMenuCard(
                        title: localization.productions,
                        imagePath: 'productions',
                        categoryPath: 'processed_productions',
                        icon: Icons.inventory_2_outlined,
                      ),
                      _buildMenuCard(
                        title: localization.labour,
                        imagePath: 'productions',
                        categoryPath: 'service_providers',
                        icon: Icons.engineering_outlined,
                      ),
                      _buildMenuCard(
                        title: localization.vehicle,
                        imagePath: 'vehicles',
                        categoryPath: 'vehicles',
                        icon: Icons.agriculture_outlined,
                      ),
                      _buildMenuCard(
                        title: localization.machineries,
                        imagePath: 'machineries',
                        categoryPath: 'machineries',
                        icon: Icons.precision_manufacturing_outlined,
                      ),
                      _buildMenuCard(
                        title: localization.agriEquipment,
                        imagePath: 'equipments',
                        categoryPath: 'agricultural_equipment',
                        icon: Icons.build_outlined,
                      ),
                      _buildMenuCard(
                        title: localization.fertilizers,
                        imagePath: 'fertilizers',
                        categoryPath: 'fertilizer',
                        icon: Icons.sanitizer_outlined,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          // Banner Ad at the bottom
          const BannerAdWidget(),
        ],
      ),
    );
  }
}
