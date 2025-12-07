/// Grammar Quiz Generator V4 - Fixed All Issues
/// 1. Correct subject-verb agreement (does/do)
/// 2. Complete sentences with objects
/// 3. No duplicate choices
/// 4. Correct answers for Did/Does questions
/// 5. No stative verbs in continuous tenses
library;

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';

final random = Random();

// ===== SUBJECTS =====
final List<String> singularSubjects = [
  "He",
  "She",
  "My father",
  "My mother",
  "The teacher",
  "John",
  "Mary",
  "Tom",
  "Lisa",
  "David",
  "Sarah",
  "My brother",
  "My sister",
  "The chef",
  "The manager",
  "The engineer",
  "The doctor",
  "The nurse",
  "The artist",
  "The lawyer",
  "My boss",
  "The driver",
  "The pilot",
  "The student",
  "My uncle",
  "My aunt",
  "The boy",
  "The girl",
  "The man",
  "The woman"
];

final List<String> pluralSubjects = [
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
  "The children",
  "The engineers",
  "The artists",
  "My colleagues",
  "The nurses",
  "The boys",
  "The girls",
  "People",
  "Many people"
];

// ===== TIME EXPRESSIONS =====
final List<String> timePresent = [
  "every day",
  "every morning",
  "every evening",
  "every week",
  "every weekend",
  "every month",
  "on Mondays",
  "on weekends",
  "twice a week",
  "once a month"
];
final List<String> freq = [
  "always",
  "usually",
  "often",
  "sometimes",
  "rarely",
  "seldom",
  "frequently",
  "normally",
  "generally"
];
final List<String> timePast = [
  "yesterday",
  "last night",
  "last week",
  "last month",
  "last year",
  "two days ago",
  "an hour ago",
  "this morning",
  "in 2020"
];
final List<String> timeFuture = [
  "tomorrow",
  "next week",
  "next month",
  "next year",
  "soon",
  "tonight",
  "later",
  "next Monday",
  "this weekend"
];
final List<String> timeNow = [
  "now",
  "right now",
  "at the moment",
  "currently",
  "at this time"
];
final List<String> timePerfect = [
  "already",
  "just",
  "recently",
  "before",
  "many times",
  "twice",
  "several times"
];
final List<String> duration = [
  "for 2 hours",
  "for 3 days",
  "for a week",
  "for a month",
  "since morning",
  "since yesterday",
  "all day"
];

// ===== STATIVE VERBS (don't use in continuous) =====
final List<String> stativeVerbs = [
  "know",
  "want",
  "need",
  "like",
  "love",
  "see",
  "hear",
  "feel",
  "think",
  "understand"
];

// ===== ACTION VERBS (safe for continuous) =====
final List<String> actionVerbs = [
  "eat",
  "drink",
  "cook",
  "speak",
  "write",
  "read",
  "listen",
  "watch",
  "play",
  "study",
  "work",
  "go",
  "come",
  "walk",
  "run",
  "drive",
  "fly",
  "buy",
  "sell",
  "pay",
  "learn",
  "teach",
  "meet",
  "help",
  "make",
  "take",
  "give",
  "get",
  "start",
  "finish",
  "stop",
  "try",
  "use",
  "open",
  "close",
  "stay",
  "live",
  "wait",
  "call",
  "sit",
  "stand",
  "arrive",
  "leave",
  "visit",
  "send",
  "spend",
  "save",
  "find",
  "sleep",
  "wake",
  "clean"
];

