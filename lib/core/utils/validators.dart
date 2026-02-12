abstract class AppValidators {
  // BVN: exactly 11 digits
  static String? validateBvn(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your BVN';
    if (value.length != 11) return 'BVN must be exactly 11 digits';
    if (!RegExp(r'^\d{11}$').hasMatch(value)) return 'BVN must contain digits only';
    return null;
  }

  // Nigerian phone: 11 digits starting with 0, or 10 digits
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^(0[789]\d{9}|\+234[789]\d{9})$').hasMatch(cleaned)) {
      return 'Enter a valid Nigerian phone number';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email address is required';
    if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? validateName(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Name'} is required';
    }
    if (value.trim().length < 2) {
      return '${fieldName ?? 'Name'} is too short';
    }
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value.trim())) {
      return 'Enter a valid name (letters only)';
    }
    return null;
  }

  static String? validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) return 'Date of birth is required';
    // Expect DD/MM/YYYY
    final parts = value.split('/');
    if (parts.length != 3) return 'Use format DD/MM/YYYY';
    final day   = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year  = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return 'Invalid date';
    final dob = DateTime(year, month, day);
    final age = DateTime.now().difference(dob).inDays ~/ 365;
    if (age < 18) return 'You must be at least 18 years old';
    if (age > 100) return 'Enter a valid date of birth';
    return null;
  }
}