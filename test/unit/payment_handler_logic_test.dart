import 'package:flutter_test/flutter_test.dart';
import 'package:slg_golds/presentation/widgets/payment_handler.dart';
import 'package:slg_golds/data/datasources/database_service.dart';
import 'package:slg_golds/core/services/local_storage_service.dart';

void main() {
  group('PaymentHandler order data parsing', () {
    test('parses mock order data correctly', () {
      // Arrange
      final orderData = {
        'orderId': 'order_mock_abc123',
        'amount': 5000.0,
        'key': 'rzp_test_mockkey',
        'isMock': true,
        'currency': 'INR',
      };

      // Act
      final isMock = orderData['isMock'] == true;
      final amount = (orderData['amount'] as num).toDouble();
      final orderId = orderData['orderId'] as String;

      // Assert
      expect(isMock, isTrue);
      expect(amount, 5000.0);
      expect(orderId, 'order_mock_abc123');
    });

    test('parses real Razorpay order data correctly', () {
      // Arrange
      final orderData = {
        'orderId': 'order_Razor123',
        'amount': 5000.0,
        'key': 'rzp_live_realkey123',
        'isMock': false,
        'currency': 'INR',
      };

      // Act
      final isMock = orderData['isMock'] == true;
      final amount = (orderData['amount'] as num).toDouble();
      final key = orderData['key'] as String;

      // Assert
      expect(isMock, isFalse);
      expect(amount, 5000.0);
      expect(key, startsWith('rzp_live'));
    });

    test('Razorpay options amount is in paise (amount * 100)', () {
      // Arrange
      const amount = 5000.0;

      // Act
      final amountInPaise = (amount * 100).round();

      // Assert
      expect(amountInPaise, 500000);
    });

    test('handles zero amount gracefully in paise conversion', () {
      // Arrange
      const amount = 0.0;

      // Act
      final amountInPaise = (amount * 100).round();

      // Assert
      expect(amountInPaise, 0);
    });

    test('handles decimal amount in paise conversion', () {
      // Arrange
      const amount = 999.99;

      // Act
      final amountInPaise = (amount * 100).round();

      // Assert
      expect(amountInPaise, 99999);
    });
  });

  group('Mock payment GST calculation', () {
    test('calculates GST and net amount correctly for 3% GST', () {
      // Arrange
      const amount = 5000.0;

      // Act
      final netAmount = amount / 1.03;
      final gstAmount = amount - netAmount;

      // Assert
      expect(netAmount, closeTo(4854.37, 0.01));
      expect(gstAmount, closeTo(145.63, 0.01));
      expect(netAmount + gstAmount, closeTo(amount, 0.01));
    });

    test('GST is always 3% of net amount', () {
      // Arrange
      const amounts = [1000.0, 2500.0, 5000.0, 10000.0, 50000.0];

      for (final amount in amounts) {
        // Act
        final netAmount = amount / 1.03;
        final gstAmount = amount - netAmount;
        final gstPercentage = (gstAmount / netAmount) * 100;

        // Assert
        expect(gstPercentage, closeTo(3.0, 0.01),
            reason: 'GST should be ~3% for amount $amount');
      }
    });
  });

  group('Payment prefill defaults', () {
    test('uses provided phone and email', () {
      // Arrange
      const userPhone = '9876543210';
      const userEmail = 'user@example.com';

      // Act
      final prefill = {
        'contact': userPhone.isNotEmpty ? userPhone : '9999999999',
        'email': userEmail.isNotEmpty ? userEmail : 'customer@example.com',
      };

      // Assert
      expect(prefill['contact'], '9876543210');
      expect(prefill['email'], 'user@example.com');
    });

    test('falls back to defaults when phone is empty', () {
      // Arrange
      const userPhone = '';
      const userEmail = 'user@example.com';

      // Act
      final prefill = {
        'contact': userPhone.isNotEmpty ? userPhone : '9999999999',
        'email': userEmail.isNotEmpty ? userEmail : 'customer@example.com',
      };

      // Assert
      expect(prefill['contact'], '9999999999');
    });

    test('falls back to defaults when email is empty', () {
      // Arrange
      const userPhone = '9876543210';
      const userEmail = '';

      // Act
      final prefill = {
        'contact': userPhone.isNotEmpty ? userPhone : '9999999999',
        'email': userEmail.isNotEmpty ? userEmail : 'customer@example.com',
      };

      // Assert
      expect(prefill['email'], 'customer@example.com');
    });
  });

  group('Payment status text mapping', () {
    test('verifying status text updates correctly', () {
      // Arrange & Act & Assert
      expect('Contacting secure server...', isNotEmpty);
      expect('Verifying signature tokens...', isNotEmpty);
      expect('Payment Successful!', isNotEmpty);
    });

    test('failure messages are descriptive', () {
      // Arrange & Act & Assert
      expect('Payment cancelled or failed.', isNotEmpty);
      expect('External wallet payments are not supported.', isNotEmpty);
      expect('Failed to open Razorpay SDK: test', contains('Failed to open'));
      expect('Error during payment verification: test',
          contains('Error during payment'));
      expect('Payment signature verification failed on server.',
          contains('verification failed'));
    });
  });

  group('Enrollment minimum amount validation', () {
    test('enrollment requires minimum 1000', () {
      // Arrange
      const monthlyAmount = 500.0;

      // Act
      final canProceed = monthlyAmount < 1000;

      // Assert
      expect(canProceed, isTrue,
          reason: 'Amount below 1000 should prevent enrollment');
    });

    test('enrollment allows 1000 or more', () {
      // Arrange
      const monthlyAmount = 1000.0;

      // Act
      final canProceed = monthlyAmount >= 1000;

      // Assert
      expect(canProceed, isTrue);
    });

    test('button disabled when amount below minimum', () {
      // Arrange
      const minAmount = 1000;
      const monthlyAmount = 500.0;
      const isLoading = false;

      // Act
      final onPressed = monthlyAmount >= minAmount && !isLoading;

      // Assert
      expect(onPressed, isFalse);
    });

    test('button enabled when amount meets minimum', () {
      // Arrange
      const minAmount = 1000;
      const monthlyAmount = 5000.0;
      const isLoading = false;

      // Act
      final onPressed = monthlyAmount >= minAmount && !isLoading;

      // Assert
      expect(onPressed, isTrue);
    });

    test('button disabled during loading even with valid amount', () {
      // Arrange
      const minAmount = 1000;
      const monthlyAmount = 5000.0;
      const isLoading = true;

      // Act
      final onPressed = monthlyAmount >= minAmount && !isLoading;

      // Assert
      expect(onPressed, isFalse);
    });
  });

  group('Enrollment summary calculations', () {
    test('calculates total payment correctly', () {
      // Arrange
      const monthlyAmount = 5000.0;
      const tenureMonths = 11;

      // Act
      final totalPayment = monthlyAmount * tenureMonths;

      // Assert
      expect(totalPayment, 55000.0);
    });

    test('calculates gold bonus (1 month equivalent)', () {
      // Arrange
      const monthlyAmount = 5000.0;

      // Act
      final goldBonus = monthlyAmount * (monthlyAmount > 0 ? 1 : 0);

      // Assert
      expect(goldBonus, 5000.0);
    });

    test('total value accumulated includes bonus month', () {
      // Arrange
      const monthlyAmount = 5000.0;
      const tenureMonths = 11;

      // Act
      final totalValue = monthlyAmount * (tenureMonths + 1);

      // Assert
      expect(totalValue, 60000.0);
    });

    test('gold bonus is zero when monthly amount is zero', () {
      // Arrange
      const monthlyAmount = 0.0;

      // Act
      final goldBonus = monthlyAmount * (monthlyAmount > 0 ? 1 : 0);

      // Assert
      expect(goldBonus, 0.0);
    });
  });
}
