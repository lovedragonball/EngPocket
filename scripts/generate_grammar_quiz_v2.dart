/// Grammar Quiz Generator V2 - Improved Diversity
/// Creates realistic, varied sentences for each tense
library;

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';

final random = Random();

// ===== REALISTIC SENTENCE TEMPLATES =====
// Each verb is paired with appropriate objects and contexts

final Map<String, List<String>> verbObjectPairs = {
  // Food & Drink
  "eat": [
    "breakfast",
    "lunch",
    "dinner",
    "an apple",
    "rice",
    "noodles",
    "pizza",
    "a sandwich"
  ],
  "drink": ["water", "coffee", "tea", "juice", "milk", "a smoothie"],
  "cook": ["dinner", "breakfast", "pasta", "rice", "soup", "a meal"],

  // Communication
  "speak": [
    "English",
    "Thai",
    "Chinese",
    "Japanese",
    "to my friends",
    "on the phone"
  ],
  "write": [
    "an email",
    "a letter",
    "a report",
    "a message",
    "notes",
    "in my diary"
  ],
  "read": [
    "a book",
    "the newspaper",
    "an article",
    "emails",
    "a magazine",
    "the news"
  ],
  "tell": ["the truth", "a story", "a joke", "my friends", "everyone"],
  "ask": [
    "a question",
    "for help",
    "for directions",
    "my teacher",
    "permission"
  ],
  "answer": ["the phone", "questions", "emails", "the door"],
  "listen": [
    "to music",
    "to the radio",
    "to my teacher",
    "to podcasts",
    "carefully"
  ],
  "call": ["my mother", "my friend", "the office", "a taxi", "for help"],

  // Movement
  "go": [
    "to school",
    "to work",
    "home",
    "shopping",
    "to the gym",
    "to bed",
    "outside"
  ],
  "come": ["home", "to class", "to the party", "to work", "back", "early"],
  "walk": ["to school", "to work", "in the park", "the dog", "home", "slowly"],
  "run": [
    "in the morning",
    "in the park",
    "to the bus stop",
    "every day",
    "fast"
  ],
  "drive": ["to work", "a car", "carefully", "to the mall", "home"],
  "fly": ["to Bangkok", "to Japan", "abroad", "on business", "home"],
  "arrive": ["at school", "at work", "on time", "early", "late", "home"],
  "leave": ["home", "the office", "early", "at 8 AM", "for work", "the party"],

  // Daily activities
  "wake": ["up early", "up at 6 AM", "up late", "up on time"],
  "sleep": ["early", "late", "well", "for 8 hours", "on the sofa"],
  "work": ["hard", "at a company", "from home", "overtime", "on weekends"],
  "study": [
    "English",
    "math",
    "science",
    "hard",
    "for the exam",
    "at university"
  ],
  "play": [
    "football",
    "basketball",
    "tennis",
    "the piano",
    "games",
    "with friends"
  ],
  "watch": [
    "TV",
    "movies",
    "YouTube",
    "the news",
    "a football match",
    "Netflix"
  ],
  "clean": ["the house", "my room", "the kitchen", "the car", "up"],
  "wash": ["the dishes", "clothes", "the car", "my hands", "my face"],

  // Transactions
  "buy": ["groceries", "clothes", "a new phone", "coffee", "tickets", "food"],
  "sell": ["products", "cars", "online", "at the market", "handmade items"],
  "pay": ["the bills", "for dinner", "by credit card", "in cash", "attention"],
  "spend": ["money", "time with family", "the weekend", "hours studying"],
  "save": ["money", "time", "energy", "for a vacation", "the document"],

  // Cognition
  "know": [
    "the answer",
    "English well",
    "many people",
    "the truth",
    "how to do it"
  ],
  "think": ["carefully", "about the future", "positively", "before speaking"],
  "understand": [
    "English",
    "the lesson",
    "the problem",
    "clearly",
    "everything"
  ],
  "remember": [
    "names",
    "important dates",
    "to call",
    "the password",
    "everything"
  ],
  "forget": ["things easily", "names", "the password", "to call", "my keys"],
  "learn": ["English", "new skills", "quickly", "from mistakes", "every day"],
  "teach": ["English", "students", "at a school", "children", "online"],

  // Preference
  "like": ["coffee", "music", "sports", "reading", "traveling", "Thai food"],
  "love": ["my family", "traveling", "music", "cooking", "my job"],
  "want": ["to travel", "a new car", "to learn", "to succeed", "more time"],
  "need": ["help", "money", "time", "to rest", "a break", "advice"],
  "hope": ["for the best", "to succeed", "to travel", "to see you"],
  "wish": ["for happiness", "to be rich", "I could fly", "for good luck"],

  // Other actions
  "help": ["my parents", "my friends", "others", "at home", "with homework"],
  "meet": ["friends", "clients", "new people", "at the cafe", "after work"],
  "visit": ["my grandparents", "friends", "the doctor", "Japan", "relatives"],
  "wait": ["for the bus", "patiently", "in line", "for my turn", "outside"],
  "use": ["a computer", "my phone", "the internet", "public transport"],
  "make": ["breakfast", "a decision", "money", "friends", "mistakes"],
  "take": ["a shower", "the bus", "photos", "a break", "medicine", "notes"],
  "give": ["advice", "a gift", "money", "presentations", "directions"],
  "get": ["up early", "home late", "good grades", "a haircut", "ready"],
  "start": ["work", "early", "a new project", "exercising", "the day"],
  "finish": ["work", "homework", "on time", "eating", "the project"],
  "open": ["the door", "the window", "my email", "a book", "a business"],
  "close": ["the door", "the window", "my eyes", "the shop", "early"],
  "stop": ["smoking", "eating late", "worrying", "at the store", "working"],
  "try": ["my best", "new food", "to learn", "harder", "again"],
  "feel": ["happy", "tired", "sick", "better", "excited", "nervous"],
  "look": ["happy", "tired", "for my keys", "at the sky", "great"],
  "become": ["successful", "a doctor", "rich", "famous", "better"],
  "keep": ["trying", "learning", "working", "in touch", "a diary"],
  "stay": ["home", "healthy", "calm", "at a hotel", "positive"],
  "sit": ["down", "quietly", "in the front", "on the sofa", "by the window"],
  "stand": ["up", "in line", "by the door", "straight", "here"],
};

