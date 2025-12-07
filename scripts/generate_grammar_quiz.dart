/// Grammar Quiz Generator
/// Generates 5,000 questions per tense for 13 grammar topics (65,000 total)
///
/// Run with: dart run scripts/generate_grammar_quiz.dart
library;

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';

// ===== VOCABULARY DATA =====

final List<String> subjectsSingular = [
  "He",
  "She",
  "It",
  "My father",
  "My mother",
  "The teacher",
  "The student",
  "The doctor",
  "The cat",
  "The dog",
  "John",
  "Mary",
  "Tom",
  "Lisa",
  "David",
  "Sarah",
  "The baby",
  "The bird",
  "The sun",
  "The moon",
  "The manager",
  "The chef",
  "The driver",
  "The pilot",
  "The nurse",
  "My brother",
  "My sister",
  "The boy",
  "The girl",
  "The man",
  "The woman",
  "The child",
  "The artist",
  "The scientist",
  "The engineer",
  "The lawyer",
  "The policeman",
  "The farmer"
];

final List<String> subjectsPlural = [
  "I",
  "You",
  "We",
  "They",
  "The students",
  "The teachers",
  "The children",
  "My parents",
  "The workers",
  "The people",
  "The birds",
  "The dogs",
  "The cats",
  "Tom and Mary",
  "The boys",
  "The girls",
  "My friends",
  "The scientists",
  "The engineers",
  "The farmers",
  "The doctors",
  "The nurses",
  "The artists"
];

