#!/usr/bin/env python3
"""
Grammar Quiz Generator
Generates 5,000 questions per tense for 13 grammar topics (65,000 total)
"""

import json
import random
import os
from typing import List, Dict, Tuple

# ===== VOCABULARY DATA =====

SUBJECTS_SINGULAR = [
    "He", "She", "It", "My father", "My mother", "The teacher", "The student",
    "The doctor", "The cat", "The dog", "John", "Mary", "Tom", "Lisa", "David",
    "Sarah", "The baby", "The bird", "The sun", "The moon", "The manager",
    "The chef", "The driver", "The pilot", "The nurse", "My brother", "My sister",
    "The boy", "The girl", "The man", "The woman", "The child", "The artist",
    "The scientist", "The engineer", "The lawyer", "The policeman", "The farmer"
]

SUBJECTS_PLURAL = [
    "I", "You", "We", "They", "The students", "The teachers", "The children",
    "My parents", "The workers", "The people", "The birds", "The dogs", "The cats",
    "Tom and Mary", "The boys", "The girls", "My friends", "The scientists",
    "The engineers", "The farmers", "The doctors", "The nurses", "The artists"
]

VERBS_BASE = {
    "eat": {"v1": "eat", "v2": "ate", "v3": "eaten", "ving": "eating", "v1_s": "eats"},
    "drink": {"v1": "drink", "v2": "drank", "v3": "drunk", "ving": "drinking", "v1_s": "drinks"},
    "go": {"v1": "go", "v2": "went", "v3": "gone", "ving": "going", "v1_s": "goes"},
    "come": {"v1": "come", "v2": "came", "v3": "come", "ving": "coming", "v1_s": "comes"},
    "play": {"v1": "play", "v2": "played", "v3": "played", "ving": "playing", "v1_s": "plays"},
    "work": {"v1": "work", "v2": "worked", "v3": "worked", "ving": "working", "v1_s": "works"},
    "study": {"v1": "study", "v2": "studied", "v3": "studied", "ving": "studying", "v1_s": "studies"},
    "read": {"v1": "read", "v2": "read", "v3": "read", "ving": "reading", "v1_s": "reads"},
    "write": {"v1": "write", "v2": "wrote", "v3": "written", "ving": "writing", "v1_s": "writes"},
    "speak": {"v1": "speak", "v2": "spoke", "v3": "spoken", "ving": "speaking", "v1_s": "speaks"},
    "run": {"v1": "run", "v2": "ran", "v3": "run", "ving": "running", "v1_s": "runs"},
    "walk": {"v1": "walk", "v2": "walked", "v3": "walked", "ving": "walking", "v1_s": "walks"},
    "sleep": {"v1": "sleep", "v2": "slept", "v3": "slept", "ving": "sleeping", "v1_s": "sleeps"},
    "wake": {"v1": "wake", "v2": "woke", "v3": "woken", "ving": "waking", "v1_s": "wakes"},
    "cook": {"v1": "cook", "v2": "cooked", "v3": "cooked", "ving": "cooking", "v1_s": "cooks"},
    "clean": {"v1": "clean", "v2": "cleaned", "v3": "cleaned", "ving": "cleaning", "v1_s": "cleans"},
    "watch": {"v1": "watch", "v2": "watched", "v3": "watched", "ving": "watching", "v1_s": "watches"},
    "listen": {"v1": "listen", "v2": "listened", "v3": "listened", "ving": "listening", "v1_s": "listens"},
    "buy": {"v1": "buy", "v2": "bought", "v3": "bought", "ving": "buying", "v1_s": "buys"},
    "sell": {"v1": "sell", "v2": "sold", "v3": "sold", "ving": "selling", "v1_s": "sells"},
    "make": {"v1": "make", "v2": "made", "v3": "made", "ving": "making", "v1_s": "makes"},
    "take": {"v1": "take", "v2": "took", "v3": "taken", "ving": "taking", "v1_s": "takes"},
    "give": {"v1": "give", "v2": "gave", "v3": "given", "ving": "giving", "v1_s": "gives"},
    "send": {"v1": "send", "v2": "sent", "v3": "sent", "ving": "sending", "v1_s": "sends"},
    "teach": {"v1": "teach", "v2": "taught", "v3": "taught", "ving": "teaching", "v1_s": "teaches"},
    "learn": {"v1": "learn", "v2": "learned", "v3": "learned", "ving": "learning", "v1_s": "learns"},
    "know": {"v1": "know", "v2": "knew", "v3": "known", "ving": "knowing", "v1_s": "knows"},
    "think": {"v1": "think", "v2": "thought", "v3": "thought", "ving": "thinking", "v1_s": "thinks"},
    "see": {"v1": "see", "v2": "saw", "v3": "seen", "ving": "seeing", "v1_s": "sees"},
    "hear": {"v1": "hear", "v2": "heard", "v3": "heard", "ving": "hearing", "v1_s": "hears"},
    "feel": {"v1": "feel", "v2": "felt", "v3": "felt", "ving": "feeling", "v1_s": "feels"},
    "love": {"v1": "love", "v2": "loved", "v3": "loved", "ving": "loving", "v1_s": "loves"},
    "like": {"v1": "like", "v2": "liked", "v3": "liked", "ving": "liking", "v1_s": "likes"},
    "want": {"v1": "want", "v2": "wanted", "v3": "wanted", "ving": "wanting", "v1_s": "wants"},
    "need": {"v1": "need", "v2": "needed", "v3": "needed", "ving": "needing", "v1_s": "needs"},
    "help": {"v1": "help", "v2": "helped", "v3": "helped", "ving": "helping", "v1_s": "helps"},
    "start": {"v1": "start", "v2": "started", "v3": "started", "ving": "starting", "v1_s": "starts"},
    "finish": {"v1": "finish", "v2": "finished", "v3": "finished", "ving": "finishing", "v1_s": "finishes"},
    "begin": {"v1": "begin", "v2": "began", "v3": "begun", "ving": "beginning", "v1_s": "begins"},
    "end": {"v1": "end", "v2": "ended", "v3": "ended", "ving": "ending", "v1_s": "ends"},
    "open": {"v1": "open", "v2": "opened", "v3": "opened", "ving": "opening", "v1_s": "opens"},
    "close": {"v1": "close", "v2": "closed", "v3": "closed", "ving": "closing", "v1_s": "closes"},
    "live": {"v1": "live", "v2": "lived", "v3": "lived", "ving": "living", "v1_s": "lives"},
    "die": {"v1": "die", "v2": "died", "v3": "died", "ving": "dying", "v1_s": "dies"},
    "arrive": {"v1": "arrive", "v2": "arrived", "v3": "arrived", "ving": "arriving", "v1_s": "arrives"},
    "leave": {"v1": "leave", "v2": "left", "v3": "left", "ving": "leaving", "v1_s": "leaves"},
    "visit": {"v1": "visit", "v2": "visited", "v3": "visited", "ving": "visiting", "v1_s": "visits"},
    "stay": {"v1": "stay", "v2": "stayed", "v3": "stayed", "ving": "staying", "v1_s": "stays"},
    "wait": {"v1": "wait", "v2": "waited", "v3": "waited", "ving": "waiting", "v1_s": "waits"},
    "call": {"v1": "call", "v2": "called", "v3": "called", "ving": "calling", "v1_s": "calls"},
    "meet": {"v1": "meet", "v2": "met", "v3": "met", "ving": "meeting", "v1_s": "meets"},
    "find": {"v1": "find", "v2": "found", "v3": "found", "ving": "finding", "v1_s": "finds"},
    "lose": {"v1": "lose", "v2": "lost", "v3": "lost", "ving": "losing", "v1_s": "loses"},
    "win": {"v1": "win", "v2": "won", "v3": "won", "ving": "winning", "v1_s": "wins"},
    "break": {"v1": "break", "v2": "broke", "v3": "broken", "ving": "breaking", "v1_s": "breaks"},
    "fix": {"v1": "fix", "v2": "fixed", "v3": "fixed", "ving": "fixing", "v1_s": "fixes"},
    "build": {"v1": "build", "v2": "built", "v3": "built", "ving": "building", "v1_s": "builds"},
    "drive": {"v1": "drive", "v2": "drove", "v3": "driven", "ving": "driving", "v1_s": "drives"},
    "fly": {"v1": "fly", "v2": "flew", "v3": "flown", "ving": "flying", "v1_s": "flies"},
    "swim": {"v1": "swim", "v2": "swam", "v3": "swum", "ving": "swimming", "v1_s": "swims"},
    "sing": {"v1": "sing", "v2": "sang", "v3": "sung", "ving": "singing", "v1_s": "sings"},
    "dance": {"v1": "dance", "v2": "danced", "v3": "danced", "ving": "dancing", "v1_s": "dances"},
    "paint": {"v1": "paint", "v2": "painted", "v3": "painted", "ving": "painting", "v1_s": "paints"},
    "draw": {"v1": "draw", "v2": "drew", "v3": "drawn", "ving": "drawing", "v1_s": "draws"},
    "grow": {"v1": "grow", "v2": "grew", "v3": "grown", "ving": "growing", "v1_s": "grows"},
    "cut": {"v1": "cut", "v2": "cut", "v3": "cut", "ving": "cutting", "v1_s": "cuts"},
    "pay": {"v1": "pay", "v2": "paid", "v3": "paid", "ving": "paying", "v1_s": "pays"},
    "spend": {"v1": "spend", "v2": "spent", "v3": "spent", "ving": "spending", "v1_s": "spends"},
    "save": {"v1": "save", "v2": "saved", "v3": "saved", "ving": "saving", "v1_s": "saves"},
    "change": {"v1": "change", "v2": "changed", "v3": "changed", "ving": "changing", "v1_s": "changes"},
    "move": {"v1": "move", "v2": "moved", "v3": "moved", "ving": "moving", "v1_s": "moves"},
    "stop": {"v1": "stop", "v2": "stopped", "v3": "stopped", "ving": "stopping", "v1_s": "stops"},
    "try": {"v1": "try", "v2": "tried", "v3": "tried", "ving": "trying", "v1_s": "tries"},
    "use": {"v1": "use", "v2": "used", "v3": "used", "ving": "using", "v1_s": "uses"},
    "show": {"v1": "show", "v2": "showed", "v3": "shown", "ving": "showing", "v1_s": "shows"},
    "tell": {"v1": "tell", "v2": "told", "v3": "told", "ving": "telling", "v1_s": "tells"},
    "ask": {"v1": "ask", "v2": "asked", "v3": "asked", "ving": "asking", "v1_s": "asks"},
    "answer": {"v1": "answer", "v2": "answered", "v3": "answered", "ving": "answering", "v1_s": "answers"},
    "explain": {"v1": "explain", "v2": "explained", "v3": "explained", "ving": "explaining", "v1_s": "explains"},
    "understand": {"v1": "understand", "v2": "understood", "v3": "understood", "ving": "understanding", "v1_s": "understands"},
    "remember": {"v1": "remember", "v2": "remembered", "v3": "remembered", "ving": "remembering", "v1_s": "remembers"},
    "forget": {"v1": "forget", "v2": "forgot", "v3": "forgotten", "ving": "forgetting", "v1_s": "forgets"},
    "believe": {"v1": "believe", "v2": "believed", "v3": "believed", "ving": "believing", "v1_s": "believes"},
    "hope": {"v1": "hope", "v2": "hoped", "v3": "hoped", "ving": "hoping", "v1_s": "hopes"},
    "wish": {"v1": "wish", "v2": "wished", "v3": "wished", "ving": "wishing", "v1_s": "wishes"},
    "decide": {"v1": "decide", "v2": "decided", "v3": "decided", "ving": "deciding", "v1_s": "decides"},
    "choose": {"v1": "choose", "v2": "chose", "v3": "chosen", "ving": "choosing", "v1_s": "chooses"},
    "wear": {"v1": "wear", "v2": "wore", "v3": "worn", "ving": "wearing", "v1_s": "wears"},
    "carry": {"v1": "carry", "v2": "carried", "v3": "carried", "ving": "carrying", "v1_s": "carries"},
    "hold": {"v1": "hold", "v2": "held", "v3": "held", "ving": "holding", "v1_s": "holds"},
    "throw": {"v1": "throw", "v2": "threw", "v3": "thrown", "ving": "throwing", "v1_s": "throws"},
    "catch": {"v1": "catch", "v2": "caught", "v3": "caught", "ving": "catching", "v1_s": "catches"},
    "sit": {"v1": "sit", "v2": "sat", "v3": "sat", "ving": "sitting", "v1_s": "sits"},
    "stand": {"v1": "stand", "v2": "stood", "v3": "stood", "ving": "standing", "v1_s": "stands"},
    "fall": {"v1": "fall", "v2": "fell", "v3": "fallen", "ving": "falling", "v1_s": "falls"},
    "rise": {"v1": "rise", "v2": "rose", "v3": "risen", "ving": "rising", "v1_s": "rises"},
    "set": {"v1": "set", "v2": "set", "v3": "set", "ving": "setting", "v1_s": "sets"},
    "put": {"v1": "put", "v2": "put", "v3": "put", "ving": "putting", "v1_s": "puts"},
    "bring": {"v1": "bring", "v2": "brought", "v3": "brought", "ving": "bringing", "v1_s": "brings"},
    "get": {"v1": "get", "v2": "got", "v3": "gotten", "ving": "getting", "v1_s": "gets"},
    "become": {"v1": "become", "v2": "became", "v3": "become", "ving": "becoming", "v1_s": "becomes"},
    "keep": {"v1": "keep", "v2": "kept", "v3": "kept", "ving": "keeping", "v1_s": "keeps"},
    "let": {"v1": "let", "v2": "let", "v3": "let", "ving": "letting", "v1_s": "lets"},
    "seem": {"v1": "seem", "v2": "seemed", "v3": "seemed", "ving": "seeming", "v1_s": "seems"},
    "appear": {"v1": "appear", "v2": "appeared", "v3": "appeared", "ving": "appearing", "v1_s": "appears"},
    "happen": {"v1": "happen", "v2": "happened", "v3": "happened", "ving": "happening", "v1_s": "happens"},
}

