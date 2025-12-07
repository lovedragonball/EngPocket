#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Fix remaining body part issues in grammar quizzes
"""
import json
from pathlib import Path

# Map problematic phrases to replacements
PHRASE_REPLACEMENTS = {
    'closing his eyes': 'helping him',
    'closing her eyes': 'helping her',
    'closing their eyes': 'helping them',
    'closing my eyes': 'helping me',
    'closing your eyes': 'helping you',
    'closing our eyes': 'helping us',
    'close his eyes': 'help him',
    'close her eyes': 'help her',
    'close their eyes': 'help them',
    'close my eyes': 'help me',
    'close your eyes': 'help you',
    'close our eyes': 'help us',
    'closes his eyes': 'helps him',
    'closes her eyes': 'helps her',
    'closes their eyes': 'helps them',
    'closes my eyes': 'helps me',
    'closes your eyes': 'helps you',
    'closes our eyes': 'helps us',
    'closed his eyes': 'helped him',
    'closed her eyes': 'helped her',
    'closed their eyes': 'helped them',
    'closed my eyes': 'helped me',
    'closed your eyes': 'helped you',
    'closed our eyes': 'helped us',
}

def fix_quiz_file(filepath):
    """Fix issues in a quiz file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    fixed_count = 0
    
    for difficulty in ['easy', 'medium', 'hard']:
        if difficulty not in data:
            continue
        
        quizzes = data[difficulty]
        for quiz in quizzes:
            original_stem = quiz['stem']
            fixed_stem = original_stem
            
            # Replace problematic phrases (case-insensitive but preserve case)
            for old_phrase, new_phrase in PHRASE_REPLACEMENTS.items():
                if old_phrase.lower() in fixed_stem.lower():
                    # Find and replace while preserving case
                    import re
                    pattern = re.compile(re.escape(old_phrase), re.IGNORECASE)
                    if pattern.search(fixed_stem):
                        fixed_stem = pattern.sub(new_phrase, fixed_stem)
                        fixed_count += 1
                        break
            
            if fixed_stem != original_stem:
                quiz['stem'] = fixed_stem
    
    # Save the fixed file
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    return fixed_count

def main():
    quiz_dir = Path('c:/Users/chawa/Downloads/App Test/eng_pocket/assets/data/quiz')
    quiz_files = sorted(quiz_dir.glob('grammar_quiz_*.json'))
    
    print("="*80)
    print("FIXING REMAINING BODY PART ISSUES")
    print("="*80)
    
    total_fixed = 0
    for quiz_file in quiz_files:
        fixed = fix_quiz_file(quiz_file)
        if fixed > 0:
            print(f"{quiz_file.name}: {fixed} fixes")
            total_fixed += fixed
    
    print(f"\n{'='*80}")
    print(f"TOTAL FIXED: {total_fixed}")
    print(f"{'='*80}")

if __name__ == '__main__':
    main()
