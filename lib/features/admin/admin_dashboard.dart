import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../services/firebase_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Magloop Control Center')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusList(context, 'Menunggu (Pending)', 'pending', Colors.orange),
            _buildStatusList(context, 'Dalam Perjalanan (On Progress)', 'in_progress', Colors.blue),
            _buildStatusList(context, 'Selesai (Completed)', 'completed', AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusList(BuildContext context, String title, String status, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService().getRequestsByStatus(status),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(padding: EdgeInsets.symmetric(horizontal: 40), child: Text('Tidak ada data', style: TextStyle(fontSize: 12, color: Colors.grey)));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: ListTile(
                    title: Text(data['partnerName'] ?? ''),
                    subtitle: Text('Status: $status'),
                    trailing: Text(status == 'completed' ? 'Success' : '...', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
