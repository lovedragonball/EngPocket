/// Grammar Home Screen
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../widgets/grammar_topic_card.dart';

class GrammarHomeScreen extends StatelessWidget {
  const GrammarHomeScreen({super.key});

  // Sample data
  static const _sampleTopics = [
    {
      'id': '1',
      'title': 'Present Simple',
      'subtitle': 'การใช้ Present Simple Tense สำหรับบอกข้อเท็จจริงและกิจวัตร',
      'questions': 5
    },
    {
      'id': '2',
      'title': 'Present Perfect',
      'subtitle':
          'การใช้ Present Perfect Tense สำหรับเหตุการณ์ที่เชื่อมโยงกับปัจจุบัน',
      'questions': 8
    },
    {
      'id': '3',
      'title': 'Passive Voice',
      'subtitle': 'การเปลี่ยนประโยค Active เป็น Passive Voice',
      'questions': 6
    },
    {
      'id': '4',
      'title': 'Conditionals',
      'subtitle': 'ประโยคเงื่อนไข If-clause ทั้ง 4 แบบ',
      'questions': 10
    },
    {
      'id': '5',
      'title': 'Reported Speech',
      'subtitle': 'การเปลี่ยนคำพูดตรงเป็นคำพูดรายงาน',
      'questions': 7
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📘 Grammar Pocket'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: _GrammarSearchDelegate(_sampleTopics),
              );
            },
            icon: const Icon(Icons.search_rounded),
          ),
        ],
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
                    AppTheme.grammarColor,
                    AppTheme.grammarColor.withValues(alpha: 0.8),
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
                          'เรียนรู้ไวยากรณ์',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_sampleTopics.length} หัวข้อ พร้อมแบบฝึกหัด',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 48,
                    color: Colors.white24,
                  ),
                ],
              ),
            ),

            // Topics List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _sampleTopics.length,
                itemBuilder: (context, index) {
                  final topic = _sampleTopics[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GrammarTopicCard(
                      title: topic['title'] as String,
                      subtitle: topic['subtitle'] as String,
                      questionsCount: topic['questions'] as int,
                      onTap: () {
                        context.push('/grammar/${topic['id']}');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrammarSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> topics;

  _GrammarSearchDelegate(this.topics);

  @override
  String get searchFieldLabel => 'ค้นหาหัวข้อไวยากรณ์...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final results = topics.where((topic) {
      final title = (topic['title'] as String).toLowerCase();
      final subtitle = (topic['subtitle'] as String).toLowerCase();
      return title.contains(query.toLowerCase()) ||
          subtitle.contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'ไม่พบหัวข้อที่ค้นหา',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final topic = results[index];
        return ListTile(
          leading: const Icon(Icons.rule_rounded),
          title: Text(topic['title'] as String),
          subtitle: Text(
            topic['subtitle'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            close(context, '');
            context.push('/grammar/${topic['id']}');
          },
        );
      },
    );
  }
}
