/// Grammar Quiz Fixer V2
/// แก้ไข 30 ข้อที่มีปัญหาจริง
library;

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main() async {
  print('=' * 60);
  print('Grammar Quiz Auto-Fix V2');
  print('=' * 60);

  final quizDir = Directory('assets/data/quiz');
  if (!quizDir.existsSync()) {
    print('Quiz directory not found!');
    return;
  }

  final files = quizDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.contains('grammar_quiz_'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  print('\nFound ${files.length} grammar quiz files\n');

  var totalFixed = 0;
  var totalRemoved = 0;
  final fixedDetails = <String>[];

  for (final file in files) {
    final content = file.readAsStringSync();
    final data = jsonDecode(content) as Map<String, dynamic>;
    final fileName = file.path.split(Platform.pathSeparator).last;

    var fileFixed = 0;
    var fileRemoved = 0;

    for (final difficulty in ['easy', 'medium', 'hard']) {
      if (data[difficulty] != null) {
        final questions = data[difficulty] as List<dynamic>;
        final fixedQuestions = <Map<String, dynamic>>[];

        for (final q in questions) {
          final question = Map<String, dynamic>.from(q as Map<String, dynamic>);
          final result = fixQuestion(question, fileName);

          if (result['action'] == 'keep') {
            fixedQuestions.add(question);
          } else if (result['action'] == 'fixed') {
            fixedQuestions.add(result['question'] as Map<String, dynamic>);
            fileFixed++;
            fixedDetails.add(
                'FIXED: [${question['id']}] "${question['stem']}" -> "${result['question']['stem']}"');
          } else if (result['action'] == 'remove') {
            fileRemoved++;
            fixedDetails
                .add('REMOVED: [${question['id']}] "${question['stem']}"');
          }
        }

        data[difficulty] = fixedQuestions;
      }
    }

    // Save the fixed file
    final encoder = const JsonEncoder.withIndent('  ');
    file.writeAsStringSync(encoder.convert(data));

    totalFixed += fileFixed;
    totalRemoved += fileRemoved;

    if (fileFixed > 0 || fileRemoved > 0) {
      print('$fileName: Fixed $fileFixed, Removed $fileRemoved');
    }
  }

  print('\n${'=' * 60}');
  print('Summary:');
  print('  - Total questions fixed: $totalFixed');
  print('  - Total questions removed: $totalRemoved');
  print('=' * 60);

  if (fixedDetails.isNotEmpty) {
    print('\n=== Fix Details ===\n');
    for (final detail in fixedDetails) {
      print(detail);
    }
  }
}

Map<String, dynamic> fixQuestion(
    Map<String, dynamic> question, String fileName) {
  final stem = question['stem'] as String? ?? '';
  final stemLower = stem.toLowerCase();

  // ========== Fix 1: "my eyes" -> "his/her eyes" or remove ==========
  // Pattern: Third person + verb + my/your (eyes/ears/mouth/nose)
  final bodyPartsPattern = RegExp(
    r'\b(my|your)\s+(eyes|ears|mouth|nose|hand|hands|arm|arms|leg|legs)\b',
    caseSensitive: false,
  );

  if (bodyPartsPattern.hasMatch(stemLower)) {
    // Check if subject is third person
    final thirdPersonSubjects = [
      'he ', 'she ', 'my father ', 'my mother ', 'the teacher ',
      'john ', 'mary ', 'tom ', 'lisa ', 'david ', 'sarah ',
      'the man ', 'the woman ', 'the boy ', 'the girl ',
      'the chef ', 'the manager ', 'the doctor ', 'the nurse ',
      'the artist ', 'my brother ', 'my sister ', 'my boss ',
      'my uncle ', 'my aunt ', 'the driver ', 'the pilot ',
      'the student ', 'the engineer ', 'the lawyer ',
      'the girls ', 'the boys ', 'the students ', 'the teachers ',
      'the workers ', 'the doctors ', 'the engineers ', 'the artists ',
      'my colleagues ', 'the nurses ', 'my parents ', 'my friends ',
      'the children ', 'people ', 'many people ', 'we ', 'they ',
      'you ', 'tom and mary ',
      // Question forms
      'does the ', 'did the ', 'did my ', 'did you ', 'does my ',
      'do the ', 'do my ', 'do you ',
      // Conditional forms
      'if the ', 'if my ', 'if you ', 'when the ', 'when my ', 'when you ',
      'as soon as the ', 'as soon as my ', 'as soon as he ', 'as soon as she ',
      // Complex forms
      'this is the best my eyes that',
    ];

    bool isThirdPerson = thirdPersonSubjects
        .any((s) => stemLower.startsWith(s) || stemLower.contains(' $s'));

    // Also check for patterns in the middle of sentence
    if (stemLower.contains('that') && stemLower.contains('my eyes')) {
      isThirdPerson = true;
    }

    if (isThirdPerson) {
      // Determine replacement based on subject
      String newStem = stem;

      // For sentences like "This is the best my eyes that..." - these are grammatically wrong
      // Let's fix the structure completely
      if (stemLower.contains('this is the best my eyes that')) {
        // Change "my eyes" to "thing" to make it sensible
        newStem = newStem.replaceAll(
            RegExp(r'This is the best my eyes that', caseSensitive: false),
            'This is the best thing that');
        question['stem'] = newStem;
        return {'action': 'fixed', 'question': question};
      }

      // Singular male subjects
      final maleSubjects = [
        'he',
        'my father',
        'my brother',
        'john',
        'tom',
        'david',
        'the man',
        'the boy',
        'the chef',
        'the manager',
        'the doctor',
        'the driver',
        'the pilot',
        'the student',
        'the engineer',
        'the lawyer',
        'my boss',
        'my uncle'
      ];

      // Singular female subjects
      final femaleSubjects = [
        'she',
        'my mother',
        'my sister',
        'mary',
        'lisa',
        'sarah',
        'the woman',
        'the girl',
        'the nurse',
        'my aunt'
      ];

      // Check subject type
      bool isMale = maleSubjects.any((s) =>
          stemLower.startsWith('$s ') ||
          stemLower.contains(' $s ') ||
          stemLower.contains('does $s ') ||
          stemLower.contains('did $s ') ||
          stemLower.contains('if $s ') ||
          stemLower.contains('when $s ') ||
          stemLower.contains('as soon as $s '));

      bool isFemale = femaleSubjects.any((s) =>
          stemLower.startsWith('$s ') ||
          stemLower.contains(' $s ') ||
          stemLower.contains('does $s ') ||
          stemLower.contains('did $s ') ||
          stemLower.contains('if $s ') ||
          stemLower.contains('when $s ') ||
          stemLower.contains('as soon as $s '));

      if (isMale) {
        newStem = newStem.replaceAllMapped(
            RegExp(
                r'\b(my|your)\s+(eyes|ears|mouth|nose|hand|hands|arm|arms|leg|legs)\b',
                caseSensitive: false),
            (match) => 'his ${match.group(2)}');
      } else if (isFemale) {
        newStem = newStem.replaceAllMapped(
            RegExp(
                r'\b(my|your)\s+(eyes|ears|mouth|nose|hand|hands|arm|arms|leg|legs)\b',
                caseSensitive: false),
            (match) => 'her ${match.group(2)}');
      } else {
        // Plural or unknown - use "their"
        newStem = newStem.replaceAllMapped(
            RegExp(
                r'\b(my|your)\s+(eyes|ears|mouth|nose|hand|hands|arm|arms|leg|legs)\b',
                caseSensitive: false),
            (match) => 'their ${match.group(2)}');
      }

      if (newStem != stem) {
        question['stem'] = newStem;
        return {'action': 'fixed', 'question': question};
      }
    }
  }

  // ========== Fix 2: "on weekends every weekend" -> "every weekend" ==========
  if (stemLower.contains('on weekends every weekend') ||
      stemLower.contains('on weekends') &&
          stemLower.contains('every weekend')) {
    String newStem = stem;
    newStem = newStem.replaceAll(
        RegExp(r'\s+on weekends\s+', caseSensitive: false), ' ');
    if (newStem != stem) {
      question['stem'] = newStem;
      return {'action': 'fixed', 'question': question};
    }

    // If still has both, just remove "on weekends"
    newStem = stem.replaceAll(
        RegExp(r'\s*on weekends\s*', caseSensitive: false), ' ');
    newStem =
        newStem.replaceAll(RegExp(r'\s+', caseSensitive: false), ' ').trim();
    // Ensure ending with period
    if (!newStem.endsWith('.') && !newStem.endsWith('?')) {
      newStem = '$newStem.';
    }
    if (newStem != stem) {
      question['stem'] = newStem;
      return {'action': 'fixed', 'question': question};
    }
  }

  return {'action': 'keep'};
}
