import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/goldapi_service.dart';

final goldApiServiceProvider = Provider<GoldApiService>((ref) {
  return GoldApiService();
});

final metalPricesProvider = AutoDisposeAsyncNotifierProvider<MetalPricesNotifier, MetalPrices>(() {
  return MetalPricesNotifier();
});

class MetalPricesNotifier extends AutoDisposeAsyncNotifier<MetalPrices> {
  Timer? _pollingTimer;

  @override
  FutureOr<MetalPrices> build() async {
    // Refresh every 60 seconds
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      // ignore: unused_result
      ref.invalidateSelf();
    });

    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    final goldApiService = ref.watch(goldApiServiceProvider);
    return await goldApiService.getMetalPrices();
  }
}
