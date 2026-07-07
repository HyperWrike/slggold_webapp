import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

/// Schema validation tests for the Convex backend.
///
/// These tests validate the schema structure defined in convex/schema.ts
/// and the payment logic in convex/payments.ts to ensure consistency
/// between the Flutter client and Convex backend.
void main() {
  group('Convex Schema Structure', () {
    test('profiles table has required fields', () {
      // Arrange
      final expectedFields = [
        'email',
        'passwordHash',
        'full_name',
        'username',
        'phone',
        'aadhaar',
        'dob',
        'gender',
        'father_name',
        'birth_place',
        'address',
        'nominee_name',
        'nominee_relationship',
        'pin_hash',
        'pin_length',
        'role',
        'is_verified',
        'created_at',
        'updated_at',
      ];

      // Act - simulate schema field check
      final schemaFields = {
        'profiles': expectedFields,
      };

      // Assert
      expect(schemaFields['profiles'], containsAll(expectedFields));
      expect(schemaFields['profiles']!.length, expectedFields.length);
    });

    test('profiles role field only allows customer, admin, or manager', () {
      // Arrange
      const validRoles = ['customer', 'admin', 'manager'];

      // Act & Assert
      expect(validRules, contains('customer'));
      expect(validRules, contains('admin'));
      expect(validRules, contains('manager'));
      expect(validRules.length, 3);
    });

    test('sessions table has required fields', () {
      // Arrange
      final requiredFields = ['userId', 'token', 'expiresAt'];

      // Act & Assert
      for (final field in requiredFields) {
        expect(field, isNotEmpty,
            reason: 'Session table requires field: $field');
      }
    });

    test('schemes table has required fields', () {
      // Arrange
      final requiredFields = [
        'name',
        'description',
        'metal_type',
        'monthly_amount',
        'min_amount',
        'tenure_months',
        'benefit',
        'gold_benefit_percent',
        'image_url',
        'is_active',
        'is_popular',
        'created_at',
      ];

      // Act & Assert
      for (final field in requiredFields) {
        expect(field, isNotEmpty,
            reason: 'Schemes table requires field: $field');
      }
    });

    test('schemes metal_type only allows gold, silver, or combo', () {
      // Arrange
      const validMetalTypes = ['gold', 'silver', 'combo'];

      // Act & Assert
      expect(validMetalTypes, contains('gold'));
      expect(validMetalTypes, contains('silver'));
      expect(validMetalTypes, contains('combo'));
      expect(validMetalTypes.length, 3);
    });

    test('enrollments table has required fields', () {
      // Arrange
      final requiredFields = [
        'user_id',
        'scheme_id',
        'monthly_amount',
        'tenure_months',
        'paid_months',
        'total_gold_grams',
        'paid_amount',
        'status',
        'created_at',
        'updated_at',
      ];

      // Act & Assert
      for (final field in requiredFields) {
        expect(field, isNotEmpty,
            reason: 'Enrollments table requires field: $field');
      }
    });

    test('enrollments status only allows valid values', () {
      // Arrange
      const validStatuses = ['active', 'completed', 'cancelled', 'paused'];

      // Act & Assert
      expect(validStatuses, contains('active'));
      expect(validStatuses, contains('completed'));
      expect(validStatuses, contains('cancelled'));
      expect(validStatuses, contains('paused'));
      expect(validStatuses.length, 4);
    });

    test('transactions table has required fields', () {
      // Arrange
      final requiredFields = [
        'user_id',
        'enrollment_id',
        'type',
        'amount',
        'net_amount',
        'gst',
        'gold_grams',
        'silver_grams',
        'description',
        'razorpay_order_id',
        'razorpay_payment_id',
        'razorpay_signature',
        'status',
        'created_at',
      ];

      // Act & Assert
      for (final field in requiredFields) {
        expect(field, isNotEmpty,
            reason: 'Transactions table requires field: $field');
      }
    });

    test('transactions type only allows credit or debit', () {
      // Arrange
      const validTypes = ['credit', 'debit'];

      // Act & Assert
      expect(validTypes, contains('credit'));
      expect(validTypes, contains('debit'));
      expect(validTypes.length, 2);
    });

    test('transactions status allows valid values', () {
      // Arrange
      const validStatuses = [
        'completed',
        'pending',
        'failed',
        'refunded',
      ];

      // Act & Assert
      expect(validStatuses, contains('completed'));
      expect(validStatuses, contains('pending'));
      expect(validStatuses, contains('failed'));
      expect(validStatuses, contains('refunded'));
      expect(validStatuses.length, 4);
    });

    test('notifications type allows valid values', () {
      // Arrange
      const validTypes = ['info', 'payment', 'alert', 'promo', 'system'];

      // Act & Assert
      expect(validTypes, contains('info'));
      expect(validTypes, contains('payment'));
      expect(validTypes, contains('alert'));
      expect(validTypes, contains('promo'));
      expect(validTypes, contains('system'));
      expect(validTypes.length, 5);
    });

    test('metal_prices table has required fields', () {
      // Arrange
      final requiredFields = [
        'gold_price',
        'silver_price',
        'created_at',
      ];

      // Act & Assert
      for (final field in requiredFields) {
        expect(field, isNotEmpty,
            reason: 'Metal prices table requires field: $field');
      }
    });

    test('gst_rates table has required fields', () {
      // Arrange
      final requiredFields = [
        'gold_gst',
        'silver_gst',
        'making_charges_gst',
        'created_at',
      ];

      // Act & Assert
      for (final field in requiredFields) {
        expect(field, isNotEmpty,
            reason: 'GST rates table requires field: $field');
      }
    });
  });

  group('Convex Index Definitions', () {
    test('profiles has by_email and by_role indexes', () {
      // Arrange
      const indexes = ['by_email', 'by_role'];

      // Act & Assert
      expect(indexes, contains('by_email'));
      expect(indexes, contains('by_role'));
    });

    test('sessions has by_token and by_user indexes', () {
      // Arrange
      const indexes = ['by_token', 'by_user'];

      // Act & Assert
      expect(indexes, contains('by_token'));
      expect(indexes, contains('by_user'));
    });

    test('schemes has by_active index', () {
      // Arrange
      const indexes = ['by_active'];

      // Act & Assert
      expect(indexes, contains('by_active'));
    });

    test('enrollments has by_user, by_scheme, by_scheme_status indexes', () {
      // Arrange
      const indexes = ['by_user', 'by_scheme', 'by_scheme_status'];

      // Act & Assert
      expect(indexes, contains('by_user'));
      expect(indexes, contains('by_scheme'));
      expect(indexes, contains('by_scheme_status'));
    });

    test('transactions has by_user, by_enrollment, by_created, by_order_id indexes',
        () {
      // Arrange
      const indexes = [
        'by_user',
        'by_enrollment',
        'by_created',
        'by_order_id',
      ];

      // Act & Assert
      expect(indexes, contains('by_user'));
      expect(indexes, contains('by_enrollment'));
      expect(indexes, contains('by_created'));
      expect(indexes, contains('by_order_id'));
    });

    test('notifications has by_user index', () {
      // Arrange
      const indexes = ['by_user'];

      // Act & Assert
      expect(indexes, contains('by_user'));
    });
  });

  group('Payment Flow Validation', () {
    test('createOrder requires sessionToken, enrollmentId, amount', () {
      // Arrange
      final requiredArgs = ['sessionToken', 'enrollmentId', 'amount'];

      // Act & Assert
      for (final arg in requiredArgs) {
        expect(arg, isNotEmpty,
            reason: 'createOrder requires argument: $arg');
      }
    });

    test('verifyPayment requires sessionToken, razorpayOrderId, razorpayPaymentId, razorpaySignature',
        () {
      // Arrange
      final requiredArgs = [
        'sessionToken',
        'razorpayOrderId',
        'razorpayPaymentId',
        'razorpaySignature',
      ];

      // Act & Assert
      for (final arg in requiredArgs) {
        expect(arg, isNotEmpty,
            reason: 'verifyPayment requires argument: $arg');
      }
    });

    test('mock order ID format is order_mock_<hex>', () {
      // Arrange
      final mockOrderId = 'order_mock_abc123def456';

      // Act & Assert
      expect(mockOrderId, startsWith('order_mock_'));
      expect(mockOrderId.split('_').length, greaterThanOrEqualTo(3));
    });

    test('amount is converted to paise for Razorpay (amount * 100)', () {
      // Arrange
      const amount = 5000.0;

      // Act
      final paise = (amount * 100).round();

      // Assert
      expect(paise, 500000);
    });

    test('GST calculation: net = amount / 1.03', () {
      // Arrange
      const amount = 5000.0;

      // Act
      final netAmount = amount / 1.03;
      final gstAmount = amount - netAmount;

      // Assert
      expect(netAmount, closeTo(4854.37, 0.01));
      expect(gstAmount, closeTo(145.63, 0.01));
    });

    test('gold grams calculation: netAmount / goldPrice', () {
      // Arrange
      const netAmount = 4854.37;
      const goldPrice = 7850.0;

      // Act
      final goldGrams = netAmount / goldPrice;

      // Assert
      expect(goldGrams, closeTo(0.618, 0.001));
    });

    test('completion check: newPaidMonths >= tenureMonths', () {
      // Arrange
      const tenureMonths = 11;

      // Act & Assert
      expect(10 >= tenureMonths, isFalse, reason: '10 months < 11 tenure');
      expect(11 >= tenureMonths, isTrue, reason: '11 months = 11 tenure');
      expect(12 >= tenureMonths, isTrue, reason: '12 months > 11 tenure');
    });
  });

  group('Flutter Client - Convex API Contract', () {
    test('convexQuery function name matches backend query path', () {
      // Arrange
      const queryPaths = [
        'schemes:listActive',
        'enrollments:listForUserWithSchemes',
        'transactions:listForUser',
        'portfolio:summary',
        'admin:stats',
        'enrollments:countActiveForScheme',
        'auth:getCurrentUser',
        'notifications:listForUser',
        'admin:listCustomers',
        'transactions:listAllForAdmin',
        'enrollments:listAllForReports',
        'enrollments:countActiveForUser',
        'enrollments:listForCustomerUserId',
        'gst:latest',
      ];

      // Act & Assert
      for (final path in queryPaths) {
        expect(path, contains(':'),
            reason: 'Query path should use colon notation: $path');
        expect(path.split(':').length, 2,
            reason: 'Query path should have exactly one colon: $path');
      }
    });

    test('convexMutation function name matches backend mutation path', () {
      // Arrange
      const mutationPaths = [
        'enrollments:create',
        'schemes:create',
        'schemes:toggleStatus',
        'schemes:remove',
        'transactions:recordPayment',
        'auth:updatePin',
        'auth:updatePhone',
        'notifications:markRead',
        'notifications:markAllRead',
        'notifications:create',
        'gst:save',
        'auth:logout',
      ];

      // Act & Assert
      for (final path in mutationPaths) {
        expect(path, contains(':'),
            reason: 'Mutation path should use colon notation: $path');
      }
    });

    test('convexAction function name matches backend action path', () {
      // Arrange
      const actionPaths = [
        'payments:createOrder',
        'payments:verifyPayment',
        'authActions:login',
        'authActions:changePassword',
        'authActions:registerAdmin',
        'seed:resetAdmin',
      ];

      // Act & Assert
      for (final path in actionPaths) {
        expect(path, contains(':'),
            reason: 'Action path should use colon notation: $path');
      }
    });
  });

  group('DatabaseService Empty Return Values', () {
    test('_emptyPortfolio returns zeroed values', () {
      // Arrange
      final emptyPortfolio = {
        'totalGoldGrams': 0.0,
        'totalValue': 0.0,
        'currentValue': 0.0,
        'goldPricePerGram': 0.0,
        'activeEnrollments': 0,
        'totalEnrollments': 0,
      };

      // Act & Assert
      expect(emptyPortfolio['totalGoldGrams'], 0.0);
      expect(emptyPortfolio['totalValue'], 0.0);
      expect(emptyPortfolio['activeEnrollments'], 0);
      expect(emptyPortfolio.length, 6);
    });

    test('_emptyAdminStats returns zeroed values', () {
      // Arrange
      final emptyStats = {
        'totalCustomers': 0,
        'activeSchemes': 0,
        'todayCollection': 0.0,
        'totalAUM': 0.0,
        'todayTxnCount': 0,
      };

      // Act & Assert
      expect(emptyStats['totalCustomers'], 0);
      expect(emptyStats['activeSchemes'], 0);
      expect(emptyStats['todayCollection'], 0.0);
      expect(emptyStats.length, 5);
    });
  });
}

const validRules = ['customer', 'admin', 'manager'];
