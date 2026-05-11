import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../schedule/screens/scanner_screen.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const String driverId = 'DRIVER_01'; // ID Driver saat ini

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const VerificationScanner())),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Verifikasi Berat'),
      ),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Tugas Penjemputan Anda:', style: Theme.of(context).textTheme.titleSmall),
            ),
          ),
          _buildTaskList(driverId),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface,
      title: const Text('Driver Magloop', style: TextStyle(color: AppColors.textPrimary)),
      actions: [
        IconButton(icon: const Icon(Icons.map_rounded, color: AppColors.primary), onPressed: () {}),
      ],
    );
  }

  Widget _buildTaskList(String driverId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pickup_requests')
          .where('assignedDriver', isEqualTo: driverId)
          .where('status', isEqualTo: 'assigned')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text('Belum ada tugas penjemputan.')),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.location_on_rounded, color: Colors.redAccent),
                    title: Text(data['partnerName'] ?? 'Mitra'),
                    subtitle: Text(data['location'] ?? ''),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              );
            },
            childCount: snapshot.data!.docs.length,
          ),
        );
      },
    );
  }
}
