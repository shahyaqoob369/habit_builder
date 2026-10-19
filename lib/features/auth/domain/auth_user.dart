import 'package:flutter/foundation.dart';

/// The signed-in user, as far as authentication knows them.
@immutable
class AuthUser {
  const AuthUser({required this.id, required this.email, this.name});

  final String id;
  final String email;

  /// Display name; social accounts may not share one.
  final String? name;

  @override
  bool operator ==(Object other) =>
      other is AuthUser &&
      other.id == id &&
      other.email == email &&
      other.name == name;

  @override
  int get hashCode => Object.hash(id, email, name);
}
