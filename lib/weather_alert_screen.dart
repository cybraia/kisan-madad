import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_ai/firebase_ai.dart';
import 'utils/constants.dart';

class WeatherAlertScreen extends StatefulWidget {
  const WeatherAlertScreen({super.key});

  @override
  State<WeatherAlertScreen> createState() => _WeatherAlertScreenState();
}

class _WeatherAlertScreenState extends State<WeatherAlertScreen> {
  String? _weatherInfo;
  String? _advisory;
  bool _loading = false;

  Future<void> _fetchWeather() async {
    setState(() {
      _loading = true;
      _advisory = null;
    });
    final lat = 13.0609576;
    final lon = 77.4737607;
    final url =
        'https://weather.googleapis.com/v1/currentConditions:lookup?key=AIzaSyBkoY7iDr9qmjhaN1A9-kT0FSCBgOP6qLY&location.latitude=$lat&location.longitude=$lon';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _weatherInfo = jsonEncode(data);
        });
        // Call Gemini API for advisory
        await _getGeminiAdvisory(data);
      } else {
        setState(() {
          _weatherInfo = 'Error: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _weatherInfo = 'Error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _getGeminiAdvisory(dynamic weatherData) async {
    try {
      final endpoint =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=';
      final prompt =
          'Given this weather data: ${jsonEncode(weatherData)}, give actionable advice for a farmer in rural India. Should they irrigate today? Should they spray pesticide? What are the risks? Reply in simple HINDI language.Give in hindi literals Give reply in about 100 words ONLY';
      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
      });
      final response = await http.post(
        Uri.parse(endpoint + geminiApiKey),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text']?.trim() ??
            '';

        if (text.isNotEmpty) {
          // Translate the advisory using Sarvam AI API
          final translationResponse = await http.post(
            Uri.parse('https://api.sarvam.ai/translate'),
            headers: {
              'api-subscription-key': 'sk_hjzi5sl7_q3jzt8V1uZ84XvmT8XF8DgaY',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'input': text,
              'source_language_code': 'auto',
              'target_language_code': 'hi-IN',
            }),
          );

          if (translationResponse.statusCode == 200) {
            final translationData = jsonDecode(translationResponse.body);
            final translatedText = translationData['output']?.trim() ?? text;
            // debugPrint('Translated Text: $translatedText');
            // debugPrint('Translation Text: $translationData');
            setState(() {
              _advisory = translatedText; // Ensure Hindi content is displayed
              _loading = false;
            });
          } else {
            setState(() {
              _advisory = 'Translation error: ${translationResponse.body}';
              _loading = false;
            });
          }
        } else {
          setState(() {
            _advisory = 'No advisory found.';
            _loading = false;
          });
        }
      } else {
        setState(() {
          _advisory = 'Gemini API error: ${response.body}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _advisory = 'Error: $e';
        _loading = false;
      });
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
                            '🌤️ मौसम सलाह',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Weather Advisory',
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Weather Info Card
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
                              const Icon(
                                Icons.cloud,
                                size: 48,
                                color: Color(0xFF2E7D32),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'आज का मौसम',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const Text(
                                'Today\'s Weather',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Get Weather Button
                        Container(
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
                              onTap: _loading ? null : _fetchWeather,
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
                                            'मौसम जानकारी प्राप्त करें',
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

                        // Advisory Section
                        if (_advisory != null) ...[
                          const Text(
                            '🌾 किसान सलाह',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const Text(
                            'Farmer\'s Advisory',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFF8E1),
                                    Color(0xFFFFF3E0),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(
                                    0xFFFF9800,
                                  ).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  _advisory!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Color(0xFF795548),
                                  ),
                                ),
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
}
