/// TTS Service - บริการ Text-to-Speech สำหรับออกเสียงคำศัพท์
library;

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  /// Initialize TTS engine
  Future<void> init() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.45); // Slower for learning
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
    });

    _isInitialized = true;
  }

  /// Speak the given text
  Future<void> speak(String text) async {
    if (!_isInitialized) await init();

    if (_isSpeaking) {
      await stop();
    }

    _isSpeaking = true;
    await _flutterTts.speak(text);
  }

  /// Stop speaking
  Future<void> stop() async {
    _isSpeaking = false;
    await _flutterTts.stop();
  }

  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  /// Speak a word with its example sentence
  Future<void> speakWordWithExample(String word, String example) async {
    await speak('$word. $example');
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stop();
  }
}
