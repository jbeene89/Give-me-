import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/game/game_screen.dart';
import '../features/shop/shop_screen.dart';
import '../features/settings/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => const MaterialPage(child: DashboardScreen()),
      ),
      GoRoute(
        path: '/game',
        pageBuilder: (context, state) => const MaterialPage(child: GameScreen()),
      ),
      GoRoute(
        path: '/shop',
        pageBuilder: (context, state) => const MaterialPage(child: ShopScreen()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => const MaterialPage(child: SettingsScreen()),
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Route error')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(state.error?.toString() ?? 'Unknown routing error'),
        ),
      );
    },
  );
});
