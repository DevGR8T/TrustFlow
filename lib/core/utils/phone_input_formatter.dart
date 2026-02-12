import 'package:flutter/services.dart';
import 'phone_validator.dart';

class NigerianPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remove all non-digit characters
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
    
    // Limit to 11 digits
    final limited = digitsOnly.substring(0, digitsOnly.length > 11 ? 11 : digitsOnly.length);
    
    // Format the number
    final formatted = NigerianPhoneValidator.format(limited);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}