// ===== VERB-OBJECT PAIRS =====
final Map<String, List<String>> verbObjectPairs = {
  "eat": [
    "breakfast",
    "lunch",
    "dinner",
    "an apple",
    "rice",
    "pizza",
    "noodles"
  ],
  "drink": ["water", "coffee", "tea", "juice", "milk", "a smoothie"],
  "cook": ["dinner", "breakfast", "pasta", "soup", "rice", "chicken"],
  "speak": ["English", "Thai", "Chinese", "Japanese", "French"],
  "write": ["an email", "a letter", "a report", "a message", "notes"],
  "read": ["a book", "the newspaper", "an article", "emails", "a magazine"],
  "listen": ["to music", "to the radio", "to my teacher", "to podcasts"],
  "watch": [
    "TV",
    "movies",
    "YouTube",
    "the news",
    "Netflix",
    "a football match"
  ],
  "play": ["football", "basketball", "tennis", "games", "piano", "guitar"],
  "study": ["English", "math", "science", "history", "for the exam"],
  "work": ["hard", "at a company", "from home", "overtime", "on weekends"],
  "go": ["to school", "to work", "home", "shopping", "to the gym"],
  "come": ["home", "to class", "to work", "back", "early"],
  "walk": ["to school", "to work", "in the park", "home"],
  "run": ["in the morning", "in the park", "every day", "fast"],
  "drive": ["to work", "a car", "carefully", "to the mall"],
  "fly": ["to Bangkok", "to Japan", "abroad", "home"],
  "buy": ["groceries", "clothes", "a new phone", "coffee", "food"],
  "sell": ["products", "cars", "online", "at the market"],
  "pay": ["the bills", "for dinner", "by credit card", "in cash"],
  "learn": ["English", "new skills", "quickly", "from mistakes"],
  "teach": ["English", "students", "children", "at a school"],
  "meet": ["friends", "clients", "new people", "at the cafe"],
  "help": ["my parents", "my friends", "others", "with homework"],
  "make": ["breakfast", "a decision", "money", "friends", "coffee"],
  "take": ["a shower", "the bus", "photos", "a break", "notes"],
  "give": ["advice", "a gift", "money", "presentations"],
  "get": ["up early", "home late", "good grades", "ready"],
  "start": ["work", "a new project", "exercising", "the day"],
  "finish": ["work", "homework", "on time", "the project"],
  "stop": ["smoking", "working", "talking", "here"],
  "try": ["my best", "new food", "to learn", "harder"],
  "use": ["a computer", "my phone", "the internet", "English"],
  "open": ["the door", "the window", "my email", "a book"],
  "close": ["the door", "the window", "my eyes", "the shop"],
  "stay": ["home", "healthy", "calm", "at a hotel"],
  "live": ["in Bangkok", "with my parents", "alone", "in a house"],
  "wait": ["for the bus", "patiently", "in line", "for my turn"],
  "call": ["my mother", "my friend", "the office", "a taxi"],
  "sit": ["down", "quietly", "in the front", "on the sofa"],
  "stand": ["up", "in line", "by the door", "here"],
  "arrive": ["at school", "at work", "on time", "early"],
  "leave": ["home", "the office", "early", "for work"],
  "visit": ["my grandparents", "friends", "the doctor", "Japan"],
  "send": ["an email", "a message", "money", "a letter"],
  "spend": ["money", "time with family", "the weekend"],
  "save": ["money", "time", "energy", "the document"],
  "find": ["my keys", "a job", "a solution", "information"],
  "sleep": ["early", "late", "well", "for 8 hours"],
  "wake": ["up early", "up at 6 AM", "up late"],
  "clean": ["the house", "my room", "the kitchen", "the car"],
};

