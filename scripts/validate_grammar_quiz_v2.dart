/// Grammar Quiz Validator V2
/// ตรวจสอบข้อสอบ grammar - แก้ไข false positive แล้ว
library;

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main() async {
  print('=' * 60);
  print('Grammar Quiz Validation Report V2');
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

  var totalQuestions = 0;
  var issueCount = 0;
  final allIssues = <Map<String, dynamic>>[];

  for (final file in files) {
    final content = file.readAsStringSync();
    final data = jsonDecode(content) as Map<String, dynamic>;
    final fileName = file.path.split(Platform.pathSeparator).last;

    var fileCount = 0;
    var fileIssues = 0;

    for (final difficulty in ['easy', 'medium', 'hard']) {
      if (data[difficulty] != null) {
        final questions = data[difficulty] as List<dynamic>;
        fileCount += questions.length;

        for (final q in questions) {
          final question = q as Map<String, dynamic>;
          final issues = validateQuestion(question, fileName, difficulty);

          if (issues.isNotEmpty) {
            fileIssues++;
            allIssues.add({
              'id': question['id'] ?? 'unknown',
              'file': fileName,
              'difficulty': difficulty,
              'stem': question['stem'] ?? '',
              'choices': question['choices'] ?? [],
              'correctIndex': question['correctIndex'] ?? 0,
              'issues': issues,
            });
          }
        }
      }
    }

    totalQuestions += fileCount;
    issueCount += fileIssues;
    print('$fileName: $fileCount questions, $fileIssues issues');
  }

  print('\n${'=' * 60}');
  print('Total: $totalQuestions questions');
  print('Real issues found: $issueCount questions with problems');
  print('=' * 60);

  if (allIssues.isNotEmpty) {
    // Group issues by type
    final issueTypes = <String, int>{};
    for (final item in allIssues) {
      for (final issue in item['issues'] as List<String>) {
        issueTypes[issue] = (issueTypes[issue] ?? 0) + 1;
      }
    }

    print('\n=== Issue Summary ===\n');
    final sortedIssues = issueTypes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final entry in sortedIssues) {
      print('  - ${entry.key}: ${entry.value}');
    }

    // Print detailed issues (first 50)
    print('\n${'=' * 60}');
    print('Detailed Issues (first 50):');
    print('=' * 60);

    for (var i = 0; i < allIssues.length && i < 50; i++) {
      final item = allIssues[i];
      final choices = item['choices'] as List<dynamic>;
      final correctIdx = item['correctIndex'] as int;
      final correctAnswer =
          correctIdx < choices.length ? choices[correctIdx] : 'N/A';

      print('\n${i + 1}. [${item['file']}] ${item['id']}');
      print('   Difficulty: ${item['difficulty']}');
      print('   Stem: ${item['stem']}');
      print('   Answer: $correctAnswer');
      for (final issue in item['issues'] as List<String>) {
        print('   ⚠️ $issue');
      }
    }

    // Save full report
    final reportFile = File('scripts/grammar_issues_report_v2.json');
    reportFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(allIssues));
    print('\n\nFull report saved to: ${reportFile.path}');
    print('Total real issues: ${allIssues.length}');
  } else {
    print('\n✅ No issues found!');
  }
}

List<String> validateQuestion(
    Map<String, dynamic> question, String fileName, String difficulty) {
  final issues = <String>[];

  // Check required fields
  final requiredFields = [
    'stem',
    'choices',
    'correctIndex',
    'explanation',
    'id'
  ];
  for (final field in requiredFields) {
    if (!question.containsKey(field)) {
      issues.add('Missing field: $field');
    }
  }

  final stem = question['stem'] as String? ?? '';
  final choices = question['choices'] as List<dynamic>? ?? [];
  final correctIndex = question['correctIndex'] as int? ?? 0;

  // Check choices count
  if (choices.length != 4) {
    issues.add('Expected 4 choices, got ${choices.length}');
  }

  // Check correctIndex range
  if (correctIndex < 0 || correctIndex >= choices.length) {
    issues.add(
        'Invalid correctIndex: $correctIndex (choices: ${choices.length})');
    return issues;
  }

  // Check blank placeholder
  if (!stem.contains('_____') && !stem.contains('____')) {
    issues.add('Stem missing blank placeholder');
  }

  // Check double spaces
  if (stem.contains('  ')) {
    issues.add('Double spaces in stem');
  }

  // Get correct answer and create full sentence
  final correctAnswer = choices[correctIndex].toString();
  final fullSentence =
      stem.replaceAll('_____', correctAnswer).replaceAll('____', correctAnswer);
  final fullLower = fullSentence.toLowerCase();

  // Check REAL semantic issues only
  issues.addAll(checkRealSemanticIssues(fullLower, stem, correctAnswer));

  return issues;
}

