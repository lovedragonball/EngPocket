/// Reading Repository - Load reading passages from JSON
library;

import 'dart:convert';
import 'package:flutter/services.dart';

class ReadingRepository {
  static final ReadingRepository _instance = ReadingRepository._internal();
  factory ReadingRepository() => _instance;
  ReadingRepository._internal();

  List<Map<String, dynamic>>? _passages;

  /// Initialize and load passages from JSON
  Future<void> init() async {
    if (_passages != null) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/reading_passages.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      _passages = jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      _passages = [];
    }
  }

  /// Get all passages
  List<Map<String, dynamic>> getAllPassages() {
    return _passages ?? [];
  }

  /// Get passage by ID
  Map<String, dynamic>? getPassageById(String id) {
    if (_passages == null) return null;
    try {
      return _passages!.firstWhere((p) => p['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Get passages filtered by topic
  List<Map<String, dynamic>> getPassagesByTopic(String topic) {
    if (_passages == null) return [];
    if (topic == 'all') return _passages!;
    return _passages!.where((p) => p['topic'] == topic).toList();
  }

  /// Get unique topics
  List<String> getTopics() {
    if (_passages == null) return [];
    final topics = _passages!.map((p) => p['topic'] as String).toSet().toList();
    return ['all', ...topics];
  }
}
