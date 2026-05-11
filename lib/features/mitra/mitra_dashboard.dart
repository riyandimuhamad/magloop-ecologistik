import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../main.dart';

class MitraDashboard extends StatelessWidget {
  const MitraDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildBalanceCard(context),
            const SizedBox(height: 32),
            _buildActionSection(context),
            const SizedBox(height: 16),
            _buildAIActionSection(context),
            const SizedBox(height: 32),
            _buildRoleSwitcher(context), 
          ],
        ),
      ),
    );
  }

  Widget _buildAIActionSection(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Membuka Gemini AI Camera... (Fitur AI QC Aktif)'))
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI Quality Control', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Deteksi kontaminasi pakan via Gemini AI', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Halo, Mitra Magloop!', style: Theme.of(context).textTheme.titleLarge),
        Text('Ayo jaga ekosistem dapur hari ini.', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return StreamBuilder<int>(
      stream: FirebaseService().getBalance(),
      builder: (context, snapshot) {
        final balance = snapshot.data ?? 0;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF065F46)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saldo GreenCoin', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('$balance GC', 
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white24, height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Setara: Rp ${(balance * 100)}', 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  ElevatedButton(
                    onPressed: () => _showRedeemDialog(context, balance),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Tukar Koin', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRedeemDialog(BuildContext context, int currentBalance) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Voucher Penukaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildRedeemItem(context, 'Voucher Sembako Rp 10rb', 100, currentBalance),
            _buildRedeemItem(context, 'Voucher Listrik Rp 20rb', 200, currentBalance),
            _buildRedeemItem(context, 'Saldo Digital Rp 50rb', 500, currentBalance),
          ],
        ),
      ),
    );
  }

  Widget _buildRedeemItem(BuildContext context, String title, int cost, int balance) {
    final bool canAfford = balance >= cost;
    return ListTile(
      leading: const Icon(Icons.redeem_rounded, color: Colors.orange),
      title: Text(title),
      subtitle: Text('$cost GreenCoins'),
      trailing: ElevatedButton(
        onPressed: canAfford ? () async {
          await FirebaseService().redeemCoins(cost);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Penukaran Berhasil!')));
        } : null,
        child: const Text('Tukar'),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return InkWell(
      onTap: () {
        // Tampilkan feedback instan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                SizedBox(width: 16),
                Text('Mengirim permintaan...'),
              ],
            ),
            duration: Duration(seconds: 1),
          ),
        );

        // Kirim ke Firebase di background (tanpa await yang menghambat UI)
        FirebaseService().createPickupRequest('Restoran Sedap', 'Jl. Merdeka No. 10').then((_) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 60),
                content: const Text('Berhasil! Permintaan Anda sudah masuk antrian.', textAlign: TextAlign.center),
                actions: [Center(child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Oke')))],
              ),
            );
          }
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Column(
          children: [
            const Icon(Icons.add_location_alt_rounded, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Setor Sampah', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
            const Text('Request driver menjemput sekarang'),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSwitcher(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Ganti Role (Demo Mode):'),
          DropdownButton<AppRole>(
            value: currentUserRole.value,
            items: AppRole.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
            onChanged: (val) {
              if (val != null) currentUserRole.value = val;
            },
          ),
        ],
      ),
    );
  }
}
