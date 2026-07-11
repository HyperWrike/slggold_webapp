import 'dart:convert';
import 'package:http/http.dart' as http;

import 'convex_api.dart';

class MetalPrices {
  final double goldPricePerGram;
  final double silverPricePerGram;
  final DateTime lastUpdated;

  const MetalPrices({
    required this.goldPricePerGram,
    required this.silverPricePerGram,
    required this.lastUpdated,
  });
}

class GoldApiService {
  static const String _baseUrl = 'https://www.goldapi.io/api';

  static const double _fallbackGoldPrice = 8500.0;
  static const double _fallbackSilverPrice = 95.0;

  String get _apiKey => const String.fromEnvironment(
        'GOLDAPI_KEY',
        defaultValue: '',
      );

  Future<double> _fetchGoldFromApi() async {
    if (_apiKey.isEmpty) return _fallbackGoldPrice;
    try {
      final client = http.Client();
      final response = await client
          .get(
            Uri.parse('$_baseUrl/XAU/INR'),
            headers: {'x-access-token': _apiKey},
          )
          .timeout(const Duration(seconds: 10));

      client.close();
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pricePerOunce = (data['price'] as num).toDouble();
        return pricePerOunce / 31.1034768;
      }
    } catch (_) {}
    return _fallbackGoldPrice;
  }

  Future<double> _fetchSilverFromApi() async {
    if (_apiKey.isEmpty) return _fallbackSilverPrice;
    try {
      final client = http.Client();
      final response = await client
          .get(
            Uri.parse('$_baseUrl/XAG/INR'),
            headers: {'x-access-token': _apiKey},
          )
          .timeout(const Duration(seconds: 10));
      client.close();
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pricePerOunce = (data['price'] as num).toDouble();
        return pricePerOunce / 31.1034768;
      }
    } catch (_) {}
    return _fallbackSilverPrice;
  }

  Future<MetalPrices> getMetalPrices() async {
    try {
      final cached = await convexQuery('metalPrices:latest', {});
      if (cached is Map) {
        final m = Map<String, dynamic>.from(cached);
        final lastUpdated = DateTime.parse(m['created_at'] as String);
        final now = DateTime.now();
        if (now.difference(lastUpdated).inMinutes < 30) {
          return MetalPrices(
            goldPricePerGram: (m['gold_price'] as num).toDouble(),
            silverPricePerGram: (m['silver_price'] as num).toDouble(),
            lastUpdated: lastUpdated,
          );
        }
      }
    } catch (_) {}

    double goldPrice = await _fetchGoldFromApi();
    double silverPrice = await _fetchSilverFromApi();

    try {
      await convexMutation('metalPrices:insert', {
        'gold_price': goldPrice,
        'silver_price': silverPrice,
      });
    } catch (_) {}

    return MetalPrices(
      goldPricePerGram: goldPrice,
      silverPricePerGram: silverPrice,
      lastUpdated: DateTime.now(),
    );
  }
}
