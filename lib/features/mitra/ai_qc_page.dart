import 'dart:io';
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
  File? _image;
  bool _isLoading = false;
  String _result = "";

  Future<void> _pickAndAnalyze() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
        _result = "";
      });

      // Panggil Gemini AI
      final bytes = await pickedFile.readAsBytes();
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
            if (_image != null) 
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
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
      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Gunakan fitur ini untuk memastikan sampah Anda bebas kontaminasi pakan maggot (plastik/kaca/logam).',
              style: TextStyle(fontSize: 12, color: Colors.blue[900]),
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
      decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hasil Analisis AI:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_result, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 8),
        const Text('Belum ada foto yang dianalisis', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildCaptureButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _pickAndAnalyze,
        icon: const Icon(Icons.camera_rounded),
        label: const Text('Ambil Foto Sampah'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
