#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fix grammar quiz issues and generate validation report
"""
import json
import os
import re
from pathlib import Path
from collections import defaultdict

# Define problematic patterns to fix
PROBLEMATIC_PHRASES = {
    # Pattern: (old_phrase, replacement, description)
    ('on weekends every weekend', 'every weekend', 'Redundant weekend expressions'),
    ('every weekend on weekends', 'every weekend', 'Redundant weekend expressions'),
}

# Problematic verbs with body parts (acting on someone else's body)
BODY_PART_ISSUES = {
    'close my eyes', 'closes my eyes', 'closed my eyes', 'closing my eyes',
    'close your eyes', 'closes your eyes', 'closed your eyes', 'closing your eyes',
    'close his eyes', 'closes his eyes', 'closed his eyes', 'closing his eyes',
    'close her eyes', 'closes her eyes', 'closed her eyes', 'closing her eyes',
    'close our eyes', 'closes our eyes', 'closed our eyes', 'closing our eyes',
    'close their eyes', 'closes their eyes', 'closed their eyes', 'closing their eyes',
}

def find_quiz_files():
    """Find all grammar quiz files"""
    quiz_dir = Path('c:/Users/chawa/Downloads/App Test/eng_pocket/assets/data/quiz')
    return sorted(quiz_dir.glob('grammar_quiz_*.json'))

def load_quiz_file(filepath):
    """Load quiz JSON file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_quiz_file(filepath, data):
    """Save quiz JSON file"""
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def check_redundant_phrases(stem):
    """Check for redundant phrases"""
    issues = []
    stem_lower = stem.lower()
    for old_phrase, replacement, desc in PROBLEMATIC_PHRASES:
        if old_phrase in stem_lower:
            issues.append({
                'type': 'Semantic',
                'description': desc,
                'old': old_phrase,
                'replacement': replacement
            })
    return issues

def check_body_part_issues(stem):
    """Check for problematic body part phrases"""
    issues = []
    stem_lower = stem.lower()
    for phrase in BODY_PART_ISSUES:
        if phrase in stem_lower:
            issues.append({
                'type': 'Semantic',
                'description': f'Problematic phrase: "{phrase}" - unclear meaning or awkward phrasing',
                'phrase': phrase
            })
    return issues

def check_capitalization_issues(stem):
    """Check for improper capitalization"""
    issues = []
    # Check for words like "If The", "When You", "When Mary" etc
    patterns = [
        r'\bIf\s+[A-Z]',  # If The, If My, If You
        r'\bWhen\s+[A-Z]',  # When You, When Mary
        r'\bAs\s+soon\s+as\s+[A-Z]',  # As soon as The
    ]
    
    for pattern in patterns:
        if re.search(pattern, stem):
            match = re.search(pattern, stem)
            if match:
                matched_text = match.group()
                # Extract the word after the conjunction
                words = matched_text.split()
                if len(words) > 1:
                    word = words[-1]
                    # Check if it should be lowercase
                    if word[0].isupper() and word.lower() not in ['I', 'My', 'Me', 'The']:
                        # These might be proper nouns, but usually should be lowercase
                        pass
                    if word in ['The', 'My', 'You', 'Your', 'Your']:
                        issues.append({
                            'type': 'Grammar',
                            'description': f'Improper capitalization: "{matched_text}" - "{word}" should be lowercase',
                            'text': matched_text
                        })
    
    return issues

def fix_stem(stem):
    """Fix issues in a stem"""
    fixed_stem = stem
    has_changes = False
    
    # Fix redundant phrases
    for old_phrase, replacement, _ in PROBLEMATIC_PHRASES:
        if old_phrase in fixed_stem.lower():
            # Case-insensitive replacement
            pattern = re.compile(re.escape(old_phrase), re.IGNORECASE)
            fixed_stem = pattern.sub(replacement, fixed_stem)
            has_changes = True
    
    # Fix capitalization after conjunctions
    # If The -> If the
    fixed_stem = re.sub(r'\bIf\s+The\b', 'If the', fixed_stem, flags=re.IGNORECASE)
    if re.search(r'\bIf\s+The\b', fixed_stem):
        has_changes = True
    
    # When You -> When you
    fixed_stem = re.sub(r'\bWhen\s+You\b', 'When you', fixed_stem)
    if re.search(r'\bWhen\s+You\b', fixed_stem):
        has_changes = True
    
    # When + Capital name (Mary, John, etc) - keep as is (proper nouns)
    
    # As soon as The -> As soon as the
    fixed_stem = re.sub(r'\bAs\s+soon\s+as\s+The\b', 'As soon as the', fixed_stem, flags=re.IGNORECASE)
    if re.search(r'\bAs\s+soon\s+as\s+The\b', fixed_stem):
        has_changes = True
    
    # Did My -> Did my
    fixed_stem = re.sub(r'\bDid\s+My\b', 'Did my', fixed_stem)
    if re.search(r'\bDid\s+My\b', fixed_stem):
        has_changes = True
    
    # Does the -> remove "does" for question with blank
    # "does the chef _____ my eyes?" should be "Does the chef _____ my eyes?"
    fixed_stem = re.sub(r'\bdoes\s+the\b', 'Does the', fixed_stem)
    if re.search(r'\bdoes\s+the\b', fixed_stem):
        has_changes = True
    
    return fixed_stem, has_changes

