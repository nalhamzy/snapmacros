import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/iap_service.dart';

final iapServiceProvider = Provider<IapService>((ref) {
  final svc = IapService();
  ref.onDispose(() => svc.dispose());
  return svc;
});
