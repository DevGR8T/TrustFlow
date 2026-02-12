class NigerianPhoneValidator {
  // Nigerian network prefixes (MTN, Glo, Airtel, 9mobile, etc.)
  static const List<String> validPrefixes = [
    // MTN
    '0703', '0706', '0803', '0806', '0810', '0813', '0814', '0816', '0903', '0906', '0913', '0916',
    // Glo
    '0705', '0805', '0807', '0811', '0815', '0905', '0915',
    // Airtel
    '0701', '0708', '0802', '0808', '0812', '0901', '0902', '0904', '0907', '0912',
    // 9mobile (formerly Etisalat)
    '0809', '0817', '0818', '0909', '0908',
    // Other operators
    '0704', '0709', '0819',
  ];

  /// Validates a Nigerian phone number
  /// Returns null if valid, error message if invalid
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any whitespace
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');

    // Check length (should be 11 digits for Nigerian numbers)
    if (cleaned.length != 11) {
      return 'Phone number must be 11 digits';
    }

    // Check if it starts with 0
    if (!cleaned.startsWith('0')) {
      return 'Phone number must start with 0';
    }

    // Check if it's all digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return 'Phone number must contain only digits';
    }

    // Check if prefix is valid
    final prefix = cleaned.substring(0, 4);
    if (!validPrefixes.contains(prefix)) {
      return 'Invalid Phone Number';
    }

    return null; // Valid
  }

  /// Formats phone number as user types: 0801 234 5678
  static String format(String value) {
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    
    if (cleaned.isEmpty) return '';
    if (cleaned.length <= 4) return cleaned;
    if (cleaned.length <= 7) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4)}';
    }
    return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7)}';
  }

  /// Removes formatting from phone number
  static String unformat(String value) {
    return value.replaceAll(RegExp(r'\s+'), '');
  }

  /// Gets network name from phone number
  static String? getNetwork(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length < 4) return null;

    final prefix = cleaned.substring(0, 4);
    
    if (['0703', '0706', '0803', '0806', '0810', '0813', '0814', '0816', '0903', '0906', '0913', '0916'].contains(prefix)) {
      return 'MTN';
    } else if (['0705', '0805', '0807', '0811', '0815', '0905', '0915'].contains(prefix)) {
      return 'Glo';
    } else if (['0701', '0708', '0802', '0808', '0812', '0901', '0902', '0904', '0907', '0912'].contains(prefix)) {
      return 'Airtel';
    } else if (['0809', '0817', '0818', '0909', '0908'].contains(prefix)) {
      return '9mobile';
    }
    
    return 'Other';
  }
}