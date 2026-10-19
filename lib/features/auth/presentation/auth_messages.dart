import 'package:flutter/material.dart';
import 'package:habit_builder/features/auth/domain/auth_failure.dart';
import 'package:habit_builder/features/auth/domain/auth_validators.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// User-facing text for auth errors.
extension AuthMessages on AppLocalizations {
  String fieldError(FieldError error) => switch (error) {
    FieldError.nameRequired => validationNameRequired,
    FieldError.emailRequired => validationEmailRequired,
    FieldError.emailInvalid => validationEmailInvalid,
    FieldError.passwordRequired => validationPasswordRequired,
    FieldError.passwordTooShort => validationPasswordTooShort(
      AuthValidators.minPasswordLength,
    ),
  };

  String authFailure(AuthFailure failure) => switch (failure) {
    AuthFailure.invalidCredentials => authErrorInvalidCredentials,
    AuthFailure.emailAlreadyInUse => authErrorEmailInUse,
    AuthFailure.network => authErrorNetwork,
    AuthFailure.cancelled || AuthFailure.unknown => authErrorUnknown,
  };
}

/// Adapts an [AuthValidators] rule to a form field validator.
FormFieldValidator<String> fieldValidator(
  BuildContext context,
  FieldError? Function(String?) rule,
) {
  return (value) {
    final error = rule(value);
    return error == null ? null : context.l10n.fieldError(error);
  };
}

/// Shows why a request failed. Cancelled social sign-ins stay silent.
void showAuthFailure(BuildContext context, AuthFailure failure) {
  if (failure == AuthFailure.cancelled) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(context.l10n.authFailure(failure))),
    );
}
