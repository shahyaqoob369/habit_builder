import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the device has a network connection, now and on every change.
typedef WatchOnline = Stream<bool> Function();

/// Online status from the system (Wi-Fi, mobile data, …). A connection
/// isn't proof that the internet works, but its absence means offline.
Stream<bool> systemOnline() async* {
  final connectivity = Connectivity();
  bool online(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
  yield online(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(online);
}

/// How the app watches the connection: always online by default (tests);
/// `main` overrides it with [systemOnline].
final watchOnlineProvider = Provider<WatchOnline>(
  (ref) =>
      () => Stream.value(true),
);

/// Whether the device is online (true until known otherwise).
final StreamProvider<bool> onlineProvider = StreamProvider<bool>(
  (ref) => ref.watch(watchOnlineProvider)().distinct(),
);
