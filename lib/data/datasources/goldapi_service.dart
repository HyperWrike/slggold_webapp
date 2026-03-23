import 'dart:convert';
import 'package:http/http.dart' as http;

class MetalPrices {
  final double goldPricePerGram;
  final double silverPricePerGram;

  const MetalPrices({
    required this.goldPricePerGram,
    required this.silverPricePerGram,
  });
}

class GoldApiService {
  static const String _apiKey = 'goldapi-31wrs0hsmmxhhj94-io';
  static const String _baseUrl = 'https://www.goldapi.io/api';

  Future<double> getGoldPrice() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/XAU/INR'),
        headers: {'x-access-token': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // API returns price per ounce. 1 Troy Ounce = 31.1034768 grams.
        final pricePerOunce = (data['price'] as num).toDouble();
        return pricePerOunce / 31.1034768; // Price per gram
      } else {
        throw Exception('Failed to load gold price');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<double> getSilverPrice() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/XAG/INR'),
        headers: {'x-access-token': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pricePerOunce = (data['price'] as num).toDouble();
        return pricePerOunce / 31.1034768; // Price per gram
      } else {
        throw Exception('Failed to load silver price');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<MetalPrices> getMetalPrices() async {
    final goldPrice = await getGoldPrice();
    final silverPrice = await getSilverPrice();
    return MetalPrices(
      goldPricePerGram: goldPrice,
      silverPricePerGram: silverPrice,
    );
  }
}