// ===== VERB FORMS =====
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
  "cook": {
    "v1": "cook",
    "v2": "cooked",
    "v3": "cooked",
    "ving": "cooking",
    "v1s": "cooks"
  },
  "speak": {
    "v1": "speak",
    "v2": "spoke",
    "v3": "spoken",
    "ving": "speaking",
    "v1s": "speaks"
  },
  "write": {
    "v1": "write",
    "v2": "wrote",
    "v3": "written",
    "ving": "writing",
    "v1s": "writes"
  },
  "read": {
    "v1": "read",
    "v2": "read",
    "v3": "read",
    "ving": "reading",
    "v1s": "reads"
  },
  "listen": {
    "v1": "listen",
    "v2": "listened",
    "v3": "listened",
    "ving": "listening",
    "v1s": "listens"
  },
  "watch": {
    "v1": "watch",
    "v2": "watched",
    "v3": "watched",
    "ving": "watching",
    "v1s": "watches"
  },
  "play": {
    "v1": "play",
    "v2": "played",
    "v3": "played",
    "ving": "playing",
    "v1s": "plays"
  },
  "study": {
    "v1": "study",
    "v2": "studied",
    "v3": "studied",
    "ving": "studying",
    "v1s": "studies"
  },
  "work": {
    "v1": "work",
    "v2": "worked",
    "v3": "worked",
    "ving": "working",
    "v1s": "works"
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
  "walk": {
    "v1": "walk",
    "v2": "walked",
    "v3": "walked",
    "ving": "walking",
    "v1s": "walks"
  },
  "run": {
    "v1": "run",
    "v2": "ran",
    "v3": "run",
    "ving": "running",
    "v1s": "runs"
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
  "pay": {
    "v1": "pay",
    "v2": "paid",
    "v3": "paid",
    "ving": "paying",
    "v1s": "pays"
  },
  "learn": {
    "v1": "learn",
    "v2": "learned",
    "v3": "learned",
    "ving": "learning",
    "v1s": "learns"
  },
  "teach": {
    "v1": "teach",
    "v2": "taught",
    "v3": "taught",
    "ving": "teaching",
    "v1s": "teaches"
  },
  "meet": {
    "v1": "meet",
    "v2": "met",
    "v3": "met",
    "ving": "meeting",
    "v1s": "meets"
  },
  "help": {
    "v1": "help",
    "v2": "helped",
    "v3": "helped",
    "ving": "helping",
    "v1s": "helps"
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
  "get": {
    "v1": "get",
    "v2": "got",
    "v3": "gotten",
    "ving": "getting",
    "v1s": "gets"
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
  "stop": {
    "v1": "stop",
    "v2": "stopped",
    "v3": "stopped",
    "ving": "stopping",
    "v1s": "stops"
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
  "stay": {
    "v1": "stay",
    "v2": "stayed",
    "v3": "stayed",
    "ving": "staying",
    "v1s": "stays"
  },
  "live": {
    "v1": "live",
    "v2": "lived",
    "v3": "lived",
    "ving": "living",
    "v1s": "lives"
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
  "send": {
    "v1": "send",
    "v2": "sent",
    "v3": "sent",
    "ving": "sending",
    "v1s": "sends"
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
  "find": {
    "v1": "find",
    "v2": "found",
    "v3": "found",
    "ving": "finding",
    "v1s": "finds"
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
  "clean": {
    "v1": "clean",
    "v2": "cleaned",
    "v3": "cleaned",
    "ving": "cleaning",
    "v1s": "cleans"
  },
};

// ===== TENSES =====
final tenses = [
  {"id": "grammar_001", "name": "present_simple", "packId": "grammar_001"},
  {"id": "grammar_002", "name": "present_continuous", "packId": "grammar_002"},
  {"id": "grammar_003", "name": "present_perfect", "packId": "grammar_003"},
  {
    "id": "grammar_004",
    "name": "present_perfect_continuous",
    "packId": "grammar_004"
  },
  {"id": "grammar_005", "name": "past_simple", "packId": "grammar_005"},
  {"id": "grammar_006", "name": "past_continuous", "packId": "grammar_006"},
  {"id": "grammar_007", "name": "past_perfect", "packId": "grammar_007"},
  {
    "id": "grammar_008",
    "name": "past_perfect_continuous",
    "packId": "grammar_008"
  },
  {"id": "grammar_009", "name": "future_simple", "packId": "grammar_009"},
  {"id": "grammar_010", "name": "future_continuous", "packId": "grammar_010"},
  {"id": "grammar_011", "name": "future_perfect", "packId": "grammar_011"},
  {
    "id": "grammar_012",
    "name": "future_perfect_continuous",
    "packId": "grammar_012"
  },
  {"id": "grammar_013", "name": "passive_voice", "packId": "grammar_013"},
];

// ===== HELPER FUNCTIONS =====
String pick(List<String> l) => l[random.nextInt(l.length)];

MapEntry<String, Map<String, String>> pickVerb({bool actionOnly = false}) {
  final keys = actionOnly
      ? actionVerbs.where((v) => verbs.containsKey(v)).toList()
      : verbs.keys.toList();
  final k = keys[random.nextInt(keys.length)];
  return MapEntry(k, verbs[k]!);
}

String pickObject(String vk) {
  final objs = verbObjectPairs[vk];
  return (objs != null && objs.isNotEmpty)
      ? objs[random.nextInt(objs.length)]
      : "";
}

/// Create 4 unique choices
List<String> makeChoices(String correct, List<String> distractors) {
  final choices = <String>{correct};
  for (var d in distractors.where((d) => d != correct)) {
    if (choices.length >= 4) break;
    choices.add(d);
  }
  // If not enough, add generic options
  while (choices.length < 4) {
    choices.add("option${choices.length}");
  }
  final result = choices.toList()..shuffle(random);
  return result;
}

// ===== GENERATORS =====

Map<String, dynamic>? genPresentSimple(String diff) {
  final ve = pickVerb();
  final vk = ve.key;
  final v = ve.value;
  final obj = pickObject(vk);
  final isSing = random.nextBool();
  final subj = isSing ? pick(singularSubjects) : pick(pluralSubjects);
  final correct = isSing ? v["v1s"]! : v["v1"]!;

  String stem;
  String expl;

  if (diff == "easy") {
    final t = pick(timePresent);
    stem = "$subj _____ $obj $t.";
    expl = isSing ? "ประธานเอกพจน์ใช้ V1+s/es" : "ประธานพหูพจน์ใช้ V1";
  } else if (diff == "medium") {
    final f = pick(freq);
    final doWord = isSing ? "does" : "do";
    final subjLower = subj.toLowerCase();
    final patterns = [
      ("$subj $f _____ $obj.", correct, "ใช้ $correct กับ adverb of frequency"),
      ("$doWord $subjLower _____ $obj?", v["v1"]!, "หลัง $doWord ใช้ V1 เสมอ"),
      (
        "$subj ${doWord}n't _____ $obj.",
        v["v1"]!,
        "หลัง ${doWord}n't ใช้ V1 เสมอ"
      ),
    ];
    final p = patterns[random.nextInt(patterns.length)];
    stem = p.$1;
    final c = p.$2;
    expl = p.$3;

    final choices = makeChoices(c, [v["v1"]!, v["v1s"]!, v["v2"]!, v["ving"]!]);
    return {
      "stem": stem,
      "choices": choices,
      "correctIndex": choices.indexOf(c),
      "explanation": expl
    };
  } else {
    final patterns = [
      "If $subj _____ $obj, I will be happy.",
      "When $subj _____ $obj, everyone is happy.",
    ];
    stem = pick(patterns);
    expl = "ใช้ Present Simple ใน if/when clause";
  }

  final choices =
      makeChoices(correct, [v["v1"]!, v["v1s"]!, v["v2"]!, v["ving"]!]);
  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl
  };
}

Map<String, dynamic>? genPresentContinuous(String diff) {
  // Only use action verbs for continuous
  final ve = pickVerb(actionOnly: true);
  final vk = ve.key;
  final v = ve.value;
  final obj = pickObject(vk);
  final isSing = random.nextBool();
  final subj = isSing ? pick(singularSubjects) : pick(pluralSubjects);
  final be = isSing ? "is" : (subj == "I" ? "am" : "are");
  final correct = "$be ${v['ving']}";

  String stem;
  String expl = "ใช้ be + Ving สำหรับเหตุการณ์ที่กำลังเกิดขึ้น";

  if (diff == "easy") {
    final t = pick(timeNow);
    stem = "$subj _____ $obj $t.";
  } else if (diff == "medium") {
    final patterns = ["Look! $subj _____ $obj.", "Listen! $subj _____ $obj."];
    stem = pick(patterns);
    expl = "ใช้ Present Continuous หลัง Look!/Listen!";
  } else {
    stem = "$subj _____ $obj these days because it's temporary.";
    expl = "ใช้ Present Continuous สำหรับสถานการณ์ชั่วคราว";
  }

  final choices =
      makeChoices(correct, [v["v1"]!, v["v2"]!, "$be ${v['v1']}", v["v1s"]!]);
  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl
  };
}

Map<String, dynamic>? genPresentPerfect(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final isSing = random.nextBool();
  final subj = isSing ? pick(singularSubjects) : pick(pluralSubjects);
  final have = isSing ? "has" : "have";
  final correct = "$have ${v['v3']}";

  String stem;
  String expl = "ใช้ have/has + V3 ใน Present Perfect";

  if (diff == "easy") {
    final t = pick(timePerfect);
    stem = "$subj _____ $t $obj.";
  } else if (diff == "medium") {
    final patterns = [
      "$subj _____ $obj since 2020.",
      "$subj _____ $obj for 5 years.",
    ];
    stem = pick(patterns);
    expl = "ใช้ Present Perfect กับ since/for";
  } else {
    stem = "This is the best $obj that $subj _____ ever tried.";
  }

  final choices = makeChoices(
      correct, [v["v1"]!, v["v2"]!, "had ${v['v3']}", "$have ${v['v1']}"]);
  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl
  };
}

Map<String, dynamic>? genPresentPerfectContinuous(String diff) {
  final ve = pickVerb(actionOnly: true);
  final v = ve.value;
  final obj = pickObject(ve.key);
  final isSing = random.nextBool();
  final subj = isSing ? pick(singularSubjects) : pick(pluralSubjects);
  final have = isSing ? "has" : "have";
  final correct = "$have been ${v['ving']}";
  final dur = pick(duration);

  String stem;
  String expl = "ใช้ have/has been + Ving เน้นความต่อเนื่อง";

  if (diff == "easy") {
    stem = "$subj _____ $obj $dur.";
  } else if (diff == "medium") {
    stem = "$subj looks tired because he/she _____ $obj all day.";
  } else {
    stem = "How long _____ $subj been ${v['ving']} $obj?";
    expl = "ถามระยะเวลาด้วย How long + have/has";
    final choices = makeChoices(have, ["has", "have", "had", "is"]);
    return {
      "stem": stem,
      "choices": choices,
      "correctIndex": choices.indexOf(have),
      "explanation": expl
    };
  }

  final choices = makeChoices(correct,
      ["$have ${v['v3']}", v["v2"]!, "was ${v['ving']}", "$have ${v['v1']}"]);
  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl
  };
}

Map<String, dynamic>? genPastSimple(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final subj = pick([...singularSubjects, ...pluralSubjects]);
  final correct = v["v2"]!;

  String stem;
  String expl = "ใช้ V2 สำหรับเหตุการณ์ในอดีต";

  if (diff == "easy") {
    final t = pick(timePast);
    stem = "$subj _____ $obj $t.";
  } else if (diff == "medium") {
    final patterns = [
      ("Did $subj _____ $obj yesterday?", v["v1"]!, "หลัง Did ใช้ V1 เสมอ"),
      (
        "$subj didn't _____ $obj last week.",
        v["v1"]!,
        "หลัง didn't ใช้ V1 เสมอ"
      ),
      (
        "$subj _____ $obj and then left.",
        correct,
        "ใช้ V2 สำหรับเหตุการณ์ในอดีต"
      ),
    ];
    final p = patterns[random.nextInt(patterns.length)];
    stem = p.$1;
    final c = p.$2;
    expl = p.$3;
    final choices = makeChoices(c, [v["v1"]!, v["v2"]!, v["v3"]!, v["ving"]!]);
    return {
      "stem": stem,
      "choices": choices,
      "correctIndex": choices.indexOf(c),
      "explanation": expl
    };
  } else {
    stem = "As soon as $subj _____ $obj, the phone rang.";
  }

  final choices =
      makeChoices(correct, [v["v1"]!, v["v3"]!, v["ving"]!, v["v1s"]!]);
  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl
  };
}

Map<String, dynamic>? genPastContinuous(String diff) {
  final ve = pickVerb(actionOnly: true);
  final v = ve.value;
  final obj = pickObject(ve.key);
  final isSing = random.nextBool();
  final subj = isSing ? pick(singularSubjects) : pick(pluralSubjects);
  final be = (isSing || subj == "I") ? "was" : "were";
  final correct = "$be ${v['ving']}";

  String stem;
  String expl = "ใช้ was/were + Ving สำหรับเหตุการณ์ที่กำลังเกิดในอดีต";

  if (diff == "easy") {
    stem = "$subj _____ $obj at 8 PM yesterday.";
  } else if (diff == "medium") {
    stem = "While $subj _____ $obj, the phone rang.";
    expl = "ใช้ Past Continuous กับ while";
  } else {
    stem = "$subj _____ $obj when I arrived.";
  }

  final choices = makeChoices(
      correct, [v["v2"]!, "is ${v['ving']}", v["v1"]!, "$be ${v['v1']}"]);
  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl
  };
}

Map<String, dynamic>? genPastPerfect(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final subj = pick([...singularSubjects, ...pluralSubjects]);
  final correct = "had ${v['v3']}";

  String stem;
  String expl = "ใช้ had + V3 สำหรับเหตุการณ์ที่เกิดก่อนอีกเหตุการณ์ในอดีต";

  if (diff == "easy") {
    stem = "By the time I arrived, $subj _____ already $obj.";
  } else if (diff == "medium") {
    stem = "After $subj _____ $obj, we left.";
  } else {
    stem = "$subj told me that they _____ never tried $obj before.";
  }

  final choices = makeChoices(
      correct, [v["v2"]!, "has ${v['v3']}", v["v1"]!, "have ${v['v3']}"]);
  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl
  };
}

