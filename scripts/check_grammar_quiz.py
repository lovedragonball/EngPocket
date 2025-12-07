"""
Grammar Quiz Validator
ตรวจสอบข้อสอบ grammar ว่ามีข้อไหนไม่ถูกต้องบ้าง
"""
import json
import os
from pathlib import Path

# Path to quiz files
QUIZ_DIR = Path(__file__).parent.parent / "assets" / "data" / "quiz"

def load_all_quizzes():
    """Load all grammar quiz files"""
    quizzes = []
    for file in sorted(QUIZ_DIR.glob("grammar_quiz_*.json")):
        with open(file, "r", encoding="utf-8") as f:
            data = json.load(f)
            file_name = file.name
            for difficulty in ["easy", "medium", "hard"]:
                if difficulty in data:
                    for q in data[difficulty]:
                        q["_file"] = file_name
                        q["_difficulty"] = difficulty
                        quizzes.append(q)
    return quizzes

def count_quizzes():
    """Count quizzes per file and total"""
    total = 0
    print("\n=== Quiz Count Per File ===")
    for file in sorted(QUIZ_DIR.glob("grammar_quiz_*.json")):
        with open(file, "r", encoding="utf-8") as f:
            data = json.load(f)
        count = 0
        for difficulty in ["easy", "medium", "hard"]:
            if difficulty in data:
                count += len(data[difficulty])
        print(f"{file.name}: {count:,} questions")
        total += count
    print(f"\n=== Total: {total:,} questions ===\n")
    return total

def check_basic_structure(question):
    """Check if question has all required fields"""
    required_fields = ["stem", "choices", "correctIndex", "explanation", "id"]
    issues = []
    
    for field in required_fields:
        if field not in question:
            issues.append(f"Missing field: {field}")
    
    if "choices" in question:
        if len(question["choices"]) != 4:
            issues.append(f"Expected 4 choices, got {len(question['choices'])}")
        
        if "correctIndex" in question:
            if question["correctIndex"] < 0 or question["correctIndex"] >= len(question["choices"]):
                issues.append(f"Invalid correctIndex: {question['correctIndex']}")
    
    return issues

def check_grammar_issues(question):
    """Check for common grammar issues in the question stem and choices"""
    issues = []
    stem = question.get("stem", "")
    choices = question.get("choices", [])
    correct_idx = question.get("correctIndex", 0)
    
    if correct_idx >= len(choices):
        return [f"correctIndex {correct_idx} out of range"]
    
    correct_answer = choices[correct_idx] if choices else ""
    
    # Check if stem has blank placeholder
    if "_____" not in stem and "____" not in stem:
        issues.append("Stem missing blank placeholder (_____)")
    
    # Check for double spaces
    if "  " in stem:
        issues.append("Double spaces in stem")
    
    # Check for common sense issues
    stem_lower = stem.lower()
    
    # Detect subject-verb agreement issues
    singular_subjects = ["he", "she", "it", "my father", "my mother", "the teacher", 
                         "john", "mary", "tom", "lisa", "david", "sarah", "my brother",
                         "my sister", "the chef", "the manager", "the engineer", "the doctor",
                         "the nurse", "the artist", "the lawyer", "my boss", "the driver",
                         "the pilot", "the student", "my uncle", "my aunt", "the boy", 
                         "the girl", "the man", "the woman"]
    
    plural_subjects = ["i", "you", "we", "they", "my parents", "the students", "the teachers",
                       "my friends", "the workers", "tom and mary", "the doctors", "the children",
                       "the engineers", "the artists", "my colleagues", "the nurses", "the boys",
                       "the girls", "people", "many people"]
    
    return issues