final Map<String, Map<String, String>> verbsBase = {
  "eat": {
    "v1": "eat",
    "v2": "ate",
    "v3": "eaten",
    "ving": "eating",
    "v1_s": "eats"
  },
  "drink": {
    "v1": "drink",
    "v2": "drank",
    "v3": "drunk",
    "ving": "drinking",
    "v1_s": "drinks"
  },
  "go": {
    "v1": "go",
    "v2": "went",
    "v3": "gone",
    "ving": "going",
    "v1_s": "goes"
  },
  "come": {
    "v1": "come",
    "v2": "came",
    "v3": "come",
    "ving": "coming",
    "v1_s": "comes"
  },
  "play": {
    "v1": "play",
    "v2": "played",
    "v3": "played",
    "ving": "playing",
    "v1_s": "plays"
  },
  "work": {
    "v1": "work",
    "v2": "worked",
    "v3": "worked",
    "ving": "working",
    "v1_s": "works"
  },
  "study": {
    "v1": "study",
    "v2": "studied",
    "v3": "studied",
    "ving": "studying",
    "v1_s": "studies"
  },
  "read": {
    "v1": "read",
    "v2": "read",
    "v3": "read",
    "ving": "reading",
    "v1_s": "reads"
  },
  "write": {
    "v1": "write",
    "v2": "wrote",
    "v3": "written",
    "ving": "writing",
    "v1_s": "writes"
  },
  "speak": {
    "v1": "speak",
    "v2": "spoke",
    "v3": "spoken",
    "ving": "speaking",
    "v1_s": "speaks"
  },
  "run": {
    "v1": "run",
    "v2": "ran",
    "v3": "run",
    "ving": "running",
    "v1_s": "runs"
  },
  "walk": {
    "v1": "walk",
    "v2": "walked",
    "v3": "walked",
    "ving": "walking",
    "v1_s": "walks"
  },
  "sleep": {
    "v1": "sleep",
    "v2": "slept",
    "v3": "slept",
    "ving": "sleeping",
    "v1_s": "sleeps"
  },
  "wake": {
    "v1": "wake",
    "v2": "woke",
    "v3": "woken",
    "ving": "waking",
    "v1_s": "wakes"
  },
  "cook": {
    "v1": "cook",
    "v2": "cooked",
    "v3": "cooked",
    "ving": "cooking",
    "v1_s": "cooks"
  },
  "clean": {
    "v1": "clean",
    "v2": "cleaned",
    "v3": "cleaned",
    "ving": "cleaning",
    "v1_s": "cleans"
  },
  "watch": {
    "v1": "watch",
    "v2": "watched",
    "v3": "watched",
    "ving": "watching",
    "v1_s": "watches"
  },
  "listen": {
    "v1": "listen",
    "v2": "listened",
    "v3": "listened",
    "ving": "listening",
    "v1_s": "listens"
  },
  "buy": {
    "v1": "buy",
    "v2": "bought",
    "v3": "bought",
    "ving": "buying",
    "v1_s": "buys"
  },
  "sell": {
    "v1": "sell",
    "v2": "sold",
    "v3": "sold",
    "ving": "selling",
    "v1_s": "sells"
  },
  "make": {
    "v1": "make",
    "v2": "made",
    "v3": "made",
    "ving": "making",
    "v1_s": "makes"
  },
  "take": {
    "v1": "take",
    "v2": "took",
    "v3": "taken",
    "ving": "taking",
    "v1_s": "takes"
  },
  "give": {
    "v1": "give",
    "v2": "gave",
    "v3": "given",
    "ving": "giving",
    "v1_s": "gives"
  },
  "send": {
    "v1": "send",
    "v2": "sent",
    "v3": "sent",
    "ving": "sending",
    "v1_s": "sends"
  },
  "teach": {
    "v1": "teach",
    "v2": "taught",
    "v3": "taught",
    "ving": "teaching",
    "v1_s": "teaches"
  },
  "learn": {
    "v1": "learn",
    "v2": "learned",
    "v3": "learned",
    "ving": "learning",
    "v1_s": "learns"
  },
  "know": {
    "v1": "know",
    "v2": "knew",
    "v3": "known",
    "ving": "knowing",
    "v1_s": "knows"
  },
  "think": {
    "v1": "think",
    "v2": "thought",
    "v3": "thought",
    "ving": "thinking",
    "v1_s": "thinks"
  },
  "see": {
    "v1": "see",
    "v2": "saw",
    "v3": "seen",
    "ving": "seeing",
    "v1_s": "sees"
  },
  "hear": {
    "v1": "hear",
    "v2": "heard",
    "v3": "heard",
    "ving": "hearing",
    "v1_s": "hears"
  },
  "feel": {
    "v1": "feel",
    "v2": "felt",
    "v3": "felt",
    "ving": "feeling",
    "v1_s": "feels"
  },
  "love": {
    "v1": "love",
    "v2": "loved",
    "v3": "loved",
    "ving": "loving",
    "v1_s": "loves"
  },
  "like": {
    "v1": "like",
    "v2": "liked",
    "v3": "liked",
    "ving": "liking",
    "v1_s": "likes"
  },
  "want": {
    "v1": "want",
    "v2": "wanted",
    "v3": "wanted",
    "ving": "wanting",
    "v1_s": "wants"
  },
  "need": {
    "v1": "need",
    "v2": "needed",
    "v3": "needed",
    "ving": "needing",
    "v1_s": "needs"
  },
  "help": {
    "v1": "help",
    "v2": "helped",
    "v3": "helped",
    "ving": "helping",
    "v1_s": "helps"
  },
  "start": {
    "v1": "start",
    "v2": "started",
    "v3": "started",
    "ving": "starting",
    "v1_s": "starts"
  },
  "finish": {
    "v1": "finish",
    "v2": "finished",
    "v3": "finished",
    "ving": "finishing",
    "v1_s": "finishes"
  },
  "begin": {
    "v1": "begin",
    "v2": "began",
    "v3": "begun",
    "ving": "beginning",
    "v1_s": "begins"
  },
  "end": {
    "v1": "end",
    "v2": "ended",
    "v3": "ended",
    "ving": "ending",
    "v1_s": "ends"
  },
  "open": {
    "v1": "open",
    "v2": "opened",
    "v3": "opened",
    "ving": "opening",
    "v1_s": "opens"
  },
  "close": {
    "v1": "close",
    "v2": "closed",
    "v3": "closed",
    "ving": "closing",
    "v1_s": "closes"
  },
  "live": {
    "v1": "live",
    "v2": "lived",
    "v3": "lived",
    "ving": "living",
    "v1_s": "lives"
  },
  "die": {
    "v1": "die",
    "v2": "died",
    "v3": "died",
    "ving": "dying",
    "v1_s": "dies"
  },
  "arrive": {
    "v1": "arrive",
    "v2": "arrived",
    "v3": "arrived",
    "ving": "arriving",
    "v1_s": "arrives"
  },
  "leave": {
    "v1": "leave",
    "v2": "left",
    "v3": "left",
    "ving": "leaving",
    "v1_s": "leaves"
  },
  "visit": {
    "v1": "visit",
    "v2": "visited",
    "v3": "visited",
    "ving": "visiting",
    "v1_s": "visits"
  },
  "stay": {
    "v1": "stay",
    "v2": "stayed",
    "v3": "stayed",
    "ving": "staying",
    "v1_s": "stays"
  },
  "wait": {
    "v1": "wait",
    "v2": "waited",
    "v3": "waited",
    "ving": "waiting",
    "v1_s": "waits"
  },
  "call": {
    "v1": "call",
    "v2": "called",
    "v3": "called",
    "ving": "calling",
    "v1_s": "calls"
  },
  "meet": {
    "v1": "meet",
    "v2": "met",
    "v3": "met",
    "ving": "meeting",
    "v1_s": "meets"
  },
  "find": {
    "v1": "find",
    "v2": "found",
    "v3": "found",
    "ving": "finding",
    "v1_s": "finds"
  },
  "lose": {
    "v1": "lose",
    "v2": "lost",
    "v3": "lost",
    "ving": "losing",
    "v1_s": "loses"
  },
  "win": {
    "v1": "win",
    "v2": "won",
    "v3": "won",
    "ving": "winning",
    "v1_s": "wins"
  },
  "break": {
    "v1": "break",
    "v2": "broke",
    "v3": "broken",
    "ving": "breaking",
    "v1_s": "breaks"
  },
  "fix": {
    "v1": "fix",
    "v2": "fixed",
    "v3": "fixed",
    "ving": "fixing",
    "v1_s": "fixes"
  },
  "build": {
    "v1": "build",
    "v2": "built",
    "v3": "built",
    "ving": "building",
    "v1_s": "builds"
  },
  "drive": {
    "v1": "drive",
    "v2": "drove",
    "v3": "driven",
    "ving": "driving",
    "v1_s": "drives"
  },
  "fly": {
    "v1": "fly",
    "v2": "flew",
    "v3": "flown",
    "ving": "flying",
    "v1_s": "flies"
  },
  "swim": {
    "v1": "swim",
    "v2": "swam",
    "v3": "swum",
    "ving": "swimming",
    "v1_s": "swims"
  },
  "sing": {
    "v1": "sing",
    "v2": "sang",
    "v3": "sung",
    "ving": "singing",
    "v1_s": "sings"
  },
  "dance": {
    "v1": "dance",
    "v2": "danced",
    "v3": "danced",
    "ving": "dancing",
    "v1_s": "dances"
  },
  "paint": {
    "v1": "paint",
    "v2": "painted",
    "v3": "painted",
    "ving": "painting",
    "v1_s": "paints"
  },
  "draw": {
    "v1": "draw",
    "v2": "drew",
    "v3": "drawn",
    "ving": "drawing",
    "v1_s": "draws"
  },
  "grow": {
    "v1": "grow",
    "v2": "grew",
    "v3": "grown",
    "ving": "growing",
    "v1_s": "grows"
  },
  "cut": {
    "v1": "cut",
    "v2": "cut",
    "v3": "cut",
    "ving": "cutting",
    "v1_s": "cuts"
  },
  "pay": {
    "v1": "pay",
    "v2": "paid",
    "v3": "paid",
    "ving": "paying",
    "v1_s": "pays"
  },
  "spend": {
    "v1": "spend",
    "v2": "spent",
    "v3": "spent",
    "ving": "spending",
    "v1_s": "spends"
  },
  "save": {
    "v1": "save",
    "v2": "saved",
    "v3": "saved",
    "ving": "saving",
    "v1_s": "saves"
  },
  "change": {
    "v1": "change",
    "v2": "changed",
    "v3": "changed",
    "ving": "changing",
    "v1_s": "changes"
  },
  "move": {
    "v1": "move",
    "v2": "moved",
    "v3": "moved",
    "ving": "moving",
    "v1_s": "moves"
  },
  "stop": {
    "v1": "stop",
    "v2": "stopped",
    "v3": "stopped",
    "ving": "stopping",
    "v1_s": "stops"
  },
  "try": {
    "v1": "try",
    "v2": "tried",
    "v3": "tried",
    "ving": "trying",
    "v1_s": "tries"
  },
  "use": {
    "v1": "use",
    "v2": "used",
    "v3": "used",
    "ving": "using",
    "v1_s": "uses"
  },
  "show": {
    "v1": "show",
    "v2": "showed",
    "v3": "shown",
    "ving": "showing",
    "v1_s": "shows"
  },
  "tell": {
    "v1": "tell",
    "v2": "told",
    "v3": "told",
    "ving": "telling",
    "v1_s": "tells"
  },
  "ask": {
    "v1": "ask",
    "v2": "asked",
    "v3": "asked",
    "ving": "asking",
    "v1_s": "asks"
  },
  "answer": {
    "v1": "answer",
    "v2": "answered",
    "v3": "answered",
    "ving": "answering",
    "v1_s": "answers"
  },
  "explain": {
    "v1": "explain",
    "v2": "explained",
    "v3": "explained",
    "ving": "explaining",
    "v1_s": "explains"
  },
  "understand": {
    "v1": "understand",
    "v2": "understood",
    "v3": "understood",
    "ving": "understanding",
    "v1_s": "understands"
  },
  "remember": {
    "v1": "remember",
    "v2": "remembered",
    "v3": "remembered",
    "ving": "remembering",
    "v1_s": "remembers"
  },
  "forget": {
    "v1": "forget",
    "v2": "forgot",
    "v3": "forgotten",
    "ving": "forgetting",
    "v1_s": "forgets"
  },
  "believe": {
    "v1": "believe",
    "v2": "believed",
    "v3": "believed",
    "ving": "believing",
    "v1_s": "believes"
  },
  "hope": {
    "v1": "hope",
    "v2": "hoped",
    "v3": "hoped",
    "ving": "hoping",
    "v1_s": "hopes"
  },
  "wish": {
    "v1": "wish",
    "v2": "wished",
    "v3": "wished",
    "ving": "wishing",
    "v1_s": "wishes"
  },
  "decide": {
    "v1": "decide",
    "v2": "decided",
    "v3": "decided",
    "ving": "deciding",
    "v1_s": "decides"
  },
  "choose": {
    "v1": "choose",
    "v2": "chose",
    "v3": "chosen",
    "ving": "choosing",
    "v1_s": "chooses"
  },
  "wear": {
    "v1": "wear",
    "v2": "wore",
    "v3": "worn",
    "ving": "wearing",
    "v1_s": "wears"
  },
  "carry": {
    "v1": "carry",
    "v2": "carried",
    "v3": "carried",
    "ving": "carrying",
    "v1_s": "carries"
  },
  "hold": {
    "v1": "hold",
    "v2": "held",
    "v3": "held",
    "ving": "holding",
    "v1_s": "holds"
  },
  "throw": {
    "v1": "throw",
    "v2": "threw",
    "v3": "thrown",
    "ving": "throwing",
    "v1_s": "throws"
  },
  "catch": {
    "v1": "catch",
    "v2": "caught",
    "v3": "caught",
    "ving": "catching",
    "v1_s": "catches"
  },
  "sit": {
    "v1": "sit",
    "v2": "sat",
    "v3": "sat",
    "ving": "sitting",
    "v1_s": "sits"
  },
  "stand": {
    "v1": "stand",
    "v2": "stood",
    "v3": "stood",
    "ving": "standing",
    "v1_s": "stands"
  },
  "fall": {
    "v1": "fall",
    "v2": "fell",
    "v3": "fallen",
    "ving": "falling",
    "v1_s": "falls"
  },
  "rise": {
    "v1": "rise",
    "v2": "rose",
    "v3": "risen",
    "ving": "rising",
    "v1_s": "rises"
  },
  "set": {
    "v1": "set",
    "v2": "set",
    "v3": "set",
    "ving": "setting",
    "v1_s": "sets"
  },
  "put": {
    "v1": "put",
    "v2": "put",
    "v3": "put",
    "ving": "putting",
    "v1_s": "puts"
  },
  "bring": {
    "v1": "bring",
    "v2": "brought",
    "v3": "brought",
    "ving": "bringing",
    "v1_s": "brings"
  },
  "get": {
    "v1": "get",
    "v2": "got",
    "v3": "gotten",
    "ving": "getting",
    "v1_s": "gets"
  },
  "become": {
    "v1": "become",
    "v2": "became",
    "v3": "become",
    "ving": "becoming",
    "v1_s": "becomes"
  },
  "keep": {
    "v1": "keep",
    "v2": "kept",
    "v3": "kept",
    "ving": "keeping",
    "v1_s": "keeps"
  },
  "let": {
    "v1": "let",
    "v2": "let",
    "v3": "let",
    "ving": "letting",
    "v1_s": "lets"
  },
  "seem": {
    "v1": "seem",
    "v2": "seemed",
    "v3": "seemed",
    "ving": "seeming",
    "v1_s": "seems"
  },
  "appear": {
    "v1": "appear",
    "v2": "appeared",
    "v3": "appeared",
    "ving": "appearing",
    "v1_s": "appears"
  },
  "happen": {
    "v1": "happen",
    "v2": "happened",
    "v3": "happened",
    "ving": "happening",
    "v1_s": "happens"
  },
};