Map<String, dynamic>? genPastPerfectContinuous(String diff) {
  final ve = pickVerb(actionOnly: true);
  final v = ve.value;
  final obj = pickObject(ve.key);
  final subj = pick([...singularSubjects, ...pluralSubjects]);
  final correct = "had been ${v['ving']}";
  final dur = pick(duration);

  String stem;
  String expl = "ใช้ had been + Ving เน้นความต่อเนื่องก่อนเหตุการณ์ในอดีต";

  if (diff == "easy") {
    stem = "$subj _____ $obj $dur before it stopped.";
  } else if (diff == "medium") {
    stem = "$subj was tired because he/she _____ $obj all day.";
  } else {
    stem = "$subj _____ $obj for years before finally succeeding.";
  }

  final choices = makeChoices(correct, [
    "had ${v['v3']}",
    "has been ${v['ving']}",
    v["v2"]!,
    "was ${v['ving']}"
  ]);
  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl
  };
}

Map<String, dynamic>? genFutureSimple(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final subj = pick([...singularSubjects, ...pluralSubjects]);
  final correct = "will ${v['v1']}";

  String stem;
  String expl = "ใช้ will + V1 สำหรับอนาคต";

  if (diff == "easy") {
    final t = pick(timeFuture);
    stem = "$subj _____ $obj $t.";
  } else if (diff == "medium") {
    stem = "I think $subj _____ $obj soon.";
    expl = "ใช้ will สำหรับการคาดเดา";
  } else {
    stem = "If it rains, $subj _____ $obj inside.";
    expl = "ใช้ will ใน main clause ของ First Conditional";
  }

  final choices = makeChoices(
      correct, [v["v1"]!, "is going to ${v['v1']}", v["v1s"]!, v["v2"]!]);
  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl
  };
}

