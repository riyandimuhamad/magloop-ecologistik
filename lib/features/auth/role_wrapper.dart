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

        // Halaman Profil yang berisi Identitas QR Mitra
        Widget profilePage = Scaffold(
          appBar: AppBar(title: const Text('Profil Saya')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const ListTile(
                  leading: CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.store, color: Colors.white)),
                  title: Text('Restoran Sedap (Mitra ID: MITRA_01)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Status: Terverifikasi'),
                ),
                const SizedBox(height: 32),
                const Text('Tunjukkan QR ini ke Driver saat penjemputan:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: QrImageView(
                      data: 'MITRA_01',
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildRoleSwitcherForProfile(),
              ],
            ),
          ),
        );

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
              BottomNavigationBarItem(icon: Icon(Icons.delivery_dining_rounded), label: 'Jadwal'),
              BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Rute'),
            ];
            break;
          case AppRole.admin:
            screens = [const AdminDashboard(), const Scaffold(body: Center(child: Text('Settings'))), profilePage];
            navItems = const [
              BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Analitik'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Ledger'),
            ];
            break;
        }

        return Scaffold(
          body: SelectionArea(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
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
