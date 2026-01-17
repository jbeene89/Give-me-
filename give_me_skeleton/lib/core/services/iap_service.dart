import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// IAP product IDs you will register in Google Play Console.
/// Keep these stable once you ship.
class IapIds {
  static const coinsSmall = 'coins_small';
  static const coinsMedium = 'coins_medium';
  static const coinsLarge = 'coins_large';
  static const vipPass = 'vip_pass';

  static const Set<String> all = {
    coinsSmall,
    coinsMedium,
    coinsLarge,
    vipPass,
  };
}

abstract class IapService {
  Stream<List<PurchaseDetails>> get purchaseUpdates;
  Future<bool> isAvailable();
  Future<List<ProductDetails>> queryProducts();
  Future<void> buy(ProductDetails product);
  Future<void> restore();
}

class FlutterIapService implements IapService {
  final InAppPurchase _iap;
  final StreamController<List<PurchaseDetails>> _purchaseController =
      StreamController.broadcast();

  late final StreamSubscription<List<PurchaseDetails>> _sub;

  FlutterIapService(this._iap) {
    _sub = _iap.purchaseStream.listen(
      (purchases) => _purchaseController.add(purchases),
      onError: (e) => _purchaseController.addError(e),
    );
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseUpdates => _purchaseController.stream;

  @override
  Future<bool> isAvailable() => _iap.isAvailable();

  @override
  Future<List<ProductDetails>> queryProducts() async {
    final response = await _iap.queryProductDetails(IapIds.all);
    return response.productDetails;
  }

  @override
  Future<void> buy(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);

    // Treat everything as consumable by default. For non-consumables,
    // you may want buyNonConsumable.
    await _iap.buyConsumable(purchaseParam: param);
  }

  @override
  Future<void> restore() => _iap.restorePurchases();

  void dispose() {
    _sub.cancel();
    _purchaseController.close();
  }
}

final iapServiceProvider = Provider<IapService>((ref) {
  final svc = FlutterIapService(InAppPurchase.instance);
  ref.onDispose(svc.dispose);
  return svc;
});
