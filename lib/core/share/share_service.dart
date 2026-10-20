import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Opens the system share sheet. Behind a provider so tests can replace it.
typedef ShareText = Future<void> Function(String text, {Rect? origin});

final shareTextProvider = Provider<ShareText>(
  (ref) => (text, {origin}) async {
    await SharePlus.instance.share(
      ShareParams(text: text, sharePositionOrigin: origin),
    );
  },
);