final List<String> objects = [
  "breakfast",
  "lunch",
  "dinner",
  "coffee",
  "tea",
  "water",
  "food",
  "the book",
  "the newspaper",
  "the letter",
  "the email",
  "the message",
  "English",
  "math",
  "science",
  "music",
  "piano",
  "guitar",
  "football",
  "basketball",
  "tennis",
  "chess",
  "games",
  "TV",
  "movies",
  "the news",
  "YouTube",
  "videos",
  "the house",
  "the room",
  "the car",
  "the bike",
  "the phone",
  "homework",
  "the project",
  "the report",
  "the exam",
  "the test",
  "clothes",
  "shoes",
  "glasses",
  "a hat",
  "a jacket",
  "money",
  "time",
  "energy",
  "effort",
  "attention",
  "friends",
  "family",
  "colleagues",
  "neighbors",
  "customers"
];

final List<String> timePresent = [
  "every day",
  "every morning",
  "every week",
  "every month",
  "always",
  "usually",
  "often",
  "sometimes",
  "never"
];
final List<String> timePast = [
  "yesterday",
  "last night",
  "last week",
  "last month",
  "last year",
  "two days ago",
  "three hours ago",
  "in 2020"
];
final List<String> timeFuture = [
  "tomorrow",
  "next week",
  "next month",
  "next year",
  "soon",
  "in the future",
  "later",
  "tonight"
];
final List<String> timeContinuous = [
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
  "ever",
  "never",
  "yet",
  "since 2020",
  "for 5 years",
  "so far"
];
final List<String> duration = [
  "for 2 hours",
  "for 3 days",
  "for a week",
  "for a month",
  "for a year",
  "since morning",
  "since yesterday",
  "all day",
  "all week"
];
final List<String> frequency = [
  "always",
  "usually",
  "often",
  "sometimes",
  "rarely",
  "never",
  "seldom",
  "frequently"
];

