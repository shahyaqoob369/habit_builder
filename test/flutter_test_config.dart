import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs before every test file: loads the app's real fonts, so text measures
/// as on a device (the default test font draws every glyph as a square).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    _load('Manrope', [
      'assets/font/Manrope-Medium.ttf',
      'assets/font/Manrope-Bold.ttf',
    ]),
    _load('Fredoka', ['assets/font/Fredoka-SemiBold.ttf']),
  ]);
  await testMain();
}

Future<void> _load(String family, List<String> assets) {
  final loader = FontLoader(family);
  for (final asset in assets) {
    loader.addFont(rootBundle.load(asset));
  }
  return loader.load();
}
