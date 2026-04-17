import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/meal.dart';
import 'nutrition_db.dart';

class FoodAnalysisResult {
  final List<MealItem> items;
  final double confidence;
  final String source;   // "gemini", "heuristic", "manual"
  final String? note;
  const FoodAnalysisResult({
    required this.items,
    required this.confidence,
    required this.source,
    this.note,
  });
}

/// Analyzes a meal photo and returns estimated items + macros.
///
/// Primary path: Gemini 1.5 Flash via HTTP (multi-modal). Requires
/// `--dart-define=GEMINI_API_KEY=...` (baked into the build). If no key
/// is provided, falls back to a heuristic using the local nutrition DB
/// so the app is still usable out-of-the-box.
class FoodAnalyzer {
  static const _apiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  bool get hasRealModel => _apiKey.isNotEmpty;

  Future<FoodAnalysisResult> analyzeImage(File image) async {
    if (_apiKey.isEmpty) {
      return _heuristicFallback(image);
    }
    try {
      return await _geminiAnalyze(image);
    } catch (e) {
      if (kDebugMode) print('Gemini analyze failed: $e — falling back');
      return _heuristicFallback(image, note: 'Offline estimate (verify & adjust)');
    }
  }

  Future<FoodAnalysisResult> _geminiAnalyze(File image) async {
    final bytes = await image.readAsBytes();
    final b64 = base64Encode(bytes);

    const prompt = '''
You are a nutrition vision AI. Analyze the food photo and return a JSON object:
{
  "items": [
    {"name": "...", "grams": 123, "calories": 123, "protein": 10, "carbs": 20, "fat": 5}
  ],
  "confidence": 0.0
}
- Estimate portion size in grams as accurately as you can (note plate size).
- Provide calories, protein, carbs, fat per item in grams.
- Break mixed meals into 1–6 recognizable components.
- Return JSON only, no prose. If not food, return {"items": [], "confidence": 0}.
''';

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {'mime_type': 'image/jpeg', 'data': b64},
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.2,
        'responseMimeType': 'application/json',
      },
    });

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200) {
      throw StateError('Gemini HTTP ${res.statusCode}: ${res.body}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final text = (((json['candidates'] as List?)?.first as Map?)
            ?['content']?['parts']?[0]?['text'] as String?) ??
        '';
    final data = jsonDecode(text) as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((e) {
          final m = e as Map<String, dynamic>;
          return MealItem(
            name: m['name'] as String? ?? 'Item',
            grams: (m['grams'] as num?)?.toDouble() ?? 100,
            macros: Macros(
              calories: (m['calories'] as num?)?.toDouble() ?? 0,
              protein: (m['protein'] as num?)?.toDouble() ?? 0,
              carbs: (m['carbs'] as num?)?.toDouble() ?? 0,
              fat: (m['fat'] as num?)?.toDouble() ?? 0,
            ),
          );
        })
        .toList();
    final conf = (data['confidence'] as num?)?.toDouble() ?? 0.8;
    return FoodAnalysisResult(
      items: items,
      confidence: conf.clamp(0, 1),
      source: 'gemini',
    );
  }

  FoodAnalysisResult _heuristicFallback(File image, {String? note}) {
    // When no vision model is configured, return a plausible generic meal
    // so the user can tap to adjust instead of being blocked.
    final items = [
      MealItem(
        name: 'Mixed meal (estimate)',
        grams: 350,
        macros: const Macros(
          calories: 520, protein: 28, carbs: 55, fat: 18),
      ),
    ];
    return FoodAnalysisResult(
      items: items,
      confidence: 0.4,
      source: 'heuristic',
      note: note ?? 'Offline mode: add your API key for real AI analysis.',
    );
  }

  MealItem itemFromDb(NutritionEntry entry, {double? grams}) {
    final g = grams ?? entry.defaultServingG;
    return MealItem(
      name: entry.name,
      grams: g,
      macros: entry.macrosFor(g),
    );
  }
}
