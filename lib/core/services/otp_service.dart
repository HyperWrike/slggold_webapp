import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OtpService {
  // OTP provider configuration is passed at build time using `--dart-define`.
  //
  // Examples:
  //  - flutter run --dart-define=TWILIO_ACCOUNT_SID=xxx --dart-define=TWILIO_AUTH_TOKEN=yyy ...
  static const String _twilioAccountSid = String.fromEnvironment(
    'TWILIO_ACCOUNT_SID',
    defaultValue: 'ACa611b9e7c550246cadfa0eecce6e3445',
  );
  static const String _twilioAuthToken = String.fromEnvironment(
    'TWILIO_AUTH_TOKEN',
    defaultValue: 'fdf39f8ff5348a0ecd01de7578c0fb3d',
  );
  static const String _twilioFromNumber = String.fromEnvironment(
    'TWILIO_FROM_NUMBER',
    defaultValue: '+12603466656',
  );

  // Fast2SMS (commonly cheaper for India)
  static const String _fast2smsApiKey = String.fromEnvironment(
    'FAST2SMS_API_KEY',
    defaultValue:
        'Dx8dAqCa5EbVznTcHuGfQ6Kh3Ps2ZUIYkNeLpj9OoMvywtm4XB4al9ZLUEfG7r1NdjMA6pnysiWPB05I',
  );
  static const String _fast2smsRoute = String.fromEnvironment(
    'FAST2SMS_ROUTE',
    defaultValue: 'otp',
  );

  // Textlocal (backup)
  static const String _textlocalApiKey = String.fromEnvironment(
    'TEXTLOCAL_API_KEY',
    defaultValue: '',
  );
  static const String _textlocalSender = String.fromEnvironment(
    'TEXTLOCAL_SENDER',
    defaultValue: '',
  );

  static const String _defaultProviderOrder = 'fast2sms,twilio,textlocal';

  List<_OtpProvider> _providerOrder() {
    const raw = String.fromEnvironment(
      'OTP_PROVIDER_ORDER',
      defaultValue: _defaultProviderOrder,
    );
    final order = raw
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty);

    final mapped = <_OtpProvider>[];
    for (final name in order) {
      switch (name) {
        case 'twilio':
          mapped.add(_OtpProvider.twilio);
          break;
        case 'fast2sms':
          mapped.add(_OtpProvider.fast2sms);
          break;
        case 'textlocal':
          mapped.add(_OtpProvider.textlocal);
          break;
      }
    }

    // Fallback: at least try something if parsing got empty.
    if (mapped.isEmpty) {
      mapped.addAll(const <_OtpProvider>[
        _OtpProvider.twilio,
        _OtpProvider.fast2sms,
        _OtpProvider.textlocal,
      ]);
    }

    return mapped;
  }

  /// Generate a random 6-digit OTP
  String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Send OTP via Twilio SMS
  Future<OtpResult> sendOtp(String mobileNumber, String otpValue) async {
    // Clean phone number
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

    final providers = _providerOrder();

    OtpResult lastFailure = OtpResult(
      success: false,
      message: 'No OTP provider is configured.',
    );

    for (final provider in providers) {
      final result = await _sendWithProvider(provider, cleanNumber, otpValue);
      if (result.success) return result;
      lastFailure = result;
    }

    return lastFailure;
  }

  Future<OtpResult> _sendWithProvider(
    _OtpProvider provider,
    String phone,
    String otp,
  ) async {
    switch (provider) {
      case _OtpProvider.twilio:
        return _sendTwilioSms(phone, otp);
      case _OtpProvider.fast2sms:
        return _sendFast2Sms(phone, otp);
      case _OtpProvider.textlocal:
        return _sendTextlocalSms(phone, otp);
    }
  }

  /// Twilio SMS API
  Future<OtpResult> _sendTwilioSms(String phone, String otp) async {
    if (_twilioAccountSid.isEmpty ||
        _twilioAuthToken.isEmpty ||
        _twilioFromNumber.isEmpty) {
      return OtpResult(
        success: false,
        message: 'Twilio not configured (missing env vars).',
      );
    }

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
        return OtpResult(
          success: true,
          message: 'OTP sent via Twilio to +91$phone',
        );
      } else {
        try {
          final error = json.decode(response.body);
          final errorMsg = error['message'] ?? 'Unknown error';
          final errorCode = error['code'] ?? '';

          // Common Twilio errors for Indian numbers
          if (errorCode == 21211) {
            return OtpResult(
              success: false,
              message: 'Invalid phone number format',
            );
          } else if (errorCode == 21408) {
            return OtpResult(
              success: false,
              message:
                  'India not enabled. Go to Twilio Console → Messaging → Geo Permissions → Enable India',
            );
          } else if (errorCode == 21608) {
            return OtpResult(
              success: false,
              message:
                  'Phone number not verified. Twilio trial can only send to verified numbers. Verify at: console.twilio.com → Phone Numbers → Verified Caller IDs',
            );
          } else if (errorCode == 21610) {
            return OtpResult(
              success: false,
              message:
                  'This phone has opted out of SMS. Reply START to your Twilio number to opt in.',
            );
          }

          return OtpResult(
            success: false,
            message: 'Twilio error ($errorCode): $errorMsg',
          );
        } catch (_) {
          return OtpResult(
            success: false,
            message: 'Twilio failed (${response.statusCode}).',
          );
        }
      }
    } catch (e) {
      return OtpResult(
        success: false,
        message: 'Network error: Check internet connection',
      );
    }
  }

  /// Fast2SMS OTP (usually cheaper in India)
  Future<OtpResult> _sendFast2Sms(String phone, String otp) async {
    if (_fast2smsApiKey.isEmpty) {
      return OtpResult(
        success: false,
        message: 'Fast2SMS not configured (missing FAST2SMS_API_KEY).',
      );
    }

    try {
      final url = Uri.parse('https://www.fast2sms.com/dev/bulkV2');
      final response = await http
          .post(
            url,
            headers: {
              'authorization': _fast2smsApiKey,
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {
              'route': _fast2smsRoute,
              'variables_values': otp,
              'numbers': phone,
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map) {
          final ret = data['return'];
          final statusCode = int.tryParse('${data['status_code'] ?? ''}');
          final isSuccess = ret == true || '$ret'.toLowerCase() == 'true';

          if (isSuccess) {
            return OtpResult(
              success: true,
              message: 'OTP sent via Fast2SMS to +91$phone',
            );
          }

          if (statusCode == 996) {
            return OtpResult(
              success: false,
              message:
                  'Fast2SMS account setup incomplete. Complete website verification in Fast2SMS OTP menu, or use DLT SMS API.',
            );
          }

          final error = data['message'] ?? data['error'] ?? 'Unknown error';
          return OtpResult(success: false, message: 'Fast2SMS failed: $error');
        }
        return OtpResult(
          success: false,
          message: 'Fast2SMS failed (unexpected response).',
        );
      }

      return OtpResult(
        success: false,
        message: 'Fast2SMS failed (${response.statusCode}).',
      );
    } catch (e) {
      return OtpResult(success: false, message: 'Fast2SMS network error: $e');
    }
  }

  /// Textlocal OTP (backup)
  Future<OtpResult> _sendTextlocalSms(String phone, String otp) async {
    if (_textlocalApiKey.isEmpty) {
      return OtpResult(
        success: false,
        message: 'Textlocal not configured (missing TEXTLOCAL_API_KEY).',
      );
    }

    try {
      final url = Uri.parse('https://api.textlocal.in/send/');
      final body = <String, String>{
        'apikey': _textlocalApiKey,
        'numbers': '+91$phone',
        'message': 'Your SLG Golds verification code is: $otp.',
      };
      if (_textlocalSender.isNotEmpty) {
        body['sender'] = _textlocalSender;
      }

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map) {
          final status = data['status'];
          if (status == 'success' || data['type'] == 'success') {
            return OtpResult(
              success: true,
              message: 'OTP sent via Textlocal to +91$phone',
            );
          }
          if (data['errors'] != null) {
            return OtpResult(
              success: false,
              message: 'Textlocal error: ${data['errors']}',
            );
          }
        }
        return OtpResult(
          success: false,
          message: 'Textlocal failed (unexpected response).',
        );
      }

      return OtpResult(
        success: false,
        message: 'Textlocal failed (${response.statusCode}).',
      );
    } catch (e) {
      return OtpResult(success: false, message: 'Textlocal network error: $e');
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

enum _OtpProvider { twilio, fast2sms, textlocal }
