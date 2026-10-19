import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/auth/domain/auth_validators.dart';

void main() {
  group('AuthValidators', () {
    test('name is required', () {
      expect(AuthValidators.name(null), FieldError.nameRequired);
      expect(AuthValidators.name('   '), FieldError.nameRequired);
      expect(AuthValidators.name('Mira'), isNull);
    });

    test('email is required and must look like an address', () {
      expect(AuthValidators.email(''), FieldError.emailRequired);
      expect(AuthValidators.email('mira'), FieldError.emailInvalid);
      expect(AuthValidators.email('mira@example'), FieldError.emailInvalid);
      expect(
        AuthValidators.email('mi ra@example.com'),
        FieldError.emailInvalid,
      );
      expect(AuthValidators.email(' mira@example.com '), isNull);
    });

    test('a login password only has to be filled in', () {
      expect(AuthValidators.password(''), FieldError.passwordRequired);
      expect(AuthValidators.password('x'), isNull);
    });

    test('a new password needs at least 8 characters', () {
      expect(AuthValidators.newPassword(null), FieldError.passwordRequired);
      expect(
        AuthValidators.newPassword('1234567'),
        FieldError.passwordTooShort,
      );
      expect(AuthValidators.newPassword('12345678'), isNull);
    });
  });
}
