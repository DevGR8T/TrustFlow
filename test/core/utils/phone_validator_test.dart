import 'package:flutter_test/flutter_test.dart';
import 'package:trust_flow/core/utils/phone_validator.dart';

void main() {
  group('NigerianPhoneValidator', () {
    test('returns error when phone is null', () {
      expect(NigerianPhoneValidator.validate(null), 'Phone number is required');
    });

    test('returns error when phone is empty', () {
      expect(NigerianPhoneValidator.validate(''), 'Phone number is required');
    });

    test('returns error when phone is less than 11 digits', () {
      expect(NigerianPhoneValidator.validate('080312345'), 'Phone number must be 11 digits');
    });

    test('returns error when phone does not start with 0', () {
      expect(NigerianPhoneValidator.validate('80312345678'), 'Phone number must start with 0');
    });

    test('returns error when phone contains non-digits', () {
      expect(NigerianPhoneValidator.validate('0803123456A'), 'Phone number must contain only digits');
    });

    test('returns error for invalid prefix', () {
      expect(NigerianPhoneValidator.validate('01001234567'), 'Invalid Phone Number');
    });

    test('returns null for valid MTN number', () {
      expect(NigerianPhoneValidator.validate('08031234567'), isNull);
    });

    test('returns null for valid Glo number', () {
      expect(NigerianPhoneValidator.validate('08051234567'), isNull);
    });

    test('returns null for valid Airtel number', () {
      expect(NigerianPhoneValidator.validate('08021234567'), isNull);
    });

    test('returns null for valid 9mobile number', () {
      expect(NigerianPhoneValidator.validate('08091234567'), isNull);
    });

    test('strips whitespace before validating', () {
      expect(NigerianPhoneValidator.validate('0803 123 4567'), isNull);
    });

    test('getNetwork returns MTN for 0803 prefix', () {
      expect(NigerianPhoneValidator.getNetwork('08031234567'), 'MTN');
    });

    test('getNetwork returns Glo for 0805 prefix', () {
      expect(NigerianPhoneValidator.getNetwork('08051234567'), 'Glo');
    });

    test('getNetwork returns Airtel for 0802 prefix', () {
      expect(NigerianPhoneValidator.getNetwork('08021234567'), 'Airtel');
    });

    test('getNetwork returns 9mobile for 0809 prefix', () {
      expect(NigerianPhoneValidator.getNetwork('08091234567'), '9mobile');
    });

    test('getNetwork returns null for short number', () {
      expect(NigerianPhoneValidator.getNetwork('080'), isNull);
    });
  });
}