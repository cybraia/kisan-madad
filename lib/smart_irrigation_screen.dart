import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/mock_sensor_data.dart';

class SmartIrrigationScreen extends StatefulWidget {
  const SmartIrrigationScreen({super.key});

  @override
  State<SmartIrrigationScreen> createState() => _SmartIrrigationScreenState();
}

class _SmartIrrigationScreenState extends State<SmartIrrigationScreen> {
  SensorData? _currentData;
  List<String> _recommendations = [];
  bool _loading = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    _generateMockData();
  }

  void _generateMockData() {
    setState(() {
      _loading = true;
    });

    // Simulate sensor reading delay
    Future.delayed(const Duration(seconds: 1), () {
      final mockData = MockSensorData.getRandomData();
      final recommendations = _analyzeData(mockData);

      setState(() {
        _currentData = mockData;
        _recommendations = recommendations;
        _loading = false;
      });
    });
  }

  List<String> _analyzeData(SensorData data) {
    final recommendations = <String>[];

    // Soil Moisture Analysis
    if (data.soilMoisture < 30) {
      if (data.weather.toLowerCase().contains('rain')) {
        recommendations.add(
          'मिट्टी सूखी है, लेकिन बारिश की संभावना है — सिंचाई में देरी करें।',
        );
        recommendations.add(
          'Soil is dry, but rain is expected — delay irrigation.',
        );
      } else {
        recommendations.add('मिट्टी सूखी है — तुरंत सिंचाई करें।');
        recommendations.add('Soil is dry — irrigate immediately.');
      }
    } else if (data.soilMoisture > 70) {
      recommendations.add('मिट्टी में नमी अधिक है — सिंचाई रोकें।');
      recommendations.add('Soil moisture is high — stop irrigation.');
    } else {
      recommendations.add('मिट्टी की नमी सामान्य है।');
      recommendations.add('Soil moisture is normal.');
    }

    // pH Analysis
    if (data.ph < 6.0) {
      recommendations.add(
        'pH कम है (${data.ph}) — चूना डालकर पोषक तत्व संतुलित करें।',
      );
      recommendations.add(
        'pH is low (${data.ph}) — apply lime to balance nutrients.',
      );
    } else if (data.ph > 7.5) {
      recommendations.add('pH अधिक है (${data.ph}) — जैविक खाद का उपयोग करें।');
      recommendations.add('pH is high (${data.ph}) — use organic manure.');
    } else {
      recommendations.add('pH स्तर उचित है (${data.ph})।');
      recommendations.add('pH level is appropriate (${data.ph}).');
    }

    // Temperature Analysis
    if (data.temperature > 35) {
      recommendations.add(
        'तापमान अधिक है (${data.temperature}°C) — छाया और पानी का ध्यान रखें।',
      );
      recommendations.add(
        'Temperature is high (${data.temperature}°C) — provide shade and water.',
      );
    } else if (data.temperature < 15) {
      recommendations.add(
        'तापमान कम है (${data.temperature}°C) — फसल को ठंड से बचाएं।',
      );
      recommendations.add(
        'Temperature is low (${data.temperature}°C) — protect crops from cold.',
      );
    }

    // Humidity Analysis
    if (data.humidity > 80) {
      recommendations.add(
        'आर्द्रता अधिक है (${data.humidity}%) — फंगल रोगों से सावधान रहें।',
      );
      recommendations.add(
        'Humidity is high (${data.humidity}%) — beware of fungal diseases.',
      );
    } else if (data.humidity < 40) {
      recommendations.add(
        'आर्द्रता कम है (${data.humidity}%) — पत्तियों पर पानी छिड़कें।',
      );
      recommendations.add(
        'Humidity is low (${data.humidity}%) — spray water on leaves.',
      );
    }

    // Weather-based recommendations
    if (data.weather.toLowerCase().contains('storm')) {
      recommendations.add('तूफान की चेतावनी — फसल को सुरक्षित करें।');
      recommendations.add('Storm warning — secure your crops.');
    } else if (data.weather.toLowerCase().contains('sunny')) {
      recommendations.add('धूप अधिक है — पानी का विशेष ध्यान रखें।');
      recommendations.add('Sunny weather — pay special attention to water.');
    }

    return recommendations;
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
          bottom: false,
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
                            '💧 स्मार्ट सिंचाई',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Smart Irrigation & Crop Care',
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'सेंसर डेटा विश्लेषण',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const Text(
                          'Sensor Data Analysis',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Refresh Button
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
                              onTap: _loading ? null : _generateMockData,
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
                                            Icons.refresh,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'नया डेटा प्राप्त करें',
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

                        // Sensor Data Display
                        if (_currentData != null) ...[
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
                                const Text(
                                  '📊 वर्तमान सेंसर डेटा',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                                const Text(
                                  'Current Sensor Data',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildSensorRow(
                                  '🌱 मिट्टी की नमी',
                                  'Soil Moisture',
                                  '${_currentData!.soilMoisture}%',
                                  _getMoistureColor(_currentData!.soilMoisture),
                                ),
                                _buildSensorRow(
                                  '🌡️ तापमान',
                                  'Temperature',
                                  '${_currentData!.temperature}°C',
                                  _getTemperatureColor(
                                    _currentData!.temperature,
                                  ),
                                ),
                                _buildSensorRow(
                                  '💧 आर्द्रता',
                                  'Humidity',
                                  '${_currentData!.humidity}%',
                                  _getHumidityColor(_currentData!.humidity),
                                ),
                                _buildSensorRow(
                                  '🧪 pH स्तर',
                                  'pH Level',
                                  '${_currentData!.ph}',
                                  _getPhColor(_currentData!.ph),
                                ),
                                _buildSensorRow(
                                  '🌤️ मौसम',
                                  'Weather',
                                  _currentData!.weather,
                                  const Color(0xFF2196F3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Recommendations
                          const Text(
                            '🤖 स्मार्ट सिफारिशें',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const Text(
                            'Smart Recommendations',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          ..._recommendations
                              .map(
                                (recommendation) => Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFF8E1),
                                        Color(0xFFFFF3E0),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFFF9800,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFFF9800,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.lightbulb,
                                          color: Color(0xFFFF9800),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          recommendation,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF795548),
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
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

  Widget _buildSensorRow(
    String label,
    String subtitle,
    String value,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getSensorIcon(label), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSensorIcon(String label) {
    if (label.contains('नमी')) return Icons.water_drop;
    if (label.contains('तापमान')) return Icons.thermostat;
    if (label.contains('आर्द्रता')) return Icons.opacity;
    if (label.contains('pH')) return Icons.science;
    if (label.contains('मौसम')) return Icons.cloud;
    return Icons.sensors;
  }

  Color _getMoistureColor(double moisture) {
    if (moisture < 30) return const Color(0xFFF44336); // Red
    if (moisture > 70) return const Color(0xFF2196F3); // Blue
    return const Color(0xFF4CAF50); // Green
  }

  Color _getTemperatureColor(double temp) {
    if (temp > 35) return const Color(0xFFF44336); // Red
    if (temp < 15) return const Color(0xFF2196F3); // Blue
    return const Color(0xFF4CAF50); // Green
  }

  Color _getHumidityColor(double humidity) {
    if (humidity > 80) return const Color(0xFF2196F3); // Blue
    if (humidity < 40) return const Color(0xFFFF9800); // Orange
    return const Color(0xFF4CAF50); // Green
  }

  Color _getPhColor(double ph) {
    if (ph < 6.0) return const Color(0xFFF44336); // Red
    if (ph > 7.5) return const Color(0xFFFF9800); // Orange
    return const Color(0xFF4CAF50); // Green
  }
}
