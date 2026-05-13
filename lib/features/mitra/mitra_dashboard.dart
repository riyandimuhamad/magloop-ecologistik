import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../main.dart';
import '../../core/config/app_config.dart';
import './ai_qc_page.dart';

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
            const SizedBox(height: 32),
            _buildWalletCard(context),
            const SizedBox(height: 32),
            _buildActionSection(context),
            const SizedBox(height: 16),
            _buildAIActionSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, Restoran Sedap!', style: Theme.of(context).textTheme.titleLarge),
            const Text('Ayo setor sampah organik hari ini.'),
          ],
        ),
        const CircleAvatar(
          backgroundColor: AppColors.primarySurface,
          child: Icon(Icons.store_rounded, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildWalletCard(BuildContext context) {
    return StreamBuilder<int>(
      stream: FirebaseService().getBalance('MITRA_01'),
      builder: (context, snapshot) {
        final balance = snapshot.data ?? 0;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            image: const DecorationImage(
              image: NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
              opacity: 0.1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saldo GreenCoin', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text('$balance GC', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Setara: Rp ${AppConfig.calculateRupiah(balance)}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                  TextButton(
                    onPressed: () => FirebaseService().redeemCoins('MITRA_01', balance),
                    style: TextButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                    child: const Text('Tukar Koin', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return InkWell(
      onTap: () {
        // 1. Jalankan proses simpan di latar belakang (Background)
        FirebaseService().createPickupRequest('Restoran Sedap', 'Jl. Sudirman No. 12', 'waste');
        
        // 2. Langsung tampilkan Dialog Sukses detik itu juga!
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            title: const Column(
              children: [
                Icon(Icons.check_circle, color: AppColors.primary, size: 64),
                SizedBox(height: 16),
                Text('BERHASIL!', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            content: const Text(
              'Permintaan penjemputan sampah Anda telah berhasil dikirim ke sistem Magloop.',
              textAlign: TextAlign.center,
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('OK, SIAP!'),
                ),
              ),
            ],
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.delete_sweep_rounded, color: AppColors.primary, size: 32),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Setor Sampah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Panggil driver untuk menjemput limbah.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildAIActionSection(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) => const AIQCPage()));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 32),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Quality Control', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Cek kebersihan pakan maggot dengan AI.', style: TextStyle(color: AppColors.primaryDark, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
