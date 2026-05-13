import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../services/ai_service.dart';

class AIQCPage extends StatefulWidget {
  const AIQCPage({super.key});

  @override
  State<AIQCPage> createState() => _AIQCPageState();
}

class _AIQCPageState extends State<AIQCPage> {
  Uint8List? _imageBytes;
  bool _isLoading = false;
  String _result = "";

  Future<void> _pickAndAnalyze() async {
    final picker = ImagePicker();
    // Gunakan gallery untuk kemudahan testing di Web, atau camera untuk mobile
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _isLoading = true;
        _result = "";
      });

      // Panggil Gemini AI
      final response = await AIService().analyzeWasteQuality(bytes);

      setState(() {
        _result = response;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Quality Control')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildExplanationCard(),
            const SizedBox(height: 32),
            if (_imageBytes != null) 
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  _imageBytes!, 
                  height: 250, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Gemini AI sedang menganalisis...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              )
            else if (_result.isNotEmpty)
              _buildResultCard()
            else
              _buildEmptyState(),
            const SizedBox(height: 40),
            _buildCaptureButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50], 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_outlined, color: Colors.blue, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kenapa AI QC?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                Text(
                  'BSF Maggot tidak bisa memakan plastik/logam. Pastikan pakan mereka bersih agar panen koin Anda maksimal!',
                  style: TextStyle(fontSize: 11, color: Colors.blue[900]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySurface, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('HASIL ANALISIS GEMINI', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 12)),
            ],
          ),
          const Divider(height: 24),
          Text(_result, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(Icons.add_a_photo_outlined, size: 80, color: Colors.grey[200]),
        const SizedBox(height: 16),
        const Text('Ambil foto sampah organik Anda\nuntuk dicek oleh AI.', 
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildCaptureButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: _pickAndAnalyze,
        icon: const Icon(Icons.camera_enhance_rounded),
        label: const Text('MULAI ANALISIS AI', style: TextStyle(letterSpacing: 1.1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.4),
        ),
      ),
    );
  }
}
