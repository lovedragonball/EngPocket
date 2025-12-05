/// VocabItem - Entity สำหรับเก็บคำศัพท์
/// 
/// ใช้สำหรับ Vocab Pocket feature
/// รองรับการเก็บคำศัพท์พร้อมตัวอย่างประโยค และ tags สำหรับ filtering
library;

import 'package:equatable/equatable.dart';

class VocabItem extends Equatable {
  final String id;
  final String word;
  final String translation;      // แปลไทย
  final String partOfSpeech;     // noun, verb, adj ฯลฯ
  final String exampleEn;        // ประโยคตัวอย่างภาษาอังกฤษ
  final String exampleTh;        // ประโยคแปลไทย
  final String level;            // basic / intermediate / advanced
  final String packId;           // อยู่ในแพ็กไหน (เช่น TGAT_V1)
  final List<String> tags;       // เช่น ["TGAT", "health"]

  const VocabItem({
    required this.id,
    required this.word,
    required this.translation,
    required this.partOfSpeech,
    required this.exampleEn,
    required this.exampleTh,
    required this.level,
    required this.packId,
    required this.tags,
  });

  /// สร้าง VocabItem จาก JSON Map
  factory VocabItem.fromJson(Map<String, dynamic> json) {
    return VocabItem(
      id: json['id'] as String,
      word: json['word'] as String,
      translation: json['translation'] as String,
      partOfSpeech: json['partOfSpeech'] as String,
      exampleEn: json['exampleEn'] as String,
      exampleTh: json['exampleTh'] as String,
      level: json['level'] as String,
      packId: json['packId'] as String,
      tags: List<String>.from(json['tags'] as List),
    );
  }

  /// แปลง VocabItem เป็น JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'partOfSpeech': partOfSpeech,
      'exampleEn': exampleEn,
      'exampleTh': exampleTh,
      'level': level,
      'packId': packId,
      'tags': tags,
    };
  }

  @override
  List<Object?> get props => [id, word, translation, partOfSpeech, 
                               exampleEn, exampleTh, level, packId, tags];
}