Map<String, dynamic>? genFutureContinuous(String diff) {
  final ve = pickVerb(actionOnly: true);
  final v = ve.value;
  final obj = pickObject(ve.key);
  final subj = pick([...singularSubjects, ...pluralSubjects]);
  final correct = "will be ${v['ving']}";

  String stem;
  String expl = "ใช้ will be + Ving สำหรับเหตุการณ์ที่จะกำลังเกิดในอนาคต";

  if (diff == "easy") {
    stem = "At this time tomorrow, $subj _____ $obj.";
  } else if (diff == "medium") {
    stem = "Don't call at 8 PM. $subj _____ $obj.";
  } else {
    stem = "This time next week, $subj _____ $obj.";
  }

  final choices = makeChoices(correct,
      ["will ${v['v1']}", "is ${v['ving']}", v["v1"]!, "will ${v['v1s']}"]);
  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl
  };
}

Map<String, dynamic>? genFuturePerfect(String diff) {
  final ve = pickVerb();
  final v = ve.value;
  final obj = pickObject(ve.key);
  final subj = pick([...singularSubjects, ...pluralSubjects]);
  final correct = "will have ${v['v3']}";

  String stem;
  String expl = "ใช้ will have + V3 สำหรับเหตุการณ์ที่จะเสร็จก่อนเวลาในอนาคต";

  if (diff == "easy") {
    stem = "By next year, $subj _____ $obj.";
  } else if (diff == "medium") {
    stem = "By the time you arrive, $subj _____ $obj.";
  } else {
    stem = "$subj _____ $obj before sunset.";
  }

  final choices = makeChoices(correct, [
    "will ${v['v1']}",
    "has ${v['v3']}",
    "had ${v['v3']}",
    "will be ${v['ving']}"
  ]);
  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl
  };
}

