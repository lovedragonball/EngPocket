/// Grammar Detail Screen
library;

import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

class GrammarDetailScreen extends StatelessWidget {
  final String topicId;

  const GrammarDetailScreen({super.key, required this.topicId});

  @override
  Widget build(BuildContext context) {
    // Sample data - จะถูกแทนที่ด้วยข้อมูลจริง
    const sampleTopic = {
      'title': 'Present Perfect',
      'explanation': '''
Present Perfect Tense ใช้กับเหตุการณ์ที่เกิดขึ้นในอดีตแต่ยังส่งผลถึงปัจจุบัน

โครงสร้าง: Subject + have/has + V3

การใช้งาน:
1. ประสบการณ์ในอดีต
2. เหตุการณ์ที่เพิ่งเกิดขึ้น
3. สถานการณ์ที่ดำเนินมาถึงปัจจุบัน
''',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(sampleTopic['title'] as String),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explanation Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.grammarColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.grammarColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppTheme.grammarColor),
                      const SizedBox(width: 8),
                      const Text(
                        'หลักการ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    sampleTopic['explanation'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Examples Section
            const Text(
              'ตัวอย่างประโยค',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildExampleCard(
              'I have visited Japan twice.',
              'ฉันเคยไปญี่ปุ่นสองครั้ง',
              'have visited',
            ),
            const SizedBox(height: 12),
            _buildExampleCard(
              'She has just finished her homework.',
              'เธอเพิ่งทำการบ้านเสร็จ',
              'has just finished',
            ),
            const SizedBox(height: 24),

            // Quiz Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mini Quiz - Coming soon!')),
                  );
                },
                icon: const Icon(Icons.quiz_rounded),
                label: const Text('ทำแบบฝึกหัด'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.grammarColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(String english, String thai, String highlight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            english,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            thai,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.grammarColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              highlight,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.grammarColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
