import 'package:flutter/foundation.dart';

/// Coarse connectivity signal. The app treats any network failure as offline;
/// this notifier lets the chrome render state without polling the OS stack.
class ConnectivityService {
  final ValueNotifier<bool> online = ValueNotifier<bool>(true);

  bool get isOnline => online.value;

  void setOnline(bool value) {
    if (online.value != value) online.value = value;
  }

  void dispose() => online.dispose();
}
