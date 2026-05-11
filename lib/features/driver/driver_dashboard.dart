import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../schedule/screens/scanner_screen.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  // Fungsi untuk membuka Google Maps
  Future<void> _openMap(String location) async {
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}";
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    const String driverId = 'DRIVER_01';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Driver Magloop')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const VerificationScanner())),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Scan QR Verification'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSection(context, 'TUGAS BARU', 'pending', driverId, Colors.orange),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: accentColor)),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService().getRequestsByStatus(status),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(padding: EdgeInsets.all(20), child: Text('Tidak ada data'));
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
        leading: Icon(status == 'pending' ? Icons.timer_outlined : Icons.local_shipping_rounded),
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
            Text('Detail Penjemputan', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.store, 'Mitra', data['partnerName']),
            _buildInfoRow(Icons.pin_drop, 'Alamat', data['location']),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  // Simpan context sebelum async
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final nav = Navigator.of(context);

                  if (status == 'pending') {
                    await FirebaseService().acceptRequest(id, driverId);
                    nav.pop(); // Tutup Popup
                    _openMap(data['location']);
                    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Order Diterima. Membuka Maps...')));
                  } else {
                    await FirebaseService().completeRequest(id, 5.5, 'MITRA_01');
                    nav.pop(); // Tutup Popup
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Tugas Selesai! Data terkirim ke Admin & Mitra.'),
                        backgroundColor: AppColors.primary,
                      )
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(status == 'pending' ? 'ACC & Buka Rute Maps' : 'Konfirmasi Selesai'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
