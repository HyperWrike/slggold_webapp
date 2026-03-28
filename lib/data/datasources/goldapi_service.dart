import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

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
  // replace 'YOUR_GOLDAPI_IO_KEY' with your actual key from goldapi.io
  static const String _apiKey = 'YOUR_GOLDAPI_IO_KEY';
  static const String _baseUrl = 'https://www.goldapi.io/api';

  // Fallback prices in INR per gram (updated to current market rates)
  static const double _fallbackGoldPrice = 14471.0;
  static const double _fallbackSilverPrice = 240.0;

  Future<double> _fetchGoldFromApi() async {
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
    final supabase = Supabase.instance.client;

    try {
      final cached = await supabase
          .from('metal_prices')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (cached != null) {
        final lastUpdated = DateTime.parse(cached['created_at']);
        final now = DateTime.now();
        if (now.difference(lastUpdated).inMinutes < 30) {
          return MetalPrices(
            goldPricePerGram: (cached['gold_price'] as num).toDouble(),
            silverPricePerGram: (cached['silver_price'] as num).toDouble(),
            lastUpdated: lastUpdated,
          );
        }
      }
    } catch (_) {}

    double goldPrice = await _fetchGoldFromApi();
    double silverPrice = await _fetchSilverFromApi();

    try {
      await supabase.from('metal_prices').insert({
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