OBJECTS = [
    "breakfast", "lunch", "dinner", "coffee", "tea", "water", "food",
    "the book", "the newspaper", "the letter", "the email", "the message",
    "English", "math", "science", "music", "piano", "guitar",
    "football", "basketball", "tennis", "chess", "games",
    "TV", "movies", "the news", "YouTube", "videos",
    "the house", "the room", "the car", "the bike", "the phone",
    "homework", "the project", "the report", "the exam", "the test",
    "clothes", "shoes", "glasses", "a hat", "a jacket",
    "money", "time", "energy", "effort", "attention",
    "friends", "family", "colleagues", "neighbors", "customers"
]

TIME_PRESENT = ["every day", "every morning", "every week", "every month", "always", "usually", "often", "sometimes", "never"]
TIME_PAST = ["yesterday", "last night", "last week", "last month", "last year", "two days ago", "three hours ago", "in 2020"]
TIME_FUTURE = ["tomorrow", "next week", "next month", "next year", "soon", "in the future", "later", "tonight"]
TIME_CONTINUOUS = ["now", "right now", "at the moment", "currently", "at this time"]
TIME_PERFECT = ["already", "just", "recently", "ever", "never", "yet", "since 2020", "for 5 years", "so far"]
DURATION = ["for 2 hours", "for 3 days", "for a week", "for a month", "for a year", "since morning", "since yesterday", "all day", "all week"]