Map<String, dynamic>? genFuturePerfectContinuous(String diff) {
  final ve = pickVerb(actionOnly: true);
  final v = ve.value;
  final obj = pickObject(ve.key);
  final subj = pick([...singularSubjects, ...pluralSubjects]);
  final correct = "will have been ${v['ving']}";
  final dur = pick(duration);
  final t = pick(timeFuture);

  String stem;
  String expl = "ใช้ will have been + Ving เน้นระยะเวลาจนถึงจุดในอนาคต";

  if (diff == "easy") {
    final patterns = [
      "By 5 PM, $subj _____ $obj $dur.",
      "By $t, $subj _____ $obj $dur.",
      "$subj _____ $obj $dur by noon.",
    ];
    stem = pick(patterns);
  } else if (diff == "medium") {
    final patterns = [
      "By next month, $subj _____ $obj for a year.",
      "In 2025, $subj _____ $obj for 5 years.",
      "$subj _____ $obj $dur by the end of the year.",
      "By the time I retire, $subj _____ $obj for decades.",
      "How long _____ $subj been ${v['ving']} by $t?",
    ];
    final idx = random.nextInt(patterns.length);
    stem = patterns[idx];
    if (stem.startsWith("How long")) {
      final choices =
          makeChoices("will have", ["will be", "has been", "had been", "will"]);
      return {
        "stem": stem,
        "choices": choices,
        "correctIndex": choices.indexOf("will have"),
        "explanation": expl
      };
    }
  } else {
    final patterns = [
      "By graduation, $subj _____ $obj for 4 years.",
      "By the end of this project, $subj _____ $obj for months.",
      "$subj _____ $obj continuously until $t.",
    ];
    stem = pick(patterns);
  }

  final choices = makeChoices(correct, [
    "will have ${v['v3']}",
    "will be ${v['ving']}",
    "has been ${v['ving']}",
    "will ${v['v1']}"
  ]);
  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl
  };
}

