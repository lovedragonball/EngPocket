/// Grammar Home Screen
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../widgets/grammar_topic_card.dart';

class GrammarHomeScreen extends StatefulWidget {
  const GrammarHomeScreen({super.key});

  @override
  State<GrammarHomeScreen> createState() => _GrammarHomeScreenState();
}

class _GrammarHomeScreenState extends State<GrammarHomeScreen> {
  List<Map<String, dynamic>> _topics = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/grammar_topics.json');
      final List<dynamic> data = json.decode(jsonString);
      if (mounted) {
        setState(() {
          _topics = data.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading grammar topics: $e');
      if (mounted) {
        setState(() {
          _error = 'ไม่สามารถโหลดหัวข้อไวยากรณ์ได้';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📘 Grammar Pocket'),
        actions: [
          if (_topics.isNotEmpty)
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: _GrammarSearchDelegate(_topics),
                );
              },
              icon: const Icon(Icons.search_rounded),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
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
                _loadTopics();
              },
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    if (_topics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีหัวข้อไวยากรณ์',
              style: TextStyle(color: Colors.grey.shade600),
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
                        '${_topics.length} หัวข้อ พร้อมแบบฝึกหัด',
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
              itemCount: _topics.length,
              itemBuilder: (context, index) {
                final topic = _topics[index];
                final quizQuestions = topic['quizQuestions'] as List? ?? [];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GrammarTopicCard(
                    title: topic['title'] as String? ?? '',
                    subtitle: _getSubtitle(topic),
                    questionsCount: quizQuestions.length,
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
    );
  }

  String _getSubtitle(Map<String, dynamic> topic) {
    final explanation = topic['explanation'] as String? ?? '';
    // Get first line or first 60 chars
    final firstLine = explanation.split('\n').first;
    if (firstLine.length > 60) {
      return '${firstLine.substring(0, 60)}...';
    }
    return firstLine;
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
      final title = (topic['title'] as String? ?? '').toLowerCase();
      final explanation = (topic['explanation'] as String? ?? '').toLowerCase();
      return title.contains(query.toLowerCase()) ||
          explanation.contains(query.toLowerCase());
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
          title: Text(topic['title'] as String? ?? ''),
          subtitle: Text(
            _getSubtitle(topic),
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

  String _getSubtitle(Map<String, dynamic> topic) {
    final explanation = topic['explanation'] as String? ?? '';
    final firstLine = explanation.split('\n').first;
    if (firstLine.length > 40) {
      return '${firstLine.substring(0, 40)}...';
    }
    return firstLine;
  }
}
