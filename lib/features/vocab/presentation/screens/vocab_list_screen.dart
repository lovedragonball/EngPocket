/// Vocab List Screen - หน้าดูคำศัพท์ทั้งหมด
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/models/vocab_item.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/services/srs_service.dart';

class VocabListScreen extends StatefulWidget {
  const VocabListScreen({super.key});

  @override
  State<VocabListScreen> createState() => _VocabListScreenState();
}

class _VocabListScreenState extends State<VocabListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TtsService _tts = TtsService();
  final SrsService _srsService = SrsService();

  String _searchQuery = '';
  String _selectedLevel = 'all';
  String _sortBy = 'alpha';
  bool _isLoading = true;

  List<VocabItem> _allVocab = [];
  Set<String> _bookmarkedIds = {};
  Map<String, dynamic> _srsData = {};

  @override
  void initState() {
    super.initState();
    _loadVocab();
    _loadBookmarks();
    _loadSrsData();
  }

  Future<void> _loadSrsData() async {
    await _srsService.init();
    if (mounted) {
      setState(() {
        _srsData = _srsService.getAllCards();
      });
    }
  }

  Future<void> _loadVocab() async {
    try {
      final List<VocabItem> allVocab = [];

      // Load from multiple vocab JSON files
      final vocabFiles = [
        'vocab_tgat_100.json',
        'vocab_alevel_50.json',
        'vocab_stock_500.json',
      ];

      for (final file in vocabFiles) {
        try {
          final String jsonString = await rootBundle.loadString(
            'assets/data/$file',
          );
          final List<dynamic> jsonList = json.decode(jsonString);

          for (final item in jsonList) {
            allVocab.add(VocabItem(
              id: item['id'] ?? '',
              word: item['word'] ?? '',
              translation: item['translation'] ?? '',
              partOfSpeech: item['partOfSpeech'] ?? 'noun',
              exampleEn: item['exampleEn'] ?? '',
              exampleTh: item['exampleTh'] ?? '',
              level: item['level'] ?? 'intermediate',
              packId: item['packId'] ?? '',
              tags: List<String>.from(item['tags'] ?? []),
            ));
          }
        } catch (e) {
          debugPrint('Error loading $file: $e');
        }
      }

      if (mounted) {
        setState(() {
          _allVocab = allVocab;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading vocab: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarked_vocab') ?? [];
    if (mounted) {
      setState(() {
        _bookmarkedIds = bookmarks.toSet();
      });
    }
  }

  Future<void> _toggleBookmark(String vocabId) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (_bookmarkedIds.contains(vocabId)) {
        _bookmarkedIds.remove(vocabId);
      } else {
        _bookmarkedIds.add(vocabId);
      }
    });

    await prefs.setStringList('bookmarked_vocab', _bookmarkedIds.toList());
  }

  List<VocabItem> get _filteredVocab {
    var result = _allVocab.where((vocab) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!vocab.word.toLowerCase().contains(query) &&
            !vocab.translation.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Level filter
      if (_selectedLevel != 'all' && vocab.level != _selectedLevel) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'alpha':
        result.sort((a, b) => a.word.compareTo(b.word));
        break;
      case 'bookmarked':
        result.sort((a, b) {
          final aBookmarked = _bookmarkedIds.contains(a.id) ? 0 : 1;
          final bBookmarked = _bookmarkedIds.contains(b.id) ? 0 : 1;
          return aBookmarked.compareTo(bBookmarked);
        });
        break;
      case 'recent':
        result.sort((a, b) {
          final aData = _srsData[a.id] as Map<String, dynamic>?;
          final bData = _srsData[b.id] as Map<String, dynamic>?;

          final aTime = aData?['lastReview'] as int? ?? 0;
          final bTime = bData?['lastReview'] as int? ?? 0;

          // Sort descending (most recent first)
          return bTime.compareTo(aTime);
        });
        break;
    }

    return result;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('📚 คำศัพท์ทั้งหมด')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.vocabColor),
              SizedBox(height: 16),
              Text('กำลังโหลดคำศัพท์...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 คำศัพท์ทั้งหมด'),
      ),
      body: Column(
        children: [
          // Search and Filter
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ค้นหาคำศัพท์...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ทั้งหมด', 'all', _selectedLevel,
                          (v) => setState(() => _selectedLevel = v)),
                      const SizedBox(width: 8),
                      _buildFilterChip('Basic', 'basic', _selectedLevel,
                          (v) => setState(() => _selectedLevel = v)),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          'Intermediate',
                          'intermediate',
                          _selectedLevel,
                          (v) => setState(() => _selectedLevel = v)),
                      const SizedBox(width: 8),
                      _buildFilterChip('Advanced', 'advanced', _selectedLevel,
                          (v) => setState(() => _selectedLevel = v)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'พบ ${_filteredVocab.length} คำ',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showSortOptions,
                  icon: const Icon(Icons.sort, size: 18),
                  label: const Text('เรียงลำดับ'),
                ),
              ],
            ),
          ),

          // Vocab list
          Expanded(
            child: _filteredVocab.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredVocab.length,
                    itemBuilder: (context, index) {
                      final vocab = _filteredVocab[index];
                      return _buildVocabCard(vocab);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, String value, String selected, Function(String) onSelect) {
    final isSelected = value == selected;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(value),
      selectedColor: AppTheme.vocabColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.vocabColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.vocabColor : AppTheme.textSecondaryColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildVocabCard(VocabItem vocab) {
    final isBookmarked = _bookmarkedIds.contains(vocab.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showVocabDetail(vocab),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Level indicator
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: _getLevelColor(vocab.level),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),

              // Word info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          vocab.word,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            vocab.partOfSpeech,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vocab.translation,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Bookmark icon
              IconButton(
                onPressed: () => _toggleBookmark(vocab.id),
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked
                      ? AppTheme.warningColor
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'basic':
        return AppTheme.successColor;
      case 'intermediate':
        return AppTheme.warningColor;
      case 'advanced':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'ไม่พบคำศัพท์',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ลองเปลี่ยนคำค้นหาหรือตัวกรอง',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เรียงลำดับตาม',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.sort_by_alpha,
                color: _sortBy == 'alpha' ? AppTheme.vocabColor : null,
              ),
              title: const Text('A-Z'),
              trailing: _sortBy == 'alpha'
                  ? const Icon(Icons.check, color: AppTheme.vocabColor)
                  : null,
              onTap: () {
                setState(() => _sortBy = 'alpha');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.bookmark,
                color: _sortBy == 'bookmarked' ? AppTheme.vocabColor : null,
              ),
              title: const Text('บันทึกไว้'),
              trailing: _sortBy == 'bookmarked'
                  ? const Icon(Icons.check, color: AppTheme.vocabColor)
                  : null,
              onTap: () {
                setState(() => _sortBy = 'bookmarked');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.history,
                color: _sortBy == 'recent' ? AppTheme.vocabColor : null,
              ),
              title: const Text('ล่าสุด (ที่เรียน)'),
              trailing: _sortBy == 'recent'
                  ? const Icon(Icons.check, color: AppTheme.vocabColor)
                  : null,
              onTap: () {
                setState(() => _sortBy = 'recent');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showVocabDetail(VocabItem vocab) {
    final isBookmarked = _bookmarkedIds.contains(vocab.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (scrollContext, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Word
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vocab.word,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.vocabColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                vocab.partOfSpeech,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.vocabColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getLevelColor(vocab.level)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                vocab.level.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getLevelColor(vocab.level),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _tts.speak(vocab.word);
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.vocabColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.volume_up,
                          color: AppTheme.vocabColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Translation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.translate, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        vocab.translation,
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Example
              if (vocab.exampleEn.isNotEmpty) ...[
                const Text(
                  'ตัวอย่างประโยค',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vocab.exampleEn,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vocab.exampleTh,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _toggleBookmark(vocab.id);
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isBookmarked
                                  ? 'ลบ "${vocab.word}" ออกจากบันทึกแล้ว'
                                  : 'บันทึก "${vocab.word}" แล้ว',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: Icon(
                        isBookmarked
                            ? Icons.bookmark_remove
                            : Icons.bookmark_add,
                      ),
                      label: Text(isBookmarked ? 'ลบบันทึก' : 'บันทึก'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        context.push('/vocab/flashcard');
                      },
                      icon: const Icon(Icons.style),
                      label: const Text('ฝึก Flashcard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.vocabColor,
                      ),
                    ),
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
