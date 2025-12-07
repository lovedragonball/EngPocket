/// Grammar Quiz Validator
/// ตรวจสอบข้อสอบ grammar ว่ามีข้อไหนไม่ถูกต้องบ้าง
library;

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main() async {
  print('=' * 60);
  print('Grammar Quiz Validation Report');
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
  print('Issues found: $issueCount questions with problems');
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

    // Print detailed issues (first 100)
    print('\n${'=' * 60}');
    print('Detailed Issues (first 100):');
    print('=' * 60);

    for (var i = 0; i < allIssues.length && i < 100; i++) {
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
    final reportFile = File('scripts/grammar_issues_report.json');
    reportFile.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(allIssues));
    print('\n\nFull report saved to: ${reportFile.path}');
    print('Total issues to review: ${allIssues.length}');
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

  // Semantic checks for weird sentences
  issues.addAll(checkSemanticIssues(fullLower, stem, correctAnswer));

  // Check subject-verb agreement
  issues.addAll(checkSubjectVerbAgreement(stem, correctAnswer, fileName));

  return issues;
}

List<String> checkSemanticIssues(
    String fullSentence, String stem, String answer) {
  final issues = <String>[];

  // Pattern: Someone closing someone else's body parts
  final weirdBodyParts = RegExp(
      r'(he|she|my father|my mother|the teacher|john|mary|tom|lisa|david|sarah|the man|the woman|the boy|the girl|the chef|the manager|the doctor|the nurse|the artist|my brother|my sister|my boss|my uncle|my aunt).*(closes?|opens?)\s+(my|your|his|her|their)\s+(eyes|ears|mouth|nose|hand|hands|arm|arms|leg|legs)');
  if (weirdBodyParts.hasMatch(fullSentence)) {
    issues.add('Semantic: Third person acting on someone else\'s body parts');
  }

  // Pattern: Strange time combinations
  if (fullSentence.contains('every day') &&
      fullSentence.contains('yesterday')) {
    issues.add('Semantic: Conflicting time markers (every day + yesterday)');
  }

  // Pattern: Double time phrases
  final timePatterns = [
    'every day',
    'every week',
    'every morning',
    'every evening',
    'every weekend',
    'every month',
    'every year',
    'on weekends',
    'on Mondays',
    'twice a week',
    'once a month'
  ];
  var timeCount = 0;
  for (final pattern in timePatterns) {
    if (fullSentence.toLowerCase().contains(pattern.toLowerCase())) {
      timeCount++;
    }
  }
  if (timeCount > 1) {
    issues.add('Semantic: Multiple time phrases in one sentence');
  }

  // Check for redundant expressions
  if (fullSentence.contains('on weekends every day')) {
    issues.add('Semantic: Redundant/conflicting time expression');
  }

  return issues;
}

List<String> checkSubjectVerbAgreement(
    String stem, String answer, String fileName) {
  final issues = <String>[];

  // Only check present simple for now
  if (!fileName.contains('present_simple')) {
    return issues;
  }

  final stemLower = stem.toLowerCase();
  final answerLower = answer.toLowerCase();

  // Singular subjects (third person)
  final singularSubjects = [
    'he ',
    'she ',
    'it ',
    'my father ',
    'my mother ',
    'my brother ',
    'my sister ',
    'my boss ',
    'my uncle ',
    'my aunt ',
    'the teacher ',
    'the chef ',
    'the manager ',
    'the engineer ',
    'the doctor ',
    'the nurse ',
    'the artist ',
    'the lawyer ',
    'the driver ',
    'the pilot ',
    'the student ',
    'the boy ',
    'the girl ',
    'the man ',
    'the woman ',
    'john ',
    'mary ',
    'tom ',
    'lisa ',
    'david ',
    'sarah ',
  ];

  // Plural subjects
  final pluralSubjects = [
    'i ',
    'you ',
    'we ',
    'they ',
    'my parents ',
    'my friends ',
    'my colleagues ',
    'the students ',
    'the teachers ',
    'the workers ',
    'the doctors ',
    'the children ',
    'the engineers ',
    'the artists ',
    'the nurses ',
    'the boys ',
    'the girls ',
    'people ',
    'many people ',
    'tom and mary ',
  ];

  // Check if subject is singular
  bool isSingular = false;
  bool isPlural = false;

  for (final subj in singularSubjects) {
    if (stemLower.startsWith(subj)) {
      isSingular = true;
      break;
    }
  }

  for (final subj in pluralSubjects) {
    if (stemLower.startsWith(subj)) {
      isPlural = true;
      break;
    }
  }

  // Common verb forms that end with 's' (V1+s)
  final verbsWithS = RegExp(
      r'^(goes|does|has|is|was|eats|drinks|cooks|speaks|writes|reads|listens|watches|plays|studies|works|walks|runs|drives|flies|buys|sells|pays|learns|teaches|meets|helps|makes|takes|gives|gets|feels|thinks|knows|likes|loves|wants|needs|starts|finishes|stops|tries|uses|opens|closes|stays|lives|waits|calls|sits|stands|arrives|leaves|visits|cleans|saves|sends)$');

  // Base form verbs (V1)
  final baseVerbs = RegExp(
      r'^(go|do|have|be|eat|drink|cook|speak|write|read|listen|watch|play|study|work|walk|run|drive|fly|buy|sell|pay|learn|teach|meet|help|make|take|give|get|feel|think|know|like|love|want|need|start|finish|stop|try|use|open|close|stay|live|wait|call|sit|stand|arrive|leave|visit|clean|save|send)$');

  if (isSingular) {
    // For singular subjects, verb should end with s/es
    if (baseVerbs.hasMatch(answerLower)) {
      issues.add(
          'Grammar: Singular subject requires verb+s (got base form "$answer")');
    }
  } else if (isPlural) {
    // For plural subjects (including I, You, We, They), verb should be base form
    if (verbsWithS.hasMatch(answerLower)) {
      // Special case: "I" should use base form
      if (stemLower.startsWith('i ')) {
        issues.add('Grammar: "I" requires base verb form (got "$answer")');
      }
    }
  }

  return issues;
}
