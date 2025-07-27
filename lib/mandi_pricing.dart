import 'dart:convert';
import 'package:http/http.dart' as http;

/// Model for a single mandi price entry
class MandiPrice {
  final String state;
  final String district;
  final String commodity;
  final String variety;
  final String arrivalDate;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;

  MandiPrice({
    required this.state,
    required this.district,
    required this.commodity,
    required this.variety,
    required this.arrivalDate,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
  });

  factory MandiPrice.fromJson(Map<String, dynamic> json) {
    return MandiPrice(
      state: json['State'] ?? '',
      district: json['District'] ?? '',
      commodity: json['Commodity'] ?? '',
      variety: json['Variety'] ?? '',
      arrivalDate: json['Arrival_Date'] ?? '',
      minPrice: double.tryParse(json['Min_Price']?.toString() ?? '') ?? 0.0,
      maxPrice: double.tryParse(json['Max_Price']?.toString() ?? '') ?? 0.0,
      modalPrice: double.tryParse(json['Modal_Price']?.toString() ?? '') ?? 0.0,
    );
  }
}

/// Service to fetch mandi prices from the API
class MandiPricingService {
  static const String _baseUrl =
      'https://api.data.gov.in/resource/35985678-0d79-46b4-9ed6-6f13308a1d24';

  /// Fetch mandi prices for a given commodity, state, and district
  static Future<List<MandiPrice>> fetchMandiPrices({
    required String apiKey,
    required String commodity,
    String? state,
    String? district,
    int limit = 30,
    String? arrivalDate,
  }) async {
    final params = {
      'api-key':
          apiKey, // Use the passed apiKey parameter instead of hardcoded value
      'format': 'json',
      'limit': limit.toString(),
      'filters[Commodity]': commodity,
      if (state != null && state.isNotEmpty) 'filters[State]': state,
      if (district != null && district.isNotEmpty)
        'filters[District]': district,
      if (arrivalDate != null && arrivalDate.isNotEmpty)
        'filters[Arrival_Date]': arrivalDate,
    };
    final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List records = data['records'] ?? [];
      return records.map((e) => MandiPrice.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch mandi prices');
    }
  }

  /// Basic price forecast using linear trend (last N days)
  /// Returns a list of forecasted modal prices for the next [daysAhead] days
  static List<double> forecastPrices(
    List<MandiPrice> prices, {
    int daysAhead = 7,
  }) {
    if (prices.length < 2) {
      // Not enough data to forecast
      return List.filled(
        daysAhead,
        prices.isNotEmpty ? prices.last.modalPrice : 0.0,
      );
    }
    // Sort by date ascending
    prices.sort((a, b) => a.arrivalDate.compareTo(b.arrivalDate));
    // Use simple linear regression (least squares) on modalPrice vs. day index
    final n = prices.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = prices.map((e) => e.modalPrice).toList();
    final xMean = x.reduce((a, b) => a + b) / n;
    final yMean = y.reduce((a, b) => a + b) / n;
    double num = 0, den = 0;
    for (int i = 0; i < n; i++) {
      num += (x[i] - xMean) * (y[i] - yMean);
      den += (x[i] - xMean) * (x[i] - xMean);
    }
    final slope = den == 0 ? 0 : num / den;
    final intercept = yMean - slope * xMean;
    // Forecast next daysAhead days
    return List.generate(daysAhead, (i) {
      final dayIndex = n + i;
      return double.parse((intercept + slope * dayIndex).toStringAsFixed(2));
    });
  }
}
