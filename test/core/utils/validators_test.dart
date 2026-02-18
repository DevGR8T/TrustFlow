import 'package:flutter_test/flutter_test.dart';
import 'package:trust_flow/core/utils/validators.dart';

void main() {
  group('AppValidators.validateDateOfBirth', () {
    test('returns error when value is null', () {
      expect(AppValidators.validateDateOfBirth(null), 'Date of birth is required');
    });

    test('returns error when value is empty', () {
      expect(AppValidators.validateDateOfBirth(''), 'Date of birth is required');
    });

    test('returns error for wrong format', () {
      expect(AppValidators.validateDateOfBirth('1990-01-01'), 'Use format DD/MM/YYYY');
    });

    test('returns error when user is under 18', () {
      final dob = '01/01/${DateTime.now().year - 10}';
      expect(AppValidators.validateDateOfBirth(dob), 'You must be at least 18 years old');
    });

    test('returns error when age is over 100', () {
      expect(AppValidators.validateDateOfBirth('01/01/1900'), 'Enter a valid date of birth');
    });

    test('returns null for valid adult date of birth', () {
      expect(AppValidators.validateDateOfBirth('01/01/1990'), isNull);
    });
  });

  group('AppValidators.validateEmail', () {
    test('returns error for empty email', () {
      expect(AppValidators.validateEmail(''), 'Email address is required');
    });

    test('returns error for invalid email', () {
      expect(AppValidators.validateEmail('notanemail'), isNotNull);
    });

    test('returns null for valid email', () {
      expect(AppValidators.validateEmail('test@example.com'), isNull);
    });
  });

  group('AppValidators.validateName', () {
    test('returns error for empty name', () {
      expect(AppValidators.validateName(''), isNotNull);
    });

    test('returns error for name with numbers', () {
      expect(AppValidators.validateName('John123'), isNotNull);
    });

    test('returns null for valid name', () {
      expect(AppValidators.validateName('Chidi'), isNull);
    });
  });
}
