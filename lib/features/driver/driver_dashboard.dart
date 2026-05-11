import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../services/firebase_service.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const String driverId = 'DRIVER_01';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Driver Magloop')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSection(context, 'Tugas Baru (Pending)', 'pending', driverId),
            _buildSection(context, 'Sedang Berjalan (OTW)', 'in_progress', driverId),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String status, String driverId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService().getRequestsByStatus(status),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(padding: EdgeInsets.all(20), child: Text('Kosong'));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                return _buildRequestCard(context, doc.id, data, status, driverId);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRequestCard(BuildContext context, String id, Map<String, dynamic> data, String status, String driverId) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ListTile(
        leading: Icon(
          status == 'pending' ? Icons.timer_outlined : Icons.local_shipping_rounded,
          color: status == 'pending' ? Colors.orange : AppColors.primary,
        ),
        title: Text(data['partnerName'] ?? 'Mitra'),
        subtitle: Text(data['location'] ?? ''),
        onTap: () => _showActionDialog(context, id, data, status, driverId),
      ),
    );
  }

  void _showActionDialog(BuildContext context, String id, Map<String, dynamic> data, String status, String driverId) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rincian Tugas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(leading: const Icon(Icons.store), title: Text(data['partnerName'])),
            ListTile(leading: const Icon(Icons.pin_drop), title: Text(data['location'])),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (status == 'pending') {
                    await FirebaseService().acceptRequest(id, driverId);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anda Sedang OTW! Mitra telah dinotifikasi.')));
                  } else {
                    await FirebaseService().completeRequest(id, 5.5, 'MITRA_01'); // Mock weight
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tugas Selesai! GreenCoin telah dikirim ke Mitra.')));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(status == 'pending' ? 'ACC & Buka Maps' : 'Konfirmasi Sampai di Peternakan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
