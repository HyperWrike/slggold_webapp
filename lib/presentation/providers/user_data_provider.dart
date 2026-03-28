import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/database_service.dart';

final userDataProvider = FutureProvider.family<Map<String, dynamic>?, String>((
  ref,
  userId,
) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getUserProfile(userId);
});

final userEnrollmentsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      userId,
    ) async {
      final db = ref.watch(databaseServiceProvider);
      return await db.getUserEnrollments(userId);
    });

final userTransactionsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      userId,
    ) async {
      final db = ref.watch(databaseServiceProvider);
      return await db.getUserTransactions(userId);
    });

final portfolioSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
      final db = ref.watch(databaseServiceProvider);
      return await db.getPortfolioSummary(userId);
    });

final availableSchemesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getAvailableSchemes();
});

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getAdminStats();
});

// Notifications
final userNotificationsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      userId,
    ) async {
      final db = ref.watch(databaseServiceProvider);
      return await db.getUserNotifications(userId);
    });

// Admin providers
final allCustomersProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getAllCustomers();
});

final allTransactionsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getAllTransactions();
});
