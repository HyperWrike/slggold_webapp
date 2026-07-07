import 'dart:math';

import 'package:slg_golds/data/datasources/convex_api.dart';

class OtpService {
  /// Generate a random 6-digit OTP
  String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Send OTP via Brevo email
  Future<OtpResult> sendOtp(String email, String otpValue) async {
    try {
      await convexAction("emailService:sendOtpEmail", {
        "email": email,
        "otp": otpValue,
      });
      return OtpResult(
        success: true,
        message: 'OTP sent to $email',
      );
    } catch (e) {
      return OtpResult(
        success: false,
        message: 'Failed to send OTP email: $e',
      );
    }
  }

  /// Verify OTP (local comparison)
  bool verifyOtp(String inputOtp, String generatedOtp) {
    return inputOtp == generatedOtp;
  }
}

class OtpResult {
  final bool success;
  final String message;

  OtpResult({required this.success, required this.message});
}
