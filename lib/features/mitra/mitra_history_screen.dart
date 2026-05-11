import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../services/firebase_service.dart';

class MitraHistoryScreen extends StatelessWidget {
  const MitraHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Riwayat Setoran')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pickup_requests')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada riwayat setoran.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final status = data['status'] ?? 'pending';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: _buildStatusIcon(status),
                  title: Text('Setoran Sampah Organik', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data['location'] ?? ''),
                  trailing: _buildStatusChip(status),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;
    switch (status) {
      case 'completed': icon = Icons.check_circle_rounded; color = AppColors.primary; break;
      case 'in_progress': icon = Icons.local_shipping_rounded; color = Colors.blue; break;
      default: icon = Icons.timer_rounded; color = Colors.orange;
    }
    return Icon(icon, color: color);
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'completed' ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: status == 'completed' ? AppColors.primary : Colors.grey),
      ),
    );
  }
}
