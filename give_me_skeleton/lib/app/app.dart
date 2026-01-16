import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import '../core/services/ads_service.dart';

class GiveMeApp extends ConsumerStatefulWidget {
  const GiveMeApp({super.key});

  @override
  ConsumerState<GiveMeApp> createState() => _GiveMeAppState();
}

class _GiveMeAppState extends ConsumerState<GiveMeApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adsServiceProvider).init());
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Give (Me)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
