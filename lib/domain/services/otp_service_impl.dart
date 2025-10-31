import 'package:uy_dosh/domain/services/otp_service.dart';
import 'package:uy_dosh/domain/models/otp_code.dart';
import 'package:uy_dosh/domain/models/auth/create_otp_request.dart';
import 'package:uy_dosh/domain/models/auth/verify_otp_request.dart';
import 'package:uy_dosh/base/api/client/public_api_client.dart';
import 'package:uy_dosh/base/logger/logger.dart';

class OtpService implements IOtpService {
  final IPublicApiClient _publicApiClient;

  OtpService(this._publicApiClient);

  @override
  Future<OtpCode> createOtp(CreateOtpRequest request) async {
    try {
      logger.d('=== OTP SERVICE DEBUG: Starting OTP creation ===');
      logger.d('=== OTP SERVICE DEBUG: Request: ${request.toJson()} ===');

      // Use public API client for OTP creation (no authentication required)
      logger.d(
        '=== OTP SERVICE DEBUG: Using public API client with endpoint: /otp/generate ===',
      );

      final response = await _publicApiClient
          .post<Map<String, dynamic>, CreateOtpRequest>(
            '/otp/generate',
            (dynamic json) => json as Map<String, dynamic>,
            data: request,
          );

      logger.d(
        '=== OTP SERVICE DEBUG: API call successful, response: ${response.toString()} ===',
      );

      // The backend returns a success message, not a full OtpCode object
      // We need to create a minimal OtpCode object for the frontend
      if (response['message'] != null &&
          response['message'].toString().contains('successfully')) {
        logger.d(
          '=== OTP SERVICE DEBUG: Backend response successful, creating OtpCode object ===',
        );

        // Extract and validate the expiresAt field
        String expiresAt;
        if (response['expiresAt'] != null) {
          expiresAt = response['expiresAt'].toString();
          logger.d(
            '=== OTP SERVICE DEBUG: Using expiresAt from backend: $expiresAt ===',
          );
        } else {
          expiresAt =
              DateTime.now().add(Duration(minutes: 10)).toIso8601String();
          logger.d(
            '=== OTP SERVICE DEBUG: Using default expiresAt: $expiresAt ===',
          );
        }

        // Create a minimal OtpCode object with the data we have
        final otpCode = OtpCode(
          id: 0, // We don't have the actual ID from backend
          email: request.email,
          code:
              '0000', // We don't have the actual code from backend, use placeholder
          type: request.type,
          isUsed: false,
          expiresAt: expiresAt,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );

        logger.d(
          '=== OTP SERVICE DEBUG: Created minimal OtpCode object successfully ===',
        );
        logger.d(
          '=== OTP SERVICE DEBUG: OtpCode details: id=${otpCode.id}, email=${otpCode.email}, type=${otpCode.type} ===',
        );
        return otpCode;
      } else {
        logger.d(
          '=== OTP SERVICE DEBUG: Backend response does not contain success message ===',
        );
        throw Exception(
          'Unexpected response format from backend: ${response.toString()}',
        );
      }
    } catch (e) {
      logger.d('=== OTP SERVICE DEBUG: Error in createOtp: $e ===');
      throw Exception('Failed to create OTP: $e');
    }
  }

  @override
  Future<bool> verifyOtp(VerifyOtpRequest request) async {
    try {
      logger.d('=== OTP VERIFY DEBUG: Starting OTP verification ===');
      logger.d('=== OTP VERIFY DEBUG: Request: ${request.toJson()} ===');

      // Use public API client since OTP validation might not require authentication
      logger.d(
        '=== OTP VERIFY DEBUG: Using public API client for /otp/validate ===',
      );

      final response = await _publicApiClient
          .post<Map<String, dynamic>, VerifyOtpRequest>(
            '/otp/validate',
            (dynamic json) => json as Map<String, dynamic>,
            data: request,
          );

      logger.d(
        '=== OTP VERIFY DEBUG: Response received: ${response.toString()} ===',
      );

      // Check if the response indicates successful validation
      // The backend returns success through the message content, not boolean flags
      final isVerified =
          response['message'] != null &&
          response['message'].toString().toLowerCase().contains(
            'validated successfully',
          );

      logger.d('=== OTP VERIFY DEBUG: Message: ${response['message']} ===');
      logger.d('=== OTP VERIFY DEBUG: Verification result: $isVerified ===');

      return isVerified;
    } catch (e) {
      logger.d('=== OTP VERIFY DEBUG: Error in verifyOtp: $e ===');
      throw Exception('Failed to verify OTP: $e');
    }
  }

  @override
  Future<OtpCode> resendOtp(String email, String type) async {
    try {
      // Create a temporary request object for resend
      final request = CreateOtpRequest(email: email, type: type);

      final response = await _publicApiClient.post<OtpCode, CreateOtpRequest>(
        '/otp/resend',
        (dynamic json) => OtpCode.fromJson(json as Map<String, dynamic>),
        data: request,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to resend OTP: $e');
    }
  }

  @override
  Future<bool> isOtpValid(String email, String code, String type) async {
    try {
      final request = VerifyOtpRequest(email: email, code: code, type: type);

      // Use public API client for consistency
      final response = await _publicApiClient
          .post<Map<String, dynamic>, VerifyOtpRequest>(
            '/otp/validate',
            (dynamic json) => json as Map<String, dynamic>,
            data: request,
          );

      // Check if the response indicates successful validation
      final isValid =
          response['message'] != null &&
          response['message'].toString().toLowerCase().contains(
            'validated successfully',
          );

      return isValid;
    } catch (e) {
      throw Exception('Failed to validate OTP: $e');
    }
  }
}