FREQUENCY = ["always", "usually", "often", "sometimes", "rarely", "never", "seldom", "frequently"]

# ===== TENSE CONFIGURATIONS =====

TENSES = [
    {
        "id": "grammar_001",
        "name": "present_simple",
        "title": "Present Simple",
        "pack_id": "grammar_001"
    },
    {
        "id": "grammar_002", 
        "name": "present_continuous",
        "title": "Present Continuous",
        "pack_id": "grammar_002"
    },
    {
        "id": "grammar_003",
        "name": "present_perfect",
        "title": "Present Perfect",
        "pack_id": "grammar_003"
    },
    {
        "id": "grammar_004",
        "name": "present_perfect_continuous",
        "title": "Present Perfect Continuous",
        "pack_id": "grammar_004"
    },
    {
        "id": "grammar_005",
        "name": "past_simple",
        "title": "Past Simple",
        "pack_id": "grammar_005"
    },
    {
        "id": "grammar_006",
        "name": "past_continuous",
        "title": "Past Continuous",
        "pack_id": "grammar_006"
    },
    {
        "id": "grammar_007",
        "name": "past_perfect",
        "title": "Past Perfect",
        "pack_id": "grammar_007"
    },
    {
        "id": "grammar_008",
        "name": "past_perfect_continuous",
        "title": "Past Perfect Continuous",
        "pack_id": "grammar_008"
    },
    {
        "id": "grammar_009",
        "name": "future_simple",
        "title": "Future Simple",
        "pack_id": "grammar_009"
    },
    {
        "id": "grammar_010",
        "name": "future_continuous",
        "title": "Future Continuous",
        "pack_id": "grammar_010"
    },
    {
        "id": "grammar_011",
        "name": "future_perfect",
        "title": "Future Perfect",
        "pack_id": "grammar_011"
    },
    {
        "id": "grammar_012",
        "name": "future_perfect_continuous",
        "title": "Future Perfect Continuous",
        "pack_id": "grammar_012"
    },
    {
        "id": "grammar_013",
        "name": "passive_voice",
        "title": "Passive Voice",
        "pack_id": "grammar_013"
    }
]

