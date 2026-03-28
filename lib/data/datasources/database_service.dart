import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../presentation/providers/auth_provider.dart';

class DatabaseService {
  final SupabaseClient _supabase;

  DatabaseService(this._supabase);

  // Schemes
  Future<List<Map<String, dynamic>>> getAvailableSchemes() async {
    try {
      final response = await _supabase
          .from('schemes')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching schemes: $e');
      return [];
    }
  }

  // User Enrollments - fetch enrollments then attach scheme data
  Future<List<Map<String, dynamic>>> getUserEnrollments(String userId) async {
    try {
      // Fetch enrollments for the user
      final enrollmentsResponse = await _supabase
          .from('enrollments')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final enrollments = List<Map<String, dynamic>>.from(enrollmentsResponse);

      // Fetch all schemes to attach to enrollments
      final schemesResponse = await _supabase.from('schemes').select();
      final schemes = List<Map<String, dynamic>>.from(schemesResponse);

      // Build a map of scheme_id -> scheme data
      final schemeMap = <String, Map<String, dynamic>>{};
      for (final scheme in schemes) {
        final id = scheme['id']?.toString();
        if (id != null) {
          schemeMap[id] = scheme;
        }
      }

      // Attach scheme data to each enrollment
      for (final enrollment in enrollments) {
        final schemeId = enrollment['scheme_id']?.toString();
        if (schemeId != null && schemeMap.containsKey(schemeId)) {
          enrollment['schemes'] = schemeMap[schemeId];
        }
      }

      return enrollments;
    } catch (e) {
      debugPrint('Error fetching enrollments: $e');
      return [];
    }
  }

  // User Transactions - get transactions linked to user's enrollments
  Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
    try {
      // First get the user's enrollments to find their enrollment IDs
      final enrollmentsResponse = await _supabase
          .from('enrollments')
          .select('id')
          .eq('user_id', userId);

      final enrollments = List<Map<String, dynamic>>.from(enrollmentsResponse);

      if (enrollments.isEmpty) {
        // Fallback: try direct user_id query on transactions
        try {
          final directResponse = await _supabase
              .from('transactions')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false)
              .limit(50);
          return List<Map<String, dynamic>>.from(directResponse);
        } catch (_) {
          return [];
        }
      }

      final enrollmentIds = enrollments.map((e) => e['id']).toList();

