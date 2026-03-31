import "package:google_generative_ai/google_generative_ai.dart";
import "package:uy_dosh/base/config/gemini_config.dart";
import "package:uy_dosh/base/logger/logger.dart";

/// Thin wrapper around [GenerativeModel] for Gemini (Google AI) API calls.
///
/// Disabled when [GeminiConfig.apiKey] is empty.
class GeminiService {
  GeminiService() : _model = _createModel();

  final GenerativeModel? _model;

  static GenerativeModel? _createModel() {
    if (!GeminiConfig.isConfigured) {
      logger.d("GeminiService: api key empty; Gemini is disabled.");
      return null;
    }
    return GenerativeModel(
      model: GeminiConfig.defaultModel,
      apiKey: GeminiConfig.apiKey,
    );
  }

  bool get isAvailable => _model != null;

  /// Returns model text, or null if the response had no text parts.
  Future<String?> generateText(String prompt) async {
    final model = _model;
    if (model == null) {
      throw StateError("Gemini is not configured (empty api key).");
    }
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text;
  }

  /// Same as [generateText] but does not throw when the API key is missing;
  /// returns null instead.
  Future<String?> generateTextOrNull(String prompt) async {
    if (_model == null) {
      return null;
    }
    return generateText(prompt);
  }
}
