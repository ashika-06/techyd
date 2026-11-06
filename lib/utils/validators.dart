/// Form validators shared by every form in the app.
/// Each returns `null` when valid, or an error message.
class Validators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _phone = RegExp(r'^[6-9]\d{9}$');
  static final RegExp _name = RegExp(r"^[A-Za-z][A-Za-z .'-]*$");

  static String? required(String? v, [String label = 'This field']) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? name(String? v) {
    final r = required(v, 'Name');
    if (r != null) return r;
    final t = v!.trim();
    if (t.length < 3) return 'Enter your full name (min 3 characters)';
    if (!_name.hasMatch(t)) return 'Name can only contain letters and spaces';
    return null;
  }

  static String? email(String? v) {
    final r = required(v, 'Email');
    if (r != null) return r;
    if (!_email.hasMatch(v!.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? phone(String? v) {
    final r = required(v, 'Phone number');
    if (r != null) return r;
    if (!_phone.hasMatch(v!.trim())) {
      return 'Enter a valid 10-digit Indian mobile number';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Use at least 6 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Include at least one letter and one number';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (v) {
      if (v == null || v.isEmpty) return 'Please confirm your password';
      if (v != original()) return 'Passwords do not match';
      return null;
    };
  }

  static String? Function(String?) minLength(int n, String label) {
    return (v) {
      final r = required(v, label);
      if (r != null) return r;
      if (v!.trim().length < n) return '$label must be at least $n characters';
      return null;
    };
  }

  static String? optionalUrl(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final t = v.trim();
    if (!RegExp(r'^https?://[^\s/$.?#].[^\s]*$').hasMatch(t)) {
      return 'Enter a valid link starting with http:// or https://';
    }
    return null;
  }

  static String? Function(String?) integer(
      {required String label, int min = 0, int? max}) {
    return (v) {
      final r = required(v, label);
      if (r != null) return r;
      final n = int.tryParse(v!.trim());
      if (n == null) return '$label must be a whole number';
      if (n < min) return '$label must be at least $min';
      if (max != null && n > max) return '$label must be at most $max';
      return null;
    };
  }
}
