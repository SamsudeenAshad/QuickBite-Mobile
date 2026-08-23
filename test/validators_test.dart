import 'package:flutter_test/flutter_test.dart';
import 'package:quickbite_cafe/utils/validators.dart';

void main() {
  group('customer name validation', () {
    test('rejects null, empty, and whitespace-only values', () {
      expect(AppValidators.customerName(null), isNotNull);
      expect(AppValidators.customerName(''), isNotNull);
      expect(AppValidators.customerName('   '), isNotNull);
    });

    test('accepts a non-empty trimmed name', () {
      expect(AppValidators.customerName('  Samsudeen Ashad  '), isNull);
    });
  });

  group('phone number validation', () {
    test('rejects missing and too-short phone numbers', () {
      expect(AppValidators.phoneNumber(null), isNotNull);
      expect(AppValidators.phoneNumber(''), isNotNull);
      expect(AppValidators.phoneNumber('12345678'), isNotNull);
    });

    test('rejects letters and a misplaced country-code marker', () {
      expect(AppValidators.phoneNumber('077ABC4567'), isNotNull);
      expect(AppValidators.phoneNumber('077+1234567'), isNotNull);
    });

    test('accepts common local and international formats', () {
      expect(AppValidators.phoneNumber('077 123 4567'), isNull);
      expect(AppValidators.phoneNumber('+94 (77) 123-4567'), isNull);
    });

    test('rejects numbers longer than the international maximum', () {
      expect(AppValidators.phoneNumber('+1234567890123456'), isNotNull);
    });
  });

  group('delivery address validation', () {
    test('requires a non-empty address', () {
      expect(AppValidators.deliveryAddress(null), isNotNull);
      expect(AppValidators.deliveryAddress('  '), isNotNull);
      expect(AppValidators.deliveryAddress('25 Café Road, Colombo'), isNull);
    });
  });

  group('cardholder name validation', () {
    test('requires a non-empty cardholder name', () {
      expect(AppValidators.cardholderName(null), isNotNull);
      expect(AppValidators.cardholderName('   '), isNotNull);
      expect(AppValidators.cardholderName('Samsudeen Ashad'), isNull);
    });
  });

  group('card number validation', () {
    test('accepts standard Luhn-valid card numbers', () {
      expect(AppValidators.isValidCardNumber('4111111111111111'), isTrue);
      expect(AppValidators.isValidCardNumber('5555555555554444'), isTrue);
      expect(AppValidators.isValidCardNumber('378282246310005'), isTrue);
      expect(AppValidators.isValidCardNumber('6011111111111117'), isTrue);
    });

    test('accepts spaces and hyphens around valid digit groups', () {
      expect(AppValidators.isValidCardNumber('4111 1111 1111 1111'), isTrue);
      expect(AppValidators.isValidCardNumber('4111-1111-1111-1111'), isTrue);
    });

    test('rejects failed checksums, invalid lengths, and letters', () {
      expect(AppValidators.isValidCardNumber('4111111111111112'), isFalse);
      expect(AppValidators.isValidCardNumber('411111111111'), isFalse);
      expect(AppValidators.isValidCardNumber('4111x11111111111'), isFalse);
    });

    test(
      'rejects repeated-digit values even if checksum is divisible by ten',
      () {
        expect(AppValidators.isValidCardNumber('0000000000000000'), isFalse);
        expect(AppValidators.isValidCardNumber('1111111111111111'), isFalse);
      },
    );

    test('returns a form error for missing or invalid numbers', () {
      expect(AppValidators.cardNumber(null), isNotNull);
      expect(AppValidators.cardNumber(''), isNotNull);
      expect(AppValidators.cardNumber('4111111111111112'), isNotNull);
      expect(AppValidators.cardNumber('4111111111111111'), isNull);
    });
  });

  group('expiry date validation', () {
    final DateTime august2026 = DateTime(2026, 8, 24);

    test('requires a value in MM/YY format', () {
      expect(AppValidators.expiryDate(null, now: august2026), isNotNull);
      expect(AppValidators.expiryDate('', now: august2026), isNotNull);
      expect(AppValidators.expiryDate('8/29', now: august2026), isNotNull);
      expect(AppValidators.expiryDate('08/2029', now: august2026), isNotNull);
    });

    test('rejects impossible months', () {
      expect(AppValidators.expiryDate('00/29', now: august2026), isNotNull);
      expect(AppValidators.expiryDate('13/29', now: august2026), isNotNull);
    });

    test('rejects an expired month or year', () {
      expect(AppValidators.expiryDate('07/26', now: august2026), isNotNull);
      expect(AppValidators.expiryDate('12/25', now: august2026), isNotNull);
    });

    test('accepts the current month and future months', () {
      expect(AppValidators.expiryDate('08/26', now: august2026), isNull);
      expect(AppValidators.expiryDate('09/26', now: august2026), isNull);
      expect(AppValidators.expiryDate('12/30', now: august2026), isNull);
    });
  });

  group('CVV validation', () {
    test('accepts only three or four digits', () {
      expect(AppValidators.cvv('123'), isNull);
      expect(AppValidators.cvv('1234'), isNull);
      expect(AppValidators.cvv(null), isNotNull);
      expect(AppValidators.cvv('12'), isNotNull);
      expect(AppValidators.cvv('12345'), isNotNull);
      expect(AppValidators.cvv('12A'), isNotNull);
    });
  });
}
