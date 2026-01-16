import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/services/iap_service.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  bool _loading = true;
  bool _available = false;
  String? _error;
  List<ProductDetails> _products = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final iap = ref.read(iapServiceProvider);

    try {
      final ok = await iap.isAvailable();
      if (!ok) {
        setState(() {
          _available = false;
          _loading = false;
        });
        return;
      }

      final products = await iap.queryProducts();
      products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));

      setState(() {
        _available = true;
        _products = products;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _available = false;
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final iap = ref.read(iapServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : !_available
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Store unavailable (expected on emulator or without Play setup).',
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(_error!, style: const TextStyle(fontSize: 12)),
                      ],
                      const SizedBox(height: 16),
                      OutlinedButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  )
                : ListView(
                    children: [
                      Text(
                        'Example SKUs: ${IapIds.all.join(', ')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      ..._products.map(
                        (p) => Card(
                          child: ListTile(
                            title: Text(p.title),
                            subtitle: Text(p.description),
                            trailing: FilledButton(
                              onPressed: () => iap.buy(p),
                              child: Text(p.price),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => iap.restore(),
                        child: const Text('Restore Purchases'),
                      ),
                    ],
                  ),
      ),
    );
  }
}
