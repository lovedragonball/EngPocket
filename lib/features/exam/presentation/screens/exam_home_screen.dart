/// Exam Home Screen
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';

class ExamHomeScreen extends StatelessWidget {
  const ExamHomeScreen({super.key});

  // Sample data
  static const _sampleExams = [
    {
      'id': 'tgat_mock_1',
      'name': 'TGAT Mock Test 1',
      'description': 'ข้อสอบจำลอง TGAT English ชุดที่ 1',
      'type': 'TGAT',
      'questions': 30,
      'difficulty': 'medium',
      'time': 60,
    },
    {
      'id': 'tgat_mock_2',
      'name': 'TGAT Mock Test 2',
      'description': 'ข้อสอบจำลอง TGAT English ชุดที่ 2',
      'type': 'TGAT',
      'questions': 30,
      'difficulty': 'hard',
      'time': 60,
    },
    {
      'id': 'alevel_mock_1',
      'name': 'A-Level Mock Test 1',
      'description': 'ข้อสอบจำลอง A-Level English',
      'type': 'A-Level',
      'questions': 50,
      'difficulty': 'hard',
      'time': 90,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Exam Pocket'),
      ),
      body: SafeArea(
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
                          '${_sampleExams.length} ชุดข้อสอบพร้อมทำ',
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
              child: Row(
                children: [
                  _buildFilterChip('ทั้งหมด', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('TGAT', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('A-Level', false),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Exam List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _sampleExams.length,
                itemBuilder: (context, index) {
                  final exam = _sampleExams[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildExamCard(context, exam),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.examColor : AppTheme.examColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.examColor,
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, Map<String, dynamic> exam) {
    final difficulty = exam['difficulty'] as String;
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.examColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      exam['type'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.examColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondaryColor),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                exam['name'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                exam['description'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.quiz_outlined, size: 16, color: AppTheme.textSecondaryColor),
                  const SizedBox(width: 4),
                  Text(
                    '${exam['questions']} ข้อ',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.timer_outlined, size: 16, color: AppTheme.textSecondaryColor),
                  const SizedBox(width: 4),
                  Text(
                    '${exam['time']} นาที',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor),
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
