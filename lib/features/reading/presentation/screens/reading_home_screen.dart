/// Reading Home Screen - หน้ารวมบทความฝึกอ่าน
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../data/reading_repository.dart';

class ReadingHomeScreen extends StatefulWidget {
  const ReadingHomeScreen({super.key});

  @override
  State<ReadingHomeScreen> createState() => _ReadingHomeScreenState();
}

class _ReadingHomeScreenState extends State<ReadingHomeScreen> {
  final ReadingRepository _repository = ReadingRepository();
  List<Map<String, dynamic>> _allPassages = [];
  List<Map<String, dynamic>> _filteredPassages = [];
  String _selectedTopic = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPassages();
  }

  Future<void> _loadPassages() async {
    await _repository.init();
    if (mounted) {
      setState(() {
        _allPassages = _repository.getAllPassages();
        _filteredPassages = _allPassages;
        _isLoading = false;
      });
    }
  }

  void _filterByTopic(String topic) {
    setState(() {
      _selectedTopic = topic;
      if (topic == 'all') {
        _filteredPassages = _allPassages;
      } else {
        _filteredPassages = _repository.getPassagesByTopic(topic);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('📖 Reading Practice')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 Reading Practice'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accentColor,
                    AppTheme.accentColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ฝึกอ่านบทความ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'พัฒนาทักษะการอ่านเพื่อสอบ TGAT & A-Level',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Topics filter
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTopicChip('ทั้งหมด', 'all'),
                    const SizedBox(width: 8),
                    _buildTopicChip('เทคโนโลยี', 'technology'),
                    const SizedBox(width: 8),
                    _buildTopicChip('สิ่งแวดล้อม', 'environment'),
                    const SizedBox(width: 8),
                    _buildTopicChip('สุขภาพ', 'health'),
                    const SizedBox(width: 8),
                    _buildTopicChip('วัฒนธรรม', 'culture'),
                  ],
                ),
              ),
            ),

            // Passages List
            if (_filteredPassages.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ไม่พบบทความในหมวดหมู่นี้',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredPassages.length,
                itemBuilder: (context, index) {
                  final passage = _filteredPassages[index];
                  return _buildPassageCard(context, passage);
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicChip(String label, String value) {
    final isSelected = _selectedTopic == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _filterByTopic(value),
      selectedColor: AppTheme.accentColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.accentColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.accentColor : AppTheme.textSecondaryColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildPassageCard(BuildContext context, Map<String, dynamic> passage) {
    final difficulty = passage['difficulty'] as String;
    final difficultyColor = _getDifficultyColor(difficulty);
    final topicIcon = _getTopicIcon(passage['topic'] as String);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          context.push('/reading/${passage['id']}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      topicIcon,
                      color: AppTheme.accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          passage['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: difficultyColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getDifficultyLabel(difficulty),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: difficultyColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${passage['wordCount']} คำ',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(passage['questions'] as List?)?.length ?? 0} ข้อ',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textSecondaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return AppTheme.successColor;
      case 'medium':
        return AppTheme.warningColor;
      case 'hard':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 'ง่าย';
      case 'medium':
        return 'ปานกลาง';
      case 'hard':
        return 'ยาก';
      default:
        return difficulty;
    }
  }

  IconData _getTopicIcon(String topic) {
    switch (topic) {
      case 'technology':
        return Icons.computer_rounded;
      case 'environment':
        return Icons.eco_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'culture':
        return Icons.restaurant_rounded;
      default:
        return Icons.article_rounded;
    }
  }
}
