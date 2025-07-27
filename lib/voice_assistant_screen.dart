import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:multipart/multipart.dart';
import 'utils/constants.dart';

/// =======================
///  CONFIG
/// =======================

const String SARVAM_API_KEY = 'sk_hjzi5sl7_q3jzt8V1uZ84XvmT8XF8DgaY';
const String GEMINI_API_KEY = geminiApiKey; 

// Endpoints
const String SARVAM_STT_URL = 'https://api.sarvam.ai/speech-to-text';

// Languages you want to use
const String SOURCE_LANGUAGE = 'hi-IN'; // what user speaks
const String TARGET_LANGUAGE = 'en-IN'; // translated to (for STT)

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  String _status = 'डिफ़ॉल्ट ऑडियो से ट्रांसक्रिप्शन प्राप्त करें';
  String _transcription = '';
  String _aiResponse = '';

  // Path to the default audio asset (must be added to pubspec.yaml under assets)
  final String _defaultAudioAsset = 'assets/default_audio.wav';

  /// =======================
  ///  DEFAULT AUDIO STT + GEMINI AI
  /// =======================
  Future<void> _processDefaultAudio() async {
    try {
      setState(() => _status = 'डिफ़ॉल्ट ऑडियो प्रोसेस हो रहा है...');

      // Load audio from assets
      final ByteData data = await rootBundle.load(_defaultAudioAsset);
      final bytes = data.buffer.asUint8List();
      debugPrint('Default audio bytes: ${bytes.length}');

      // Create multipart request using http package
      final uri = Uri.parse(SARVAM_STT_URL);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['api-subscription-key'] = SARVAM_API_KEY;

      // Add fields
      request.fields['source_language_code'] = SOURCE_LANGUAGE;
      request.fields['target_language_code'] = TARGET_LANGUAGE;

      // Add file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'default_audio.wav',
          contentType: MediaType('audio', 'wav'),
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('STT status: ${response.statusCode}');
      debugPrint('STT response: ${response.body}');

      if (response.statusCode != 200) {
        setState(() => _status = 'STT failed: ${response.statusCode}');
        return;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final transcript = body['transcript'] as String? ?? '';

      setState(() {
        _transcription = transcript;
        _status = 'ट्रांसक्रिप्शन पूरा हुआ! AI जवाब प्राप्त कर रहा है...';
      });

      // Get AI response from Gemini
      if (transcript.isNotEmpty) {
        await _getAIResponse(transcript);
      }
    } catch (e) {
      setState(() => _status = 'Error: $e');
      debugPrint('Error in _processDefaultAudio: $e');
    }
  }

  /// =======================
  ///  GEMINI AI RESPONSE
  /// =======================
  Future<void> _getAIResponse(String transcript) async {
    try {
      setState(() => _status = 'AI जवाब प्राप्त कर रहा है...');

      final endpoint =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$GEMINI_API_KEY';

      final prompt =
          'User asked in Hindi: "$transcript". Please provide a helpful response in Hindi ONLY. Keep it simple and practical for a farmer. Reply in about 100 words.';

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
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint('Gemini status: ${response.statusCode}');
      debugPrint('Gemini response: ${response.body}');

      if (response.statusCode != 200) {
        setState(() => _status = 'AI response failed: ${response.statusCode}');
        return;
      }

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = responseBody['candidates'] as List?;

      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates.first['content'] as Map<String, dynamic>;
        final parts = content['parts'] as List;
        final text = parts.first['text'] as String;

        setState(() {
          _aiResponse = text;
          _status = 'जवाब तैयार है!';
        });
      } else {
        setState(() => _status = 'AI से जवाब नहीं मिला');
      }
    } catch (e) {
      setState(() => _status = 'AI Error: $e');
      debugPrint('Error in _getAIResponse: $e');
    }
  }

  /// =======================
  ///  UI
  /// =======================
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
                            '🎤 आवाज सहायक',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Voice Assistant',
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
                      children: [
                        // Status Card
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
                                Icons.mic,
                                size: 48,
                                color: Color(0xFF2E7D32),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _status,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Button to process default audio
                        GestureDetector(
                          onTap: _processDefaultAudio,
                          child: Container(
                            width: 180,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2E7D32,
                                  ).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'ऑडियो प्रोसेस करें',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Transcription
                        if (_transcription.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFF8E1), Color(0xFFFFF3E0)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFF9800).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '🎯 आपका सवाल',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF795548),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _transcription,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF795548),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // AI Response
                        if (_aiResponse.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE3F2FD), Color(0xFFE1F5FE)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2196F3).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '🤖 AI जवाब',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _aiResponse,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1976D2),
                                    height: 1.5,
                                  ),
                                ),
                              ],
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