// People subjects (for most verbs)
final List<String> peopleSubjectsSingular = [
  "He",
  "She",
  "My father",
  "My mother",
  "The teacher",
  "The student",
  "The doctor",
  "John",
  "Mary",
  "Tom",
  "Lisa",
  "My brother",
  "My sister",
  "The chef",
  "The manager",
  "My friend",
  "The engineer",
  "David",
  "Sarah",
  "The nurse",
  "The artist",
  "The lawyer",
  "My boss",
  "The driver"
];

final List<String> peopleSubjectsPlural = [
  "I",
  "You",
  "We",
  "They",
  "My parents",
  "The students",
  "The teachers",
  "My friends",
  "The workers",
  "Tom and Mary",
  "The doctors",
  "The children"
];

// Time expressions
final List<String> timePresent = [
  "every day",
  "every morning",
  "every week",
  "usually",
  "often",
  "sometimes",
  "always"
];
final List<String> timePast = [
  "yesterday",
  "last night",
  "last week",
  "last month",
  "two days ago",
  "this morning"
];
final List<String> timeFuture = [
  "tomorrow",
  "next week",
  "next month",
  "soon",
  "tonight",
  "later"
];
final List<String> timeContinuous = [
  "now",
  "right now",
  "at the moment",
  "currently"
];
final List<String> timePerfect = [
  "already",
  "just",
  "recently",
  "before",
  "many times"
];
final List<String> duration = [
  "for 2 hours",
  "for 3 days",
  "for a week",
  "since morning",
  "all day"
];

final List<String> frequency = [
  "always",
  "usually",
  "often",
  "sometimes",
  "rarely",
  "never"
];