# ===== QUESTION GENERATORS =====

def generate_present_simple(verb_key: str, verb: dict, is_singular: bool, difficulty: str) -> dict:
    """Generate a Present Simple question"""
    subject = random.choice(SUBJECTS_SINGULAR if is_singular else SUBJECTS_PLURAL)
    obj = random.choice(OBJECTS)
    time = random.choice(TIME_PRESENT)
    
    correct = verb["v1_s"] if is_singular else verb["v1"]
    
    if difficulty == "easy":
        stem = f"{subject} _____ {obj} {time}."
        explanation = f"ใช้ '{correct}' เพราะ{'ประธานเป็นเอกพจน์บุรุษที่ 3 ต้องเติม -s/-es' if is_singular else 'ประธานเป็นพหูพจน์ ใช้ V1'}"
    elif difficulty == "medium":
        freq = random.choice(FREQUENCY)
        stem = f"{subject} {freq} _____ {obj}."
        explanation = f"ใช้ '{correct}' เพราะมีคำบ่งชี้ '{freq}' แสดงกิจวัตร"
    else:  # hard
        stem = f"When it rains, {subject.lower() if subject[0].isupper() and subject not in ['I'] else subject} _____ {obj}."
        explanation = f"ใช้ '{correct}' ใน conditional clause สำหรับความจริงทั่วไป"
    
    # Generate distractors
    choices = [correct]
    distractors = [verb["v2"], verb["ving"], verb["v3"]]
    if is_singular:
        distractors.append(verb["v1"])
    else:
        distractors.append(verb["v1_s"])
    
    for d in distractors:
        if d not in choices and len(choices) < 4:
            choices.append(d)
    
    while len(choices) < 4:
        choices.append(random.choice(list(VERBS_BASE.values()))["v1"])
    
    random.shuffle(choices)
    correct_index = choices.index(correct)
    
    return {
        "stem": stem,
        "choices": choices[:4],
        "correctIndex": correct_index,
        "explanation": explanation
    }


def generate_present_continuous(verb_key: str, verb: dict, is_singular: bool, difficulty: str) -> dict:
    """Generate a Present Continuous question"""
    subject = random.choice(SUBJECTS_SINGULAR if is_singular else SUBJECTS_PLURAL)
    obj = random.choice(OBJECTS)
    time = random.choice(TIME_CONTINUOUS)
    
    be_verb = "is" if is_singular else ("am" if subject == "I" else "are")
    correct = f"{be_verb} {verb['ving']}"
    
    if difficulty == "easy":
        stem = f"{subject} _____ {obj} {time}."
        explanation = f"ใช้ '{correct}' เพราะมีคำว่า '{time}' แสดงเหตุการณ์ที่กำลังเกิดขึ้น"
    elif difficulty == "medium":
        stem = f"Look! {subject} _____ {obj}."
        explanation = f"ใช้ '{correct}' เพราะมี Look! แสดงเหตุการณ์ที่กำลังเกิด"
    else:  # hard
        stem = f"{subject} _____ {obj} these days. It's just a temporary situation."
        explanation = f"ใช้ '{correct}' สำหรับสถานการณ์ชั่วคราว"
    
    choices = [correct]
    distractors = [
        verb["v1"],
        verb["v1_s"],
        verb["v2"],
        f"was {verb['ving']}",
        f"were {verb['ving']}"
    ]
    
    for d in distractors:
        if d not in choices and len(choices) < 4:
            choices.append(d)
    
    random.shuffle(choices)
    correct_index = choices.index(correct)
    
    return {
        "stem": stem,
        "choices": choices[:4],
        "correctIndex": correct_index,
        "explanation": explanation
    }