// Tenses configuration
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

final random = Random();

String randomChoice(List<String> list) => list[random.nextInt(list.length)];

MapEntry<String, Map<String, String>> randomVerb() {
  final keys = verbsBase.keys.toList();
  final key = keys[random.nextInt(keys.length)];
  return MapEntry(key, verbsBase[key]!);
}

List<String> shuffleList(List<String> list) {
  final shuffled = List<String>.from(list);
  shuffled.shuffle(random);
  return shuffled;
}

// ===== QUESTION GENERATORS =====

Map<String, dynamic> generatePresentSimple(
    Map<String, String> verb, bool isSingular, String difficulty) {
  final subject = randomChoice(isSingular ? subjectsSingular : subjectsPlural);
  final obj = randomChoice(objects);
  final time = randomChoice(timePresent);

  final correct = isSingular ? verb["v1_s"]! : verb["v1"]!;

  String stem;
  String explanation;

  if (difficulty == "easy") {
    stem = "$subject _____ $obj $time.";
    explanation =
        "ใช้ '$correct' เพราะ${isSingular ? 'ประธานเป็นเอกพจน์บุรุษที่ 3 ต้องเติม -s/-es' : 'ประธานเป็นพหูพจน์ ใช้ V1'}";
  } else if (difficulty == "medium") {
    final freq = randomChoice(frequency);
    stem = "$subject $freq _____ $obj.";
    explanation = "ใช้ '$correct' เพราะมีคำบ่งชี้ '$freq' แสดงกิจวัตร";
  } else {
    stem = "When it rains, ${subject.toLowerCase()} _____ $obj.";
    explanation = "ใช้ '$correct' ใน conditional clause สำหรับความจริงทั่วไป";
  }

  var choices = [correct];
  final distractors = [verb["v2"]!, verb["ving"]!, verb["v3"]!];
  if (isSingular) {
    distractors.add(verb["v1"]!);
  } else {
    distractors.add(verb["v1_s"]!);
  }

  for (var d in distractors) {
    if (!choices.contains(d) && choices.length < 4) {
      choices.add(d);
    }
  }

  choices = shuffleList(choices).take(4).toList();
  final correctIndex = choices.indexOf(correct);

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": correctIndex,
    "explanation": explanation
  };
}