// Verb forms
final Map<String, Map<String, String>> verbs = {
  "eat": {
    "v1": "eat",
    "v2": "ate",
    "v3": "eaten",
    "ving": "eating",
    "v1s": "eats"
  },
  "drink": {
    "v1": "drink",
    "v2": "drank",
    "v3": "drunk",
    "ving": "drinking",
    "v1s": "drinks"
  },
  "go": {
    "v1": "go",
    "v2": "went",
    "v3": "gone",
    "ving": "going",
    "v1s": "goes"
  },
  "come": {
    "v1": "come",
    "v2": "came",
    "v3": "come",
    "ving": "coming",
    "v1s": "comes"
  },
  "play": {
    "v1": "play",
    "v2": "played",
    "v3": "played",
    "ving": "playing",
    "v1s": "plays"
  },
  "work": {
    "v1": "work",
    "v2": "worked",
    "v3": "worked",
    "ving": "working",
    "v1s": "works"
  },
  "study": {
    "v1": "study",
    "v2": "studied",
    "v3": "studied",
    "ving": "studying",
    "v1s": "studies"
  },
  "read": {
    "v1": "read",
    "v2": "read",
    "v3": "read",
    "ving": "reading",
    "v1s": "reads"
  },
  "write": {
    "v1": "write",
    "v2": "wrote",
    "v3": "written",
    "ving": "writing",
    "v1s": "writes"
  },
  "speak": {
    "v1": "speak",
    "v2": "spoke",
    "v3": "spoken",
    "ving": "speaking",
    "v1s": "speaks"
  },
  "run": {
    "v1": "run",
    "v2": "ran",
    "v3": "run",
    "ving": "running",
    "v1s": "runs"
  },
  "walk": {
    "v1": "walk",
    "v2": "walked",
    "v3": "walked",
    "ving": "walking",
    "v1s": "walks"
  },
  "sleep": {
    "v1": "sleep",
    "v2": "slept",
    "v3": "slept",
    "ving": "sleeping",
    "v1s": "sleeps"
  },
  "wake": {
    "v1": "wake",
    "v2": "woke",
    "v3": "woken",
    "ving": "waking",
    "v1s": "wakes"
  },
  "cook": {
    "v1": "cook",
    "v2": "cooked",
    "v3": "cooked",
    "ving": "cooking",
    "v1s": "cooks"
  },
  "clean": {
    "v1": "clean",
    "v2": "cleaned",
    "v3": "cleaned",
    "ving": "cleaning",
    "v1s": "cleans"
  },
  "watch": {
    "v1": "watch",
    "v2": "watched",
    "v3": "watched",
    "ving": "watching",
    "v1s": "watches"
  },
  "listen": {
    "v1": "listen",
    "v2": "listened",
    "v3": "listened",
    "ving": "listening",
    "v1s": "listens"
  },
  "buy": {
    "v1": "buy",
    "v2": "bought",
    "v3": "bought",
    "ving": "buying",
    "v1s": "buys"
  },
  "sell": {
    "v1": "sell",
    "v2": "sold",
    "v3": "sold",
    "ving": "selling",
    "v1s": "sells"
  },
  "make": {
    "v1": "make",
    "v2": "made",
    "v3": "made",
    "ving": "making",
    "v1s": "makes"
  },
  "take": {
    "v1": "take",
    "v2": "took",
    "v3": "taken",
    "ving": "taking",
    "v1s": "takes"
  },
  "give": {
    "v1": "give",
    "v2": "gave",
    "v3": "given",
    "ving": "giving",
    "v1s": "gives"
  },
  "teach": {
    "v1": "teach",
    "v2": "taught",
    "v3": "taught",
    "ving": "teaching",
    "v1s": "teaches"
  },
  "learn": {
    "v1": "learn",
    "v2": "learned",
    "v3": "learned",
    "ving": "learning",
    "v1s": "learns"
  },
  "know": {
    "v1": "know",
    "v2": "knew",
    "v3": "known",
    "ving": "knowing",
    "v1s": "knows"
  },
  "think": {
    "v1": "think",
    "v2": "thought",
    "v3": "thought",
    "ving": "thinking",
    "v1s": "thinks"
  },
  "see": {
    "v1": "see",
    "v2": "saw",
    "v3": "seen",
    "ving": "seeing",
    "v1s": "sees"
  },
  "hear": {
    "v1": "hear",
    "v2": "heard",
    "v3": "heard",
    "ving": "hearing",
    "v1s": "hears"
  },
  "feel": {
    "v1": "feel",
    "v2": "felt",
    "v3": "felt",
    "ving": "feeling",
    "v1s": "feels"
  },
  "love": {
    "v1": "love",
    "v2": "loved",
    "v3": "loved",
    "ving": "loving",
    "v1s": "loves"
  },
  "like": {
    "v1": "like",
    "v2": "liked",
    "v3": "liked",
    "ving": "liking",
    "v1s": "likes"
  },
  "want": {
    "v1": "want",
    "v2": "wanted",
    "v3": "wanted",
    "ving": "wanting",
    "v1s": "wants"
  },
  "need": {
    "v1": "need",
    "v2": "needed",
    "v3": "needed",
    "ving": "needing",
    "v1s": "needs"
  },
  "help": {
    "v1": "help",
    "v2": "helped",
    "v3": "helped",
    "ving": "helping",
    "v1s": "helps"
  },
  "start": {
    "v1": "start",
    "v2": "started",
    "v3": "started",
    "ving": "starting",
    "v1s": "starts"
  },
  "finish": {
    "v1": "finish",
    "v2": "finished",
    "v3": "finished",
    "ving": "finishing",
    "v1s": "finishes"
  },
  "open": {
    "v1": "open",
    "v2": "opened",
    "v3": "opened",
    "ving": "opening",
    "v1s": "opens"
  },
  "close": {
    "v1": "close",
    "v2": "closed",
    "v3": "closed",
    "ving": "closing",
    "v1s": "closes"
  },
  "live": {
    "v1": "live",
    "v2": "lived",
    "v3": "lived",
    "ving": "living",
    "v1s": "lives"
  },
  "arrive": {
    "v1": "arrive",
    "v2": "arrived",
    "v3": "arrived",
    "ving": "arriving",
    "v1s": "arrives"
  },
  "leave": {
    "v1": "leave",
    "v2": "left",
    "v3": "left",
    "ving": "leaving",
    "v1s": "leaves"
  },
  "visit": {
    "v1": "visit",
    "v2": "visited",
    "v3": "visited",
    "ving": "visiting",
    "v1s": "visits"
  },
  "stay": {
    "v1": "stay",
    "v2": "stayed",
    "v3": "stayed",
    "ving": "staying",
    "v1s": "stays"
  },
  "wait": {
    "v1": "wait",
    "v2": "waited",
    "v3": "waited",
    "ving": "waiting",
    "v1s": "waits"
  },
  "call": {
    "v1": "call",
    "v2": "called",
    "v3": "called",
    "ving": "calling",
    "v1s": "calls"
  },
  "meet": {
    "v1": "meet",
    "v2": "met",
    "v3": "met",
    "ving": "meeting",
    "v1s": "meets"
  },
  "find": {
    "v1": "find",
    "v2": "found",
    "v3": "found",
    "ving": "finding",
    "v1s": "finds"
  },
  "lose": {
    "v1": "lose",
    "v2": "lost",
    "v3": "lost",
    "ving": "losing",
    "v1s": "loses"
  },
  "drive": {
    "v1": "drive",
    "v2": "drove",
    "v3": "driven",
    "ving": "driving",
    "v1s": "drives"
  },
  "fly": {
    "v1": "fly",
    "v2": "flew",
    "v3": "flown",
    "ving": "flying",
    "v1s": "flies"
  },
  "spend": {
    "v1": "spend",
    "v2": "spent",
    "v3": "spent",
    "ving": "spending",
    "v1s": "spends"
  },
  "save": {
    "v1": "save",
    "v2": "saved",
    "v3": "saved",
    "ving": "saving",
    "v1s": "saves"
  },
  "try": {
    "v1": "try",
    "v2": "tried",
    "v3": "tried",
    "ving": "trying",
    "v1s": "tries"
  },
  "use": {
    "v1": "use",
    "v2": "used",
    "v3": "used",
    "ving": "using",
    "v1s": "uses"
  },
  "tell": {
    "v1": "tell",
    "v2": "told",
    "v3": "told",
    "ving": "telling",
    "v1s": "tells"
  },
  "ask": {
    "v1": "ask",
    "v2": "asked",
    "v3": "asked",
    "ving": "asking",
    "v1s": "asks"
  },
  "answer": {
    "v1": "answer",
    "v2": "answered",
    "v3": "answered",
    "ving": "answering",
    "v1s": "answers"
  },
  "understand": {
    "v1": "understand",
    "v2": "understood",
    "v3": "understood",
    "ving": "understanding",
    "v1s": "understands"
  },
  "remember": {
    "v1": "remember",
    "v2": "remembered",
    "v3": "remembered",
    "ving": "remembering",
    "v1s": "remembers"
  },
  "forget": {
    "v1": "forget",
    "v2": "forgot",
    "v3": "forgotten",
    "ving": "forgetting",
    "v1s": "forgets"
  },
  "hope": {
    "v1": "hope",
    "v2": "hoped",
    "v3": "hoped",
    "ving": "hoping",
    "v1s": "hopes"
  },
  "get": {
    "v1": "get",
    "v2": "got",
    "v3": "gotten",
    "ving": "getting",
    "v1s": "gets"
  },
  "become": {
    "v1": "become",
    "v2": "became",
    "v3": "become",
    "ving": "becoming",
    "v1s": "becomes"
  },
  "keep": {
    "v1": "keep",
    "v2": "kept",
    "v3": "kept",
    "ving": "keeping",
    "v1s": "keeps"
  },
  "sit": {
    "v1": "sit",
    "v2": "sat",
    "v3": "sat",
    "ving": "sitting",
    "v1s": "sits"
  },
  "stand": {
    "v1": "stand",
    "v2": "stood",
    "v3": "stood",
    "ving": "standing",
    "v1s": "stands"
  },
  "stop": {
    "v1": "stop",
    "v2": "stopped",
    "v3": "stopped",
    "ving": "stopping",
    "v1s": "stops"
  },
};

