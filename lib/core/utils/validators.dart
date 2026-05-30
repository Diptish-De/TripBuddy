class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'At least 6 characters';
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? tripName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Trip name is required';
    if (value.trim().length < 2) return 'At least 2 characters';
    if (value.trim().length > 50) return 'Max 50 characters';
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final amount = double.tryParse(value.trim());
    if (amount == null) return 'Enter a valid number';
    if (amount <= 0) return 'Must be greater than 0';
    return null;
  }

  static String? inviteCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'Invite code is required';
    if (value.trim().length != 6) return 'Code must be 6 characters';
    return null;
  }

  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'At least 2 characters';
    if (value.trim().length > 30) return 'Max 30 characters';
    return null;
  }
}