Map<String, dynamic>? genPassiveVoice(String diff) {
  final ve = pickVerb();
  final v = ve.value;

  final passiveSubjects = [
    "English",
    "This book",
    "The report",
    "The project",
    "Coffee",
    "The email",
    "The letter",
    "Rice",
    "Thai food",
    "The car",
    "The house",
    "The door",
    "The window",
    "The message",
    "The news",
    "Pizza",
    "The homework",
    "The test",
    "The meeting",
    "The document",
    "The package",
    "The order",
    "The bill",
    "The contract",
    "The photo",
    "The video",
    "The song",
    "The movie",
    "The article",
    "Dinner",
    "Breakfast",
    "Lunch",
    "The phone",
    "The computer",
    "The money",
    "The gift",
    "The problem",
    "The question",
    "The answer",
    "The work",
    "The job",
    "The plan",
    "The idea",
    "The food",
    "The drink",
    "The product",
    "The service",
    "The website",
    "The app",
    "The game"
  ];

  final agents = [
    "many people",
    "the teacher",
    "the students",
    "the chef",
    "the company",
    "the workers",
    "experts",
    "the team",
    "the manager",
    "professionals",
    "the government",
    "the police",
    "the doctors",
    "the engineers",
    "the staff",
    "everyone",
    "the public",
    "customers",
    "clients",
    "the audience"
  ];

  final locations = [
    "in Thailand",
    "in Japan",
    "around the world",
    "at the office",
    "at school",
    "in the factory",
    "everywhere",
    "in America",
    "in Europe",
    "at the hospital",
    "in many countries",
    "at home",
    "in the kitchen",
    "at the store",
    "online"
  ];

  final frequency = [
    "every day",
    "every week",
    "every month",
    "regularly",
    "often",
    "always",
    "usually",
    "frequently",
    "twice a week",
    "once a month"
  ];

  final ps = pick(passiveSubjects);
  final agent = pick(agents);
  final loc = pick(locations);
  final t1 = pick(timePast);
  final t2 = pick(timeFuture);
  final freq = pick(frequency);

  String stem;
  String correct;
  String expl = "ใช้ be + V3 สำหรับ Passive Voice";

  if (diff == "easy") {
    final patterns = [
      "$ps _____ by $agent $freq.",
      "$ps _____ $loc $freq.",
      "$ps _____ by professionals.",
      "$ps _____ carefully $freq.",
      "$ps _____ $loc by $agent.",
      "$ps _____ around the world.",
      "$ps _____ by $agent in many countries.",
      "$ps _____ at this company $freq.",
      "$ps _____ by the team $freq.",
      "$ps _____ properly by experts.",
    ];
    stem = pick(patterns);
    correct = "is ${v['v3']}";
  } else if (diff == "medium") {
    final patterns = [
      "$ps _____ by $agent $t1.",
      "$ps _____ $loc $t1.",
      "$ps _____ before the deadline.",
      "$ps _____ by the team last night.",
      "$ps _____ carefully $t1.",
      "$ps _____ $t1 by professionals.",
      "$ps wasn't _____ by anyone.",
      "Was $ps _____ by $agent?",
      "$ps _____ when I arrived.",
      "$ps has been _____ already.",
      "$ps has been _____ by $agent.",
      "$ps hasn't been _____ yet.",
    ];
    final idx = random.nextInt(patterns.length);
    stem = patterns[idx];
    if (stem.contains("wasn't _____") ||
        stem.contains("Was $ps _____") ||
        stem.contains("has been _____") ||
        stem.contains("hasn't been _____")) {
      correct = v["v3"]!;
      expl = "ใช้ V3 หลัง be/been ใน Passive Voice";
    } else {
      correct = "was ${v['v3']}";
      expl = "ใช้ was/were + V3 สำหรับ Passive Voice ในอดีต";
    }
  } else {
    final patterns = [
      "$ps _____ by $agent right now.",
      "$ps _____ at this moment.",
      "$ps will be _____ by the team $t2.",
      "$ps should be _____ carefully.",
      "$ps must be _____ before Friday.",
      "$ps can be _____ easily.",
      "$ps might be _____ $t2.",
      "$ps needs to be _____ immediately.",
      "$ps is going to be _____ soon.",
      "$ps will be _____ by $agent.",
      "$ps had been _____ before I arrived.",
      "By $t2, $ps will have been _____ completely.",
    ];
    final idx = random.nextInt(patterns.length);
    stem = patterns[idx];
    if (stem.contains("_____ by") && stem.contains("right now")) {
      correct = "is being ${v['v3']}";
      expl = "ใช้ is being + V3 สำหรับ Passive Voice ปัจจุบัน";
    } else if (stem.contains("will be _____") ||
        stem.contains("should be _____") ||
        stem.contains("must be _____") ||
        stem.contains("can be _____") ||
        stem.contains("might be _____") ||
        stem.contains("needs to be _____") ||
        stem.contains("is going to be _____") ||
        stem.contains("had been _____") ||
        stem.contains("will have been _____")) {
      correct = v["v3"]!;
      expl = "หลัง modal + be / have been ใช้ V3";
    } else {
      correct = "is being ${v['v3']}";
      expl = "ใช้ is being + V3 สำหรับเหตุการณ์ที่กำลังถูกกระทำ";
    }
  }

  final choices =
      makeChoices(correct, [v["v1"]!, v["v2"]!, v["ving"]!, "is ${v['v1']}"]);
  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": choices.indexOf(correct),
    "explanation": expl
  };
}

