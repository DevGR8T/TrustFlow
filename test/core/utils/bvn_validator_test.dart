import 'package:flutter_test/flutter_test.dart';
import 'package:trust_flow/core/utils/bvn_validator.dart';

void main() {
  group('NigerianBvnValidator', () {
    test('returns error when BVN is null', () {
      expect(NigerianBvnValidator.validate(null), 'BVN is required');
    });

    test('returns error when BVN is empty', () {
      expect(NigerianBvnValidator.validate(''), 'BVN is required');
    });

    test('returns error when BVN is less than 11 digits', () {
      expect(NigerianBvnValidator.validate('1234567890'), 'BVN must be exactly 11 digits');
    });

    test('returns error when BVN is more than 11 digits', () {
      expect(NigerianBvnValidator.validate('123456789012'), 'BVN must be exactly 11 digits');
    });

    test('returns error when BVN contains non-digits', () {
      expect(NigerianBvnValidator.validate('1234567890A'), 'BVN must contain only digits');
    });

    test('returns null for valid BVN passing checksum', () {
      // Generate a valid BVN that passes Luhn checksum
      // 12345678903 passes the modified Luhn check
      final result = NigerianBvnValidator.validate('12345678903');
      expect(result, isNull);
    });

    test('returns error for BVN failing checksum', () {
      expect(NigerianBvnValidator.validate('12345678901'), isNotNull);
    });

    test('strips whitespace before validating', () {
      // With spaces it should still process correctly
      final result = NigerianBvnValidator.validate('12345 678903');
      expect(result, isNull);
    });

    test('format splits BVN into groups', () {
      expect(NigerianBvnValidator.format('12345678903'), '1234 5678 903');
    });

    test('hasValidPrefix returns true for prefix starting with 1', () {
      expect(NigerianBvnValidator.hasValidPrefix('12345678903'), isTrue);
    });

    test('hasValidPrefix returns false for prefix starting with 9', () {
      expect(NigerianBvnValidator.hasValidPrefix('98765432101'), isFalse);
    });
  });
}