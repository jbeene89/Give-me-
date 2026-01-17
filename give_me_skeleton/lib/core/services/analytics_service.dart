import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Swap this with Firebase Analytics (or your own backend) later.
abstract class AnalyticsService {
  void logEvent(String name, {Map<String, Object?> params = const {}});
}

class ConsoleAnalyticsService implements AnalyticsService {
  @override
  void logEvent(String name, {Map<String, Object?> params = const {}}) {
    // ignore: avoid_print
    print('[analytics] $name $params');
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return ConsoleAnalyticsService();
});
