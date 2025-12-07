/// Grammar Quiz Generator V3 - Maximum Diversity
/// Creates unique, realistic sentences with many variations
library;

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';

final random = Random();

// ===== EXPANDED DATA =====

final List<String> subjects1 = [
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
final List<String> subjects2 = [
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

final List<String> timeP = [
  "every day",
  "every morning",
  "every evening",
  "every week",
  "every weekend",
  "every month",
  "every year",
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
  "never",
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
  "in 2020",
  "when I was young"
];
final List<String> timeFut = [
  "tomorrow",
  "next week",
  "next month",
  "next year",
  "soon",
  "tonight",
  "later",
  "in the future",
  "next Monday",
  "this weekend"
];
final List<String> timeNow = [
  "now",
  "right now",
  "at the moment",
  "currently",
  "at this time",
  "these days"
];
final List<String> timePerf = [
  "already",
  "just",
  "recently",
  "yet",
  "ever",
  "never",
  "before",
  "many times",
  "twice",
  "several times"
];
final List<String> dur = [
  "for 2 hours",
  "for 3 days",
  "for a week",
  "for a month",
  "for years",
  "since morning",
  "since yesterday",
  "since 2020",
  "all day",
  "all week"
];

// Verb combos: verb -> list of natural phrases
final Map<String, List<String>> vp = {
  "eat": [
    "breakfast",
    "lunch",
    "dinner",
    "fruit",
    "rice",
    "pizza",
    "noodles",
    "vegetables",
    "snacks",
    "fast food"
  ],
  "drink": [
    "water",
    "coffee",
    "tea",
    "juice",
    "milk",
    "soda",
    "beer",
    "wine",
    "a smoothie",
    "hot chocolate"
  ],
  "cook": [
    "dinner",
    "breakfast",
    "pasta",
    "soup",
    "rice",
    "chicken",
    "fish",
    "vegetables",
    "Thai food",
    "a meal"
  ],
  "speak": [
    "English",
    "Thai",
    "Chinese",
    "Japanese",
    "French",
    "to my friends",
    "on the phone",
    "fluently",
    "loudly",
    "quietly"
  ],
  "write": [
    "an email",
    "a letter",
    "a report",
    "a message",
    "notes",
    "a story",
    "in my diary",
    "code",
    "poetry",
    "essays"
  ],
  "read": [
    "a book",
    "the newspaper",
    "an article",
    "emails",
    "a magazine",
    "the news",
    "novels",
    "comics",
    "textbooks",
    "blogs"
  ],
  "listen": [
    "to music",
    "to the radio",
    "to my teacher",
    "to podcasts",
    "carefully",
    "to the news",
    "to English songs",
    "to audiobooks"
  ],
  "watch": [
    "TV",
    "movies",
    "YouTube",
    "the news",
    "Netflix",
    "a football match",
    "videos",
    "dramas",
    "documentaries",
    "anime"
  ],
  "play": [
    "football",
    "basketball",
    "tennis",
    "games",
    "piano",
    "guitar",
    "chess",
    "video games",
    "badminton",
    "golf"
  ],
  "study": [
    "English",
    "math",
    "science",
    "history",
    "biology",
    "chemistry",
    "physics",
    "for the exam",
    "hard",
    "at university"
  ],
  "work": [
    "hard",
    "at a company",
    "from home",
    "overtime",
    "on weekends",
    "as a teacher",
    "in an office",
    "with computers",
    "in a hospital",
    "at a bank"
  ],
  "go": [
    "to school",
    "to work",
    "home",
    "shopping",
    "to the gym",
    "to bed",
    "outside",
    "to the park",
    "abroad",
    "swimming"
  ],
  "come": [
    "home",
    "to class",
    "to work",
    "back",
    "early",
    "late",
    "here",
    "inside",
    "to the party",
    "to visit"
  ],
  "walk": [
    "to school",
    "to work",
    "in the park",
    "home",
    "slowly",
    "quickly",
    "with my dog",
    "every morning",
    "to the store",
    "along the beach"
  ],
  "run": [
    "in the morning",
    "in the park",
    "every day",
    "fast",
    "slowly",
    "a marathon",
    "to catch the bus",
    "for exercise",
    "5 kilometers",
    "with friends"
  ],
  "drive": [
    "to work",
    "a car",
    "carefully",
    "to the mall",
    "home",
    "a truck",
    "to school",
    "every day",
    "on weekends",
    "at night"
  ],
  "fly": [
    "to Bangkok",
    "to Japan",
    "abroad",
    "on business",
    "home",
    "to America",
    "to Europe",
    "first class",
    "every month",
    "for vacation"
  ],
  "buy": [
    "groceries",
    "clothes",
    "a new phone",
    "coffee",
    "tickets",
    "food",
    "books",
    "shoes",
    "a computer",
    "gifts"
  ],
  "sell": [
    "products",
    "cars",
    "online",
    "at the market",
    "handmade items",
    "clothes",
    "food",
    "electronics",
    "art",
    "furniture"
  ],
  "pay": [
    "the bills",
    "for dinner",
    "by credit card",
    "in cash",
    "attention",
    "the rent",
    "taxes",
    "for parking",
    "online",
    "monthly"
  ],
  "learn": [
    "English",
    "new skills",
    "quickly",
    "from mistakes",
    "every day",
    "to drive",
    "to cook",
    "programming",
    "music",
    "languages"
  ],
  "teach": [
    "English",
    "students",
    "children",
    "at a school",
    "online",
    "math",
    "science",
    "music",
    "art",
    "cooking"
  ],
  "meet": [
    "friends",
    "clients",
    "new people",
    "at the cafe",
    "after work",
    "for lunch",
    "at the office",
    "online",
    "my boss",
    "customers"
  ],
  "help": [
    "my parents",
    "my friends",
    "others",
    "with homework",
    "at home",
    "the poor",
    "my colleagues",
    "with cooking",
    "with cleaning",
    "with work"
  ],
  "make": [
    "breakfast",
    "a decision",
    "money",
    "friends",
    "mistakes",
    "coffee",
    "dinner",
    "plans",
    "a cake",
    "a reservation"
  ],
  "take": [
    "a shower",
    "the bus",
    "photos",
    "a break",
    "medicine",
    "notes",
    "a walk",
    "a nap",
    "a taxi",
    "an exam"
  ],
  "give": [
    "advice",
    "a gift",
    "money",
    "presentations",
    "directions",
    "a speech",
    "feedback",
    "support",
    "love",
    "attention"
  ],
  "get": [
    "up early",
    "home late",
    "good grades",
    "a haircut",
    "ready",
    "married",
    "a job",
    "angry",
    "sick",
    "better"
  ],
  "feel": [
    "happy",
    "tired",
    "sick",
    "better",
    "excited",
    "nervous",
    "sad",
    "angry",
    "stressed",
    "relaxed"
  ],
  "think": [
    "carefully",
    "about the future",
    "positively",
    "before speaking",
    "deeply",
    "logically",
    "creatively",
    "about you",
    "a lot",
    "too much"
  ],
  "know": [
    "the answer",
    "English well",
    "many people",
    "the truth",
    "how to cook",
    "a lot",
    "nothing",
    "everything",
    "my neighbors",
    "the rules"
  ],
  "like": [
    "coffee",
    "music",
    "sports",
    "reading",
    "traveling",
    "Thai food",
    "movies",
    "pizza",
    "nature",
    "animals"
  ],
  "love": [
    "my family",
    "traveling",
    "music",
    "cooking",
    "my job",
    "reading",
    "sports",
    "art",
    "nature",
    "learning"
  ],
  "want": [
    "to travel",
    "a new car",
    "to learn",
    "to succeed",
    "more time",
    "to rest",
    "a vacation",
    "to help",
    "to improve",
    "to change"
  ],
  "need": [
    "help",
    "money",
    "time",
    "to rest",
    "a break",
    "advice",
    "support",
    "to study",
    "to work",
    "to sleep"
  ],
  "start": [
    "work",
    "early",
    "a new project",
    "exercising",
    "the day",
    "a business",
    "learning",
    "cooking",
    "at 9 AM",
    "next week"
  ],
  "finish": [
    "work",
    "homework",
    "on time",
    "eating",
    "the project",
    "early",
    "the book",
    "the report",
    "cleaning",
    "at 5 PM"
  ],
  "stop": [
    "smoking",
    "eating late",
    "worrying",
    "at the store",
    "working",
    "the car",
    "talking",
    "crying",
    "here",
    "for a break"
  ],
  "try": [
    "my best",
    "new food",
    "to learn",
    "harder",
    "again",
    "something new",
    "to help",
    "to understand",
    "to improve",
    "to change"
  ],
  "use": [
    "a computer",
    "my phone",
    "the internet",
    "public transport",
    "English",
    "social media",
    "a dictionary",
    "chopsticks",
    "tools",
    "technology"
  ],
  "open": [
    "the door",
    "the window",
    "my email",
    "a book",
    "a business",
    "a shop",
    "the box",
    "a bank account",
    "a file",
    "my heart"
  ],
  "close": [
    "the door",
    "the window",
    "my eyes",
    "the shop",
    "early",
    "the book",
    "the file",
    "my account",
    "the box",
    "at 6 PM"
  ],
  "stay": [
    "home",
    "healthy",
    "calm",
    "at a hotel",
    "positive",
    "focused",
    "late",
    "with friends",
    "in bed",
    "overnight"
  ],
  "live": [
    "in Bangkok",
    "with my parents",
    "alone",
    "in a house",
    "in an apartment",
    "happily",
    "well",
    "nearby",
    "abroad",
    "in the city"
  ],
  "wait": [
    "for the bus",
    "patiently",
    "in line",
    "for my turn",
    "outside",
    "for you",
    "at the station",
    "for the results",
    "for hours",
    "for a response"
  ],
  "call": [
    "my mother",
    "my friend",
    "the office",
    "a taxi",
    "for help",
    "the doctor",
    "customer service",
    "my boss",
    "the police",
    "the restaurant"
  ],
  "sit": [
    "down",
    "quietly",
    "in the front",
    "on the sofa",
    "by the window",
    "at the table",
    "on the floor",
    "in a chair",
    "next to me",
    "alone"
  ],
  "stand": [
    "up",
    "in line",
    "by the door",
    "straight",
    "here",
    "outside",
    "alone",
    "still",
    "for hours",
    "at the entrance"
  ],
  "arrive": [
    "at school",
    "at work",
    "on time",
    "early",
    "late",
    "home",
    "at the airport",
    "at the station",
    "safely",
    "at 8 AM"
  ],
  "leave": [
    "home",
    "the office",
    "early",
    "at 8 AM",
    "for work",
    "the party",
    "tomorrow",
    "soon",
    "for vacation",
    "next week"
  ],
  "visit": [
    "my grandparents",
    "friends",
    "the doctor",
    "Japan",
    "relatives",
    "the museum",
    "the park",
    "the hospital",
    "clients",
    "my hometown"
  ],
};

// Full verb forms
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
  "feel": {
    "v1": "feel",
    "v2": "felt",
    "v3": "felt",
    "ving": "feeling",
    "v1s": "feels"
  },
  "think": {
    "v1": "think",
    "v2": "thought",
    "v3": "thought",
    "ving": "thinking",
    "v1s": "thinks"
  },
  "know": {
    "v1": "know",
    "v2": "knew",
    "v3": "known",
    "ving": "knowing",
    "v1s": "knows"
  },
  "like": {
    "v1": "like",
    "v2": "liked",
    "v3": "liked",
    "ving": "liking",
    "v1s": "likes"
  },
  "love": {
    "v1": "love",
    "v2": "loved",
    "v3": "loved",
    "ving": "loving",
    "v1s": "loves"
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
  "lose": {
    "v1": "lose",
    "v2": "lost",
    "v3": "lost",
    "ving": "losing",
    "v1s": "loses"
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

String p(List<String> l) => l[random.nextInt(l.length)];
List<String> sh(List<String> l) =>
    (List.from(l)..shuffle(random)).cast<String>();

MapEntry<String, Map<String, String>> pv() {
  final k = verbs.keys.toList()[random.nextInt(verbs.length)];
  return MapEntry(k, verbs[k]!);
}

String po(String k) => vp.containsKey(k) ? p(vp[k]!) : "";

// Generate with pattern index for variety
Map<String, dynamic> gen(String tense, String diff, int patIdx) {
  final ve = pv();
  final vk = ve.key;
  final v = ve.value;
  final o = po(vk);
  final isSing = random.nextBool();
  final s1 = p(subjects1);
  final s2 = p(subjects2);
  final s = isSing ? s1 : s2;

  String stem = "";
  String correct = "";
  String expl = "";
  List<String> ch = [];

  switch (tense) {
    case "present_simple":
      correct = isSing ? v["v1s"]! : v["v1"]!;
      if (diff == "easy") {
        final t = p(timeP);
        final pats = ["$s _____ $o $t.", "$t, $s _____ $o.", "$s _____ $o."];
        stem = pats[patIdx % pats.length];
      } else if (diff == "medium") {
        final f = p(freq);
        final pats = [
          "$s $f _____ $o.",
          "How often does ${s.toLowerCase()} _____ $o?",
          "$s doesn't _____ $o.",
          "Does ${s.toLowerCase()} _____ $o?"
        ];
        stem = pats[patIdx % pats.length];
        if (stem.contains("does") || stem.contains("doesn't")) {
          correct = v["v1"]!;
        }
      } else {
        final pats = [
          "If $s _____ $o, I will be happy.",
          "When $s _____ $o, we all enjoy it.",
          "Water _____ at 100°C.",
          "The sun _____ in the east."
        ];
        stem = pats[patIdx % pats.length];
        if (patIdx % 4 >= 2) {
          correct = patIdx % 4 == 2 ? "boils" : "rises";
        }
      }
      ch = [correct, v["v2"]!, v["ving"]!, isSing ? v["v1"]! : v["v1s"]!];
      expl = "Present Simple: ${isSing ? 'V1+s/es' : 'V1'}";
      break;

    case "present_continuous":
      final be = isSing ? "is" : (s == "I" ? "am" : "are");
      correct = "$be ${v['ving']}";
      if (diff == "easy") {
        final t = p(timeNow);
        final pats = [
          "$s _____ $o $t.",
          "$t, $s _____ $o.",
          "Look! $s _____ $o."
        ];
        stem = pats[patIdx % pats.length];
      } else if (diff == "medium") {
        final pats = [
          "Be quiet! $s _____ $o.",
          "Listen! Someone _____ $o.",
          "What _____ $s doing now?",
          "$s _____ $o today."
        ];
        stem = pats[patIdx % pats.length];
      } else {
        stem = "$s _____ $o these days. It's temporary.";
      }
      ch = [correct, v["v1"]!, v["v2"]!, "$be ${v['v1']}"];
      expl = "Present Continuous: be + Ving";
      break;

    case "present_perfect":
      final hv = isSing ? "has" : "have";
      correct = "$hv ${v['v3']}";
      if (diff == "easy") {
        final t = p(timePerf);
        final pats = [
          "$s _____ $t $o.",
          "$s _____ $o $t.",
          "_____ $s ever ${v['v3']} $o?"
        ];
        stem = pats[patIdx % pats.length];
        if (stem.startsWith("_____")) correct = isSing ? "Has" : "Have";
      } else if (diff == "medium") {
        final pats = [
          "$s _____ $o since 2020.",
          "$s _____ $o for 5 years.",
          "How long _____ $s ${v['v3']} $o?",
          "$s _____ never $o before."
        ];
        stem = pats[patIdx % pats.length];
        if (stem.contains("How long")) correct = isSing ? "has" : "have";
      } else {
        stem = "This is the best $o $s _____ ever ${v['v3']}.";
      }
      ch = [correct, v["v1"]!, v["v2"]!, "had ${v['v3']}"];
      expl = "Present Perfect: have/has + V3";
      break;

    case "present_perfect_continuous":
      final hv = isSing ? "has" : "have";
      correct = "$hv been ${v['ving']}";
      final d = p(dur);
      if (diff == "easy") {
        final pats = ["$s _____ $o $d.", "$s _____ $o since morning."];
        stem = pats[patIdx % pats.length];
      } else if (diff == "medium") {
        final pats = [
          "$s looks tired. $s _____ $o all day.",
          "How long _____ $s been ${v['ving']}?",
          "$s _____ $o for hours."
        ];
        stem = pats[patIdx % pats.length];
        if (stem.contains("How long")) correct = isSing ? "has" : "have";
      } else {
        stem = "$s _____ $o recently, so the house is a mess.";
      }
      ch = [correct, "$hv ${v['v3']}", v["v2"]!, "was ${v['ving']}"];
      expl = "Present Perfect Continuous: have/has been + Ving";
      break;

    case "past_simple":
      correct = v["v2"]!;
      if (diff == "easy") {
        final t = p(timePast);
        final pats = ["$s _____ $o $t.", "$t, $s _____ $o."];
        stem = pats[patIdx % pats.length];
      } else if (diff == "medium") {
        final pats = [
          "When did $s _____ $o?",
          "$s didn't _____ $o.",
          "Did $s _____ $o yesterday?",
          "$s _____ $o and then left."
        ];
        stem = pats[patIdx % pats.length];
        if (stem.contains("did") ||
            stem.contains("didn't") ||
            stem.contains("Did")) {
          correct = v["v1"]!;
        }
      } else {
        final pats = [
          "As soon as $s _____ $o, the phone rang.",
          "After $s _____ $o, we went home.",
          "$s _____ $o before I arrived."
        ];
        stem = pats[patIdx % pats.length];
      }
      ch = [correct, v["v1"]!, v["v3"]!, v["ving"]!];
      expl = "Past Simple: V2";
      break;

    case "past_continuous":
      final be = (isSing || s == "I") ? "was" : "were";
      correct = "$be ${v['ving']}";
      if (diff == "easy") {
        final pats = [
          "$s _____ $o at 8 PM yesterday.",
          "At this time last night, $s _____ $o."
        ];
        stem = pats[patIdx % pats.length];
      } else if (diff == "medium") {
        final pats = [
          "While $s _____ $o, the phone rang.",
          "$s _____ $o when I arrived.",
          "What _____ $s doing at 9 PM?"
        ];
        stem = pats[patIdx % pats.length];
        if (stem.contains("What")) correct = be;
      } else {
        stem = "$s _____ $o all evening, so ${s.toLowerCase()} was tired.";
      }
      ch = [correct, v["v2"]!, "is ${v['ving']}", v["v1"]!];
      expl = "Past Continuous: was/were + Ving";
      break;

    case "past_perfect":
      correct = "had ${v['v3']}";
      if (diff == "easy") {
        final pats = [
          "By the time I arrived, $s _____ already $o.",
          "$s _____ $o before noon."
        ];
        stem = pats[patIdx % pats.length];
      } else if (diff == "medium") {
        final pats = [
          "After $s _____ $o, we left.",
          "$s said they _____ never $o before.",
          "Before I came, $s _____ $o."
        ];
        stem = pats[patIdx % pats.length];
      } else {
        stem = "If $s _____ $o earlier, we would have succeeded.";
      }
      ch = [correct, v["v2"]!, "has ${v['v3']}", v["v1"]!];
      expl = "Past Perfect: had + V3";
      break;

    case "past_perfect_continuous":
      correct = "had been ${v['ving']}";
      final d2 = p(dur);
      if (diff == "easy") {
        final pats = [
          "$s _____ $o $d2 before it stopped.",
          "$s _____ $o for hours."
        ];
        stem = pats[patIdx % pats.length];
      } else if (diff == "medium") {
        final pats = [
          "$s was exhausted because ${s.toLowerCase()} _____ $o all day.",
          "How long had $s _____ $o before the rain?"
        ];
        stem = pats[patIdx % pats.length];
        if (stem.contains("How long")) correct = "been ${v['ving']}";
      } else {
        stem = "$s _____ $o for years before finally succeeding.";
      }
      ch = [correct, "had ${v['v3']}", "has been ${v['ving']}", v["v2"]!];
      expl = "Past Perfect Continuous: had been + Ving";
      break;

    case "future_simple":
      correct = "will ${v['v1']}";
      if (diff == "easy") {
        final t = p(timeFut);
        final pats = ["$s _____ $o $t.", "$t, $s _____ $o."];
        stem = pats[patIdx % pats.length];
      } else if (diff == "medium") {
        final pats = [
          "I think $s _____ $o.",
          "$s _____ probably $o.",
          "I'm sure $s _____ $o."
        ];
        stem = pats[patIdx % pats.length];
      } else {
        stem = "If it rains, $s _____ $o inside.";
      }
      ch = [correct, v["v1"]!, "is going to ${v['v1']}", v["v1s"]!];
      expl = "Future Simple: will + V1";
      break;

    case "future_continuous":
      correct = "will be ${v['ving']}";
      if (diff == "easy") {
        final pats = [
          "At this time tomorrow, $s _____ $o.",
          "This time next week, $s _____ $o."
        ];
        stem = pats[patIdx % pats.length];
      } else if (diff == "medium") {
        final pats = [
          "Don't call at 8. $s _____ $o.",
          "When you arrive, $s _____ $o."
        ];
        stem = pats[patIdx % pats.length];
      } else {
        stem = "Will $s _____ $o at 10 PM tonight?";
      }
      ch = [correct, "will ${v['v1']}", "is ${v['ving']}", v["v1"]!];
      expl = "Future Continuous: will be + Ving";
      break;

    case "future_perfect":
      correct = "will have ${v['v3']}";
      if (diff == "easy") {
        final pats = ["By next year, $s _____ $o.", "By 2030, $s _____ $o."];
        stem = pats[patIdx % pats.length];
      } else if (diff == "medium") {
        final pats = [
          "By the time you arrive, $s _____ $o.",
          "$s _____ $o before sunset."
        ];
        stem = pats[patIdx % pats.length];
      } else {
        stem = "How many times will $s _____ $o by then?";
      }
      ch = [correct, "will ${v['v1']}", "has ${v['v3']}", "had ${v['v3']}"];
      expl = "Future Perfect: will have + V3";
      break;

    case "future_perfect_continuous":
      correct = "will have been ${v['ving']}";
      final d3 = p(dur);
      if (diff == "easy") {
        final pats = [
          "By 5 PM, $s _____ $o $d3.",
          "By next month, $s _____ $o for a year."
        ];
        stem = pats[patIdx % pats.length];
      } else if (diff == "medium") {
        stem = "By graduation, $s _____ $o for 4 years.";
      } else {
        stem = "How long will $s _____ $o by the end of this year?";
      }
      ch = [
        correct,
        "will have ${v['v3']}",
        "will be ${v['ving']}",
        "has been ${v['ving']}"
      ];
      expl = "Future Perfect Continuous: will have been + Ving";
      break;

    case "passive_voice":
      // Expanded passive subjects (50+)
      final passSub = [
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
        "Music",
        "The game",
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
        "The building",
        "Dinner",
        "Breakfast",
        "Lunch",
        "The bridge",
        "The road",
        "The new phone",
        "The gift",
        "The money",
        "The prize",
        "The medal",
        "The award",
        "The scholarship",
        "The job",
        "The ticket",
        "The reservation",
        "The appointment",
        "The decision",
        "The announcement"
      ];

      // Agents for "by" clauses
      final agents = [
        "many people",
        "the teacher",
        "the students",
        "my mother",
        "the chef",
        "the company",
        "the government",
        "the workers",
        "experts",
        "professionals",
        "the team",
        "the manager",
        "the doctor",
        "the police",
        "the staff",
        "everyone",
        "millions of people",
        "the employees",
        "the engineers",
        "volunteers"
      ];

      // Locations
      final locations = [
        "in Thailand",
        "in Japan",
        "in America",
        "around the world",
        "at the office",
        "at school",
        "in the factory",
        "at the restaurant",
        "in the hospital",
        "at home",
        "in many countries",
        "everywhere",
        "in this city",
        "in that building",
        "at the store"
      ];

      final ps = p(passSub);
      final agent = p(agents);
      final loc = p(locations);
      final t1 = p(timePast);
      final t2 = p(timeFut);

      if (diff == "easy") {
        final pats = [
          "$ps _____ by $agent.",
          "$ps _____ every day.",
          "$ps _____ $loc.",
          "$ps _____ regularly.",
          "$ps _____ twice a week.",
          "$ps _____ by professionals.",
          "$ps _____ carefully.",
          "$ps _____ properly.",
          "$ps _____ quickly.",
          "$ps _____ slowly.",
        ];
        stem = pats[patIdx % pats.length];
        correct = "is ${v['v3']}";
      } else if (diff == "medium") {
        final pats = [
          "$ps _____ $t1.",
          "$ps _____ by $agent $t1.",
          "$ps _____ before the deadline.",
          "$ps _____ last night by the team.",
          "$ps _____ when I arrived.",
          "When _____ $ps ${v['v3']}?",
          "$ps has _____ already.",
          "$ps has been _____ by $agent.",
          "$ps haven't been _____ yet.",
          "$ps was _____ $t1.",
        ];
        stem = pats[patIdx % pats.length];
        if (stem.contains("When _____")) {
          correct = "was";
        } else if (stem.contains("has _____") ||
            stem.contains("has been _____") ||
            stem.contains("haven't been _____")) {
          correct = v["v3"]!;
        } else {
          correct = "was ${v['v3']}";
        }
      } else {
        final pats = [
          "$ps _____ right now.",
          "$ps _____ at the moment.",
          "$ps is being _____ by $agent.",
          "$ps _____ $t2.",
          "$ps will be _____ by the team.",
          "$ps should be _____ carefully.",
          "$ps must be _____ before Friday.",
          "$ps can be _____ easily.",
          "$ps might be _____ tomorrow.",
          "$ps needs to be _____ immediately.",
          "The work _____ being done at the moment.",
          "$ps had been _____ before we arrived.",
        ];
        stem = pats[patIdx % pats.length];
        if (stem.contains("is being _____") ||
            stem.contains("will be _____") ||
            stem.contains("should be _____") ||
            stem.contains("must be _____") ||
            stem.contains("can be _____") ||
            stem.contains("might be _____") ||
            stem.contains("needs to be _____") ||
            stem.contains("had been _____")) {
          correct = v["v3"]!;
        } else if (stem.contains("_____ being done")) {
          correct = "is";
        } else {
          correct = "is being ${v['v3']}";
        }
      }
      ch = [correct, v["v1"]!, v["v2"]!, v["ving"]!];
      expl = "Passive Voice: be + V3";
      break;
  }

  // Ensure 4 unique choices
  ch = ch.toSet().toList();
  while (ch.length < 4) {
    ch.add(v["v${random.nextInt(3) + 1}"] ?? v["v1"]!);
  }
  ch = sh(ch).take(4).toList();

  return {
    "stem": stem,
    "choices": ch,
    "correctIndex": ch.indexOf(correct),
    "explanation": expl,
  };
}

void main() {
  final dir = Directory("assets/data/quiz");
  if (!dir.existsSync()) dir.createSync(recursive: true);

  print("Grammar Quiz Generator V3 - Maximum Diversity");
  print("=" * 50);

  for (var t in tenses) {
    print("\n${t['name']}...");
    final qs = <String, List<Map<String, dynamic>>>{
      "easy": [],
      "medium": [],
      "hard": []
    };
    final used = <String>{};

    for (var d in ["easy", "medium", "hard"]) {
      final target = d == "medium" ? 2000 : 1500;
      var i = 0;
      var pat = 0;
      while (i < target && pat < target * 10) {
        final q = gen(t["name"]!, d, pat++);
        final stem = q["stem"] as String;
        if (stem.isEmpty || used.contains(stem)) continue;
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

  print("\nDone!");
}
