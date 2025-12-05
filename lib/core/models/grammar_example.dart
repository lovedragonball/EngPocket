/// GrammarExample - Entity สำหรับตัวอย่างประโยคในไวยากรณ์
library;

import 'package:equatable/equatable.dart';

class GrammarExample extends Equatable {
  final String sentenceEn;    // ประโยคภาษาอังกฤษ
  final String sentenceTh;    // คำแปลภาษาไทย
  final String? highlight;    // ส่วนที่ต้องการเน้น (optional)

  const GrammarExample({
    required this.sentenceEn,
    required this.sentenceTh,
    this.highlight,
  });

  factory GrammarExample.fromJson(Map<String, dynamic> json) {
    return GrammarExample(
      sentenceEn: json['sentenceEn'] as String,
      sentenceTh: json['sentenceTh'] as String,
      highlight: json['highlight'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sentenceEn': sentenceEn,
      'sentenceTh': sentenceTh,
      'highlight': highlight,
    };
  }

  @override
  List<Object?> get props => [sentenceEn, sentenceTh, highlight];
}
