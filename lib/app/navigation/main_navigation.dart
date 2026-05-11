import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../features/schedule/screens/schedule_screen.dart';
import '../../features/logistik/screens/logistik_screen.dart';
import '../../features/greencoin/screens/greencoin_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  // Destinations config
  static const List<_NavDestination> _destinations = [
    _NavDestination(
      label: 'Jadwal',
      activeIcon: Icons.calendar_today_rounded,
      inactiveIcon: Icons.calendar_today_outlined,
    ),
    _NavDestination(
      label: 'Logistik',
      activeIcon: Icons.local_shipping_rounded,
      inactiveIcon: Icons.local_shipping_outlined,
    ),
    _NavDestination(
      label: 'GreenCoin',
      activeIcon: Icons.eco_rounded,
      inactiveIcon: Icons.eco_outlined,
    ),
  ];

  final List<Widget> _screens = const [
    ScheduleScreen(),
    LogistikScreen(),
    GreenCoinScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SelectionArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _MagloopNavBar(
        currentIndex: _currentIndex,
        destinations: _destinations,
        onTap: _onTabTapped,
      ),
    );
  }
}

// ─── Custom Bottom Navigation Bar ─────────────────────────────────────────
class _MagloopNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavDestination> destinations;
  final ValueChanged<int> onTap;

  const _MagloopNavBar({
    required this.currentIndex,
    required this.destinations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 80,
          child: Row(
            children: List.generate(destinations.length, (index) {
              final dest = destinations[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with indicator pill
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primarySurface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Icon(
                            isSelected ? dest.activeIcon : dest.inactiveIcon,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Label
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                          child: Text(dest.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Nav Destination Data ─────────────────────────────────────────────────
class _NavDestination {
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;

  const _NavDestination({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });
}