List<String> checkRealSemanticIssues(
    String fullSentence, String stem, String answer) {
  final issues = <String>[];

  // ===== REAL PROBLEM 1: Someone acting on someone ELSE's body parts =====
  // Pattern: Third person + closes/opens my/your (eyes/ears/mouth/nose)
  final weirdBodyParts = RegExp(
    r'(he|she|my father|my mother|the teacher|john|mary|tom|lisa|david|sarah|the man|the woman|the boy|the girl|the chef|the manager|the doctor|the nurse|the artist|my brother|my sister|my boss|my uncle|my aunt|the driver|the pilot|the student|the engineer|the lawyer|the girls|the boys|the students|the teachers|the workers|the doctors|the engineers|the artists|my colleagues|the nurses|my parents|my friends|the children|people|many people|we|they|you|tom and mary)\s+\w+\s+(my|your)\s+(eyes|ears|mouth|nose|hand|hands|arm|arms|leg|legs)',
    caseSensitive: false,
  );
  if (weirdBodyParts.hasMatch(fullSentence)) {
    issues.add('Semantic: Third person acting on someone else\'s body parts');
  }

  // ===== REAL PROBLEM 2: Conflicting time expressions =====
  // "on weekends every day" - these CONFLICT
  if (fullSentence.contains('on weekends every day') ||
      fullSentence.contains('every day on weekends') ||
      fullSentence.contains('on mondays every day') ||
      fullSentence.contains('every day on mondays') ||
      fullSentence.contains('every weekend every day') ||
      fullSentence.contains('every day every weekend')) {
    issues.add('Semantic: Conflicting time expressions');
  }

  // ===== REAL PROBLEM 3: Literally duplicate phrases =====
  // "every weekend every weekend" or "every day every day"
  if (RegExp(
          r'(every weekend|every day|every morning|every evening|every week|every month)\s+\1',
          caseSensitive: false)
      .hasMatch(fullSentence)) {
    issues.add('Semantic: Duplicate time phrase');
  }

  // ===== REAL PROBLEM 4: "on weekends" + "every weekend" together =====
  if (fullSentence.contains('on weekends') &&
      fullSentence.contains('every weekend')) {
    issues.add(
        'Semantic: Redundant weekend expressions (on weekends + every weekend)');
  }

  // ===== REAL PROBLEM 5: Multiple DIFFERENT time phrases that conflict =====
  // "every morning every weekend" - morning and weekend don't conflict, skip
  // "twice a week every day" - these conflict
  if ((fullSentence.contains('twice a week') ||
          fullSentence.contains('once a month')) &&
      (fullSentence.contains('every day') ||
          fullSentence.contains('every morning') ||
          fullSentence.contains('every evening'))) {
    issues.add('Semantic: Conflicting frequency expressions');
  }

  // ===== REAL PROBLEM 6: Past tense marker with present simple verb =====
  // "yesterday he eats" - tense mismatch
  final pastMarkers = [
    'yesterday',
    'last night',
    'last week',
    'last month',
    'last year',
    'ago'
  ];
  final hasPastMarker = pastMarkers.any((m) => fullSentence.contains(m));
  if (hasPastMarker && fileName.contains('present_simple')) {
    issues.add('Semantic: Past time marker in present simple tense question');
  }

  return issues;
}

// Note: We're NOT checking "every weekend" alone as it's valid
// Note: We're NOT checking "Tom and Mary" + base verb as it's correct (they = plural)
String fileName = ''; // Global for checking tense
