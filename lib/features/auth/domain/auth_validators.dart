/// A form field's validation problem. The screen turns it into a message.
enum FieldError {
  nameRequired,
  emailRequired,
  emailInvalid,
  passwordRequired,
  passwordTooShort,
}

/// Validation rules for the auth forms. Each returns null when the value is
/// valid.
abstract final class AuthValidators {
  /// Minimum length of a new password.
  static const minPasswordLength = 8;

  // Deliberately loose: one @, something on both sides, a dot in the
  // domain. The backend's confirmation email is the real check.
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static FieldError? name(String? value) =>
      (value ?? '').trim().isEmpty ? FieldError.nameRequired : null;

  static FieldError? email(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return FieldError.emailRequired;
    if (!_email.hasMatch(email)) return FieldError.emailInvalid;
    return null;
  }

  /// For logging in: any non-empty password, so older accounts still work.
  static FieldError? password(String? value) =>
      (value ?? '').isEmpty ? FieldError.passwordRequired : null;

  /// For a new account.
  static FieldError? newPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return FieldError.passwordRequired;
    if (password.length < minPasswordLength) {
      return FieldError.passwordTooShort;
    }
    return null;
  }
}
