/// Grammar Quiz Fixer
/// แก้ไขข้อสอบ grammar ที่มีปัญหาโดยอัตโนมัติ
library;

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main() async {
  print('=' * 60);
  print('Grammar Quiz Auto-Fix');
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
          } else if (result['action'] == 'remove') {
            fileRemoved++;
            // Don't add to fixedQuestions - effectively removing it
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
}

Map<String, dynamic> fixQuestion(
    Map<String, dynamic> question, String fileName) {
  final stem = question['stem'] as String? ?? '';
  final stemLower = stem.toLowerCase();

  // ========== Fix 1: Body parts issue (someone else's body parts) ==========
  // Pattern: Third person + my (eyes/ears/mouth/nose/hand/hands)
  final bodyPartsPattern = RegExp(
    r'^(he|she|my father|my mother|the teacher|john|mary|tom|lisa|david|sarah|the man|the woman|the boy|the girl|the chef|the manager|the doctor|the nurse|the artist|my brother|my sister|my boss|my uncle|my aunt|the driver|the pilot|the student|the engineer|the lawyer|the girls|the boys|the students|the teachers|the workers|the doctors|the engineers|the artists|my colleagues|the nurses|my parents|my friends|the children|people|many people|we|they|you|i|tom and mary)\s+_+.*\s+(my|your)\s+(eyes|ears|mouth|nose|hand|hands|arm|arms|leg|legs)',
    caseSensitive: false,
  );

  if (bodyPartsPattern.hasMatch(stemLower)) {
    // Fix: Change "my eyes" to "his/her eyes" or "their eyes"
    final singularSubjects = [
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

    String newStem = stem;

    // Determine replacement based on subject
    bool isMale = singularSubjects.any((s) => stemLower.startsWith(s));
    bool isFemale = femaleSubjects.any((s) => stemLower.startsWith(s));

    if (isMale) {
      newStem = newStem.replaceAll(
          RegExp(r'\bmy (eyes|ears|mouth|nose|hand|hands|arm|arms|leg|legs)\b',
              caseSensitive: false),
          'his \$1');
      newStem = newStem.replaceAll(
          RegExp(
              r'\byour (eyes|ears|mouth|nose|hand|hands|arm|arms|leg|legs)\b',
              caseSensitive: false),
          'his \$1');
    } else if (isFemale) {
      newStem = newStem.replaceAll(
          RegExp(r'\bmy (eyes|ears|mouth|nose|hand|hands|arm|arms|leg|legs)\b',
              caseSensitive: false),
          'her \$1');
      newStem = newStem.replaceAll(
          RegExp(
              r'\byour (eyes|ears|mouth|nose|hand|hands|arm|arms|leg|legs)\b',
              caseSensitive: false),
          'her \$1');
    } else {
      // Plural subjects
      newStem = newStem.replaceAll(
          RegExp(r'\bmy (eyes|ears|mouth|nose|hand|hands|arm|arms|leg|legs)\b',
              caseSensitive: false),
          'their \$1');
      newStem = newStem.replaceAll(
          RegExp(
              r'\byour (eyes|ears|mouth|nose|hand|hands|arm|arms|leg|legs)\b',
              caseSensitive: false),
          'their \$1');
    }

    if (newStem != stem) {
      question['stem'] = newStem;
      return {'action': 'fixed', 'question': question};
    }
  }

  // ========== Fix 2: Redundant time expressions ==========
  // Pattern: "on weekends every day" or similar conflicts
  if (stemLower.contains('on weekends every day') ||
      stemLower.contains('every day on weekends') ||
      stemLower.contains('on mondays every day') ||
      stemLower.contains('every day on mondays')) {
    // Remove the conflicting part
    String newStem = stem;
    newStem = newStem.replaceAll(
        RegExp(r'\s+on weekends\s+every day', caseSensitive: false),
        ' every day');
    newStem = newStem.replaceAll(
        RegExp(r'\s+every day\s+on weekends', caseSensitive: false),
        ' on weekends');
    newStem = newStem.replaceAll(
        RegExp(r'\s+on Mondays\s+every day', caseSensitive: false),
        ' every day');
    newStem = newStem.replaceAll(
        RegExp(r'\s+every day\s+on Mondays', caseSensitive: false),
        ' on Mondays');

    // Also fix "on weekends every weekend"
    newStem = newStem.replaceAll(
        RegExp(r'\s+on weekends\s+every weekend', caseSensitive: false),
        ' every weekend');
    newStem = newStem.replaceAll(
        RegExp(r'\s+every weekend\s+on weekends', caseSensitive: false),
        ' every weekend');

    if (newStem != stem) {
      question['stem'] = newStem;
      return {'action': 'fixed', 'question': question};
    }
  }

  // ========== Fix 3: Multiple time phrases at the end ==========
  // Detect patterns like "in the morning every weekend" or "for exercise every weekend"
  final multiTimeAtEnd = RegExp(
    r'(in the morning|in the evening|in the afternoon|in the park|for exercise|for dinner|for lunch|for breakfast|to school|to work|at home|at a hotel|at the office)\s+(every weekend|every day|every morning|every evening|every week|every month|every year|on weekends|on Mondays|twice a week|once a month)\s*[.?]?$',
    caseSensitive: false,
  );

  if (multiTimeAtEnd.hasMatch(stem)) {
    // Keep only the last time phrase
    String newStem = stem.replaceAllMapped(multiTimeAtEnd, (match) {
      return '${match.group(1)}.';
    });

    if (newStem != stem) {
      question['stem'] = newStem;
      return {'action': 'fixed', 'question': question};
    }
  }

  // ========== Fix 4: "every weekend" appears twice or with similar phrases ==========
  final weekendPatterns = [
    (
      RegExp(r'\s+every weekend\s+every weekend', caseSensitive: false),
      ' every weekend'
    ),
    (RegExp(r'\s+every day\s+every day', caseSensitive: false), ' every day'),
    (
      RegExp(r'\s+every morning\s+every morning', caseSensitive: false),
      ' every morning'
    ),
    (
      RegExp(r'\s+every evening\s+every evening', caseSensitive: false),
      ' every evening'
    ),
  ];

  for (final pattern in weekendPatterns) {
    if (pattern.$1.hasMatch(stem)) {
      final newStem = stem.replaceAll(pattern.$1, pattern.$2);
      question['stem'] = newStem;
      return {'action': 'fixed', 'question': question};
    }
  }

  // ========== Fix 5: Remove "every weekend" if there's already a specific time ==========
  // E.g., "every weekend" at end when there's already "in the park" (location, not time)
  // This is actually fine in most cases, so we'll be more selective

  // Detect: time phrase + "every weekend/every day" where time phrase is NOT a location
  final timeClash = RegExp(
    r'(every morning|every evening|every afternoon|twice a week|once a month|on Mondays|on weekends)\s+_+.*\s+(every weekend|every day|every week)\.?$',
    caseSensitive: false,
  );

  if (timeClash.hasMatch(stem)) {
    // Remove the trailing time phrase
    String newStem = stem.replaceAll(
        RegExp(r'\s+(every weekend|every day|every week)\.?$',
            caseSensitive: false),
        '.');
    if (newStem != stem) {
      question['stem'] = newStem;
      return {'action': 'fixed', 'question': question};
    }
  }

  // ========== Fix 6: Phrases that have a modifier + "every weekend" ==========
  // Pattern: "harder every weekend" -> just "harder"
  // This is valid English, so skip this fix

  // ========== Fix 7: Location + time at end ==========
  // "in the park every weekend" is valid, but "every morning every weekend" is not
  final doubleTimePattern = RegExp(
    r'\b(every morning|every evening|every afternoon|every night|twice a week|once a month|on Mondays|on Tuesdays|on Wednesdays|on Thursdays|on Fridays|on Saturdays|on Sundays).*\b(every weekend|every day|every week|every month|every year|twice a week|once a month)\s*\.?$',
    caseSensitive: false,
  );

  if (doubleTimePattern.hasMatch(stem)) {
    // Remove the last time expression
    String newStem = stem.replaceAll(
        RegExp(
            r'\s+(every weekend|every day|every week|every month|every year|twice a week|once a month)\s*\.?$',
            caseSensitive: false),
        '.');
    if (newStem != stem) {
      question['stem'] = newStem;
      return {'action': 'fixed', 'question': question};
    }
  }

  // ========== Fix 8: Specific patterns from the report ==========
  // "Chinese every weekend" - has "every weekend" when verb phrase implies frequency already
  // These are actually valid, so we keep most of them but fix obvious duplicates

  // Pattern: Simple subject + verb + object + TWO different time expressions
  // E.g., "He _____ English every weekend." where "every weekend" is redundant
  // Actually, "every weekend" alone is fine in this context

  // Let's be more specific - remove trailing "every weekend" if stem already has frequency words
  final frequencyWords = [
    'always',
    'usually',
    'often',
    'sometimes',
    'rarely',
    'never',
    'seldom',
    'frequently'
  ];
  final hasFrequencyWord =
      frequencyWords.any((w) => stemLower.contains(' $w '));

  if (hasFrequencyWord && stemLower.contains('every weekend')) {
    String newStem = stem.replaceAll(
        RegExp(r'\s+every weekend\.?$', caseSensitive: false), '.');
    if (newStem != stem) {
      question['stem'] = newStem;
      return {'action': 'fixed', 'question': question};
    }
  }

  return {'action': 'keep'};
}
