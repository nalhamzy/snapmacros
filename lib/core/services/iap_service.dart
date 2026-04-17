import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'iap_product_ids.dart';

typedef PurchaseSuccessCallback = void Function(String productId);

class IapProduct {
  final String id;
  final String title;
  final String price;
  final String description;
  const IapProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
  });
}

class IapService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  final Map<String, ProductDetails> _products = {};
  bool _available = false;

  PurchaseSuccessCallback? onPurchaseSuccess;

  Future<void> initialize() async {
    if (kIsWeb) return;
    _available = await _iap.isAvailable();
    if (!_available) return;
    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onDone: () => _sub?.cancel(),
      onError: (_) {},
    );
    try {
      final response = await _iap.queryProductDetails(IapProductIds.all);
      for (final p in response.productDetails) {
        _products[p.id] = p;
      }
    } catch (e) {
      if (kDebugMode) print('IAP query failed: $e');
    }
  }

  bool get isAvailable => _available;

  IapProduct? product(String id) {
    final p = _products[id];
    if (p == null) return _fallback(id);
    return IapProduct(
      id: p.id,
      title: p.title.isNotEmpty ? p.title : _fallback(id).title,
      price: p.price.isNotEmpty ? p.price : _fallback(id).price,
      description: p.description,
    );
  }

  List<IapProduct> allProducts() =>
      IapProductIds.all.map(product).whereType<IapProduct>().toList();

  Future<bool> purchase(String productId) async {
    if (!_available) return false;
    final details = _products[productId];
    if (details == null) return false;
    final param = PurchaseParam(productDetails: details);
    try {
      return await _iap.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      if (kDebugMode) print('IAP purchase failed: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!_available) return;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      if (kDebugMode) print('IAP restore failed: $e');
    }
  }

  void _onPurchaseUpdates(List<PurchaseDetails> updates) {
    for (final p in updates) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        onPurchaseSuccess?.call(p.productID);
      }
      if (p.pendingCompletePurchase) {
        _iap.completePurchase(p);
      }
    }
  }

  void dispose() => _sub?.cancel();

  IapProduct _fallback(String id) {
    switch (id) {
      case IapProductIds.proWeekly:
        return const IapProduct(
          id: IapProductIds.proWeekly,
          title: 'SnapMacros Pro — Weekly',
          price: '\$3.99',
          description: '3-day free trial',
        );
      case IapProductIds.proMonthly:
        return const IapProduct(
          id: IapProductIds.proMonthly,
          title: 'SnapMacros Pro — Monthly',
          price: '\$7.99',
          description: '7-day free trial',
        );
      case IapProductIds.proYearly:
        return const IapProduct(
          id: IapProductIds.proYearly,
          title: 'SnapMacros Pro — Yearly',
          price: '\$29.99',
          description: 'Best value',
        );
      case IapProductIds.lifetime:
        return const IapProduct(
          id: IapProductIds.lifetime,
          title: 'SnapMacros Lifetime',
          price: '\$49.99',
          description: 'One-time',
        );
    }
    return IapProduct(id: id, title: id, price: '', description: '');
  }

  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}
