import 'package:intl/intl.dart';

class ValidateInput {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  static String? weight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your weight';
    }
    final numericValue = double.tryParse(value);
    if (numericValue == null) {
      return 'Enter a valid number';
    }
    if (numericValue < 30 || numericValue > 300) {
      return 'Weight must be between 30-300 kg';
    }
    return null;
  }

  static String? height(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your height';
    }
    final numericValue = double.tryParse(value);
    if (numericValue == null) {
      return 'Enter a valid number';
    }
    if (numericValue < 100 || numericValue > 250) {
      return 'Height must be between 100-250 cm';
    }
    return null;
  }

  static String? birthday(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your birthday';
    }
    try {
      final date = DateFormat('MM/dd/yyyy').parseStrict(value);
      final minimumDate = DateTime.now().subtract(const Duration(days: 4745));
      if (date.isAfter(minimumDate)) {
        return 'You must be at least 13 years old';
      }
    } catch (e) {
      return 'Use DD/MM/YYYY format';
    }
    return null;
  }
}
