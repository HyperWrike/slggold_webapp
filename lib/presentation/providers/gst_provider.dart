import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/database_service.dart';
import 'auth_provider.dart';

final gstRatesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  final rates = await db.getLatestGstRates();
  return rates ?? {
    'gold_gst': 3.0,
    'silver_gst': 3.0,
    'making_charges_gst': 18.0,
  };
});
