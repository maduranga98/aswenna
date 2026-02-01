import 'package:aswenna/core/utils/color_utils.dart';
import 'package:aswenna/features/auth/signUp.dart';
import 'package:aswenna/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:introduction_slider/source/presentation/pages/introduction_slider.dart';
import 'package:introduction_slider/source/presentation/widgets/buttons.dart';
import 'package:introduction_slider/source/presentation/widgets/dot_indicator.dart';
import 'package:introduction_slider/source/presentation/widgets/introduction_slider_item.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  IntroductionSliderItem _buildSliderItem({
    required String imagePath,
    required String title,
    required String subtitle,
    double? imageSize,
  }) {
    return IntroductionSliderItem(
      logo: Container(
        width: imageSize ?? 250.0,
        height: imageSize ?? 250.0,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.accent, // Changed from white to golden accent for logo visibility
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image(image: AssetImage(imagePath), fit: BoxFit.contain),
        ),
      ),
      title: Container(
        margin: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      subtitle: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16.0, height: 1.5),
        ),
      ),
      backgroundColor:
          AppColors.primary, // Set background color to match the app theme
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionSlider(
        items: [
          _buildSliderItem(
            imagePath: 'assets/img1.png',
            title: AppLocalizations.of(context)!.intro1_topic,
            subtitle: AppLocalizations.of(context)!.intro_new,
          ),
          _buildSliderItem(
            imagePath: 'assets/mission.png',
            title: AppLocalizations.of(context)!.intro2_topic,
            subtitle: AppLocalizations.of(context)!.intro_new2,
          ),
          _buildSliderItem(
            imagePath: 'assets/logo.png',
            title: AppLocalizations.of(context)!.intro3_topic,
            subtitle: AppLocalizations.of(context)!.intro1,
          ),
          _buildSliderItem(
            imagePath: 'assets/reg.webp',
            title: AppLocalizations.of(context)!.intro4_topic,
            subtitle: AppLocalizations.of(context)!.intro2,
          ),
          _buildSliderItem(
            imagePath: 'assets/privacy-policy.webp',
            title: AppLocalizations.of(context)!.intro5_topic,
            subtitle: AppLocalizations.of(context)!.intro3,
          ),
        ],
        showStatusBar: true,
        dotIndicator: DotIndicator(
          selectedColor: Colors.white,
          unselectedColor: Colors.white.withValues(alpha: 0.3),
          size: 10.0,
        ),
        back: Back(
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          curve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 300),
        ),
        next: Next(
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_forward, color: Colors.white, size: 24),
          ),
          curve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 300),
        ),
        done: Done(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Get Started',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          home: SignUp(),
        ),
      ),
    );
  }
}
