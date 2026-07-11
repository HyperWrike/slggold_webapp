import 'package:flutter/foundation.dart';

import '../../core/services/local_storage_service.dart';
import 'convex_api.dart';

class DatabaseService {
  DatabaseService(this._storage);

  final LocalStorageService _storage;

  Future<String?> _sessionToken() => _storage.getAuthToken();

  Future<List<Map<String, dynamic>>> getAvailableSchemes() async {
    try {
      final data = await convexQuery('schemes:listActive', {});
      return _asMapList(data);
    } catch (e) {
      debugPrint('Error fetching schemes: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserEnrollments(String userId) async {
    try {
      final token = await _sessionToken();
      if (token == null) return [];
      final data = await convexQuery('enrollments:listForUserWithSchemes', {
        'sessionToken': token,
      });
      return _asMapList(data);
    } catch (e) {
      debugPrint('Error fetching enrollments: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
    try {
      final token = await _sessionToken();
      if (token == null) return [];
      final data = await convexQuery('transactions:listForUser', {
        'sessionToken': token,
      });
      return _asMapList(data);
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getPortfolioSummary(String userId) async {
    try {
      final token = await _sessionToken();
      if (token == null) {
        return _emptyPortfolio();
      }
      final data = await convexQuery('portfolio:summary', {
        'sessionToken': token,
      });
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return _emptyPortfolio();
    } catch (e) {
      debugPrint('Error fetching portfolio summary: $e');
      return _emptyPortfolio();
    }
  }

  Map<String, dynamic> _emptyPortfolio() => {
    'totalGoldGrams': 0.0,
    'totalValue': 0.0,
    'currentValue': 0.0,
    'goldPricePerGram': 0.0,
    'activeEnrollments': 0,
    'totalEnrollments': 0,
  };

  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final token = await _sessionToken();
      if (token == null) {
        return _emptyAdminStats();
      }
      final data = await convexQuery('admin:stats', {'sessionToken': token});
      if (data is Map) return Map<String, dynamic>.from(data);
      return _emptyAdminStats();
    } catch (e) {
      debugPrint('Error fetching admin stats: $e');
      return _emptyAdminStats();
    }
  }

  Map<String, dynamic> _emptyAdminStats() => {
    'totalCustomers': 0,
    'activeSchemes': 0,
    'todayCollection': 0.0,
    'totalAUM': 0.0,
    'todayTxnCount': 0,
  };

  Future<String> createEnrollment({
    required String userId,
    required String schemeId,
    required double monthlyAmount,
    required int tenureMonths,
  }) async {
    final token = await _sessionToken();
    if (token == null) throw Exception('Not signed in');
    final result = await convexMutation('enrollments:create', {
      'sessionToken': token,
      'schemeId': schemeId,
      'monthlyAmount': monthlyAmount,
      'tenureMonths': tenureMonths,
    });
    if (result is Map && result['id'] != null) {
      return result['id'].toString();
    }
    throw Exception('Failed to create enrollment: no ID returned.');
  }

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
    final token = await _sessionToken();
    if (token == null) throw Exception('Not signed in');
    await convexMutation('schemes:create', {
      'sessionToken': token,
      'name': name,
      'description': description,
      'metal_type': metalType,
      'monthly_amount': monthlyAmount,
      'min_amount': minAmount,
      'tenure_months': tenureMonths,
      'benefit': benefit,
      'is_popular': isPopular,
    });
  }

  Future<void> toggleSchemeStatus(String schemeId, bool isActive) async {
    final token = await _sessionToken();
    if (token == null) throw Exception('Not signed in');
    await convexMutation('schemes:toggleStatus', {
      'sessionToken': token,
      'schemeId': schemeId,
      'isActive': isActive,
    });
  }

  Future<void> removeScheme(String schemeId) async {
    final token = await _sessionToken();
    if (token == null) throw Exception('Not signed in');
    await convexMutation('schemes:remove', {
      'sessionToken': token,
      'schemeId': schemeId,
    });
  }

  Future<int> getEnrollmentCountForScheme(String schemeId) async {
    try {
      final token = await _sessionToken();
      if (token == null) return 0;
      final data = await convexQuery('enrollments:countActiveForScheme', {
        'sessionToken': token,
        'schemeId': schemeId,
      });
      if (data is int) return data;
      if (data is num) return data.toInt();
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> recordPayment({
    required String enrollmentId,
    required String userId,
    required double amount,
  }) async {
    final token = await _sessionToken();
    if (token == null) throw Exception('Not signed in');
    await convexMutation('transactions:recordPayment', {
      'sessionToken': token,
      'enrollmentId': enrollmentId,
      'amount': amount,
    });
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final token = await _sessionToken();
      if (token == null) return null;
      final data = await convexQuery('auth:getCurrentUser', {
        'sessionToken': token,
      });
      if (data == null) return null;
      return Map<String, dynamic>.from(data as Map);
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final token = await _sessionToken();
      if (token == null) return [];
      final data = await convexQuery('notifications:listForUser', {
        'sessionToken': token,
      });
      return _asMapList(data);
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final token = await _sessionToken();
      if (token == null) return;
      await convexMutation('notifications:markRead', {
        'sessionToken': token,
        'notificationId': notificationId,
      });
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final token = await _sessionToken();
      if (token == null) return;
      await convexMutation('notifications:markAllRead', {
        'sessionToken': token,
      });
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> createNotification({
    String? userId,
    required String title,
    required String message,
    String icon = 'notifications',
    String type = 'info',
    bool isGlobal = false,
  }) async {
    try {
      final token = await _sessionToken();
      if (token == null) return;
      await convexMutation('notifications:create', {
        'sessionToken': token,
        'userId': userId,
        'title': title,
        'message': message,
        'icon': icon,
        'notifType': type,
        'isGlobal': isGlobal,
      });
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }

  /// Admin login: uses same credential flow; ensures role is admin or manager.
  Future<Map<String, dynamic>?> adminLogin(
    String email,
    String password,
  ) async {
    try {
      final res = await convexAction('authActions:login', {
        'email': email,
        'password': password,
      });
      if (res is! Map) return null;
      final resultMap = Map<String, dynamic>.from(res as Map);
      final profileData = resultMap['profile'];
      if (profileData is! Map) return null;
      final profile = Map<String, dynamic>.from(profileData as Map);
      final role = profile['role'] as String? ?? '';
      if (role != 'admin' && role != 'manager') {
        final token = resultMap['token'];
        if (token is String) {
          await convexMutation('auth:logout', {'sessionToken': token});
        }
        return null;
      }
      final token = resultMap['token'];
      if (token is String) {
        await _storage.saveAuthToken(token);
      }
      return profile;
    } catch (e) {
      debugPrint('Admin login error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    try {
      final token = await _sessionToken();
      if (token == null) return [];
      final data = await convexQuery('admin:listCustomers', {
        'sessionToken': token,
      });
      return _asMapList(data);
    } catch (e) {
      debugPrint('Error fetching customers: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTransactions({
    int limit = 100,
  }) async {
    try {
      final token = await _sessionToken();
      if (token == null) return [];
      final data = await convexQuery('transactions:listAllForAdmin', {
        'sessionToken': token,
        'limit': limit,
      });
      return _asMapList(data);
    } catch (e) {
      debugPrint('Error fetching all transactions: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllEnrollmentsForReports() async {
    final token = await _sessionToken();
    if (token == null) return [];
    final data = await convexQuery('enrollments:listAllForReports', {
      'sessionToken': token,
    });
    return _asMapList(data);
  }

  Future<int> getActiveEnrollmentCountForUserId(String userId) async {
    try {
      final token = await _sessionToken();
      if (token == null) return 0;
      final data = await convexQuery('enrollments:countActiveForUser', {
        'sessionToken': token,
        'userId': userId,
      });
      if (data is int) return data;
      if (data is num) return data.toInt();
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getEnrollmentsForCustomer(
    String customerUserId,
  ) async {
    final token = await _sessionToken();
    if (token == null) return [];
    final data = await convexQuery('enrollments:listForCustomerUserId', {
      'sessionToken': token,
      'customerUserId': customerUserId,
    });
    return _asMapList(data);
  }

  Future<void> updatePinHash(String pinHash) async {
    final token = await _sessionToken();
    if (token == null) throw Exception('Not signed in');
    await convexMutation('auth:updatePin', {
      'sessionToken': token,
      'pin_hash': pinHash,
    });
  }

  Future<void> updatePhoneNumber(String phone) async {
    final token = await _sessionToken();
    if (token == null) throw Exception('Not signed in');
    await convexMutation('auth:updatePhone', {
      'sessionToken': token,
      'phone': phone,
    });
  }

  Future<void> changeAccountPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _sessionToken();
    if (token == null) throw Exception('Not signed in');
    await convexAction('authActions:changePassword', {
      'sessionToken': token,
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<void> registerAdminAccount({
    required String email,
    required String password,
  }) async {
    await convexAction('authActions:registerAdmin', {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>?> getLatestGstRates() async {
    final token = await _sessionToken();
    if (token == null) return null;
    try {
      final data = await convexQuery('gst:latest', {'sessionToken': token});
      if (data == null) return null;
      return Map<String, dynamic>.from(data as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveGstRates({
    required double goldGst,
    required double silverGst,
    required double makingChargesGst,
  }) async {
    final token = await _sessionToken();
    if (token == null) throw Exception('Not signed in');
    await convexMutation('gst:save', {
      'sessionToken': token,
      'gold_gst': goldGst,
      'silver_gst': silverGst,
      'making_charges_gst': makingChargesGst,
    });
  }

  Future<Map<String, dynamic>> createRazorpayOrder({
    required String enrollmentId,
    required double amount,
  }) async {
    final token = await _sessionToken();
    if (token == null) throw Exception('Not signed in');
    final data = await convexAction('payments:createOrder', {
      'sessionToken': token,
      'enrollmentId': enrollmentId,
      'amount': amount,
    });
    return Map<String, dynamic>.from(data as Map);
  }

  Future<bool> verifyRazorpayPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final token = await _sessionToken();
      if (token == null) throw Exception('Not signed in');
      final data = await convexAction('payments:verifyPayment', {
        'sessionToken': token,
        'razorpayOrderId': orderId,
        'razorpayPaymentId': paymentId,
        'razorpaySignature': signature,
      });
      if (data is Map && data['ok'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error verifying Razorpay payment: $e');
      return false;
    }
  }
}

List<Map<String, dynamic>> _asMapList(dynamic data) {
  if (data is! List) return [];
  return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}
