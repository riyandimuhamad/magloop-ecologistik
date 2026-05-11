import 'package:flutter/material.dart';
import '../../main.dart';
import '../mitra/mitra_dashboard.dart';
import '../driver/driver_dashboard.dart';
import '../admin/admin_dashboard.dart';
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

        // Widget Placeholder Profil yang berisi Role Switcher
        Widget profilePlaceholder = Scaffold(
          appBar: AppBar(title: const Text('Profil Saya')),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('User Magloop'),
                  subtitle: Text('Status: Terverifikasi'),
                ),
                const Divider(),
                _buildRoleSwitcherForProfile(),
              ],
            ),
          ),
        );

        switch (role) {
          case AppRole.mitra:
            screens = [
              const MitraDashboard(), 
              const Scaffold(body: Center(child: Text('Riwayat Setoran'))),
              profilePlaceholder
            ];
            navItems = const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Riwayat'),
            ];
            break;
          case AppRole.driver:
            screens = [
              const DriverDashboard(), 
              const Scaffold(body: Center(child: Text('Rute Pengiriman'))),
              profilePlaceholder
            ];
            navItems = const [
              BottomNavigationBarItem(icon: Icon(Icons.delivery_dining_rounded), label: 'Jadwal'),
              BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Rute'),
            ];
            break;
          case AppRole.admin:
            screens = [
              const AdminDashboard(), 
              const Scaffold(body: Center(child: Text('Ledger Transaksi'))),
              profilePlaceholder
            ];
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
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                label: 'Profil',
              ),
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
          const Text('Switch Role (Demo):', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButton<AppRole>(
            isExpanded: true,
            value: currentUserRole.value,
            items: AppRole.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase()))).toList(),
            onChanged: (val) {
              if (val != null) {
                currentUserRole.value = val;
                setState(() => _currentIndex = 0); // Balik ke Home tiap ganti role
              }
            },
          ),
        ],
      ),
    );
  }
}
