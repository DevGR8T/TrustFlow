/// Input Validators
class Validators {
  /// Validate full name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    
    // Remove spaces and special characters
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length < 10 || cleaned.length > 11) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  /// Validate email (optional)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validate BVN
  static String? validateBvn(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your BVN';
    }
    
    if (value.length != 11) {
      return 'BVN must be exactly 11 digits';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'BVN must contain only numbers';
    }
    
    return null;
  }

  /// Validate date of birth
  static String? validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your date of birth';
    }
    
    // Basic format check (DD/MM/YYYY)
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
      return 'Please use DD/MM/YYYY format';
    }
    
    // Parse and validate date
    try {
      final parts = value.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      final date = DateTime(year, month, day);
      final now = DateTime.now();
      
      // Check if date is in the future
      if (date.isAfter(now)) {
        return 'Date cannot be in the future';
      }
      
      // Check minimum age (18 years)
      final age = now.year - date.year;
      if (age < 18) {
        return 'You must be at least 18 years old';
      }
      
      // Check maximum age (reasonable limit)
      if (age > 100) {
        return 'Please enter a valid date of birth';
      }
      
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }
}