// Tenses
final List<Map<String, String>> tenses = [
  {
    "id": "grammar_001",
    "name": "present_simple",
    "title": "Present Simple",
    "packId": "grammar_001"
  },
  {
    "id": "grammar_002",
    "name": "present_continuous",
    "title": "Present Continuous",
    "packId": "grammar_002"
  },
  {
    "id": "grammar_003",
    "name": "present_perfect",
    "title": "Present Perfect",
    "packId": "grammar_003"
  },
  {
    "id": "grammar_004",
    "name": "present_perfect_continuous",
    "title": "Present Perfect Continuous",
    "packId": "grammar_004"
  },
  {
    "id": "grammar_005",
    "name": "past_simple",
    "title": "Past Simple",
    "packId": "grammar_005"
  },
  {
    "id": "grammar_006",
    "name": "past_continuous",
    "title": "Past Continuous",
    "packId": "grammar_006"
  },
  {
    "id": "grammar_007",
    "name": "past_perfect",
    "title": "Past Perfect",
    "packId": "grammar_007"
  },
  {
    "id": "grammar_008",
    "name": "past_perfect_continuous",
    "title": "Past Perfect Continuous",
    "packId": "grammar_008"
  },
  {
    "id": "grammar_009",
    "name": "future_simple",
    "title": "Future Simple",
    "packId": "grammar_009"
  },
  {
    "id": "grammar_010",
    "name": "future_continuous",
    "title": "Future Continuous",
    "packId": "grammar_010"
  },
  {
    "id": "grammar_011",
    "name": "future_perfect",
    "title": "Future Perfect",
    "packId": "grammar_011"
  },
  {
    "id": "grammar_012",
    "name": "future_perfect_continuous",
    "title": "Future Perfect Continuous",
    "packId": "grammar_012"
  },
  {
    "id": "grammar_013",
    "name": "passive_voice",
    "title": "Passive Voice",
    "packId": "grammar_013"
  },
];

