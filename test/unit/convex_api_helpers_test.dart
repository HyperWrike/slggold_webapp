import 'package:flutter_test/flutter_test.dart';
import 'package:slg_golds/data/datasources/convex_api.dart';

void main() {
  group('convexArgs', () {
    test('removes null values from argument map', () {
      // Arrange
      final args = <String, dynamic>{
        'name': 'test',
        'email': 'user@test.com',
        'emptyField': null,
        'zeroValue': 0,
        'falseValue': false,
        'emptyString': '',
      };

      // Act
      final result = convexArgs(args);

      // Assert
      expect(result.containsKey('name'), isTrue);
      expect(result.containsKey('email'), isTrue);
      expect(result.containsKey('emptyField'), isFalse,
          reason: 'null values should be removed');
      expect(result.containsKey('zeroValue'), isTrue,
          reason: 'zero is not null, should be kept');
      expect(result.containsKey('falseValue'), isTrue,
          reason: 'false is not null, should be kept');
      expect(result.containsKey('emptyString'), isTrue,
          reason: 'empty string is not null, should be kept');
    });

    test('returns empty map when all values are null', () {
      // Arrange
      final args = <String, dynamic>{
        'a': null,
        'b': null,
      };

      // Act
      final result = convexArgs(args);

      // Assert
      expect(result, isEmpty);
    });

    test('preserves original map without modifying it', () {
      // Arrange
      final original = <String, dynamic>{
        'keep': 'value',
        'remove': null,
      };

      // Act
      final result = convexArgs(original);

      // Assert
      expect(original.length, 2,
          reason: 'original map should not be modified');
      expect(result.length, 1);
    });

    test('handles empty map', () {
      // Arrange
      final args = <String, dynamic>{};

      // Act
      final result = convexArgs(args);

      // Assert
      expect(result, isEmpty);
    });
  });
}
