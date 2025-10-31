import 'package:uy_dosh/domain/models/otp_code.dart';
import 'package:uy_dosh/domain/models/auth/create_otp_request.dart';
import 'package:uy_dosh/domain/models/auth/verify_otp_request.dart';

abstract class IOtpService {
  /// Create and send an OTP code to the specified email
  Future<OtpCode> createOtp(CreateOtpRequest request);

  /// Verify an OTP code for the specified email
  Future<bool> verifyOtp(VerifyOtpRequest request);

  /// Resend OTP code to the specified email
  Future<OtpCode> resendOtp(String email, String type);

  /// Check if an OTP code is valid and not expired
  Future<bool> isOtpValid(String email, String code, String type);
}