Map<String, dynamic> generatePresentContinuous(
    Map<String, String> verb, bool isSingular, String difficulty) {
  final subject = randomChoice(isSingular ? subjectsSingular : subjectsPlural);
  final obj = randomChoice(objects);
  final time = randomChoice(timeContinuous);

  final beVerb = isSingular ? "is" : (subject == "I" ? "am" : "are");
  final correct = "$beVerb ${verb['ving']}";

  String stem;
  String explanation;

  if (difficulty == "easy") {
    stem = "$subject _____ $obj $time.";
    explanation =
        "ใช้ '$correct' เพราะมีคำว่า '$time' แสดงเหตุการณ์ที่กำลังเกิดขึ้น";
  } else if (difficulty == "medium") {
    stem = "Look! $subject _____ $obj.";
    explanation = "ใช้ '$correct' เพราะมี Look! แสดงเหตุการณ์ที่กำลังเกิด";
  } else {
    stem = "$subject _____ $obj these days. It's just a temporary situation.";
    explanation = "ใช้ '$correct' สำหรับสถานการณ์ชั่วคราว";
  }

  var choices = [correct];
  final distractors = [
    verb["v1"]!,
    verb["v1_s"]!,
    verb["v2"]!,
    "was ${verb['ving']}",
  ];

  for (var d in distractors) {
    if (!choices.contains(d) && choices.length < 4) {
      choices.add(d);
    }
  }

  choices = shuffleList(choices).take(4).toList();
  final correctIndex = choices.indexOf(correct);

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": correctIndex,
    "explanation": explanation
  };
}

Map<String, dynamic> generatePresentPerfect(
    Map<String, String> verb, bool isSingular, String difficulty) {
  final subject = randomChoice(isSingular ? subjectsSingular : subjectsPlural);
  final obj = randomChoice(objects);

  final haveVerb = isSingular ? "has" : "have";
  final correct = "$haveVerb ${verb['v3']}";

  String stem;
  String explanation;

  if (difficulty == "easy") {
    stem = "$subject _____ $obj before.";
    explanation = "ใช้ '$correct' เพราะพูดถึงประสบการณ์";
  } else if (difficulty == "medium") {
    stem = "$subject _____ $obj since last year.";
    explanation = "ใช้ '$correct' กับ since สำหรับช่วงเวลาจากอดีตถึงปัจจุบัน";
  } else {
    stem = "This is the best $obj ${subject.toLowerCase()} _____ ever seen.";
    explanation = "ใช้ '$correct' กับ superlative + ever";
  }

  var choices = [correct];
  final distractors = [
    verb["v1"]!,
    verb["v2"]!,
    "had ${verb['v3']}",
    "${isSingular ? 'have' : 'has'} ${verb['v3']}"
  ];

  for (var d in distractors) {
    if (!choices.contains(d) && choices.length < 4) {
      choices.add(d);
    }
  }

  choices = shuffleList(choices).take(4).toList();
  final correctIndex = choices.indexOf(correct);

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": correctIndex,
    "explanation": explanation
  };
}

Map<String, dynamic> generatePresentPerfectContinuous(
    Map<String, String> verb, bool isSingular, String difficulty) {
  final subject = randomChoice(isSingular ? subjectsSingular : subjectsPlural);
  final dur = randomChoice(duration);

  final haveVerb = isSingular ? "has" : "have";
  final correct = "$haveVerb been ${verb['ving']}";

  String stem;
  String explanation;

  if (difficulty == "easy") {
    stem = "$subject _____ $dur.";
    explanation = "ใช้ '$correct' เน้นความต่อเนื่องของการกระทำ";
  } else if (difficulty == "medium") {
    stem = "$subject looks tired because they _____ all day.";
    explanation = "ใช้ '$correct' อธิบายสาเหตุที่เหนื่อย";
  } else {
    stem = "How long _____ ${subject.toLowerCase()} been ${verb['ving']}?";
    explanation = "ใช้ '$haveVerb been ${verb['ving']}' สำหรับถามระยะเวลา";
  }

  var choices = [correct];
  final distractors = [
    "$haveVerb ${verb['v3']}",
    verb["v2"]!,
    "was ${verb['ving']}",
    "had been ${verb['ving']}"
  ];

  for (var d in distractors) {
    if (!choices.contains(d) && choices.length < 4) {
      choices.add(d);
    }
  }

  choices = shuffleList(choices).take(4).toList();
  final correctIndex = choices.indexOf(correct);

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": correctIndex,
    "explanation": explanation
  };
}

