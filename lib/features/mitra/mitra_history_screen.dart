import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';

class MitraHistoryScreen extends StatelessWidget {
  const MitraHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppRole>(
      valueListenable: currentUserRole,
      builder: (context, role, _) {
        // Filter: Mitra hanya lihat 'waste', Petani hanya lihat 'fertilizer'
        final String targetType = (role == AppRole.petani) ? 'fertilizer' : 'waste';
        final String title = (role == AppRole.petani) ? 'Riwayat Pesanan Pupuk' : 'Riwayat Setoran Sampah';

        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pickup_requests')
                .where('type', isEqualTo: targetType)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState(targetType);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildHistoryCard(data, targetType);
                },
              );
            },
          ),
        );
      }
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> data, String type) {
    final status = data['status'] ?? 'pending';
    final Color statusColor = status == 'completed' ? AppColors.primary : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            type == 'waste' ? Icons.delete_outline : Icons.grass_rounded,
            color: statusColor,
          ),
        ),
        title: Text(data['partnerName'] ?? 'Mitra'),
        subtitle: Text(data['location'] ?? ''),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            type == 'waste' ? 'Belum ada riwayat setoran.' : 'Belum ada riwayat pesanan pupuk.',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
