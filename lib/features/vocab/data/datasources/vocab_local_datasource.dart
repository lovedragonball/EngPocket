/// Vocab Local Datasource - อ่าน/เขียน vocab จาก JSON และ local storage
library;

import '../../../../core/models/vocab_item.dart';
import '../../../../core/utils/asset_loader.dart';
import '../../../../config/app_config.dart';

abstract class VocabLocalDatasource {
  Future<List<VocabItem>> getAllVocab();
  Future<List<VocabItem>> getVocabByPack(String packId);
  Future<VocabItem?> getVocabById(String id);
}

class VocabLocalDatasourceImpl implements VocabLocalDatasource {
  List<VocabItem>? _cachedVocab;

  @override
  Future<List<VocabItem>> getAllVocab() async {
    if (_cachedVocab != null) return _cachedVocab!;
    
    _cachedVocab = await AssetLoader.loadAndTransform(
      AppConfig.defaultVocabPack,
      VocabItem.fromJson,
    );
    
    return _cachedVocab!;
  }

  @override
  Future<List<VocabItem>> getVocabByPack(String packId) async {
    final allVocab = await getAllVocab();
    return allVocab.where((v) => v.packId == packId).toList();
  }

  @override
  Future<VocabItem?> getVocabById(String id) async {
    final allVocab = await getAllVocab();
    try {
      return allVocab.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }
  
  /// Clear cache (เรียกเมื่อต้องการ reload)
  void clearCache() {
    _cachedVocab = null;
  }
}
