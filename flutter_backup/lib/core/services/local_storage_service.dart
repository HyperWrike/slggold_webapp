import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Save Token
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Get Token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Delete Token
  Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Biometric preference
  Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  Future<bool> getBiometricEnabled() async {
    final val = await _storage.read(key: 'biometric_enabled');
    return val == 'true';
  }

  // Save Offline Data (JSON stringified)
  Future<void> saveOfflineData(String key, String data) async {
    await _storage.write(key: 'offline_\$key', value: data);
  }

  // Get Offline Data
  Future<String?> getOfflineData(String key) async {
    return await _storage.read(key: 'offline_\$key');
  }

  // Clear Offline Data
  Future<void> clearOfflineData(String key) async {
    await _storage.delete(key: 'offline_\$key');
  }
}