String pick(List<String> list) => list[random.nextInt(list.length)];

MapEntry<String, Map<String, String>> pickVerb() {
  final keys = verbs.keys.toList();
  final key = keys[random.nextInt(keys.length)];
  return MapEntry(key, verbs[key]!);
}

String pickObject(String verbKey) {
  final objects = verbObjectPairs[verbKey];
  if (objects != null && objects.isNotEmpty) {
    return objects[random.nextInt(objects.length)];
  }
  return "";
}

List<String> shuffle(List<String> list) {
  final result = List<String>.from(list)..shuffle(random);
  return result;
}

// ===== PRESENT SIMPLE =====
Map<String, dynamic> genPresentSimple(String diff) {
  final ve = pickVerb();
  final vKey = ve.key;
  final v = ve.value;
  final obj = pickObject(vKey);
  final isSing = random.nextBool();
  final subj =
      isSing ? pick(peopleSubjectsSingular) : pick(peopleSubjectsPlural);
  final correct = isSing ? v["v1s"]! : v["v1"]!;

  String stem;
  String expl;

  if (diff == "easy") {
    final t = pick(timePresent);
    stem = "$subj _____ $obj $t.";
    expl =
        "ใช้ '$correct' เพราะ${isSing ? 'ประธานเป็นเอกพจน์บุรุษที่ 3' : 'ประธานเป็นพหูพจน์'}";
  } else if (diff == "medium") {
    final f = pick(frequency);
    final patterns = [
      "$subj $f _____ $obj.",
      "How often does ${subj.toLowerCase()} _____ $obj?",
      "$subj doesn't _____ $obj very often.",
    ];
    stem = pick(patterns);
    if (stem.contains("doesn't") || stem.contains("does")) {
      expl = "หลัง does/doesn't ใช้ V1 เสมอ";
    } else {
      expl = "ใช้ '$correct' กับ '$f' แสดงกิจวัตร";
    }
  } else {
    final patterns = [
      "When the weather is nice, $subj _____ $obj.",
      "If $subj _____ $obj, everyone is happy.",
      "Water _____ at 100 degrees Celsius. (boils)",
      "The earth _____ around the sun. (revolves)",
    ];
    final idx = random.nextInt(patterns.length);
    if (idx >= 2) {
      stem = patterns[idx].split(" (")[0];
      expl = "ใช้ Present Simple สำหรับความจริงทางวิทยาศาสตร์";
    } else {
      stem = patterns[idx];
      expl = "ใช้ Present Simple ใน conditional clause";
    }
  }

  var choices = [correct, v["v2"]!, v["ving"]!, v["v3"]!];
  if (isSing && !choices.contains(v["v1"]!)) choices[3] = v["v1"]!;
  if (!isSing && !choices.contains(v["v1s"]!)) choices[3] = v["v1s"]!;
  choices = shuffle(choices).take(4).toList();

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl,
  };
}

// ===== PRESENT CONTINUOUS =====
Map<String, dynamic> genPresentContinuous(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final isSing = random.nextBool();
  final subj =
      isSing ? pick(peopleSubjectsSingular) : pick(peopleSubjectsPlural);
  final be = isSing ? "is" : (subj == "I" ? "am" : "are");
  final correct = "$be ${v['ving']}";

  String stem;
  String expl;

  if (diff == "easy") {
    final t = pick(timeContinuous);
    stem = "$subj _____ $obj $t.";
    expl = "ใช้ '$correct' กับ '$t' แสดงเหตุการณ์ที่กำลังเกิดขึ้น";
  } else if (diff == "medium") {
    final patterns = [
      "Look! $subj _____ $obj.",
      "Listen! Someone _____ the phone.",
      "Be quiet! The baby _____ now.",
    ];
    stem = pick(patterns);
    expl = "ใช้ Present Continuous หลัง Look!/Listen!/Be quiet!";
  } else {
    stem = "$subj _____ $obj these days because it's a temporary situation.";
    expl = "ใช้ Present Continuous สำหรับสถานการณ์ชั่วคราว";
  }

  var choices = [correct, v["v1"]!, v["v2"]!, v["v1s"]!];
  choices = shuffle(choices).take(4).toList();

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl,
  };
}

