import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'constants/app_strings.dart';
import 'constants/app_theme.dart';
import 'providers/diet_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja');

  final storage = StorageService();
  await storage.init();
  final isFirstLaunch = storage.isFirstLaunch();

  runApp(
    ChangeNotifierProvider(
      create: (_) => DietProvider(storage)..init(),
      child: DietApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

class DietApp extends StatelessWidget {
  const DietApp({super.key, required this.isFirstLaunch});

  final bool isFirstLaunch;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: AppTheme.lightTheme,
      home: isFirstLaunch ? const OnboardingScreen() : const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
