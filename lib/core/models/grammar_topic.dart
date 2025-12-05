/// GrammarTopic - Entity สำหรับหัวข้อไวยากรณ์หนึ่งหัวข้อ
library;

import 'package:equatable/equatable.dart';
import 'grammar_example.dart';
import 'question.dart';

class GrammarTopic extends Equatable {
  final String id;
  final String title;                    // ชื่อหัวข้อ เช่น "Present Perfect"
  final String explanation;              // สรุปหลักการ
  final List<GrammarExample> examples;   // ประโยคตัวอย่าง
  final List<Question> quizQuestions;    // mini quiz ท้ายบท

  const GrammarTopic({
    required this.id,
    required this.title,
    required this.explanation,
    required this.examples,
    required this.quizQuestions,
  });

  factory GrammarTopic.fromJson(Map<String, dynamic> json) {
    return GrammarTopic(
      id: json['id'] as String,
      title: json['title'] as String,
      explanation: json['explanation'] as String,
      examples: (json['examples'] as List)
          .map((e) => GrammarExample.fromJson(e as Map<String, dynamic>))
          .toList(),
      quizQuestions: (json['quizQuestions'] as List)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'explanation': explanation,
      'examples': examples.map((e) => e.toJson()).toList(),
      'quizQuestions': quizQuestions.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, title, explanation, examples, quizQuestions];
}