// ===== PRESENT PERFECT =====
Map<String, dynamic> genPresentPerfect(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final isSing = random.nextBool();
  final subj =
      isSing ? pick(peopleSubjectsSingular) : pick(peopleSubjectsPlural);
  final have = isSing ? "has" : "have";
  final correct = "$have ${v['v3']}";

  String stem;
  String expl;

  if (diff == "easy") {
    final t = pick(timePerfect);
    stem = "$subj _____ $t $obj.";
    expl = "ใช้ '$correct' กับ '$t' ใน Present Perfect";
  } else if (diff == "medium") {
    final patterns = [
      "$subj _____ $obj since last year.",
      "$subj _____ $obj for 5 years.",
      "How long _____ $subj ${v['v3']} $obj?",
    ];
    stem = pick(patterns);
    expl = "ใช้ Present Perfect กับ since/for/How long";
  } else {
    stem = "This is the best $obj ${subj.toLowerCase()} _____ ever ${v['v3']}.";
    expl = "ใช้ Present Perfect กับ superlative + ever";
  }

  var choices = [correct, v["v1"]!, v["v2"]!, "had ${v['v3']}"];
  choices = shuffle(choices).take(4).toList();

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl,
  };
}

// ===== PRESENT PERFECT CONTINUOUS =====
Map<String, dynamic> genPresentPerfectContinuous(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final isSing = random.nextBool();
  final subj =
      isSing ? pick(peopleSubjectsSingular) : pick(peopleSubjectsPlural);
  final have = isSing ? "has" : "have";
  final correct = "$have been ${v['ving']}";

  String stem;
  String expl;
  final dur = pick(duration);

  if (diff == "easy") {
    stem = "$subj _____ $obj $dur.";
    expl = "ใช้ '$correct' เน้นความต่อเนื่องจากอดีตถึงปัจจุบัน";
  } else if (diff == "medium") {
    stem =
        "$subj looks tired because ${subj.toLowerCase()} _____ $obj all day.";
    expl = "ใช้ Present Perfect Continuous อธิบายสาเหตุ";
  } else {
    stem = "How long _____ ${subj.toLowerCase()} been ${v['ving']} $obj?";
    expl = "ใช้ '$have been ${v['ving']}' สำหรับถามระยะเวลา";
  }

  var choices = [correct, "$have ${v['v3']}", v["v2"]!, "was ${v['ving']}"];
  choices = shuffle(choices).take(4).toList();

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl,
  };
}

// ===== PAST SIMPLE =====
Map<String, dynamic> genPastSimple(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final subj = pick([...peopleSubjectsSingular, ...peopleSubjectsPlural]);
  final correct = v["v2"]!;

  String stem;
  String expl;

  if (diff == "easy") {
    final t = pick(timePast);
    stem = "$subj _____ $obj $t.";
    expl = "ใช้ '$correct' (V2) กับ '$t' แสดงอดีต";
  } else if (diff == "medium") {
    final patterns = [
      "When did ${subj.toLowerCase()} _____ $obj?",
      "$subj didn't _____ $obj yesterday.",
      "Did ${subj.toLowerCase()} _____ $obj last week?",
    ];
    stem = pick(patterns);
    expl = "หลัง did/didn't ใช้ V1 เสมอ";
  } else {
    stem = "As soon as $subj _____ $obj, the phone rang.";
    expl = "ใช้ Past Simple เล่าเหตุการณ์ต่อเนื่องในอดีต";
  }

  var choices = [correct, v["v1"]!, v["v3"]!, v["ving"]!];
  choices = shuffle(choices).take(4).toList();

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl,
  };
}

// ===== PAST CONTINUOUS =====
Map<String, dynamic> genPastContinuous(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final isSing = random.nextBool();
  final subj =
      isSing ? pick(peopleSubjectsSingular) : pick(peopleSubjectsPlural);
  final be = (isSing || subj == "I") ? "was" : "were";
  final correct = "$be ${v['ving']}";

  String stem;
  String expl;

  if (diff == "easy") {
    stem = "$subj _____ $obj at 8 PM yesterday.";
    expl = "ใช้ '$correct' ระบุเวลาเจาะจงในอดีต";
  } else if (diff == "medium") {
    stem = "While $subj _____ $obj, the phone rang.";
    expl = "ใช้ Past Continuous กับ while สำหรับเหตุการณ์ที่ถูกแทรก";
  } else {
    stem = "What $be ${subj.toLowerCase()} _____ when the accident happened?";
    expl = "ใช้ Past Continuous ถามว่ากำลังทำอะไรอยู่";
  }

  var choices = [correct, v["v2"]!, "is ${v['ving']}", "has ${v['v3']}"];
  choices = shuffle(choices).take(4).toList();

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl,
  };
}

// ===== PAST PERFECT =====
Map<String, dynamic> genPastPerfect(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final subj = pick([...peopleSubjectsSingular, ...peopleSubjectsPlural]);
  final correct = "had ${v['v3']}";

  String stem;
  String expl;

  if (diff == "easy") {
    stem = "By the time we arrived, $subj _____ already $obj.";
    expl = "ใช้ '$correct' เพราะเกิดก่อนอีกเหตุการณ์ในอดีต";
  } else if (diff == "medium") {
    stem = "After $subj _____ $obj, I went home.";
    expl = "ใช้ Past Perfect หลัง after สำหรับเหตุการณ์ก่อนหน้า";
  } else {
    stem = "$subj told me that they _____ never $obj before.";
    expl = "ใช้ Past Perfect ใน reported speech";
  }

  var choices = [correct, v["v2"]!, "has ${v['v3']}", v["v1"]!];
  choices = shuffle(choices).take(4).toList();

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl,
  };
}