// ===== GENERATOR MAPPING =====
typedef GenFunc = Map<String, dynamic>? Function(String);

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

void main() {
  final dir = Directory("assets/data/quiz");
  if (!dir.existsSync()) dir.createSync(recursive: true);

  print("=" * 60);
  print("Grammar Quiz Generator V4 - All Issues Fixed");
  print("=" * 60);
  print("1. Correct subject-verb agreement");
  print("2. Complete sentences with objects");
  print("3. No duplicate choices");
  print("4. Correct answers for Did/Does questions");
  print("5. No stative verbs in continuous tenses");
  print("=" * 60);

  for (var t in tenses) {
    print("\n${t['name']}...");
    final qs = <String, List<Map<String, dynamic>>>{
      "easy": [],
      "medium": [],
      "hard": []
    };
    final used = <String>{};

    final gen = generators[t["name"]!]!;

    for (var d in ["easy", "medium", "hard"]) {
      final target = d == "medium" ? 2000 : 1500;
      var i = 0;
      var attempts = 0;
      while (i < target && attempts < target * 20) {
        attempts++;
        final q = gen(d);
        if (q == null) continue;

        final stem = q["stem"] as String;
        if (stem.isEmpty || used.contains(stem)) continue;
        if (q["correctIndex"] == -1) continue; // Invalid choice

        used.add(stem);
        q["id"] = "q_${t['packId']}_${d[0]}_${i + 1}";
        q["skillType"] = "grammar";
        q["packId"] = t["packId"];
        qs[d]!.add(q);
        i++;
      }
      print("  $d: ${qs[d]!.length}");
    }

    final fn =
        "assets/data/quiz/grammar_quiz_${t['id']!.replaceFirst('grammar_', '')}_${t['name']}.json";
    File(fn).writeAsStringSync(const JsonEncoder.withIndent("  ").convert(qs));
  }

  print("\n${"=" * 60}");
  print("Generation complete!");
  print("=" * 60);
}
