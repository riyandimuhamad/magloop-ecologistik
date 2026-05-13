import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../schedule/screens/scanner_screen.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  Future<void> _openMap(String location) async {
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}";
    final Uri url = Uri.parse(googleMapsUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Maps Error: $e');
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
            _buildDriverWallet(),
            _buildSection(context, 'TUGAS BARU', 'pending', driverId, Colors.orange),
            _buildSection(context, 'SEDANG BERJALAN', 'in_progress', driverId, AppColors.primary),
            _buildSection(context, 'RIWAYAT SELESAI', 'completed', driverId, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverWallet() {
    return StreamBuilder<int>(
      stream: FirebaseService().getBalance('DRIVER_01'),
      builder: (context, snapshot) {
        final balance = snapshot.data ?? 0;
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
              opacity: 0.1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saldo Penghasilan Driver', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              Text('$balance GC', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Setara: Rp ${balance * 100}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                    child: const Text('Cairkan Koin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildSection(BuildContext context, String title, String status, String driverId, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: accentColor, fontSize: 12)),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService().getRequestsByStatus(status),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(padding: EdgeInsets.all(20), child: Text('Tidak ada tugas', style: TextStyle(color: Colors.grey)));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ListTile(
                    leading: Icon(status == 'pending' ? Icons.timer_outlined : Icons.local_shipping_rounded, color: accentColor),
                    title: Text(data['partnerName'] ?? 'Mitra'),
                    subtitle: Text(data['location'] ?? ''),
                    onTap: status == 'completed' 
                      ? null // Jika sudah selesai, tidak bisa diklik
                      : () => _showActionDialog(context, doc.id, data, status, driverId),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showActionDialog(BuildContext context, String id, Map<String, dynamic> data, String status, String driverId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Detail Tugas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(leading: const Icon(Icons.store), title: Text(data['partnerName'])),
            ListTile(leading: const Icon(Icons.pin_drop), title: Text(data['location'])),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (status == 'pending') {
                    await FirebaseService().acceptRequest(id, driverId);
                    _openMap(data['location']);
                  } else {
                    await FirebaseService().completeRequest(id, 5.5, 'MITRA_01', driverId);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tugas Selesai! Koin Driver & Mitra bertambah.')));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(status == 'pending' ? 'ACC & Buka Maps' : 'Konfirmasi Selesai'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