def generate_present_perfect(verb_key: str, verb: dict, is_singular: bool, difficulty: str) -> dict:
    """Generate a Present Perfect question"""
    subject = random.choice(SUBJECTS_SINGULAR if is_singular else SUBJECTS_PLURAL)
    obj = random.choice(OBJECTS)
    time = random.choice(TIME_PERFECT)
    
    have_verb = "has" if is_singular else "have"
    correct = f"{have_verb} {verb['v3']}"
    
    if difficulty == "easy":
        stem = f"{subject} _____ {time} {verb['v3']} {obj}."
        stem = f"{subject} {time.split()[0] if ' ' in time else ''} _____ {obj}."
        explanation = f"ใช้ '{correct}' เพราะมี '{time}' บ่งชี้ Present Perfect"
    elif difficulty == "medium":
        stem = f"{subject} _____ {obj} since last year."
        explanation = f"ใช้ '{correct}' กับ since สำหรับช่วงเวลาจากอดีตถึงปัจจุบัน"
    else:  # hard
        stem = f"This is the best {obj} {subject.lower() if subject != 'I' else 'I'} _____ ever _____."
        correct = f"{have_verb}/{verb['v3']}"
        explanation = f"ใช้ {have_verb} {verb['v3']} กับ superlative + ever"
    
    choices = [correct]
    distractors = [
        verb["v1"],
        verb["v2"],
        f"had {verb['v3']}",
        f"{'has' if not is_singular else 'have'} {verb['v3']}"
    ]
    
    for d in distractors:
        if d not in choices and len(choices) < 4:
            choices.append(d)
    
    random.shuffle(choices)
    correct_index = choices.index(correct)
    
    return {
        "stem": stem,
        "choices": choices[:4],
        "correctIndex": correct_index,
        "explanation": explanation
    }


def generate_present_perfect_continuous(verb_key: str, verb: dict, is_singular: bool, difficulty: str) -> dict:
    """Generate a Present Perfect Continuous question"""
    subject = random.choice(SUBJECTS_SINGULAR if is_singular else SUBJECTS_PLURAL)
    duration = random.choice(DURATION)
    
    have_verb = "has" if is_singular else "have"
    correct = f"{have_verb} been {verb['ving']}"
    
    if difficulty == "easy":
        stem = f"{subject} _____ {duration}."
        explanation = f"ใช้ '{correct}' เน้นความต่อเนื่องของการกระทำ"
    elif difficulty == "medium":
        stem = f"{subject} looks tired because {subject.lower() if subject != 'I' else 'I'} _____ all day."
        explanation = f"ใช้ '{correct}' อธิบายสาเหตุที่เหนื่อย"
    else:  # hard
        stem = f"How long _____ {subject.lower() if subject != 'I' else 'you'} _____?"
        correct = f"{have_verb}/been {verb['ving']}"
        explanation = f"ใช้ {have_verb} been {verb['ving']} สำหรับถามระยะเวลา"
    
    choices = [correct]
    distractors = [
        f"{have_verb} {verb['v3']}",
        verb["v2"],
        f"was {verb['ving']}",
        f"had been {verb['ving']}"
    ]
    
    for d in distractors:
        if d not in choices and len(choices) < 4:
            choices.append(d)
    
    random.shuffle(choices)
    correct_index = choices.index(correct)
    
    return {
        "stem": stem,
        "choices": choices[:4],
        "correctIndex": correct_index,
        "explanation": explanation
    }


def generate_past_simple(verb_key: str, verb: dict, is_singular: bool, difficulty: str) -> dict:
    """Generate a Past Simple question"""
    subject = random.choice(SUBJECTS_SINGULAR if is_singular else SUBJECTS_PLURAL)
    obj = random.choice(OBJECTS)
    time = random.choice(TIME_PAST)
    
    correct = verb["v2"]
    
    if difficulty == "easy":
        stem = f"{subject} _____ {obj} {time}."
        explanation = f"ใช้ '{correct}' (V2) เพราะมี '{time}' แสดงอดีตที่จบไปแล้ว"
    elif difficulty == "medium":
        stem = f"When _____ {subject.lower() if subject != 'I' else 'you'} _____ {obj}?"
        correct = f"did/{verb['v1']}"
        explanation = f"ใช้ did + V1 สำหรับคำถามในอดีต"
    else:  # hard
        stem = f"The moment {subject.lower() if subject != 'I' else 'I'} _____ the news, everyone was shocked."
        explanation = f"ใช้ '{correct}' เพราะเป็นเหตุการณ์ที่เกิดและจบในอดีต"
    
    choices = [correct]
    distractors = [
        verb["v1"],
        verb["v3"],
        verb["ving"],
        f"has {verb['v3']}"
    ]
    
    for d in distractors:
        if d not in choices and len(choices) < 4:
            choices.append(d)
    
    random.shuffle(choices)
    correct_index = choices.index(correct)
    
    return {
        "stem": stem,
        "choices": choices[:4],
        "correctIndex": correct_index,
        "explanation": explanation
    }


