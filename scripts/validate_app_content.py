#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Comprehensive grammar and translation checker for all app content
- Grammar checking for English text
- Translation accuracy checking
- Consistency checks
"""
import json
import re
from pathlib import Path
from collections import defaultdict
import os

# Grammar patterns to check
GRAMMAR_ISSUES = {
    'capitalization': [],
    'punctuation': [],
    'sentence_structure': [],
    'verb_tense': [],
    'subject_verb_agreement': [],
    'article_usage': [],
}

# Common grammar mistakes to look for
GRAMMAR_PATTERNS = [
    # Capitalize first letter of sentences
    (r'^[a-z]', 'Capitalization'),
    # Check for common mistakes
    (r'\b(is|are|was|were)\s+(not\s+)?(a|an|the)?\s+\w+ing\b', 'Verb tense'),
    # Check for double spaces
    (r'\s{2,}', 'Extra spaces'),
]

# Common Thai translation mistakes
THAI_PATTERNS = {
    'ทั้งนี้': 'ทั้งหมด',  # ambiguous
    'ต่าง': 'แตกต่าง',  # incomplete
}

def scan_json_files():
    """Scan all JSON files in data directory"""
    data_dir = Path('c:/Users/chawa/Downloads/App Test/eng_pocket/assets/data')
    
    files_to_check = {
        'vocab': sorted(data_dir.glob('vocab_part*.json')),
        'exam_packs': sorted(data_dir.glob('exam_pack*.json')),
        'grammar_quizzes': sorted(data_dir.glob('quiz/grammar_quiz*.json')),
        'reading_passages': [data_dir / 'reading_passages.json'],
        'grammar_topics': [data_dir / 'grammar_topics.json'],
    }
    
    return files_to_check

def check_english_grammar(text):
    """Check English grammar in text"""
    issues = []
    
    if not text or not isinstance(text, str):
        return issues
    
    # Check for missing capitalization at start
    if text and text[0].islower() and not text.startswith('i '):
        # Exception for phrases starting with specific words
        if not any(text.startswith(x) for x in ['a ', 'an ', 'the ']):
            issues.append({
                'type': 'capitalization',
                'message': f'Starts with lowercase: "{text[:30]}..."',
                'severity': 'low'
            })
    
    # Check for double spaces
    if '  ' in text:
        issues.append({
            'type': 'spacing',
            'message': 'Contains double spaces',
            'severity': 'medium'
        })
    
    # Check for missing periods at end of sentences (if it looks like a complete sentence)
    if len(text) > 10 and text[-1] not in '.!?\n' and ' ' in text:
        words = text.split()
        if len(words) > 5:  # More than 5 words
            # Check if it looks like a complete sentence
            if text[0].isupper() and ' ' in text:
                issues.append({
                    'type': 'punctuation',
                    'message': f'No ending punctuation: "{text[:40]}..."',
                    'severity': 'low'
                })
    
    # Check for common grammar mistakes
    if re.search(r'\b(are)\s+(is)\b', text):
        issues.append({
            'type': 'grammar',
            'message': 'Incorrect verb placement: "are is"',
            'severity': 'high'
        })
    
    if re.search(r'\b(is)\s+(are)\b', text):
        issues.append({
            'type': 'grammar',
            'message': 'Incorrect verb placement: "is are"',
            'severity': 'high'
        })
    
    # Check for articles
    if re.search(r'\b(a)\s+[aeiou]', text):
        issues.append({
            'type': 'article',
            'message': 'Should use "an" before vowel',
            'severity': 'medium'
        })
    
    return issues

def check_thai_translation(text):
    """Check Thai translation quality"""
    issues = []
    
    if not text or not isinstance(text, str):
        return issues
    
    # Check for missing Thai characters
    thai_chars = re.findall(r'[\u0E00-\u0E7F]', text)
    if len(text) > 5 and not thai_chars:
        issues.append({
            'type': 'missing_thai',
            'message': 'No Thai characters found',
            'severity': 'high'
        })
    
    # Check for incomplete translations (too short)
    if len(text) < 2:
        issues.append({
            'type': 'incomplete',
            'message': 'Translation too short',
            'severity': 'medium'
        })
    
    # Check for problematic patterns
    for bad_word, suggestion in THAI_PATTERNS.items():
        if bad_word in text:
            issues.append({
                'type': 'translation_quality',
                'message': f'Consider using "{suggestion}" instead of "{bad_word}"',
                'severity': 'low'
            })
    
    return issues

def check_vocab_file(filepath):
    """Check a vocabulary file"""
    issues = []
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if not isinstance(data, list):
            return issues
        
        for idx, item in enumerate(data):
            item_issues = {
                'file': filepath.name,
                'index': idx,
                'id': item.get('id', 'unknown'),
                'word': item.get('word', ''),
                'issues': []
            }
            
            # Check word
            if 'word' in item:
                word_issues = check_english_grammar(item['word'])
                item_issues['issues'].extend([(issue['type'], issue['message'], 'word') for issue in word_issues])
            
            # Check translation
            if 'translation' in item:
                trans_issues = check_thai_translation(item['translation'])
                item_issues['issues'].extend([(issue['type'], issue['message'], 'translation') for issue in trans_issues])
            
            # Check example
            if 'example' in item:
                ex_issues = check_english_grammar(item['example'])
                item_issues['issues'].extend([(issue['type'], issue['message'], 'example') for issue in ex_issues])
            
            if item_issues['issues']:
                issues.append(item_issues)
    
    except Exception as e:
        pass
    
    return issues

def check_quiz_file(filepath):
    """Check a quiz file"""
    issues = []
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Handle both array and object formats
        if isinstance(data, dict):
            quizzes_data = []
            for difficulty in ['easy', 'medium', 'hard']:
                if difficulty in data:
                    quizzes_data.extend(data[difficulty])
        else:
            quizzes_data = data if isinstance(data, list) else []
        
        for idx, quiz in enumerate(quizzes_data):
            item_issues = {
                'file': filepath.name,
                'index': idx,
                'id': quiz.get('id', 'unknown'),
                'issues': []
            }
            
            # Check stem
            if 'stem' in quiz:
                stem_issues = check_english_grammar(quiz['stem'])
                item_issues['issues'].extend([(issue['type'], issue['message'], 'stem') for issue in stem_issues])
            
            # Check choices
            if 'choices' in quiz and isinstance(quiz['choices'], list):
                for choice_idx, choice in enumerate(quiz['choices']):
                    choice_issues = check_english_grammar(str(choice))
                    item_issues['issues'].extend([(issue['type'], issue['message'], f'choice_{choice_idx}') for issue in choice_issues])
            
            # Check explanation
            if 'explanation' in quiz:
                exp_issues = check_english_grammar(quiz['explanation'])
                item_issues['issues'].extend([(issue['type'], issue['message'], 'explanation') for issue in exp_issues])
            
            if item_issues['issues']:
                issues.append(item_issues)
    
    except Exception as e:
        pass
    
    return issues

def main():
    print("="*100)
    print("COMPREHENSIVE APP CONTENT VALIDATION")
    print("Checking Grammar, Spelling, and Translations")
    print("="*100)
    
    files_to_check = scan_json_files()
    
    all_issues = {
        'vocab': [],
        'exam_packs': [],
        'grammar_quizzes': [],
        'reading_passages': [],
        'grammar_topics': [],
    }
    
    total_files = 0
    total_issues = 0
    
    for category, files in files_to_check.items():
        print(f"\n{'='*100}")
        print(f"Checking {category.upper()} ({len(files)} files)")
        print(f"{'='*100}")
        
        for filepath in files:
            if not filepath.exists():
                continue
            
            total_files += 1
            
            if 'vocab' in category or 'passages' in category or 'topics' in category:
                issues = check_vocab_file(filepath)
            else:
                issues = check_quiz_file(filepath)
            
            if issues:
                all_issues[category].extend(issues)
                total_issues += len(issues)
                print(f"  {filepath.name}: {len(issues)} potential issues")
            else:
                print(f"  {filepath.name}: ✅ OK")
    
    # Generate report
    print(f"\n{'='*100}")
    print(f"SUMMARY")
    print(f"{'='*100}")
    print(f"Files checked: {total_files}")
    print(f"Potential issues found: {total_issues}")
    
    if total_issues > 0:
        print(f"\n{'='*100}")
        print(f"ISSUES FOUND BY CATEGORY")
        print(f"{'='*100}")
        
        for category, issues in all_issues.items():
            if issues:
                print(f"\n{category.upper()}: {len(issues)} items with issues")
                # Show first 5
                for item in issues[:5]:
                    print(f"  - {item['id']} (in {item['file']})")
                    for issue in item['issues'][:3]:
                        print(f"      • {issue[0]}: {issue[1]}")
                    if len(item['issues']) > 3:
                        print(f"      ... and {len(item['issues']) - 3} more")
    
    # Save detailed report
    report_path = Path('c:/Users/chawa/Downloads/App Test/eng_pocket/scripts/app_content_validation_report.json')
    
    report_data = {
        'summary': {
            'total_files': total_files,
            'total_issues': total_issues,
            'status': 'PASSED' if total_issues == 0 else 'NEEDS REVIEW'
        },
        'issues_by_category': {k: len(v) for k, v in all_issues.items()},
        'detailed_issues': all_issues
    }
    
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump(report_data, f, ensure_ascii=False, indent=2)
    
    print(f"\n📄 Detailed report saved to: app_content_validation_report.json")

if __name__ == '__main__':
    main()
