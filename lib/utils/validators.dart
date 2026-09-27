class Validators {
  Validators._();

  // Validate a transaction title.
  static String? title(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a title';
    }
    if (value.trim().length < 2) {
      return 'Title must be at least 2 characters';
    }
    if (value.trim().length > 60) {
      return 'Title must be under 60 characters';
    }
    return null;
  }

  // Validate a monetary amount.
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (parsed <= 0) {
      return 'Amount must be greater than 0';
    }
    if (parsed > 100000000) {
      return 'Amount is too large';
    }
    return null;
  }

  // Validate an optional note field.
  static String? note(String? value) {
    if (value != null && value.trim().length > 200) {
      return 'Note must be under 200 characters';
    }
    return null;
  }

  // Validate an email address.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validate a password.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
