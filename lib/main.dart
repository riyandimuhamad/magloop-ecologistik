import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/role_wrapper.dart';

enum AppRole { mitra, driver, admin, petani }

// Global State untuk Role Switching (Demo)
final ValueNotifier<AppRole> currentUserRole = ValueNotifier<AppRole>(AppRole.mitra);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }
  runApp(const MagloopApp());
}

class MagloopApp extends StatelessWidget {
  const MagloopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppRole>(
      valueListenable: currentUserRole,
      builder: (context, role, _) {
        return MaterialApp(
          title: 'Magloop Ecologistik',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const RoleWrapper(),
        );
      },
    );
  }
}