// ===== PAST PERFECT CONTINUOUS =====
Map<String, dynamic> genPastPerfectContinuous(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final subj = pick([...peopleSubjectsSingular, ...peopleSubjectsPlural]);
  final correct = "had been ${v['ving']}";
  final dur = pick(duration);

  String stem;
  String expl;

  if (diff == "easy") {
    stem = "$subj _____ $obj $dur before it stopped.";
    expl = "ใช้ '$correct' เน้นความต่อเนื่องก่อนเหตุการณ์ในอดีต";
  } else if (diff == "medium") {
    stem = "$subj was tired because they _____ $obj all day.";
    expl = "ใช้ Past Perfect Continuous อธิบายสาเหตุในอดีต";
  } else {
    stem = "How long had ${subj.toLowerCase()} _____ $obj before you called?";
    expl = "ใช้ 'had been ${v['ving']}' สำหรับถามระยะเวลา";
  }

  var choices = [correct, "had ${v['v3']}", "has been ${v['ving']}", v["v2"]!];
  choices = shuffle(choices).take(4).toList();

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl,
  };
}

// ===== FUTURE SIMPLE =====
Map<String, dynamic> genFutureSimple(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final subj = pick([...peopleSubjectsSingular, ...peopleSubjectsPlural]);
  final correct = "will ${v['v1']}";

  String stem;
  String expl;

  if (diff == "easy") {
    final t = pick(timeFuture);
    stem = "$subj _____ $obj $t.";
    expl = "ใช้ '$correct' กับ '$t' สำหรับอนาคต";
  } else if (diff == "medium") {
    stem = "I think $subj _____ $obj soon.";
    expl = "ใช้ will + V1 สำหรับการคาดเดา";
  } else {
    stem = "If you don't hurry, $subj _____ $obj without you.";
    expl = "ใช้ will ใน main clause ของ First Conditional";
  }

  var choices = [correct, v["v1"]!, "is going to ${v['v1']}", v["v1s"]!];
  choices = shuffle(choices).take(4).toList();

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl,
  };
}

// ===== FUTURE CONTINUOUS =====
Map<String, dynamic> genFutureContinuous(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final subj = pick([...peopleSubjectsSingular, ...peopleSubjectsPlural]);
  final correct = "will be ${v['ving']}";

  String stem;
  String expl;

  if (diff == "easy") {
    stem = "At this time tomorrow, $subj _____ $obj.";
    expl = "ใช้ '$correct' ระบุเวลาเจาะจงในอนาคต";
  } else if (diff == "medium") {
    stem = "Don't call me at 8 PM. I _____ $obj.";
    expl = "ใช้ Future Continuous สำหรับกิจกรรมที่จะกำลังทำอยู่";
  } else {
    stem = "Will $subj _____ $obj this time next week?";
    expl = "ใช้ 'will be ${v['ving']}' สำหรับถามแผนในอนาคต";
  }

  var choices = [correct, "will ${v['v1']}", "is ${v['ving']}", v["v1"]!];
  choices = shuffle(choices).take(4).toList();

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl,
  };
}

// ===== FUTURE PERFECT =====
Map<String, dynamic> genFuturePerfect(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final subj = pick([...peopleSubjectsSingular, ...peopleSubjectsPlural]);
  final correct = "will have ${v['v3']}";

  String stem;
  String expl;

  if (diff == "easy") {
    stem = "By next year, $subj _____ $obj.";
    expl = "ใช้ '$correct' กับ by + เวลาในอนาคต";
  } else if (diff == "medium") {
    stem = "By the time you arrive, I _____ $obj.";
    expl = "ใช้ Future Perfect กับ by the time";
  } else {
    stem = "How many times will $subj _____ $obj by the end of this year?";
    expl = "ใช้ 'will have ${v['v3']}' สำหรับถาม";
  }

  var choices = [
    correct,
    "will ${v['v1']}",
    "has ${v['v3']}",
    "had ${v['v3']}"
  ];
  choices = shuffle(choices).take(4).toList();

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl,
  };
}

// ===== FUTURE PERFECT CONTINUOUS =====
Map<String, dynamic> genFuturePerfectContinuous(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final subj = pick([...peopleSubjectsSingular, ...peopleSubjectsPlural]);
  final correct = "will have been ${v['ving']}";
  final dur = pick(duration);

  String stem;
  String expl;

  if (diff == "easy") {
    stem = "By 5 o'clock, $subj _____ $obj $dur.";
    expl = "ใช้ '$correct' เน้นระยะเวลาจนถึงจุดในอนาคต";
  } else if (diff == "medium") {
    stem = "By next month, I _____ at this company for 10 years.";
    expl = "ใช้ Future Perfect Continuous สำหรับระยะเวลาที่จะครบ";
  } else {
    stem = "How long will $subj _____ $obj by the time you graduate?";
    expl = "ใช้ 'will have been ${v['ving']}' สำหรับถามระยะเวลา";
  }

  var choices = [
    correct,
    "will have ${v['v3']}",
    "will be ${v['ving']}",
    "has been ${v['ving']}"
  ];
  choices = shuffle(choices).take(4).toList();

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl,
  };
}