Map<String, dynamic> generatePastSimple(
    Map<String, String> verb, bool isSingular, String difficulty) {
  final subject = randomChoice(isSingular ? subjectsSingular : subjectsPlural);
  final obj = randomChoice(objects);
  final time = randomChoice(timePast);

  final correct = verb["v2"]!;

  String stem;
  String explanation;

  if (difficulty == "easy") {
    stem = "$subject _____ $obj $time.";
    explanation = "ใช้ '$correct' (V2) เพราะมี '$time' แสดงอดีตที่จบไปแล้ว";
  } else if (difficulty == "medium") {
    stem = "When did ${subject.toLowerCase()} _____ $obj?";
    explanation = "ใช้ V1 หลัง did ในคำถาม";
  } else {
    stem =
        "The moment ${subject.toLowerCase()} _____ the news, everyone was shocked.";
    explanation = "ใช้ '$correct' เพราะเป็นเหตุการณ์ที่เกิดและจบในอดีต";
  }

  var choices = [correct];
  final distractors = [
    verb["v1"]!,
    verb["v3"]!,
    verb["ving"]!,
    "has ${verb['v3']}"
  ];

  for (var d in distractors) {
    if (!choices.contains(d) && choices.length < 4) {
      choices.add(d);
    }
  }

  choices = shuffleList(choices).take(4).toList();
  final correctIndex = choices.indexOf(correct);

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": correctIndex,
    "explanation": explanation
  };
}

Map<String, dynamic> generatePastContinuous(
    Map<String, String> verb, bool isSingular, String difficulty) {
  final subject = randomChoice(isSingular ? subjectsSingular : subjectsPlural);
  final obj = randomChoice(objects);

  final beVerb = (isSingular || subject == "I") ? "was" : "were";
  final correct = "$beVerb ${verb['ving']}";

  String stem;
  String explanation;

  if (difficulty == "easy") {
    stem = "$subject _____ $obj at 8 PM yesterday.";
    explanation = "ใช้ '$correct' เพราะระบุเวลาเจาะจงในอดีต";
  } else if (difficulty == "medium") {
    stem = "While ${subject.toLowerCase()} _____ $obj, the phone rang.";
    explanation = "ใช้ '$correct' กับ while สำหรับเหตุการณ์ที่ถูกแทรก";
  } else {
    stem =
        "What $beVerb ${subject.toLowerCase()} _____ when the accident happened?";
    explanation = "ใช้ '$beVerb ${verb['ving']}' สำหรับถามเหตุการณ์ในอดีต";
  }

  var choices = [correct];
  final distractors = [
    verb["v2"]!,
    "${beVerb == 'was' ? 'were' : 'was'} ${verb['ving']}",
    "is ${verb['ving']}",
    "had ${verb['v3']}"
  ];

  for (var d in distractors) {
    if (!choices.contains(d) && choices.length < 4) {
      choices.add(d);
    }
  }

  choices = shuffleList(choices).take(4).toList();
  final correctIndex = choices.indexOf(correct);

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": correctIndex,
    "explanation": explanation
  };
}

Map<String, dynamic> generatePastPerfect(
    Map<String, String> verb, bool isSingular, String difficulty) {
  final subject = randomChoice(isSingular ? subjectsSingular : subjectsPlural);
  final obj = randomChoice(objects);

  final correct = "had ${verb['v3']}";

  String stem;
  String explanation;

  if (difficulty == "easy") {
    stem = "By the time we arrived, ${subject.toLowerCase()} _____ $obj.";
    explanation = "ใช้ '$correct' เพราะเกิดก่อนอีกเหตุการณ์ในอดีต";
  } else if (difficulty == "medium") {
    stem = "After ${subject.toLowerCase()} _____ $obj, I went home.";
    explanation = "ใช้ '$correct' กับ after สำหรับเหตุการณ์ก่อนหน้า";
  } else {
    stem = "$subject told me that they _____ $obj before.";
    explanation = "ใช้ '$correct' ใน reported speech";
  }

  var choices = [correct];
  final distractors = [
    verb["v2"]!,
    "has ${verb['v3']}",
    "have ${verb['v3']}",
    verb["v1"]!
  ];

  for (var d in distractors) {
    if (!choices.contains(d) && choices.length < 4) {
      choices.add(d);
    }
  }

  choices = shuffleList(choices).take(4).toList();
  final correctIndex = choices.indexOf(correct);

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": correctIndex,
    "explanation": explanation
  };
}

Map<String, dynamic> generatePastPerfectContinuous(
    Map<String, String> verb, bool isSingular, String difficulty) {
  final subject = randomChoice(isSingular ? subjectsSingular : subjectsPlural);
  final dur = randomChoice(duration);

  final correct = "had been ${verb['ving']}";

  String stem;
  String explanation;

  if (difficulty == "easy") {
    stem = "$subject _____ $dur before it stopped.";
    explanation = "ใช้ '$correct' เน้นความต่อเนื่องก่อนเหตุการณ์ในอดีต";
  } else if (difficulty == "medium") {
    stem = "$subject was tired because they _____ all day.";
    explanation = "ใช้ '$correct' อธิบายสาเหตุในอดีต";
  } else {
    stem =
        "How long had ${subject.toLowerCase()} _____ before you found the answer?";
    explanation = "ใช้ 'had been ${verb['ving']}' สำหรับถามระยะเวลา";
  }

  var choices = [correct];
  final distractors = [
    "had ${verb['v3']}",
    "has been ${verb['ving']}",
    "was ${verb['ving']}",
    verb["v2"]!
  ];

  for (var d in distractors) {
    if (!choices.contains(d) && choices.length < 4) {
      choices.add(d);
    }
  }

  choices = shuffleList(choices).take(4).toList();
  final correctIndex = choices.indexOf(correct);

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": correctIndex,
    "explanation": explanation
  };
}

