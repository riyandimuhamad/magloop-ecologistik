import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/firebase_service.dart';

class PetaniDashboard extends StatelessWidget {
  const PetaniDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, Mitra Petani!', style: Theme.of(context).textTheme.titleLarge),
            const Text('Pesan pupuk organik untuk pertanian berkelanjutan.'),
            const SizedBox(height: 24),
            _buildOrderSection(context),
            const SizedBox(height: 32),
            const Text('Daftar Pesanan Pupuk', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildHistoryItem('Pupuk Kasgot 50kg', 'On Progress', Colors.blue),
            _buildHistoryItem('Pupuk Kasgot 10kg', 'Completed', AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green[800],
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [Colors.green[800]!, Colors.green[900]!]),
      ),
      child: Column(
        children: [
          const Icon(Icons.local_florist_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text('Pesan Pupuk Kasgot', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Kirim permintaan pupuk organik ke Admin', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showOrderDialog(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green[900]),
            child: const Text('Buat Pesanan Baru'),
          ),
        ],
      ),
    );
  }

  void _showOrderDialog(BuildContext parentContext) {
    final TextEditingController amountCtrl = TextEditingController();
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Detail Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Berapa banyak pupuk kasgot yang Anda butuhkan?', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Jumlah', suffixText: 'Kg'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final amount = amountCtrl.text;
              if (amount.isNotEmpty) {
                // 1. Simpan di background
                FirebaseService().createPickupRequest(
                  'Mitra Petani', 
                  'Kebun Lokasi A ($amount Kg)',
                  'fertilizer'
                );
                
                // 2. Tutup dialog input
                Navigator.pop(ctx);
                
                // 3. Tampilkan Dialog Sukses Instan
                showDialog(
                  context: parentContext,
                  builder: (sctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Column(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 64),
                        SizedBox(height: 16),
                        Text('PESANAN TERKIRIM!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    content: Text('Pesanan $amount Kg pupuk kasgot Anda telah diterima dan akan segera diproses.', textAlign: TextAlign.center),
                    actions: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(sctx),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
                          child: const Text('OK'),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Pesan Sekarang'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String status, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.agriculture_rounded, color: color),
        title: Text(title),
        subtitle: Text('Status: $status'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