      // Fetch transactions for those enrollments
      final transactionsResponse = await _supabase
          .from('transactions')
          .select()
          .inFilter('enrollment_id', enrollmentIds)
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(transactionsResponse);
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      return [];
    }
  }

  // Portfolio Summary
  Future<Map<String, dynamic>> getPortfolioSummary(String userId) async {
    try {
      final enrollmentsResponse = await _supabase
          .from('enrollments')
          .select(
            'total_gold_grams, paid_amount, monthly_amount, paid_months, tenure_months, status',
          )
          .eq('user_id', userId);

      final enrollments = List<Map<String, dynamic>>.from(enrollmentsResponse);

      double totalGold = 0;
      double totalInvested = 0;
      double totalCurrentValue = 0;
      int activeCount = 0;

      // Get current gold price for value calculation
      double goldPrice = 0;
      try {
        final priceResponse = await _supabase
            .from('metal_prices')
            .select('gold_price')
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
        if (priceResponse != null) {
          goldPrice = (priceResponse['gold_price'] as num?)?.toDouble() ?? 0;
        }
      } catch (_) {}

      // Fallback gold price
      if (goldPrice <= 0) {
        goldPrice = 7850.0; // Approx INR per gram
      }

      for (var e in enrollments) {
        final grams = (e['total_gold_grams'] as num?)?.toDouble() ?? 0;
        final invested = (e['paid_amount'] as num?)?.toDouble() ?? 0;
        final status = e['status'] as String? ?? '';

        totalGold += grams;
        totalInvested += invested;
        totalCurrentValue += grams * goldPrice;

        if (status == 'active') {
          activeCount++;
        }
      }

      return {
        'totalGoldGrams': totalGold,
        'totalValue': totalInvested,
        'currentValue': totalCurrentValue,
        'goldPricePerGram': goldPrice,
        'activeEnrollments': activeCount,
        'totalEnrollments': enrollments.length,
      };
    } catch (e) {
      debugPrint('Error fetching portfolio summary: $e');
      return {
        'totalGoldGrams': 0.0,
        'totalValue': 0.0,
        'currentValue': 0.0,
        'goldPricePerGram': 0.0,
        'activeEnrollments': 0,
        'totalEnrollments': 0,
      };
    }
  }

  // Admin Stats
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      // Count customers (all profiles except admin/manager)
      final allProfiles = await _supabase.from('profiles').select('id, role');
      int customerCount = 0;
      for (final p in allProfiles) {
        final role = p['role'] as String? ?? 'customer';
        if (role == 'customer') customerCount++;
      }

      // Count active schemes
      final schemes = await _supabase
          .from('schemes')
          .select('id')
          .eq('is_active', true);

      // Today's collection
      final today = DateTime.now();
      final todayStart = DateTime(
        today.year,
        today.month,
        today.day,
      ).toIso8601String();
      final collections = await _supabase
          .from('transactions')
          .select('amount')
          .eq('type', 'credit')
          .gte('created_at', todayStart);

      double todayCollection = 0;
      for (var c in collections) {
        todayCollection += (c['amount'] as num?)?.toDouble() ?? 0;
      }

      // Total AUM (all paid amounts from enrollments)
      final enrollmentsData = await _supabase
          .from('enrollments')
          .select('paid_amount');
      double totalAUM = 0;
      for (var e in enrollmentsData) {
        totalAUM += (e['paid_amount'] as num?)?.toDouble() ?? 0;
      }

      // Today's transaction count
      final todayTxns = await _supabase
          .from('transactions')
          .select('id')
          .gte('created_at', todayStart);

      return {
        'totalCustomers': customerCount,
        'activeSchemes': schemes.length,
        'todayCollection': todayCollection,
        'totalAUM': totalAUM,
        'todayTxnCount': todayTxns.length,
      };
    } catch (e) {
      debugPrint('Error fetching admin stats: $e');
      return {
        'totalCustomers': 0,
        'activeSchemes': 0,
        'todayCollection': 0.0,
        'totalAUM': 0.0,
        'todayTxnCount': 0,
      };
    }
  }

  // Create Enrollment
  Future<void> createEnrollment({
    required String userId,
    required String schemeId,
    required double monthlyAmount,
    required int tenureMonths,
  }) async {
    await _supabase.from('enrollments').insert({
      'user_id': userId,
      'scheme_id': schemeId,
      'monthly_amount': monthlyAmount,
      'tenure_months': tenureMonths,
      'paid_months': 0,
      'total_gold_grams': 0,
      'paid_amount': 0,
      'status': 'active',
    });
  }

  // Admin: Create Scheme
  Future<void> createScheme({
    required String name,
    required String description,
    required String metalType,
    required double monthlyAmount,
    required double minAmount,
    required int tenureMonths,
    required String benefit,
    required bool isPopular,
  }) async {
    await _supabase.from('schemes').insert({
      'name': name,
      'description': description,
      'metal_type': metalType,
      'monthly_amount': monthlyAmount,
      'min_amount': minAmount,
      'tenure_months': tenureMonths,
      'benefit': benefit,
      'is_popular': isPopular,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Admin: Toggle Scheme Status
  Future<void> toggleSchemeStatus(String schemeId, bool isActive) async {
    await _supabase
        .from('schemes')
        .update({'is_active': isActive})
        .eq('id', schemeId);
  }

  // Admin: Get Enrollment Count for Scheme
  Future<int> getEnrollmentCountForScheme(String schemeId) async {
    try {
      final response = await _supabase
          .from('enrollments')
          .select('id')
          .eq('scheme_id', schemeId)
          .eq('status', 'active');
      return (response as List).length;
    } catch (_) {
      return 0;
    }
  }

  // Record Payment
  Future<void> recordPayment({
    required String enrollmentId,
    required String userId,
    required double amount,
  }) async {
    await _supabase.from('transactions').insert({
      'enrollment_id': enrollmentId,
      'user_id': userId,
      'type': 'credit',
      'amount': amount,
      'status': 'completed',
    });
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  // Notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .or('user_id.eq.$userId,is_global.eq.true')
          .order('created_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  // Admin: Create notification
  Future<void> createNotification({
    String? userId,
    required String title,
    required String message,
    String icon = 'notifications',
    String type = 'info',
    bool isGlobal = false,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'icon': icon,
        'type': type,
        'is_global': isGlobal,
      });
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }

  // Admin: Login
  Future<Map<String, dynamic>?> adminLogin(
    String email,
    String password,
  ) async {
    try {
      // Try to sign in with Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) return null;

      // Check if user has admin role
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (profile == null ||
          (profile['role'] != 'admin' && profile['role'] != 'manager')) {
        await _supabase.auth.signOut();
        return null;
      }

      return profile;
    } catch (e) {
      debugPrint('Admin login error: $e');
      return null;
    }
  }

  // Admin: Get all customers
  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    try {
      // Get all profiles, then filter out admins/managers in Dart
      // This avoids issues where role is null or not set
      final response = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      final allProfiles = List<Map<String, dynamic>>.from(response);

      // Filter out admin/manager roles, include customers and null roles
      return allProfiles.where((p) {
        final role = p['role'] as String?;
        return role == null || role == 'customer';
      }).toList();
    } catch (e) {
      debugPrint('Error fetching customers: $e');
      return [];
    }
  }

  // Admin: Get all transactions with user names
  Future<List<Map<String, dynamic>>> getAllTransactions({
    int limit = 100,
  }) async {
    try {
      // Fetch transactions
      final response = await _supabase
          .from('transactions')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      final txns = List<Map<String, dynamic>>.from(response);

      // Fetch all profiles to map user_id -> full_name
      final profiles = await _supabase
          .from('profiles')
          .select('id, full_name, username');

      final profileMap = <String, Map<String, dynamic>>{};
      for (final p in profiles) {
        final id = p['id']?.toString();
        if (id != null) profileMap[id] = p;
      }

      // Attach user name to each transaction
      for (final txn in txns) {
        final userId = txn['user_id']?.toString();
        if (userId != null && profileMap.containsKey(userId)) {
          txn['user_name'] = profileMap[userId]?['full_name'] ?? '';
          txn['user_username'] = profileMap[userId]?['username'] ?? '';
        }
      }

      return txns;
    } catch (e) {
      debugPrint('Error fetching all transactions: $e');
      return [];
    }
  }
}

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return DatabaseService(supabase);
});
