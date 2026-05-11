import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AIService {
  // Ganti dengan API Key Anda dari Google AI Studio
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';
  
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
  );

  Future<String> analyzeWasteQuality(Uint8List imageBytes) async {
    try {
      final content = [
        Content.multi([
          DataPart('image/jpeg', imageBytes),
          TextPart('Analisis foto sampah organik ini. Apakah ada kontaminasi non-organik (plastik/logam)? Berikan skor kualitas 1-10 untuk pakan maggot.'),
        ])
      ];
      
      final response = await _model.generateContent(content);
      return response.text ?? 'Gagal menganalisis gambar.';
    } catch (e) {
      return 'Error AI: $e';
    }
  }
}
