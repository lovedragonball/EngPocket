/// Asset loader utility for loading JSON data from assets
library;

import 'dart:convert';
import 'package:flutter/services.dart';

class AssetLoader {
  AssetLoader._();

  /// โหลด JSON จาก assets แล้วแปลงเป็น List<Map>
  static Future<List<Map<String, dynamic>>> loadJsonList(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = json.decode(jsonString) as List;
      return jsonData.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw AssetLoadException('Failed to load $assetPath: $e');
    }
  }

  /// โหลด JSON จาก assets แล้วแปลงเป็น Map
  static Future<Map<String, dynamic>> loadJsonMap(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw AssetLoadException('Failed to load $assetPath: $e');
    }
  }

  /// โหลด JSON พร้อม transform ด้วย fromJson function
  static Future<List<T>> loadAndTransform<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final jsonList = await loadJsonList(assetPath);
    return jsonList.map((json) => fromJson(json)).toList();
  }
}

class AssetLoadException implements Exception {
  final String message;
  AssetLoadException(this.message);
  
  @override
  String toString() => 'AssetLoadException: $message';
}