def process_all_quizzes():
    """Process all quiz files"""
    quiz_files = find_quiz_files()
    
    total_fixed = 0
    fixes_by_file = defaultdict(list)
    
    for quiz_file in quiz_files:
        print(f"\nProcessing: {quiz_file.name}")
        quiz_data = load_quiz_file(quiz_file)
        
        # Process each difficulty level
        for difficulty in ['easy', 'medium', 'hard']:
            if difficulty not in quiz_data:
                continue
            
            quizzes = quiz_data[difficulty]
            for idx, quiz in enumerate(quizzes):
                original_stem = quiz['stem']
                fixed_stem, has_changes = fix_stem(original_stem)
                
                if has_changes:
                    quiz['stem'] = fixed_stem
                    total_fixed += 1
                    fixes_by_file[quiz_file.name].append({
                        'id': quiz.get('id', f'unknown_{idx}'),
                        'difficulty': difficulty,
                        'before': original_stem,
                        'after': fixed_stem
                    })
        
        # Save the fixed file
        save_quiz_file(quiz_file, quiz_data)
        print(f"  ✓ Fixed {len(fixes_by_file[quiz_file.name])} issues")
    
    return fixes_by_file, total_fixed

def validate_all_quizzes():
    """Validate all quizzes for remaining issues"""
    quiz_files = find_quiz_files()
    
    all_issues = []
    issues_by_type = defaultdict(list)
    
    for quiz_file in quiz_files:
        print(f"\nValidating: {quiz_file.name}")
        quiz_data = load_quiz_file(quiz_file)
        
        for difficulty in ['easy', 'medium', 'hard']:
            if difficulty not in quiz_data:
                continue
            
            quizzes = quiz_data[difficulty]
            for idx, quiz in enumerate(quizzes):
                stem = quiz['stem']
                quiz_id = quiz.get('id', f'unknown_{idx}')
                
                # Check for various issues
                issues = []
                issues.extend(check_redundant_phrases(stem))
                issues.extend(check_body_part_issues(stem))
                issues.extend(check_capitalization_issues(stem))
                
                if issues:
                    for issue in issues:
                        all_issues.append({
                            'id': quiz_id,
                            'file': quiz_file.name,
                            'difficulty': difficulty,
                            'stem': stem,
                            'choices': quiz['choices'],
                            'correctIndex': quiz['correctIndex'],
                            **issue
                        })
                        issues_by_type[issue['type']].append(quiz_id)
    
    return all_issues, issues_by_type

def main():
    print("="*80)
    print("FIXING GRAMMAR QUIZ ISSUES")
    print("="*80)
    
    # Fix issues
    fixes_by_file, total_fixed = process_all_quizzes()
    
    print(f"\n{'='*80}")
    print(f"SUMMARY OF FIXES: {total_fixed} total fixes applied")
    print(f"{'='*80}")
    
    for filename, fixes in sorted(fixes_by_file.items()):
        if fixes:
            print(f"\n{filename}: {len(fixes)} fixes")
            for fix in fixes[:3]:  # Show first 3
                print(f"  - {fix['id']}: '{fix['before'][:50]}...' → '{fix['after'][:50]}...'")
            if len(fixes) > 3:
                print(f"  ... and {len(fixes) - 3} more")
    
    # Validate again
    print(f"\n{'='*80}")
    print("VALIDATING QUIZZES AFTER FIXES")
    print(f"{'='*80}")
    
    all_issues, issues_by_type = validate_all_quizzes()
    
    if all_issues:
        print(f"\n⚠️  REMAINING ISSUES FOUND: {len(all_issues)}")
        
        for issue_type, count in issues_by_type.items():
            print(f"\n{issue_type} Issues: {len(set(count))} unique items")
            print(f"  Examples:")
            examples = set(count)
            for example_id in list(examples)[:5]:
                for issue in all_issues:
                    if issue['id'] == example_id:
                        print(f"    - {example_id}: {issue.get('description', issue.get('type', 'Unknown'))}")
                        print(f"      Stem: '{issue['stem'][:60]}...'")
                        break
    else:
        print("\n✅ NO ISSUES FOUND! All quizzes are valid.")
    
    # Save detailed report
    report = {
        'summary': {
            'total_fixed': total_fixed,
            'fixes_by_file': {k: len(v) for k, v in fixes_by_file.items()},
            'remaining_issues': len(all_issues),
            'issues_by_type': {k: len(v) for k, v in issues_by_type.items()}
        },
        'fixes': fixes_by_file,
        'remaining_issues': all_issues
    }
    
    report_path = Path('c:/Users/chawa/Downloads/App Test/eng_pocket/scripts/grammar_fixes_report.json')
    with open(report_path, 'w', encoding='utf-8') as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    
    print(f"\n📄 Detailed report saved to: grammar_fixes_report.json")

if __name__ == '__main__':
    main()
