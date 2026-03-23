import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

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
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl(this.supabase);

  String _hashPin(String pin) {
    // Basic SHA-256 hash for PIN (since bcrypt is heavy for client side)
    // In production, recommend checking pin securely or sending encrypted.
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<UserModel> loginCustomer(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user == null) {
      throw Exception('Login failed');
    }

    final profileResponse = await supabase
        .from('profiles')
        .select()
        .eq('id', response.user!.id)
        .single();
        
    return UserModel.fromJson(profileResponse);
  }

  @override
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Future<UserModel> registerCustomer({
    required String email,
    required String password,
    required Map<String, dynamic> profileData,
    required String pin,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Registration failed');
    }

    // Add pinHash to profile data
    profileData['id'] = response.user!.id;
    profileData['pin_hash'] = _hashPin(pin);
    profileData['pin_length'] = pin.length;
    profileData['role'] = 'customer';

    final profileResponse = await supabase
        .from('profiles')
        .insert(profileData)
        .select()
        .single();

    return UserModel.fromJson(profileResponse);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final profileResponse = await supabase
        .from('profiles')
        .select('pin_hash')
        .eq('id', user.id)
        .single();
    
    final storedHash = profileResponse['pin_hash'];
    return storedHash == _hashPin(pin);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final session = supabase.auth.currentSession;
    if (session == null) return null;

    try {
      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .single();
      return UserModel.fromJson(profileResponse);
    } catch (e) {
      return null;
    }
  }
}
