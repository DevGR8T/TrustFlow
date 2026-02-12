class NigerianBvnValidator {
  /// Validates a Nigerian BVN (Bank Verification Number)
  /// Returns null if valid, error message if invalid
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'BVN is required';
    }

    // Remove any whitespace
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');

    // Check if it's exactly 11 digits
    if (cleaned.length != 11) {
      return 'BVN must be exactly 11 digits';
    }

    // Check if it's all digits
    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return 'BVN must contain only digits';
    }

    // Basic checksum validation (Luhn algorithm variant used by NIBSS)
    if (!_validateChecksum(cleaned)) {
      return 'Invalid BVN number';
    }

    return null; // Valid
  }

  /// Validates BVN checksum using modified Luhn algorithm
  /// Note: This is a simplified version. Real BVN validation happens on the server
  static bool _validateChecksum(String bvn) {
    if (bvn.length != 11) return false;

    int sum = 0;
    bool alternate = false;

    // Process from right to left
    for (int i = bvn.length - 1; i >= 0; i--) {
      int digit = int.parse(bvn[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    // Valid if sum is divisible by 10
    return (sum % 10) == 0;
  }

  /// Formats BVN for display (optional spacing every 3-4 digits)
  static String format(String value) {
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    
    if (cleaned.isEmpty) return '';
    if (cleaned.length <= 4) return cleaned;
    if (cleaned.length <= 8) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4)}';
    }
    return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 8)} ${cleaned.substring(8)}';
  }

  /// Removes formatting from BVN
  static String unformat(String value) {
    return value.replaceAll(RegExp(r'\s+'), '');
  }

  /// Checks if BVN starts with valid prefix
  /// BVNs typically start with 1, 2, or 3
  static bool hasValidPrefix(String bvn) {
    if (bvn.isEmpty) return false;
    final firstDigit = bvn[0];
    return ['1', '2', '3'].contains(firstDigit);
  }
}