def generate_past_continuous(verb_key: str, verb: dict, is_singular: bool, difficulty: str) -> dict:
    """Generate a Past Continuous question"""
    subject = random.choice(SUBJECTS_SINGULAR if is_singular else SUBJECTS_PLURAL)
    obj = random.choice(OBJECTS)
    
    be_verb = "was" if is_singular or subject == "I" else "were"
    correct = f"{be_verb} {verb['ving']}"
    
    if difficulty == "easy":
        stem = f"{subject} _____ {obj} at 8 PM yesterday."
        explanation = f"ใช้ '{correct}' เพราะระบุเวลาเจาะจงในอดีต"
    elif difficulty == "medium":
        stem = f"While {subject.lower() if subject != 'I' else 'I'} _____ {obj}, the phone rang."
        explanation = f"ใช้ '{correct}' กับ while สำหรับเหตุการณ์ที่ถูกแทรก"
    else:  # hard
        stem = f"What _____ {subject.lower() if subject != 'I' else 'you'} _____ when the accident happened?"
        correct = f"{be_verb}/{verb['ving']}"
        explanation = f"ใช้ {be_verb} {verb['ving']} สำหรับถามเหตุการณ์ในอดีต"
    
    choices = [correct]
    distractors = [
        verb["v2"],
        f"{'were' if be_verb == 'was' else 'was'} {verb['ving']}",
        f"is {verb['ving']}",
        f"had {verb['v3']}"
    ]
    
    for d in distractors:
        if d not in choices and len(choices) < 4:
            choices.append(d)
    
    random.shuffle(choices)
    correct_index = choices.index(correct)
    
    return {
        "stem": stem,
        "choices": choices[:4],
        "correctIndex": correct_index,
        "explanation": explanation
    }


def generate_past_perfect(verb_key: str, verb: dict, is_singular: bool, difficulty: str) -> dict:
    """Generate a Past Perfect question"""
    subject = random.choice(SUBJECTS_SINGULAR if is_singular else SUBJECTS_PLURAL)
    obj = random.choice(OBJECTS)
    
    correct = f"had {verb['v3']}"
    
    if difficulty == "easy":
        stem = f"By the time we arrived, {subject.lower() if subject != 'I' else 'I'} _____ already _____."
        correct = f"had/{verb['v3']}"
        explanation = f"ใช้ had {verb['v3']} เพราะเกิดก่อนอีกเหตุการณ์ในอดีต"
    elif difficulty == "medium":
        stem = f"After {subject.lower() if subject != 'I' else 'I'} _____ {obj}, I went home."
        explanation = f"ใช้ '{correct}' กับ after สำหรับเหตุการณ์ก่อนหน้า"
    else:  # hard
        stem = f"{subject} told me that they _____ {obj} before."
        explanation = f"ใช้ '{correct}' ใน reported speech"
    
    choices = [correct]
    distractors = [
        verb["v2"],
        f"has {verb['v3']}",
        f"have {verb['v3']}",
        verb["v1"]
    ]
    
    for d in distractors:
        if d not in choices and len(choices) < 4:
            choices.append(d)
    
    random.shuffle(choices)
    correct_index = choices.index(correct)
    
    return {
        "stem": stem,
        "choices": choices[:4],
        "correctIndex": correct_index,
        "explanation": explanation
    }


def generate_past_perfect_continuous(verb_key: str, verb: dict, is_singular: bool, difficulty: str) -> dict:
    """Generate a Past Perfect Continuous question"""
    subject = random.choice(SUBJECTS_SINGULAR if is_singular else SUBJECTS_PLURAL)
    duration = random.choice(DURATION)
    
    correct = f"had been {verb['ving']}"
    
    if difficulty == "easy":
        stem = f"{subject} _____ {duration} before it stopped."
        explanation = f"ใช้ '{correct}' เน้นความต่อเนื่องก่อนเหตุการณ์ในอดีต"
    elif difficulty == "medium":
        stem = f"{subject} was tired because they _____ all day."
        explanation = f"ใช้ '{correct}' อธิบายสาเหตุในอดีต"
    else:  # hard
        stem = f"How long _____ {subject.lower() if subject != 'I' else 'you'} _____ before you found the answer?"
        correct = f"had/been {verb['ving']}"
        explanation = f"ใช้ had been {verb['ving']} สำหรับถามระยะเวลา"
    
    choices = [correct]
    distractors = [
        f"had {verb['v3']}",
        f"has been {verb['ving']}",
        f"was {verb['ving']}",
        verb["v2"]
    ]
    
    for d in distractors:
        if d not in choices and len(choices) < 4:
            choices.append(d)
    
    random.shuffle(choices)
    correct_index = choices.index(correct)
    
    return {
        "stem": stem,
        "choices": choices[:4],
        "correctIndex": correct_index,
        "explanation": explanation
    }