Map<String, dynamic> generateFutureSimple(
    Map<String, String> verb, bool isSingular, String difficulty) {
  final subject = randomChoice(isSingular ? subjectsSingular : subjectsPlural);
  final obj = randomChoice(objects);
  final time = randomChoice(timeFuture);

  final correct = "will ${verb['v1']}";

  String stem;
  String explanation;

  if (difficulty == "easy") {
    stem = "$subject _____ $obj $time.";
    explanation = "ใช้ '$correct' สำหรับเหตุการณ์ในอนาคต";
  } else if (difficulty == "medium") {
    stem = "I think ${subject.toLowerCase()} _____ $obj.";
    explanation = "ใช้ '$correct' สำหรับการคาดเดา";
  } else {
    stem = "If you don't hurry, ${subject.toLowerCase()} _____ $obj.";
    explanation = "ใช้ '$correct' ใน main clause ของ First Conditional";
  }

  var choices = [correct];
  final distractors = [
    verb["v1"]!,
    verb["v1_s"]!,
    "is going to ${verb['v1']}",
    "is ${verb['ving']}"
  ];

  for (var d in distractors) {
    if (!choices.contains(d) && choices.length < 4) {
      choices.add(d);
    }
  }

  choices = shuffleList(choices).take(4).toList();
  final correctIndex = choices.indexOf(correct);

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": correctIndex,
    "explanation": explanation
  };
}

Map<String, dynamic> generateFutureContinuous(
    Map<String, String> verb, bool isSingular, String difficulty) {
  final subject = randomChoice(isSingular ? subjectsSingular : subjectsPlural);
  final obj = randomChoice(objects);

  final correct = "will be ${verb['ving']}";

  String stem;
  String explanation;

  if (difficulty == "easy") {
    stem = "At this time tomorrow, ${subject.toLowerCase()} _____ $obj.";
    explanation = "ใช้ '$correct' เพราะระบุเวลาเจาะจงในอนาคต";
  } else if (difficulty == "medium") {
    stem = "Don't call me at 8 PM. I _____ $obj.";
    explanation = "ใช้ '$correct' สำหรับกิจกรรมที่จะกำลังทำอยู่";
  } else {
    stem =
        "Will ${subject.toLowerCase()} _____ the car tomorrow? I need to borrow it.";
    explanation = "ใช้ '$correct' สำหรับถามแผนในอนาคต";
  }

  var choices = [correct];
  final distractors = [
    "will ${verb['v1']}",
    "is ${verb['ving']}",
    verb["v1"]!,
    "was ${verb['ving']}"
  ];

  for (var d in distractors) {
    if (!choices.contains(d) && choices.length < 4) {
      choices.add(d);
    }
  }

  choices = shuffleList(choices).take(4).toList();
  final correctIndex = choices.indexOf(correct);

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": correctIndex,
    "explanation": explanation
  };
}

Map<String, dynamic> generateFuturePerfect(
    Map<String, String> verb, bool isSingular, String difficulty) {
  final subject = randomChoice(isSingular ? subjectsSingular : subjectsPlural);
  final obj = randomChoice(objects);

  final correct = "will have ${verb['v3']}";

  String stem;
  String explanation;

  if (difficulty == "easy") {
    stem = "By next year, ${subject.toLowerCase()} _____ $obj.";
    explanation = "ใช้ '$correct' กับ by + เวลาในอนาคต";
  } else if (difficulty == "medium") {
    stem = "By the time you arrive, I _____ $obj.";
    explanation = "ใช้ '$correct' กับ by the time";
  } else {
    stem =
        "How many times will ${subject.toLowerCase()} _____ $obj by the end of this year?";
    explanation = "ใช้ 'will have ${verb['v3']}' สำหรับถาม";
  }

  var choices = [correct];
  final distractors = [
    "will ${verb['v1']}",
    "has ${verb['v3']}",
    "had ${verb['v3']}",
    "will be ${verb['ving']}"
  ];

  for (var d in distractors) {
    if (!choices.contains(d) && choices.length < 4) {
      choices.add(d);
    }
  }

  choices = shuffleList(choices).take(4).toList();
  final correctIndex = choices.indexOf(correct);

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": correctIndex,
    "explanation": explanation
  };
}

