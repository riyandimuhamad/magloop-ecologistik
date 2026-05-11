import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import 'navigation/main_navigation.dart';

class MagloopApp extends StatelessWidget {
  const MagloopApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lock to portrait mode (Optional for Web)
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);

    // Status bar style (Optional for Web)
    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarColor: Colors.transparent,
    //     statusBarIconBrightness: Brightness.dark,
    //     systemNavigationBarColor: AppColors.surface,
    //     systemNavigationBarIconBrightness: Brightness.dark,
    //   ),
    // );

    return MaterialApp(
      title: 'Magloop Ecologistik',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}
