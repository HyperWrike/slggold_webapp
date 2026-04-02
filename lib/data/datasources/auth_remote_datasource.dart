import '../models/user_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../core/services/local_storage_service.dart';
import 'convex_api.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> registerCustomer({
    required String email,
    required String password,
    required Map<String, dynamic> profileData,
    required String pin,
  });

  Future<UserModel> loginCustomer(String email, String password);
  Future<void> logout();
  Future<bool> verifyPin(String pin);
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._storage);

  final LocalStorageService _storage;

  String _hashPin(String pin) {
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<UserModel> loginCustomer(String email, String password) async {
    final res = await convexAction('authActions:login', {
      'email': email,
      'password': password,
    });
    if (res is! Map) throw Exception('Invalid login response');
    final resultMap = Map<String, dynamic>.from(res as Map);
    final token = resultMap['token'];
    if (token is! String) throw Exception('Invalid login response');
    await _storage.saveAuthToken(token);
    final profileData = resultMap['profile'];
    if (profileData is! Map) throw Exception('Invalid login response');
    final profile = Map<String, dynamic>.from(profileData as Map);
    return UserModel.fromJson(profile);
  }

  @override
  Future<void> logout() async {
    final token = await _storage.getAuthToken();
    if (token != null) {
      try {
        await convexMutation('auth:logout', {'sessionToken': token});
      } catch (_) {}
    }
    await _storage.deleteAuthToken();
  }

  @override
  Future<UserModel> registerCustomer({
    required String email,
    required String password,
    required Map<String, dynamic> profileData,
    required String pin,
  }) async {
    final res = await convexAction('authActions:register', {
      'email': email,
      'password': password,
      'full_name': profileData['full_name'],
      'username': profileData['username'],
      'phone': profileData['phone'],
      'aadhaar': profileData['aadhaar'],
      'dob': profileData['dob'],
      'gender': profileData['gender'],
      'father_name': profileData['father_name'],
      'birth_place': profileData['birth_place'],
      'address': profileData['address'],
      'nominee_name': profileData['nominee_name'],
      'nominee_relationship': profileData['nominee_relationship'],
      'pin_hash': _hashPin(pin),
      'pin_length': pin.length.toString(),
    });
    if (res is! Map) throw Exception('Invalid registration response');
    final resultMap = Map<String, dynamic>.from(res as Map);
    final token = resultMap['token'];
    if (token is! String) throw Exception('Invalid registration response');
    await _storage.saveAuthToken(token);
    final profile = resultMap['profile'];
    if (profile is! Map) throw Exception('Invalid registration response');
    return UserModel.fromJson(Map<String, dynamic>.from(profile as Map));
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final user = await getCurrentUser();
    if (user == null) throw Exception('Not logged in');

    final token = await _storage.getAuthToken();
    if (token == null) throw Exception('Not logged in');

    final data = await convexQuery('auth:getCurrentUser', {
      'sessionToken': token,
    });
    if (data == null) return false;
    final map = Map<String, dynamic>.from(data as Map);
    final storedHash = map['pin_hash'];
    return storedHash == _hashPin(pin);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final token = await _storage.getAuthToken();
    if (token == null) return null;

    try {
      final data = await convexQuery('auth:getCurrentUser', {
        'sessionToken': token,
      });
      if (data == null) return null;
      return UserModel.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      return null;
    }
  }
}