Map<String, dynamic> generateFuturePerfectContinuous(
    Map<String, String> verb, bool isSingular, String difficulty) {
  final subject = randomChoice(isSingular ? subjectsSingular : subjectsPlural);
  final dur = randomChoice(duration);

  final correct = "will have been ${verb['ving']}";

  String stem;
  String explanation;

  if (difficulty == "easy") {
    stem = "By 5 o'clock, ${subject.toLowerCase()} _____ $dur.";
    explanation = "ใช้ '$correct' เน้นระยะเวลาจนถึงจุดในอนาคต";
  } else if (difficulty == "medium") {
    stem = "By next month, I _____ at this company for 10 years.";
    explanation = "ใช้ '$correct' สำหรับระยะเวลาที่จะครบ";
  } else {
    stem =
        "How long will ${subject.toLowerCase()} _____ by the time you graduate?";
    explanation = "ใช้ 'will have been ${verb['ving']}' สำหรับถามระยะเวลา";
  }

  var choices = [correct];
  final distractors = [
    "will have ${verb['v3']}",
    "will be ${verb['ving']}",
    "has been ${verb['ving']}",
    "had been ${verb['ving']}"
  ];

  for (var d in distractors) {
    if (!choices.contains(d) && choices.length < 4) {
      choices.add(d);
    }
  }

  choices = shuffleList(choices).take(4).toList();
  final correctIndex = choices.indexOf(correct);

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": correctIndex,
    "explanation": explanation
  };
}

Map<String, dynamic> generatePassiveVoice(
    Map<String, String> verb, bool isSingular, String difficulty) {
  final subject = randomChoice(objects);
  final agent = randomChoice([...subjectsSingular, ...subjectsPlural]);

  final beVerb = isSingular ? "is" : "are";
  final correct = "$beVerb ${verb['v3']}";

  String stem;
  String explanation;

  if (difficulty == "easy") {
    stem = "The $subject _____ by ${agent.toLowerCase()}.";
    explanation = "ใช้ '$correct' สำหรับ passive voice (be + V3)";
  } else if (difficulty == "medium") {
    stem = "English _____ in many countries.";
    explanation = "ใช้ 'is spoken' สำหรับ passive voice เมื่อผู้กระทำไม่สำคัญ";
  } else {
    stem = "The project _____ by the team right now.";
    explanation =
        "ใช้ 'is being ${verb['v3']}' สำหรับ passive voice ใน Present Continuous";
  }

  var choices = [correct];
  final distractors = [
    verb["v1"]!,
    verb["v2"]!,
    "was ${verb['v3']}",
    verb["ving"]!
  ];

  for (var d in distractors) {
    if (!choices.contains(d) && choices.length < 4) {
      choices.add(d);
    }
  }

  choices = shuffleList(choices).take(4).toList();
  final correctIndex = choices.indexOf(correct);

  return {
    "stem": stem,
    "choices": choices,
    "correctIndex": correctIndex,
    "explanation": explanation
  };
}

typedef QuestionGenerator = Map<String, dynamic> Function(
    Map<String, String> verb, bool isSingular, String difficulty);

final Map<String, QuestionGenerator> generators = {
  "present_simple": generatePresentSimple,
  "present_continuous": generatePresentContinuous,
  "present_perfect": generatePresentPerfect,
  "present_perfect_continuous": generatePresentPerfectContinuous,
  "past_simple": generatePastSimple,
  "past_continuous": generatePastContinuous,
  "past_perfect": generatePastPerfect,
  "past_perfect_continuous": generatePastPerfectContinuous,
  "future_simple": generateFutureSimple,
  "future_continuous": generateFutureContinuous,
  "future_perfect": generateFuturePerfect,
  "future_perfect_continuous": generateFuturePerfectContinuous,
  "passive_voice": generatePassiveVoice,
};

Map<String, List<Map<String, dynamic>>> generateQuestionsForTense(
    Map<String, String> tense, int count) {
  final tenseName = tense["name"]!;
  final packId = tense["packId"]!;
  final generator = generators[tenseName]!;

  // Distribution: easy 1500, medium 2000, hard 1500
  final difficulties = {
    "easy": (count * 0.3).round(),
    "medium": (count * 0.4).round(),
    "hard": (count * 0.3).round()
  };

  final questions = <String, List<Map<String, dynamic>>>{
    "easy": [],
    "medium": [],
    "hard": []
  };

  for (var entry in difficulties.entries) {
    final difficulty = entry.key;
    final num = entry.value;
    print("  Generating $num $difficulty questions...");

    for (var i = 0; i < num; i++) {
      final verb = randomVerb().value;
      final isSingular = random.nextBool();

      final q = generator(verb, isSingular, difficulty);
      q["id"] = "q_${packId}_${difficulty[0]}_${i + 1}";
      q["skillType"] = "grammar";
      q["packId"] = packId;

      questions[difficulty]!.add(q);
    }
  }

  return questions;
}

void main() {
  final outputDir = Directory("assets/data/quiz");
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  print("=" * 60);
  print("Grammar Quiz Generator (Dart Version)");
  print("=" * 60);
  print("Generating 5,000 questions per tense (${tenses.length} tenses)");
  print("Total: ${5000 * tenses.length} questions");
  print("=" * 60);

  for (var tense in tenses) {
    print("\nProcessing: ${tense['title']}");
    final questions = generateQuestionsForTense(tense, 5000);

    final filename =
        "assets/data/quiz/grammar_quiz_${tense['id']!.replaceFirst('grammar_', '')}_${tense['name']}.json";

    final file = File(filename);
    file.writeAsStringSync(
        const JsonEncoder.withIndent("  ").convert(questions));

    final total =
        questions.values.fold<int>(0, (sum, list) => sum + list.length);
    print("  Saved $total questions to $filename");
  }

  print("\n${"=" * 60}");
  print("Generation complete!");
  print("=" * 60);
}
