import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../services/firebase_service.dart';
import '../../../../core/theme/app_theme.dart';

class VerificationScanner extends StatefulWidget {
  const VerificationScanner({super.key});

  @override
  State<VerificationScanner> createState() => _VerificationScannerState();
}

class _VerificationScannerState extends State<VerificationScanner> {
  bool isScanned = false;
  final MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _showWeightInput(String partnerId) {
    final TextEditingController weightCtrl = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Input Berat Sampah'),
        content: TextField(
          controller: weightCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            suffixText: 'Kg',
            hintText: '0.0',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => isScanned = false);
              Navigator.pop(ctx);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final double weight = double.tryParse(weightCtrl.text) ?? 0;
              await FirebaseService().recordTransaction(
                partnerId: partnerId,
                weight: weight,
                type: 'Organic',
              );
              Navigator.pop(ctx);
              _showSuccessAnimation();
            },
            child: const Text('Simpan Ke Ledger'),
          ),
        ],
      ),
    );
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, size: 80, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Berhasil Diverifikasi!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('Selesai'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi QR')),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && !isScanned) {
                setState(() => isScanned = true);
                _showWeightInput(barcodes.first.rawValue ?? 'Unknown');
              }
            },
          ),
          // Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
