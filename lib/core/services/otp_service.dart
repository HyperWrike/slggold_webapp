import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OtpService {
  // Twilio Config (Free $15 trial - get from twilio.com)
  static const String _twilioAccountSid = 'ACa611b9e7c550246cadfa0eecce6e3445';
  static const String _twilioAuthToken = 'fdf39f8ff5348a0ecd01de7578c0fb3d';
  static const String _twilioFromNumber = '+12603466656';

  // MSG91 Config (Free tier - get from msg91.com)
  static const String _msg91AuthKey = 'YOUR_MSG91_AUTH_KEY';
  static const String _msg91SenderId = 'SLGOLD';
  static const String _msg91TemplateId = 'YOUR_TEMPLATE_ID';

  /// Generate a random 6-digit OTP
  String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Send OTP - tries SMS services in order
  Future<OtpResult> sendOtp(String mobileNumber, String otpValue) async {
    final cleanNumber = mobileNumber
        .replaceAll('+91', '')
        .replaceAll(' ', '')
        .replaceAll('-', '');

    if (cleanNumber.length != 10) {
      return OtpResult(
        success: false,
        message: 'Invalid phone number. Must be 10 digits.',
      );
    }

    // Try Twilio first (most reliable SMS)
    final result1 = await _tryTwilio(cleanNumber, otpValue);
    if (result1.success) return result1;

    // Try MSG91
    final result2 = await _tryMsg91(cleanNumber, otpValue);
    if (result2.success) return result2;

    // All SMS failed
    return OtpResult(
      success: false,
      message: 'SMS services unavailable. Check API keys.',
    );
  }

  /// Method 1: Twilio SMS API
  Future<OtpResult> _tryTwilio(String phone, String otp) async {
    try {
      // Basic Auth with Account SID:Auth Token
      final credentials = base64Encode(
        utf8.encode('$_twilioAccountSid:$_twilioAuthToken'),
      );

      final url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$_twilioAccountSid/Messages.json',
      );

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Basic $credentials',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {
              'From': _twilioFromNumber,
              'To': '+91$phone',
              'Body':
                  'Your SLG Golds verification code is: $otp. Valid for 5 minutes.',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return OtpResult(success: true, message: 'OTP sent via Twilio SMS');
      }
      return OtpResult(success: false, message: 'Twilio SMS failed');
    } catch (e) {
      return OtpResult(success: false, message: 'Twilio error');
    }
  }

  /// Method 2: MSG91 SMS API (Free: 20 SMS/day)
  Future<OtpResult> _tryMsg91(String phone, String otp) async {
    try {
      final url = Uri.parse('https://control.msg91.com/api/v5/otp');

      final response = await http
          .post(
            url,
            headers: {
              'accept': 'application/json',
              'content-type': 'application/json',
              'authkey': _msg91AuthKey,
            },
            body: json.encode({
              'template_id': _msg91TemplateId,
              'mobile': '91$phone',
              'authkey': _msg91AuthKey,
              'otp': otp,
              'sender': _msg91SenderId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['type'] == 'success') {
          return OtpResult(success: true, message: 'OTP sent via MSG91');
        }
      }
      return OtpResult(success: false, message: 'MSG91 failed');
    } catch (e) {
      return OtpResult(success: false, message: 'MSG91 error');
    }
  }

  /// Verify OTP
  bool verifyOtp(String inputOtp, String generatedOtp) {
    return inputOtp == generatedOtp;
  }
}

class OtpResult {
  final bool success;
  final String message;

  OtpResult({required this.success, required this.message});
}