def check_semantic_issues(question):
    """Check for semantic/logical issues in sentences"""
    issues = []
    stem = question.get("stem", "")
    choices = question.get("choices", [])
    correct_idx = question.get("correctIndex", 0)
    
    if correct_idx >= len(choices):
        return issues
    
    # Fill in the blank to check full sentence
    correct_answer = choices[correct_idx]
    full_sentence = stem.replace("_____", correct_answer).replace("____", correct_answer)
    
    # Check for weird semantic combinations
    semantic_checks = [
        # Check "closes my eyes" issues - one person closing someone else's body parts
        (r"(he|she|my father|my mother|the teacher|john|mary|tom|lisa|david|sarah|the man|the woman|the boy|the girl).*closes?\s+my\s+(eyes|ears|mouth|nose)", 
         "Semantic: Person closing someone else's body parts"),
        
        # More pattern checks can be added here
    ]
    
    import re
    full_lower = full_sentence.lower()
    
    for pattern, message in semantic_checks:
        if re.search(pattern, full_lower):
            issues.append(message)
    
    return issues

def check_duplicate_phrases(quizzes):
    """Find duplicate stems or very similar questions"""
    stems = {}
    duplicates = []
    
    for q in quizzes:
        stem = q.get("stem", "")
        if stem in stems:
            duplicates.append({
                "stem": stem,
                "question1": stems[stem],
                "question2": q["id"]
            })
        else:
            stems[stem] = q.get("id", "unknown")
    
    return duplicates

def validate_all_quizzes():
    """Main validation function"""
    quizzes = load_all_quizzes()
    
    print(f"Loaded {len(quizzes):,} questions")
    
    all_issues = []
    
    for q in quizzes:
        issues = []
        
        # Basic structure check
        issues.extend(check_basic_structure(q))
        
        # Grammar issues
        issues.extend(check_grammar_issues(q))
        
        # Semantic issues
        issues.extend(check_semantic_issues(q))
        
        if issues:
            all_issues.append({
                "id": q.get("id", "unknown"),
                "file": q.get("_file", "unknown"),
                "difficulty": q.get("_difficulty", "unknown"),
                "stem": q.get("stem", ""),
                "correct_answer": q.get("choices", [])[q.get("correctIndex", 0)] if q.get("choices") else "",
                "issues": issues
            })
    
    return all_issues

def generate_report():
    """Generate a comprehensive report"""
    print("=" * 60)
    print("Grammar Quiz Validation Report")
    print("=" * 60)
    
    # Count quizzes
    total = count_quizzes()
    
    # Validate
    print("Validating questions...")
    issues = validate_all_quizzes()
    
    if issues:
        print(f"\n=== Found {len(issues)} questions with issues ===\n")
        
        # Group by issue type
        issue_counts = {}
        for item in issues:
            for issue in item["issues"]:
                issue_counts[issue] = issue_counts.get(issue, 0) + 1
        
        print("Issue Summary:")
        for issue, count in sorted(issue_counts.items(), key=lambda x: -x[1]):
            print(f"  - {issue}: {count}")
        
        print("\n" + "=" * 60)
        print("Detailed Issues (first 50):")
        print("=" * 60)
        
        for i, item in enumerate(issues[:50]):
            print(f"\n{i+1}. [{item['file']}] {item['id']}")
            print(f"   Difficulty: {item['difficulty']}")
            print(f"   Stem: {item['stem']}")
            print(f"   Answer: {item['correct_answer']}")
            for issue in item["issues"]:
                print(f"   ⚠️ {issue}")
        
        # Save full report
        report_path = Path(__file__).parent / "grammar_issues_report.json"
        with open(report_path, "w", encoding="utf-8") as f:
            json.dump(issues, f, ensure_ascii=False, indent=2)
        print(f"\n\nFull report saved to: {report_path}")
    else:
        print("\n✅ No issues found!")
    
    # Check for duplicates
    print("\n" + "=" * 60)
    print("Checking for duplicates...")
    print("=" * 60)
    
    quizzes = load_all_quizzes()
    duplicates = check_duplicate_phrases(quizzes)
    
    if duplicates:
        print(f"\nFound {len(duplicates)} duplicate stems:")
        for i, dup in enumerate(duplicates[:20]):
            print(f"\n{i+1}. {dup['stem'][:80]}...")
            print(f"   IDs: {dup['question1']} and {dup['question2']}")
    else:
        print("No duplicate stems found.")

if __name__ == "__main__":
    generate_report()
