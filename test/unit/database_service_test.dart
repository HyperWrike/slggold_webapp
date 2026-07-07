import 'package:flutter_test/flutter_test.dart';
import 'package:slg_golds/data/datasources/database_service.dart';
import 'package:slg_golds/core/services/local_storage_service.dart';
import 'package:slg_golds/core/convex_launch_state.dart';

void main() {
  setUp(() {
    ConvexLaunchState.isReady = false;
  });

  group('DatabaseService', () {
    group('createEnrollment', () {
      test('throws when not signed in (no session token)', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act & Assert
        expect(
          () => db.createEnrollment(
            userId: 'user_1',
            schemeId: 'scheme_1',
            monthlyAmount: 5000,
            tenureMonths: 11,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Not signed in'),
          )),
        );
      });
    });

    group('createRazorpayOrder', () {
      test('throws when not signed in', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act & Assert
        expect(
          () => db.createRazorpayOrder(
            enrollmentId: 'enr_1',
            amount: 5000,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Not signed in'),
          )),
        );
      });
    });

    group('recordPayment', () {
      test('throws when not signed in', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act & Assert
        expect(
          () => db.recordPayment(
            enrollmentId: 'enr_1',
            userId: 'user_1',
            amount: 5000,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Not signed in'),
          )),
        );
      });
    });

    group('getAvailableSchemes', () {
      test('returns empty list when Convex not ready', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: 'token_123');
        final db = DatabaseService(storage);

        // Act
        final result = await db.getAvailableSchemes();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getUserEnrollments', () {
      test('returns empty list when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act
        final result = await db.getUserEnrollments('user_1');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getUserTransactions', () {
      test('returns empty list when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act
        final result = await db.getUserTransactions('user_1');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getPortfolioSummary', () {
      test('returns empty portfolio when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act
        final result = await db.getPortfolioSummary('user_1');

        // Assert
        expect(result['totalGoldGrams'], 0.0);
        expect(result['totalValue'], 0.0);
        expect(result['activeEnrollments'], 0);
      });
    });

    group('getAdminStats', () {
      test('returns empty stats when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act
        final result = await db.getAdminStats();

        // Assert
        expect(result['totalCustomers'], 0);
        expect(result['activeSchemes'], 0);
        expect(result['todayCollection'], 0.0);
      });
    });

    group('getEnrollmentCountForScheme', () {
      test('returns 0 when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act
        final result = await db.getEnrollmentCountForScheme('scheme_1');

        // Assert
        expect(result, 0);
      });
    });

    group('createScheme', () {
      test('throws when not signed in', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act & Assert
        expect(
          () => db.createScheme(
            name: 'Test Scheme',
            description: 'Test',
            metalType: 'gold',
            monthlyAmount: 5000,
            minAmount: 1000,
            tenureMonths: 11,
            benefit: 'Test benefit',
            isPopular: true,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Not signed in'),
          )),
        );
      });
    });

    group('toggleSchemeStatus', () {
      test('throws when not signed in', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act & Assert
        expect(
          () => db.toggleSchemeStatus('scheme_1', true),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Not signed in'),
          )),
        );
      });
    });

    group('removeScheme', () {
      test('throws when not signed in', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act & Assert
        expect(
          () => db.removeScheme('scheme_1'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Not signed in'),
          )),
        );
      });
    });

    group('updatePinHash', () {
      test('throws when not signed in', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act & Assert
        expect(
          () => db.updatePinHash('hash123'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Not signed in'),
          )),
        );
      });
    });

    group('updatePhoneNumber', () {
      test('throws when not signed in', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act & Assert
        expect(
          () => db.updatePhoneNumber('9999999999'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Not signed in'),
          )),
        );
      });
    });

    group('changeAccountPassword', () {
      test('throws when not signed in', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act & Assert
        expect(
          () => db.changeAccountPassword(
            currentPassword: 'old',
            newPassword: 'new',
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Not signed in'),
          )),
        );
      });
    });

    group('saveGstRates', () {
      test('throws when not signed in', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act & Assert
        expect(
          () => db.saveGstRates(
            goldGst: 3.0,
            silverGst: 3.0,
            makingChargesGst: 18.0,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Not signed in'),
          )),
        );
      });
    });

    group('markNotificationAsRead', () {
      test('silently returns when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act & Assert - should not throw
        await db.markNotificationAsRead('notif_1');
      });
    });

    group('markAllNotificationsAsRead', () {
      test('silently returns when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act & Assert - should not throw
        await db.markAllNotificationsAsRead('user_1');
      });
    });

    group('createNotification', () {
      test('silently returns when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act & Assert - should not throw
        await db.createNotification(
          title: 'Test',
          message: 'Test message',
        );
      });
    });

    group('getUserProfile', () {
      test('returns null when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act
        final result = await db.getUserProfile('user_1');

        // Assert
        expect(result, isNull);
      });
    });

    group('getUserNotifications', () {
      test('returns empty list when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act
        final result = await db.getUserNotifications('user_1');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getLatestGstRates', () {
      test('returns null when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act
        final result = await db.getLatestGstRates();

        // Assert
        expect(result, isNull);
      });
    });

    group('getAllCustomers', () {
      test('returns empty list when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act
        final result = await db.getAllCustomers();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getAllTransactions', () {
      test('returns empty list when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act
        final result = await db.getAllTransactions();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getAllEnrollmentsForReports', () {
      test('returns empty list when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act
        final result = await db.getAllEnrollmentsForReports();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getActiveEnrollmentCountForUserId', () {
      test('returns 0 when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act
        final result = await db.getActiveEnrollmentCountForUserId('user_1');

        // Assert
        expect(result, 0);
      });
    });

    group('getEnrollmentsForCustomer', () {
      test('returns empty list when no session token', () async {
        // Arrange
        final storage = _MockLocalStorageService(token: null);
        final db = DatabaseService(storage);

        // Act
        final result = await db.getEnrollmentsForCustomer('user_1');

        // Assert
        expect(result, isEmpty);
      });
    });
  });
}

class _MockLocalStorageService extends LocalStorageService {
  final String? token;

  _MockLocalStorageService({this.token});

  @override
  Future<String?> getAuthToken() async => token;
}
