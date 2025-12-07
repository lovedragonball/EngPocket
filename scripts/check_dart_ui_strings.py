#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Check Dart UI strings for grammar and translation issues
"""
import re
from pathlib import Path
from collections import defaultdict

def check_dart_file(filepath):
    """Check a Dart file for UI text issues"""
    issues = []
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.split('\n')
        
        for line_num, line in enumerate(lines, 1):
            # Look for string literals (single and double quotes)
            # Match patterns like: 'text', "text", '''text''', """text"""
            
            # Find quoted strings
            patterns = [
                r"['\"]([^'\"]{5,})['\"]",  # Short strings
                r"'''(.+?)'''",  # Triple quoted
                r'"""(.+?)"""',  # Triple double quoted
            ]
            
            for pattern in patterns:
                matches = re.finditer(pattern, line)
                for match in matches:
                    text = match.group(1) if match.lastindex else match.group(0)
                    
                    # Skip code-related strings
                    if any(skip in text for skip in ['assets/', 'package:', '//', '/*', '*/','import', 'export', 'library']):
                        continue
                    
                    # Look for UI text
                    if re.search(r'[A-Z][a-z]+.*[\w\s]', text) or 'ย' in text or 'ก' in text:
                        item_issues = check_text(text, filepath.name, line_num)
                        issues.extend(item_issues)
    
    except Exception as e:
        pass
    
    return issues

def check_text(text, filename, line_num):
    """Check individual text for issues"""
    issues = []
    
    # Check for obvious grammar issues
    if len(text) > 10:
        # Missing spaces after punctuation
        if re.search(r'[,\.!?][A-Z]', text):
            issues.append({
                'file': filename,
                'line': line_num,
                'type': 'spacing',
                'text': text,
                'message': 'Missing space after punctuation',
                'severity': 'low'
            })
        
        # Check for double spaces
        if '  ' in text:
            issues.append({
                'file': filename,
                'line': line_num,
                'type': 'spacing',
                'text': text,
                'message': 'Extra spaces',
                'severity': 'low'
            })
    
    # Check Thai translations (if contains Thai)
    if re.search(r'[\u0E00-\u0E7F]', text):
        if len(text) < 2:
            issues.append({
                'file': filename,
                'line': line_num,
                'type': 'thai_translation',
                'text': text,
                'message': 'Thai translation too short',
                'severity': 'medium'
            })
    
    return issues

def main():
    print("="*100)
    print("DART UI STRINGS VALIDATION")
    print("="*100)
    
    lib_dir = Path('c:/Users/chawa/Downloads/App Test/eng_pocket/lib')
    
    dart_files = list(lib_dir.rglob('*.dart'))
    
    all_issues = []
    checked_count = 0
    
    for dart_file in dart_files:
        issues = check_dart_file(dart_file)
        if issues:
            all_issues.extend(issues)
        checked_count += 1
        
        if checked_count % 50 == 0:
            print(f"  Checked {checked_count} files...")
    
    print(f"\n{'='*100}")
    print(f"SUMMARY")
    print(f"{'='*100}")
    print(f"Dart files checked: {checked_count}")
    print(f"Potential issues found: {len(all_issues)}")
    
    if all_issues:
        # Group by severity
        by_severity = defaultdict(list)
        for issue in all_issues:
            by_severity[issue['severity']].append(issue)
        
        for severity in ['high', 'medium', 'low']:
            if severity in by_severity:
                print(f"\n{severity.upper()}: {len(by_severity[severity])}")
                for issue in by_severity[severity][:5]:
                    print(f"  - {issue['file']}:{issue['line']}")
                    print(f"    {issue['message']}")
                    print(f"    Text: '{issue['text'][:50]}...'")
    else:
        print("\n✅ No major issues found in Dart UI strings!")

if __name__ == '__main__':
    main()
