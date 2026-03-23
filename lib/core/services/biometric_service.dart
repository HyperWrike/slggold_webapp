import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({String reason = 'Please authenticate to access SLG Golds'}) async {
    final isAvailable = await isBiometricAvailable();
    if (!isAvailable) return false;

    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        // Handle not enrolled
      } else if (e.code == auth_error.lockedOut || e.code == auth_error.permanentlyLockedOut) {
        // Handle locked out
      }
      return false;
    }
  }
}
