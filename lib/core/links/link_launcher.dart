import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a link outside the app (browser, mail). Returns false if nothing
/// could open it. Behind a provider so tests can replace it.
typedef OpenLink = Future<bool> Function(Uri uri);

final openLinkProvider = Provider<OpenLink>(
  (ref) => (uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      return false;
    }
  },
);