def generate_future_simple(verb_key: str, verb: dict, is_singular: bool, difficulty: str) -> dict:
    """Generate a Future Simple question"""
    subject = random.choice(SUBJECTS_SINGULAR if is_singular else SUBJECTS_PLURAL)
    obj = random.choice(OBJECTS)
    time = random.choice(TIME_FUTURE)
    
    correct = f"will {verb['v1']}"
    
    if difficulty == "easy":
        stem = f"{subject} _____ {obj} {time}."
        explanation = f"ใช้ '{correct}' สำหรับเหตุการณ์ในอนาคต"
    elif difficulty == "medium":
        stem = f"I think {subject.lower() if subject != 'I' else 'I'} _____ {obj}."
        explanation = f"ใช้ '{correct}' สำหรับการคาดเดา"
    else:  # hard
        stem = f"If you don't hurry, {subject.lower() if subject != 'I' else 'you'} _____ {obj}."
        explanation = f"ใช้ '{correct}' ใน main clause ของ First Conditional"
    
    choices = [correct]
    distractors = [
        verb["v1"],
        verb["v1_s"],
        f"is going to {verb['v1']}",
        f"is {verb['ving']}"
    ]
    
    for d in distractors:
        if d not in choices and len(choices) < 4:
            choices.append(d)
    
    random.shuffle(choices)
    correct_index = choices.index(correct)
    
    return {
        "stem": stem,
        "choices": choices[:4],
        "correctIndex": correct_index,
        "explanation": explanation
    }


def generate_future_continuous(verb_key: str, verb: dict, is_singular: bool, difficulty: str) -> dict:
    """Generate a Future Continuous question"""
    subject = random.choice(SUBJECTS_SINGULAR if is_singular else SUBJECTS_PLURAL)
    obj = random.choice(OBJECTS)
    
    correct = f"will be {verb['ving']}"
    
    if difficulty == "easy":
        stem = f"At this time tomorrow, {subject.lower() if subject != 'I' else 'I'} _____ {obj}."
        explanation = f"ใช้ '{correct}' เพราะระบุเวลาเจาะจงในอนาคต"
    elif difficulty == "medium":
        stem = f"Don't call me at 8 PM. I _____ {obj}."
        explanation = f"ใช้ '{correct}' สำหรับกิจกรรมที่จะกำลังทำอยู่"
    else:  # hard
        stem = f"_____ {subject.lower() if subject != 'I' else 'you'} _____ the car tomorrow? I need to borrow it."
        correct = f"Will/be {verb['ving']}"
        explanation = f"ใช้ Will be {verb['ving']} สำหรับถามแผนในอนาคต"
    
    choices = [correct]
    distractors = [
        f"will {verb['v1']}",
        f"is {verb['ving']}",
        verb["v1"],
        f"was {verb['ving']}"
    ]
    
    for d in distractors:
        if d not in choices and len(choices) < 4:
            choices.append(d)
    
    random.shuffle(choices)
    correct_index = choices.index(correct)
    
    return {
        "stem": stem,
        "choices": choices[:4],
        "correctIndex": correct_index,
        "explanation": explanation
    }


def generate_future_perfect(verb_key: str, verb: dict, is_singular: bool, difficulty: str) -> dict:
    """Generate a Future Perfect question"""
    subject = random.choice(SUBJECTS_SINGULAR if is_singular else SUBJECTS_PLURAL)
    obj = random.choice(OBJECTS)
    
    correct = f"will have {verb['v3']}"
    
    if difficulty == "easy":
        stem = f"By next year, {subject.lower() if subject != 'I' else 'I'} _____ {obj}."
        explanation = f"ใช้ '{correct}' กับ by + เวลาในอนาคต"
    elif difficulty == "medium":
        stem = f"By the time you arrive, I _____ {obj}."
        explanation = f"ใช้ '{correct}' กับ by the time"
    else:  # hard
        stem = f"How many times _____ {subject.lower() if subject != 'I' else 'you'} _____ {obj} by the end of this year?"
        correct = f"will/have {verb['v3']}"
        explanation = f"ใช้ will have {verb['v3']} สำหรับถาม"
    
    choices = [correct]
    distractors = [
        f"will {verb['v1']}",
        f"has {verb['v3']}",
        f"had {verb['v3']}",
        f"will be {verb['ving']}"
    ]
    
    for d in distractors:
        if d not in choices and len(choices) < 4:
            choices.append(d)
    
    random.shuffle(choices)
    correct_index = choices.index(correct)
    
    return {
        "stem": stem,
        "choices": choices[:4],
        "correctIndex": correct_index,
        "explanation": explanation
    }


