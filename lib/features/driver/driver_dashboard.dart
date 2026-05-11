import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../schedule/screens/scanner_screen.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const String driverId = 'DRIVER_01';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Driver Magloop'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const VerificationScanner())),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Scan QR Verification'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildSection(context, 'TUGAS BARU', 'pending', driverId, Colors.orange),
            const Divider(height: 1),
            _buildSection(context, 'SEDANG BERJALAN', 'in_progress', driverId, AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String status, String driverId, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          color: accentColor.withOpacity(0.05),
          child: Row(
            children: [
              Container(width: 4, height: 16, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12, color: accentColor)),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService().getRequestsByStatus(status),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState(status == 'pending' ? 'Belum ada tugas baru' : 'Tidak ada tugas berjalan');
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, String id, Map<String, dynamic> data, String status, String driverId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: (status == 'pending' ? Colors.orange : AppColors.primary).withOpacity(0.1),
          child: Icon(
            status == 'pending' ? Icons.notifications_active_outlined : Icons.local_shipping_rounded,
            color: status == 'pending' ? Colors.orange : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(data['partnerName'] ?? 'Mitra', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.pin_drop_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(data['location'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey))),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        onTap: () => _showActionDialog(context, id, data, status, driverId),
      ),
    );
  }

  void _showActionDialog(BuildContext context, String id, Map<String, dynamic> data, String status, String driverId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(status == 'pending' ? 'Terima Penjemputan?' : 'Selesaikan Tugas?', 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildDetailRow(Icons.storefront_rounded, 'Nama Mitra', data['partnerName']),
            _buildDetailRow(Icons.location_on_rounded, 'Lokasi', data['location']),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (status == 'pending') {
                    await FirebaseService().acceptRequest(id, driverId);
                    if (context.mounted) Navigator.pop(ctx);
                  } else {
                    await FirebaseService().completeRequest(id, 5.5, 'MITRA_01');
                    if (context.mounted) Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(status == 'pending' ? 'ACC & Buka Rute' : 'Konfirmasi Selesai', 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