// ===== PASSIVE VOICE =====
Map<String, dynamic> genPassiveVoice(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final isSing = random.nextBool();
  final be = isSing ? "is" : "are";
  final correct = "$be ${v['v3']}";

  // Objects that work well as passive subjects
  final passiveSubjects = [
    "English",
    "Thai food",
    "This book",
    "The report",
    "The project",
    "Many emails",
    "Coffee",
    "The car",
    "The house",
    "Homework"
  ];
  final subj = pick(passiveSubjects);

  String stem;
  String expl;

  if (diff == "easy") {
    stem = "$subj _____ by many people.";
    expl = "ใช้ '$correct' สำหรับ passive voice (be + V3)";
  } else if (diff == "medium") {
    stem = "$subj _____ every day.";
    expl = "ใช้ passive voice เมื่อไม่เน้นผู้กระทำ";
  } else {
    final correct2 = "is being ${v['v3']}";
    stem = "$subj _____ right now.";
    expl = "ใช้ 'is being ${v['v3']}' สำหรับ passive ใน Present Continuous";

    var choices = [correct2, v["v1"]!, v["v2"]!, "was ${v['v3']}"];
    choices = shuffle(choices).take(4).toList();
    return {
      "stem": stem,
      "choices": choices,
      "correctIndex": choices.indexOf(correct2),
      "explanation": expl,
    };
  }

  var choices = [correct, v["v1"]!, v["v2"]!, v["ving"]!];
  choices = shuffle(choices).take(4).toList();

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl,
  };
}

// ===== GENERATOR MAPPING =====
typedef GenFunc = Map<String, dynamic> Function(String);

final Map<String, GenFunc> generators = {
  "present_simple": genPresentSimple,
  "present_continuous": genPresentContinuous,
  "present_perfect": genPresentPerfect,
  "present_perfect_continuous": genPresentPerfectContinuous,
  "past_simple": genPastSimple,
  "past_continuous": genPastContinuous,
  "past_perfect": genPastPerfect,
  "past_perfect_continuous": genPastPerfectContinuous,
  "future_simple": genFutureSimple,
  "future_continuous": genFutureContinuous,
  "future_perfect": genFuturePerfect,
  "future_perfect_continuous": genFuturePerfectContinuous,
  "passive_voice": genPassiveVoice,
};

Map<String, List<Map<String, dynamic>>> generateForTense(
    Map<String, String> tense, int count) {
  final name = tense["name"]!;
  final packId = tense["packId"]!;
  final gen = generators[name]!;

  final diffs = {
    "easy": (count * 0.3).round(),
    "medium": (count * 0.4).round(),
    "hard": (count * 0.3).round()
  };
  final questions = <String, List<Map<String, dynamic>>>{
    "easy": [],
    "medium": [],
    "hard": []
  };

  // Track unique stems to avoid duplicates
  final usedStems = <String>{};

  for (var entry in diffs.entries) {
    final diff = entry.key;
    final num = entry.value;
    print("  Generating $num $diff questions...");

    var i = 0;
    var attempts = 0;
    while (i < num && attempts < num * 3) {
      attempts++;
      final q = gen(diff);
      final stem = q["stem"] as String;

      // Skip if duplicate
      if (usedStems.contains(stem)) continue;
      usedStems.add(stem);

      q["id"] = "q_${packId}_${diff[0]}_${i + 1}";
      q["skillType"] = "grammar";
      q["packId"] = packId;
      questions[diff]!.add(q);
      i++;
    }
  }

  return questions;
}

void main() {
  final outputDir = Directory("assets/data/quiz");
  if (!outputDir.existsSync()) outputDir.createSync(recursive: true);

  print("=" * 60);
  print("Grammar Quiz Generator V2 (Improved Diversity)");
  print("=" * 60);
  print("Generating 5,000 questions per tense (${tenses.length} tenses)");
  print("=" * 60);

  for (var tense in tenses) {
    print("\nProcessing: ${tense['title']}");
    final questions = generateForTense(tense, 5000);

    final filename =
        "assets/data/quiz/grammar_quiz_${tense['id']!.replaceFirst('grammar_', '')}_${tense['name']}.json";
    File(filename).writeAsStringSync(
        const JsonEncoder.withIndent("  ").convert(questions));

    final total =
        questions.values.fold<int>(0, (sum, list) => sum + list.length);
    print("  Saved $total questions to $filename");
  }

  print("\n${"=" * 60}");
  print("Generation complete!");
  print("=" * 60);
}
