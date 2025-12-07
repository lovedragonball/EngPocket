/// Exam Home Screen
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';

class ExamHomeScreen extends StatefulWidget {
  const ExamHomeScreen({super.key});

  @override
  State<ExamHomeScreen> createState() => _ExamHomeScreenState();
}

class _ExamHomeScreenState extends State<ExamHomeScreen> {
  String _selectedFilter = 'ทั้งหมด';
  List<Map<String, dynamic>> _allExams = [];
  bool _isLoading = true;
  String? _error;

  // List of exam pack files to load
  static const _examPackFiles = [
    'assets/data/exam_pack_beginner_basic.json',
    'assets/data/exam_pack_beginner_everyday.json',
    'assets/data/exam_pack_tgat_mock1.json',
    'assets/data/exam_pack_tgat_mock2.json',
    'assets/data/exam_pack_alevel_mock1.json',
  ];

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    final loadedExams = <Map<String, dynamic>>[];

    for (final file in _examPackFiles) {
      try {
        final jsonString = await rootBundle.loadString(file);
        final Map<String, dynamic> data = json.decode(jsonString);

        // Each file has "packs" array with exam info
        final packs = data['packs'] as List?;
        if (packs != null) {
          for (final pack in packs) {
            final packMap = pack as Map<String, dynamic>;
            loadedExams.add({
              'id': packMap['id'] ?? '',
              'name': packMap['name'] ?? '',
              'description': packMap['description'] ?? '',
              'type': packMap['examType'] ?? 'Other',
              'questions': packMap['numQuestions'] ?? 0,
              'difficulty': packMap['difficulty'] ?? 'medium',
              'time': packMap['timeLimit'] ?? 60,
            });
          }
        }
      } catch (e) {
        debugPrint('Could not load $file: $e');
      }
    }

    // Also try to load from exam_packs_tgat_alevel.json
    try {
      final jsonString = await rootBundle
          .loadString('assets/data/exam_packs_tgat_alevel.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      final packs = data['packs'] as List?;
      if (packs != null) {
        for (final pack in packs) {
          final packMap = pack as Map<String, dynamic>;
          // Avoid duplicates
          final id = packMap['id'] ?? '';
          if (!loadedExams.any((e) => e['id'] == id)) {
            loadedExams.add({
              'id': id,
              'name': packMap['name'] ?? '',
              'description': packMap['description'] ?? '',
              'type': packMap['examType'] ?? 'Other',
              'questions': packMap['numQuestions'] ?? 0,
              'difficulty': packMap['difficulty'] ?? 'medium',
              'time': packMap['timeLimit'] ?? 60,
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Could not load exam_packs_tgat_alevel.json: $e');
    }

    if (mounted) {
      setState(() {
        _allExams = loadedExams;
        _isLoading = false;
        if (loadedExams.isEmpty) {
          _error = 'ไม่สามารถโหลดข้อสอบได้';
        }
      });
    }
  }

  List<Map<String, dynamic>> get _filteredExams {
    if (_selectedFilter == 'ทั้งหมด') {
      return _allExams;
    }
    return _allExams.where((exam) => exam['type'] == _selectedFilter).toList();
  }

  Set<String> get _availableTypes {
    final types = <String>{'ทั้งหมด'};
    for (final exam in _allExams) {
      final type = exam['type'] as String?;
      if (type != null && type.isNotEmpty) {
        types.add(type);
      }
    }
    return types;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Exam Pocket'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _allExams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadExams();
              },
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.examColor,
                  AppTheme.examColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ทดสอบความพร้อม',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_allExams.length} ชุดข้อสอบพร้อมทำ',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.assignment_rounded,
                  size: 48,
                  color: Colors.white24,
                ),
              ],
            ),
          ),

          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _availableTypes.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(type),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Exam List
          Expanded(
            child: _filteredExams.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ไม่พบข้อสอบในหมวดนี้',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredExams.length,
                    itemBuilder: (context, index) {
                      final exam = _filteredExams[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildExamCard(context, exam),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.examColor
              : AppTheme.examColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.examColor
                : AppTheme.examColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.examColor,
          ),
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, Map<String, dynamic> exam) {
    final difficulty = exam['difficulty'] as String? ?? 'medium';
    Color difficultyColor;
    String difficultyText;

    switch (difficulty) {
      case 'easy':
        difficultyColor = AppTheme.successColor;
        difficultyText = 'ง่าย';
        break;
      case 'hard':
        difficultyColor = AppTheme.errorColor;
        difficultyText = 'ยาก';
        break;
      default:
        difficultyColor = AppTheme.warningColor;
        difficultyText = 'ปานกลาง';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/exam/${exam['id']}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.examColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      exam['type'] as String? ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.examColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: difficultyColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      difficultyText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: difficultyColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppTheme.textSecondaryColor),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                exam['name'] as String? ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                exam['description'] as String? ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.quiz_outlined,
                      size: 16, color: AppTheme.textSecondaryColor),
                  const SizedBox(width: 4),
                  Text(
                    '${exam['questions']} ข้อ',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondaryColor),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.timer_outlined,
                      size: 16, color: AppTheme.textSecondaryColor),
                  const SizedBox(width: 4),
                  Text(
                    '${exam['time']} นาที',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondaryColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