def generate_future_perfect_continuous(verb_key: str, verb: dict, is_singular: bool, difficulty: str) -> dict:
    """Generate a Future Perfect Continuous question"""
    subject = random.choice(SUBJECTS_SINGULAR if is_singular else SUBJECTS_PLURAL)
    duration = random.choice(DURATION)
    
    correct = f"will have been {verb['ving']}"
    
    if difficulty == "easy":
        stem = f"By 5 o'clock, {subject.lower() if subject != 'I' else 'I'} _____ {duration}."
        explanation = f"ใช้ '{correct}' เน้นระยะเวลาจนถึงจุดในอนาคต"
    elif difficulty == "medium":
        stem = f"By next month, I _____ at this company for 10 years."
        explanation = f"ใช้ '{correct}' สำหรับระยะเวลาที่จะครบ"
    else:  # hard
        stem = f"How long _____ {subject.lower() if subject != 'I' else 'you'} _____ by the time you graduate?"
        correct = f"will/have been {verb['ving']}"
        explanation = f"ใช้ will have been {verb['ving']} สำหรับถามระยะเวลา"
    
    choices = [correct]
    distractors = [
        f"will have {verb['v3']}",
        f"will be {verb['ving']}",
        f"has been {verb['ving']}",
        f"had been {verb['ving']}"
    ]
    
    for d in distractors:
        if d not in choices and len(choices) < 4:
            choices.append(d)
    
    random.shuffle(choices)
    correct_index = choices.index(correct)
    
    return {
        "stem": stem,
        "choices": choices[:4],
        "correctIndex": correct_index,
        "explanation": explanation
    }


def generate_passive_voice(verb_key: str, verb: dict, is_singular: bool, difficulty: str) -> dict:
    """Generate a Passive Voice question"""
    subject = random.choice(OBJECTS)  # For passive, object becomes subject
    agent = random.choice(SUBJECTS_SINGULAR + SUBJECTS_PLURAL)
    
    be_verb = "is" if is_singular else "are"
    correct = f"{be_verb} {verb['v3']}"
    
    if difficulty == "easy":
        stem = f"The {subject} _____ by {agent.lower()}."
        explanation = f"ใช้ '{correct}' สำหรับ passive voice (be + V3)"
    elif difficulty == "medium":
        stem = f"English _____ in many countries."
        correct = "is spoken"
        explanation = f"ใช้ 'is spoken' สำหรับ passive voice เมื่อผู้กระทำไม่สำคัญ"
    else:  # hard
        stem = f"The project _____ by the team right now."
        correct = f"is being {verb['v3']}"
        explanation = f"ใช้ 'is being {verb['v3']}' สำหรับ passive voice ใน Present Continuous"
    
    choices = [correct]
    distractors = [
        verb["v1"],
        verb["v2"],
        f"was {verb['v3']}",
        verb["ving"]
    ]
    
    for d in distractors:
        if d not in choices and len(choices) < 4:
            choices.append(d)
    
    random.shuffle(choices)
    correct_index = choices.index(correct)
    
    return {
        "stem": stem,
        "choices": choices[:4],
        "correctIndex": correct_index,
        "explanation": explanation
    }


# ===== GENERATOR MAPPING =====

GENERATORS = {
    "present_simple": generate_present_simple,
    "present_continuous": generate_present_continuous,
    "present_perfect": generate_present_perfect,
    "present_perfect_continuous": generate_present_perfect_continuous,
    "past_simple": generate_past_simple,
    "past_continuous": generate_past_continuous,
    "past_perfect": generate_past_perfect,
    "past_perfect_continuous": generate_past_perfect_continuous,
    "future_simple": generate_future_simple,
    "future_continuous": generate_future_continuous,
    "future_perfect": generate_future_perfect,
    "future_perfect_continuous": generate_future_perfect_continuous,
    "passive_voice": generate_passive_voice,
}


def generate_questions_for_tense(tense: dict, count: int = 5000) -> dict:
    """Generate questions for a specific tense"""
    tense_name = tense["name"]
    pack_id = tense["pack_id"]
    generator = GENERATORS[tense_name]
    
    # Distribution: easy 1500, medium 2000, hard 1500
    difficulties = {
        "easy": int(count * 0.3),
        "medium": int(count * 0.4),
        "hard": int(count * 0.3)
    }
    
    questions = {"easy": [], "medium": [], "hard": []}
    verbs = list(VERBS_BASE.items())
    
    for difficulty, num in difficulties.items():
        print(f"  Generating {num} {difficulty} questions...")
        for i in range(num):
            verb_key, verb = random.choice(verbs)
            is_singular = random.choice([True, False])
            
            q = generator(verb_key, verb, is_singular, difficulty)
            q["id"] = f"q_{pack_id}_{difficulty[0]}_{i+1}"
            q["skillType"] = "grammar"
            q["packId"] = pack_id
            
            questions[difficulty].append(q)
    
    return questions


def main():
    output_dir = "assets/data/quiz"
    os.makedirs(output_dir, exist_ok=True)
    
    print("=" * 60)
    print("Grammar Quiz Generator")
    print("=" * 60)
    print(f"Generating 5,000 questions per tense ({len(TENSES)} tenses)")
    print(f"Total: {5000 * len(TENSES):,} questions")
    print("=" * 60)
    
    for tense in TENSES:
        print(f"\nProcessing: {tense['title']}")
        questions = generate_questions_for_tense(tense, 5000)
        
        filename = f"{output_dir}/grammar_quiz_{tense['id'].replace('grammar_', '')}_{tense['name']}.json"
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(questions, f, ensure_ascii=False, indent=2)
        
        total = sum(len(q) for q in questions.values())
        print(f"  Saved {total:,} questions to {filename}")
    
    print("\n" + "=" * 60)
    print("Generation complete!")
    print("=" * 60)


if __name__ == "__main__":
    main()
