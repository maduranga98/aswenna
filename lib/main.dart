import 'package:aswenna/features/auth/loadingPage.dart';
import 'package:aswenna/l10n/app_localizations.dart';
import 'package:aswenna/providers/items_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aswenna/providers/locale_provider.dart';
import 'package:aswenna/core/services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AdService.initialize();
  Provider.debugCheckInvalidValueType = null;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LocaleProvider()..loadSavedLocale(),
        ),
        ChangeNotifierProvider(
          create: (context) => ItemsProvider(), // ← ADD THIS
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return MaterialApp(
          title: 'Aswenna App',
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoadingPage(),
        );
      },
    );
  }
}
