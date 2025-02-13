import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/features/auth/login.dart';
import 'package:aswenna/widgets/customeListView.dart';
import 'package:aswenna/widgets/language_selector.dart';
import 'package:aswenna/widgets/tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: AppColors.surface,
            child: Stack(
              children: [
                // Image with gradient overlay
                Positioned.fill(
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                // Title
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      // Modern AppBar with gradient
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
          ),
        ),
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png', // Add your app logo
              height: 32,
            ),
            SizedBox(width: 8),
            Text('Aswenna'),
          ],
        ),
        actions: [
          LanguageSelector(),
          IconButton(
            icon: Icon(Icons.person_outline),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountDetails()),
                ),
          ),
        ],
      ),
      drawer: _buildDrawer(context, localization),
      body: CustomScrollView(
        slivers: [
          // Header Section with curved bottom
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Aswenna',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your Agriculture Marketplace',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Grid Section
          // Update the SliverGrid.delegate section in the HomePage:
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildListDelegate([
                _buildMenuCard(
                  title: localization.land,
                  imagePath: 'assets/img/lands.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomeListView(
                                listname: 'lands',
                                useAppBar: true,
                                title: AppLocalizations.of(context)!.land,
                                titleE: 'land',
                                lan: 'si',
                              ),
                        ),
                      ),
                ),
                _buildMenuCard(
                  title: localization.harvest,
                  imagePath: 'assets/img/harvest.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomeListView(
                                listname: 'harvest',
                                useAppBar: true,
                                title: AppLocalizations.of(context)!.harvest,
                                titleE: 'harvest',
                                lan: 'si',
                              ),
                        ),
                      ),
                ),
                _buildMenuCard(
                  title: localization.culitivation,
                  imagePath: 'assets/img/harvest.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomeListView(
                                listname: 'harvest',
                                useAppBar: true,
                                title: AppLocalizations.of(context)!.harvest,
                                titleE: 'harvest',
                                lan: 'si',
                              ),
                        ),
                      ),
                ),
                _buildMenuCard(
                  title: localization.animals,
                  imagePath: 'assets/img/farms.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomeListView(
                                listname: 'animals',
                                useAppBar: true,
                                title: AppLocalizations.of(context)!.animals,
                                lan: 'si',
                                titleE: 'animals',
                              ),
                        ),
                      ),
                ),
                _buildMenuCard(
                  title: localization.productions,
                  imagePath: 'assets/img/farms.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomeListView(
                                listname: 'production',
                                useAppBar: true,
                                title:
                                    AppLocalizations.of(context)!.productions,
                                titleE: 'productions',
                                lan: 'si',
                              ),
                        ),
                      ),
                ),
                _buildMenuCard(
                  title: localization.labour,
                  imagePath: 'assets/img/farms.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomeListView(
                                listname: 'labour',
                                useAppBar: true,
                                title: AppLocalizations.of(context)!.labour,
                                titleE: 'labour',
                                lan: 'si',
                              ),
                        ),
                      ),
                ),
                _buildMenuCard(
                  title: localization.seeds,
                  imagePath: 'assets/img/seeds.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomeListView(
                                listname: 'production',
                                useAppBar: true,
                                title:
                                    AppLocalizations.of(context)!.productions,
                                titleE: 'productions',
                                lan: 'si',
                              ),
                        ),
                      ),
                ),

                _buildMenuCard(
                  title: localization.vehicle,
                  imagePath: 'assets/img/vehicles.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomeListView(
                                listname: 'vehicles',
                                useAppBar: true,
                                title: AppLocalizations.of(context)!.vehicle,
                                titleE: 'vehicles',
                                lan: 'si',
                              ),
                        ),
                      ),
                ),
                _buildMenuCard(
                  title: localization.transport,
                  imagePath: 'assets/img/transport.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomeListView(
                                listname: 'transport',
                                useAppBar: true,
                                title: AppLocalizations.of(context)!.transport,
                                titleE: 'transport',
                                lan: 'si',
                              ),
                        ),
                      ),
                ),
                _buildMenuCard(
                  title: localization.machineries,
                  imagePath: 'assets/img/machineries.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomeListView(
                                listname: 'machineries',
                                useAppBar: true,
                                title:
                                    AppLocalizations.of(context)!.machineries,
                                titleE: 'machineries',
                                lan: 'si',
                              ),
                        ),
                      ),
                ),
                _buildMenuCard(
                  title: localization.agriEquipment,
                  imagePath: 'assets/img/equipments.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomeListView(
                                listname: 'agroequip',
                                useAppBar: true,
                                title:
                                    AppLocalizations.of(context)!.agriEquipment,
                                titleE: 'agriEquipmet',
                                lan: 'si',
                              ),
                        ),
                      ),
                ),
                _buildMenuCard(
                  title: localization.fertilizers,
                  imagePath: 'assets/img/fertilizers.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomTabBar(
                                tabNames: [
                                  AppLocalizations.of(
                                    context,
                                  )!.fertilizers_tab1,
                                  AppLocalizations.of(
                                    context,
                                  )!.fertilizers_tab2,
                                ],
                                tabWidgets: [
                                  CustomeListView(
                                    listname: 'fertilizer',
                                    useAppBar: false,
                                    title: '',
                                    titleE: '',
                                    lan: 'si',
                                  ),
                                  CustomeListView(
                                    listname: 'chemfertilizer',
                                    useAppBar: false,
                                    title: '',
                                    titleE: '',
                                    lan: 'si',
                                  ),
                                ],
                                title:
                                    AppLocalizations.of(context)!.fertilizers,
                              ),
                        ),
                      ),
                ),
                _buildMenuCard(
                  title: localization.agrochems,
                  imagePath: 'assets/img/chems.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomeListView(
                                listname: 'agroChems',
                                useAppBar: true,
                                title: AppLocalizations.of(context)!.agrochems,
                                titleE: 'agrochems',
                                lan: 'si',
                              ),
                        ),
                      ),
                ),
                _buildMenuCard(
                  title: localization.market,
                  imagePath: 'assets/img/market.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomTabBar(
                                tabNames: [
                                  AppLocalizations.of(context)!.import,
                                  AppLocalizations.of(context)!.export,
                                ],
                                tabWidgets: [
                                  CustomeListView(
                                    listname: 'import',
                                    useAppBar: false,
                                    title: '',
                                    titleE: '',
                                    lan: 'si',
                                  ),
                                  CustomeListView(
                                    listname: 'export',
                                    useAppBar: false,
                                    title: '',
                                    titleE: '',
                                    lan: 'si',
                                  ),
                                ],
                                title: AppLocalizations.of(context)!.market,
                              ),
                        ),
                      ),
                ),
                _buildMenuCard(
                  title: localization.advice,
                  imagePath: 'assets/img/advice.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomeListView(
                                listname: 'advice',
                                useAppBar: true,
                                title: AppLocalizations.of(context)!.advice,
                                titleE: 'advice',
                                lan: 'si',
                              ),
                        ),
                      ),
                ),
                _buildMenuCard(
                  title: localization.info,
                  imagePath: 'assets/img/info.webp',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CustomeListView(
                                listname: 'info',
                                useAppBar: true,
                                title: AppLocalizations.of(context)!.info,
                                titleE: 'info',
                                lan: 'si',
                              ),
                        ),
                      ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Image.asset('assets/profile.png'),
                ),
              ),
              accountName: Text(
                userData['name'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              accountEmail: Text(userData['id'] ?? ''),
            ),
            // Drawer items with improved styling
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
            Divider(color: Colors.white24),
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
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class ListViewPage extends StatelessWidget {
  final String title;
  final String category;

  const ListViewPage({Key? key, required this.title, required this.category})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: AppColors.primary),
      body: Center(
        child: Text('List view for $category will be implemented here'),
      ),
    );
  }
}

class AccountDetails extends StatelessWidget {
  const AccountDetails({super.key});

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? Colors.white70, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/profile.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    userData['name'] ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 32),
                  _buildInfoSection(
                    title: 'Personal Information',
                    children: [
                      _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        text: userData['address'] ?? '',
                      ),
                      _buildInfoRow(
                        icon: Icons.badge_outlined,
                        text: userData['id'] ?? '',
                      ),
                    ],
                  ),
                  _buildInfoSection(
                    title: 'Contact Information',
                    children: [
                      _buildInfoRow(
                        icon: Icons.phone_outlined,
                        text: userData['mob1'] ?? '',
                      ),
                      if (userData['mob2'] != null &&
                          userData['mob2']!.isNotEmpty)
                        _buildInfoRow(
                          icon: Icons.phone_outlined,
                          text: userData['mob2'] ?? '',
                        ),
                    ],
                  ),
                  _buildInfoSection(
                    title: 'Location Details',
                    children: [
                      _buildInfoRow(
                        icon: Icons.location_city_outlined,
                        text: userData['district'] ?? '',
                      ),
                      _buildInfoRow(
                        icon: Icons.location_on_outlined,
                        text: userData['dso'] ?? '',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom clipper for the curved app bar
class CustomAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
