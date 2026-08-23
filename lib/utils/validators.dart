abstract final class AppValidators {
  static final RegExp _phoneCharacters = RegExp(r'^\+?[0-9()\s-]+$');
  static final RegExp _expiryPattern = RegExp(r'^(0[1-9]|1[0-2])/(\d{2})$');
  static final RegExp _cvvPattern = RegExp(r'^\d{3,4}$');

  static String? customerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your name.';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    final String phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return 'Enter your phone number.';
    }
    if (!_phoneCharacters.hasMatch(phone)) {
      return 'Use numbers and an optional country code only.';
    }

    final String digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9 || digits.length > 15) {
      return 'Enter a valid phone number with 9–15 digits.';
    }
    return null;
  }

  static String? deliveryAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your delivery address.';
    }
    return null;
  }

  static String? cardholderName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter the cardholder name.';
    }
    return null;
  }

  static String? cardNumber(String? value) {
    final String number = value?.trim() ?? '';
    if (number.isEmpty) {
      return 'Enter the card number.';
    }
    if (!isValidCardNumber(number)) {
      return 'Enter a valid card number.';
    }
    return null;
  }

  static bool isValidCardNumber(String value) {
    if (!RegExp(r'^[0-9\s-]+$').hasMatch(value)) {
      return false;
    }

    final String digits = value.replaceAll(RegExp(r'[\s-]'), '');
    if (digits.length < 13 || digits.length > 19) {
      return false;
    }
    if (digits.split('').toSet().length == 1) {
      return false;
    }

    int sum = 0;
    bool shouldDouble = false;
    for (int index = digits.length - 1; index >= 0; index -= 1) {
      int digit = int.parse(digits[index]);
      if (shouldDouble) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      sum += digit;
      shouldDouble = !shouldDouble;
    }
    return sum % 10 == 0;
  }

  static String? expiryDate(String? value, {DateTime? now}) {
    final String expiry = value?.trim() ?? '';
    if (expiry.isEmpty) {
      return 'Enter the card expiry date.';
    }

    final RegExpMatch? match = _expiryPattern.firstMatch(expiry);
    if (match == null) {
      return 'Use MM/YY, for example 08/29.';
    }

    final int month = int.parse(match.group(1)!);
    final int year = 2000 + int.parse(match.group(2)!);
    final DateTime current = now ?? DateTime.now();
    if (year < current.year ||
        (year == current.year && month < current.month)) {
      return 'Use a card that has not expired.';
    }
    return null;
  }

  static String? cvv(String? value) {
    final String securityCode = value?.trim() ?? '';
    if (securityCode.isEmpty) {
      return 'Enter the CVV.';
    }
    if (!_cvvPattern.hasMatch(securityCode)) {
      return 'Enter the 3 or 4 digit CVV.';
    }
    return null;
  }
}
