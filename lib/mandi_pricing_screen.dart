import 'package:flutter/material.dart';
import 'mandi_pricing.dart';

class MandiPricingScreen extends StatefulWidget {
  const MandiPricingScreen({super.key});

  @override
  State<MandiPricingScreen> createState() => _MandiPricingScreenState();
}

class _MandiPricingScreenState extends State<MandiPricingScreen> {
  final _commodityController = TextEditingController(text: 'Wheat');
  final _stateController = TextEditingController(text: 'Uttar Pradesh');
  final _districtController = TextEditingController(text: 'Agra');
  final _dateController = TextEditingController(text: '2025-07');
  bool _loading = false;
  String? _error;
  List<MandiPrice> _prices = [];
  List<double> _forecast = [];

  Future<void> _fetchPrices() async {
    setState(() {
      _loading = true;
      _error = null;
      _prices = [];
      _forecast = [];
    });
    try {
      final prices = await MandiPricingService.fetchMandiPrices(
        apiKey: String.fromEnvironment(
          'DATA_GOV_API_KEY',
          defaultValue: 'YOUR_DATA_GOV_API_KEY_HERE',
        ),
        commodity: _commodityController.text,
        state: _stateController.text,
        district: _districtController.text,
        limit: 10,
        arrivalDate: _dateController.text, // filter for July 2025
      );
      final forecast = MandiPricingService.forecastPrices(prices, daysAhead: 7);
      setState(() {
        _prices = prices;
        _forecast = forecast;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50), Color(0xFF8BC34A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Expanded(
                      child: Column(
                        children: [
                          Text(
                            '📊 मंडी भाव',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Market Prices',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'फसल भाव जानकारी',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const Text(
                          'Crop Price Information',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Input Fields
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE8F5E8), Color(0xFFF1F8E9)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildInputField(
                                controller: _commodityController,
                                label: 'फसल',
                                hint: 'Crop (e.g., Wheat)',
                                icon: Icons.agriculture,
                              ),
                              const SizedBox(height: 16),
                              _buildInputField(
                                controller: _stateController,
                                label: 'राज्य',
                                hint: 'State (e.g., Uttar Pradesh)',
                                icon: Icons.location_on,
                              ),
                              const SizedBox(height: 16),
                              _buildInputField(
                                controller: _districtController,
                                label: 'जिला',
                                hint: 'District (e.g., Agra)',
                                icon: Icons.location_city,
                              ),
                              const SizedBox(height: 16),
                              _buildInputField(
                                controller: _dateController,
                                label: 'तारीख',
                                hint: 'Date (YYYY-MM)',
                                icon: Icons.calendar_today,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Fetch Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E7D32).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _loading ? null : _fetchPrices,
                              borderRadius: BorderRadius.circular(16),
                              child: Center(
                                child: _loading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'भाव जानकारी प्राप्त करें',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error Display
                        if (_error != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFF44336).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFF44336),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Color(0xFFF44336),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Results
                        if (_prices.isNotEmpty || _forecast.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_prices.isNotEmpty) ...[
                                    _buildSectionHeader(
                                      '📈 हाल के भाव',
                                      'Recent Prices',
                                    ),
                                    const SizedBox(height: 16),
                                    ..._prices.map((p) => _buildPriceCard(p)),
                                    const SizedBox(height: 24),
                                  ],
                                  if (_forecast.isNotEmpty) ...[
                                    _buildSectionHeader(
                                      '🔮 भविष्यवाणी',
                                      'Forecast (Next 7 Days)',
                                    ),
                                    const SizedBox(height: 16),
                                    ..._forecast.asMap().entries.map(
                                      (e) => _buildForecastCard(
                                        e.key + 1,
                                        e.value,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF4CAF50),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(MandiPrice price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFF3E0)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Color(0xFF795548),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                price.arrivalDate,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF795548),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceInfo(
                'मोडल भाव',
                'Modal Price',
                '₹${price.modalPrice}',
              ),
              _buildPriceInfo('न्यूनतम', 'Min', '₹${price.minPrice}'),
              _buildPriceInfo('अधिकतम', 'Max', '₹${price.maxPrice}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(String label, String subtitle, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF795548)),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 10, color: Color(0xFF8D6E63)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastCard(int day, double price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E8), Color(0xFFF1F8E9)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.trending_up,
              color: Color(0xFF2E7D32),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'दिन $day',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Text(
                  'Day $day',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}
