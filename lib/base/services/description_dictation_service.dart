import "package:dio/dio.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

/// Result of `POST /app/openai/transcribe-description` (OpenAI Whisper).
class DescriptionDictationResult {
  const DescriptionDictationResult({
    this.text,
    this.authRequired = false,
    this.notConfigured = false,
    this.errorMessage,
  });

  final String? text;
  final bool authRequired;
  final bool notConfigured;
  final String? errorMessage;

  bool get isSuccess =>
      text != null && text!.trim().isNotEmpty && !authRequired && !notConfigured;
}

class DescriptionDictationService {
  DescriptionDictationService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  Future<DescriptionDictationResult> transcribeRecording({
    required String filePath,
    required String languageCode,
  }) async {
    final base = EnvironmentUtil.basePath;
    final uri = base.endsWith("/")
        ? "${base}app/openai/transcribe-description"
        : "$base/app/openai/transcribe-description";

    final formData = FormData.fromMap({
      "audio": await MultipartFile.fromFile(
        filePath,
        filename: "recording.m4a",
      ),
      "language": languageCode,
    });

    try {
      final res = await _oauthApiClient.dio.post<Map<String, dynamic>>(
        uri,
        data: formData,
      );
      final raw = res.data?["text"];
      final text = raw is String ? raw.trim() : "";
      if (text.isEmpty) {
        return const DescriptionDictationResult();
      }
      return DescriptionDictationResult(text: text);
    } on DioException catch (e, st) {
      final status = e.response?.statusCode;
      if (status == 401) {
        return const DescriptionDictationResult(authRequired: true);
      }
      if (status == 503) {
        return const DescriptionDictationResult(notConfigured: true);
      }
      logger.w(
        "Dictation transcribe failed: $e",
        error: e,
        stackTrace: st,
      );
      return DescriptionDictationResult(errorMessage: e.message);
    } catch (e, st) {
      logger.w("Dictation transcribe error", error: e, stackTrace: st);
      return DescriptionDictationResult(errorMessage: "$e");
    }
  }
}
