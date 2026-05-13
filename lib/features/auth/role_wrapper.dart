import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../main.dart';
import '../mitra/mitra_dashboard.dart';
import '../driver/driver_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../mitra/mitra_history_screen.dart';
import '../../core/theme/app_theme.dart';

class RoleWrapper extends StatefulWidget {
  const RoleWrapper({super.key});

  @override
  State<RoleWrapper> createState() => _RoleWrapperState();
}

class _RoleWrapperState extends State<RoleWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppRole>(
      valueListenable: currentUserRole,
      builder: (context, role, _) {
        List<Widget> screens = [];
        List<BottomNavigationBarItem> navItems = [];

        // Halaman Profil Dinamis
        Widget profilePage = _buildDynamicProfile(role);

        switch (role) {
          case AppRole.mitra:
            screens = [const MitraDashboard(), const MitraHistoryScreen(), profilePage];
            navItems = const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Riwayat'),
            ];
            break;
          case AppRole.driver:
            screens = [const DriverDashboard(), const Scaffold(body: Center(child: Text('Map Rute'))), profilePage];
            navItems = const [
              BottomNavigationBarItem(icon: Icon(Icons.delivery_dining_rounded), label: 'Logistik'),
              BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Rute'),
            ];
            break;
          case AppRole.admin:
            screens = [const AdminDashboard(), const Scaffold(body: Center(child: Text('Settings'))), profilePage];
            navItems = const [
              BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Sistem'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Audit'),
            ];
            break;
        }

        return Scaffold(
          body: SelectionArea(
            child: IndexedStack(index: _currentIndex, children: screens),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textTertiary,
            type: BottomNavigationBarType.fixed,
            items: [
              ...navItems,
              const BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profil'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDynamicProfile(AppRole role) {
    String title = "";
    String subtitle = "";
    Widget? identityWidget;

    if (role == AppRole.mitra) {
      title = "Restoran Sedap";
      subtitle = "Mitra ID: MITRA_01";
      identityWidget = Column(
        children: [
          const Text('QR Penjemputan Mitra:', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          QrImageView(data: 'MITRA_01', size: 180.0, version: QrVersions.auto),
        ],
      );
    } else if (role == AppRole.driver) {
      title = "Budi Sudarsono";
      subtitle = "Driver ID: DRIVER_01";
      identityWidget = Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16)),
        child: const Column(
          children: [
            Icon(Icons.verified_user_rounded, color: Colors.blue, size: 48),
            SizedBox(height: 12),
            Text('DRIVER TERVERIFIKASI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
      );
    } else {
      title = "Admin Magloop";
      subtitle = "Control Center Access";
      identityWidget = const Icon(Icons.admin_panel_settings_rounded, size: 80, color: AppColors.primary);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(backgroundColor: AppColors.primary, child: Icon(role == AppRole.driver ? Icons.person : Icons.store, color: Colors.white)),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(subtitle),
            ),
            const SizedBox(height: 32),
            Center(child: identityWidget),
            const SizedBox(height: 48),
            _buildRoleSwitcherForProfile(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSwitcherForProfile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Switch Role (Demo Mode):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          DropdownButton<AppRole>(
            isExpanded: true,
            value: currentUserRole.value,
            items: AppRole.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase()))).toList(),
            onChanged: (val) {
              if (val != null) {
                currentUserRole.value = val;
                setState(() => _currentIndex = 0);
              }
            },
          ),
        ],
      ),
    );
  }
}
