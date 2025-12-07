#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Smart grammar and translation checker - focusing on real issues
"""
import json
import re
from pathlib import Path
from collections import defaultdict

def check_english_grammar(text, context='general'):
    """Check English grammar in text with context awareness"""
    issues = []
    
    if not text or not isinstance(text, str):
        return issues
    
    # Don't check single words, choices, or very short phrases
    if len(text) < 8 or ' ' not in text:
        return issues
    
    # Skip if it's just a verb form (choice option)
    verb_forms = ['ing', 'ed', 'en']
    if any(text.lower().endswith(v) for v in verb_forms) and len(text.split()) == 1:
        return issues
    
    # Check for double spaces
    if '  ' in text:
        issues.append({
            'type': 'spacing',
            'message': 'Contains double spaces',
            'severity': 'medium',
            'text': text
        })
    
    # Check for missing periods at end of sentences (actual sentences)
    if context == 'sentence' and len(text) > 15:
        # Must look like a complete sentence
        if text[0].isupper() and ' ' in text and text[-1] not in '.!?\n':
            if re.match(r'^[A-Z][a-z]+.*[a-z]$', text):
                issues.append({
                    'type': 'punctuation',
                    'message': f'No ending punctuation',
                    'severity': 'low',
                    'text': text
                })
    
    # Check for common grammar mistakes
    if re.search(r'\b(are)\s+(is|am)\b', text, re.IGNORECASE):
        issues.append({
            'type': 'grammar',
            'message': 'Verb agreement issue: "are is" or "are am"',
            'severity': 'high',
            'text': text
        })
    
    if re.search(r'\b(have|has)\s+(has|have)\b', text, re.IGNORECASE):
        issues.append({
            'type': 'grammar',
            'message': 'Duplicate auxiliary verb',
            'severity': 'high',
            'text': text
        })
    
    # Check for articles - "a" before vowel
    if re.search(r'\ba\s+[aeiou]', text, re.IGNORECASE):
        issues.append({
            'type': 'article',
            'message': 'Should use "an" before vowel',
            'severity': 'medium',
            'text': text
        })
    
    # Check for missing articles where needed (this|that + noun without article)
    if re.search(r'\b(this|that)\s+[a-z]+\s+(is|are|was|were)', text, re.IGNORECASE):
        pass  # This is complex, skip for now
    
    return issues

def check_thai_translation(text):
    """Check Thai translation quality"""
    issues = []
    
    if not text or not isinstance(text, str):
        return issues
    
    # Check for meaningful Thai characters
    thai_chars = re.findall(r'[\u0E00-\u0E7F]', text)
    
    # Allow some English transliterations, but mostly Thai
    if len(text) > 3 and len(thai_chars) == 0:
        issues.append({
            'type': 'missing_thai',
            'message': 'No Thai characters found - should be Thai translation',
            'severity': 'high',
            'text': text
        })
    
    # Check for incomplete translations (too short)
    if len(text) < 1:
        issues.append({
            'type': 'incomplete',
            'message': 'Empty translation',
            'severity': 'high',
            'text': text
        })
    
    # Common problematic patterns
    if text == '...':
        issues.append({
            'type': 'placeholder',
            'message': 'Placeholder "..." instead of actual translation',
            'severity': 'high',
            'text': text
        })
    
    if re.search(r'^[\-\.]+$', text):
        issues.append({
            'type': 'placeholder',
            'message': 'Empty/placeholder translation',
            'severity': 'high',
            'text': text
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
            if not isinstance(item, dict):
                continue
            
            item_id = item.get('id', f'unknown_{idx}')
            word = item.get('word', '')
            translation = item.get('translation', '')
            example = item.get('example', '')
            
            # Check translation - most critical
            trans_issues = check_thai_translation(translation)
            if trans_issues:
                for issue in trans_issues:
                    issues.append({
                        'id': item_id,
                        'file': filepath.name,
                        'field': 'translation',
                        'value': translation,
                        'type': issue['type'],
                        'message': issue['message'],
                        'severity': issue['severity']
                    })
            
            # Check example - check for grammar
            if example and len(example) > 10:
                ex_issues = check_english_grammar(example, 'sentence')
                for issue in ex_issues:
                    issues.append({
                        'id': item_id,
                        'file': filepath.name,
                        'field': 'example',
                        'value': example,
                        'type': issue['type'],
                        'message': issue['message'],
                        'severity': issue['severity']
                    })
    
    except Exception as e:
        pass
    
    return issues

def check_reading_passage(filepath):
    """Check reading passage file"""
    issues = []
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if not isinstance(data, list):
            return issues
        
        for passage in data:
            if not isinstance(passage, dict):
                continue
            
            passage_id = passage.get('id', 'unknown')
            content = passage.get('content', '')
            
            # Check for obvious grammar issues
            gram_issues = check_english_grammar(content, 'passage')
            for issue in gram_issues:
                issues.append({
                    'id': passage_id,
                    'file': filepath.name,
                    'field': 'content',
                    'type': issue['type'],
                    'message': issue['message'],
                    'severity': issue['severity']
                })
            
            # Check questions
            if 'questions' in passage and isinstance(passage['questions'], list):
                for q_idx, question in enumerate(passage['questions']):
                    q_id = question.get('id', f'q_{q_idx}')
                    stem = question.get('stem', '')
                    
                    q_issues = check_english_grammar(stem, 'question')
                    for issue in q_issues:
                        issues.append({
                            'id': q_id,
                            'file': filepath.name,
                            'field': 'question_stem',
                            'value': stem,
                            'type': issue['type'],
                            'message': issue['message'],
                            'severity': issue['severity']
                        })
    
    except Exception as e:
        pass
    
    return issues

def main():
    print("="*100)
    print("SMART APP CONTENT VALIDATION")
    print("Focusing on Real Grammar and Translation Issues")
    print("="*100)
    
    data_dir = Path('c:/Users/chawa/Downloads/App Test/eng_pocket/assets/data')
    
    all_issues = {
        'vocab': [],
        'reading_passages': [],
    }
    
    total_checked = 0
    
    # Check vocab files
    print(f"\nChecking VOCAB files...")
    vocab_files = sorted(data_dir.glob('vocab_part*.json'))
    for vocab_file in vocab_files:
        issues = check_vocab_file(vocab_file)
        if issues:
            all_issues['vocab'].extend(issues)
        total_checked += 1
        if total_checked % 20 == 0:
            print(f"  Checked {total_checked} files...")
    
    # Check reading passages
    print(f"\nChecking READING PASSAGES...")
    passage_file = data_dir / 'reading_passages.json'
    if passage_file.exists():
        issues = check_reading_passage(passage_file)
        all_issues['reading_passages'].extend(issues)
        total_checked += 1
    
    # Summary
    print(f"\n{'='*100}")
    print(f"VALIDATION SUMMARY")
    print(f"{'='*100}")
    
    total_issues = sum(len(v) for v in all_issues.values())
    print(f"Files checked: {total_checked}")
    print(f"Real issues found: {total_issues}")
    
    if total_issues > 0:
        print(f"\n{'='*100}")
        print(f"ISSUES BY SEVERITY")
        print(f"{'='*100}")
        
        issues_by_severity = defaultdict(list)
        
        for issues in all_issues.values():
            for issue in issues:
                issues_by_severity[issue['severity']].append(issue)
        
        for severity in ['high', 'medium', 'low']:
            if severity in issues_by_severity:
                count = len(issues_by_severity[severity])
                print(f"\n{severity.upper()}: {count} issues")
                
                # Group by type
                by_type = defaultdict(list)
                for issue in issues_by_severity[severity]:
                    by_type[issue['type']].append(issue)
                
                for issue_type, items in by_type.items():
                    print(f"  {issue_type}: {len(items)}")
                    
                    # Show first 3 examples
                    for item in items[:3]:
                        print(f"    - {item['id']} ({item['file']})")
                        print(f"      {item['message']}")
                        if 'value' in item:
                            print(f"      Value: '{item['value'][:60]}...'")
                    
                    if len(items) > 3:
                        print(f"    ... and {len(items) - 3} more")
    else:
        print("\n✅ No real issues found!")
    
    # Save report
    report_path = Path('c:/Users/chawa/Downloads/App Test/eng_pocket/scripts/smart_content_validation.json')
    
    report_data = {
        'summary': {
            'files_checked': total_checked,
            'total_issues': total_issues,
            'status': 'PASSED' if total_issues == 0 else 'NEEDS_REVIEW'
        },
        'issues_by_category': {k: len(v) for k, v in all_issues.items()},
        'all_issues': all_issues
    }
    
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump(report_data, f, ensure_ascii=False, indent=2)
    
    print(f"\n📄 Detailed report saved to: smart_content_validation.json")

if __name__ == '__main__':
    main()
