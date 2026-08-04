class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? schoolId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ID Number is required';
    }
    final schoolIdRegex = RegExp(r'^\d{4}-\d{4}$');
    if (!schoolIdRegex.hasMatch(value)) {
      return 'Enter a valid ID Number (XXXX-XXXX)';
    }
    return null;
  }
}
