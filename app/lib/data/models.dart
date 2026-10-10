import 'package:flutter/foundation.dart';

Map<String, dynamic> jsonMap(Object? value) =>
    Map<String, dynamic>.from(value! as Map);

List<Map<String, dynamic>> jsonMapList(Object? value) =>
    (value as List? ?? const <Object>[])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

String localizedText(Object? value, [String locale = 'fr-FR']) {
  if (value is String) return value;
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    final localized = map[locale] ?? map['fr-FR'];
    if (localized is String) return localized;
  }
  return '';
}

@immutable
class SessionActivity {
  const SessionActivity({
    required this.order,
    required this.type,
    required this.contentRef,
  });

  factory SessionActivity.fromJson(Map<String, dynamic> json) =>
      SessionActivity(
        order: json['order'] as int,
        type: json['type'] as String,
        contentRef: json['content_ref'] as String,
      );

  final int order;
  final String type;
  final String contentRef;
}

@immutable
class LanguageUnit {
  const LanguageUnit({
    required this.id,
    required this.type,
    required this.canonicalForm,
    required this.translation,
    required this.register,
    required this.flashcardEligible,
  });

  factory LanguageUnit.fromJson(Map<String, dynamic> json) => LanguageUnit(
    id: json['id'] as String,
    type: json['type'] as String,
    canonicalForm: json['canonical_form'] as String,
    translation: localizedText(json['translations']),
    register: json['register'] as String? ?? 'kirjakieli',
    flashcardEligible: json['flashcard_eligible'] as bool? ?? false,
  );

  final String id;
  final String type;
  final String canonicalForm;
  final String translation;
  final String register;
  final bool flashcardEligible;
}

@immutable
class DialogueLine {
  const DialogueLine({
    required this.id,
    required this.section,
    required this.kind,
    required this.speaker,
    required this.language,
    required this.text,
    required this.intent,
    required this.translation,
    required this.unitIds,
    required this.pauseAfter,
  });

  factory DialogueLine.fromJson(Map<String, dynamic> json) {
    final direction = json['direction'] is Map
        ? jsonMap(json['direction'])
        : const <String, dynamic>{};
    return DialogueLine(
      id: json['id'] as String,
      section: json['section'] as String,
      kind: json['kind'] as String,
      speaker: json['speaker'] as String,
      language: json['language'] as String,
      text: json['text'] as String,
      intent: json['intent'] as String? ?? '',
      translation: localizedText(json['translations']),
      unitIds: List<String>.from(json['unit_ids'] as List? ?? const []),
      pauseAfter: Duration(
        milliseconds: direction['pause_after_ms'] as int? ?? 0,
      ),
    );
  }

  final String id;
  final String section;
  final String kind;
  final String speaker;
  final String language;
  final String text;
  final String intent;
  final String translation;
  final List<String> unitIds;
  final Duration pauseAfter;

  bool get isInstruction => kind == 'instruction';
}

@immutable
class RecallPair {
  const RecallPair({required this.prompt, required this.answer});

  final DialogueLine prompt;
  final DialogueLine answer;
}

@immutable
class ReadingToken {
  const ReadingToken({
    required this.surface,
    required this.start,
    required this.end,
    required this.lemma,
    required this.unitId,
    required this.translation,
    required this.grammar,
  });

  factory ReadingToken.fromJson(Map<String, dynamic> json) => ReadingToken(
    surface: json['surface'] as String,
    start: json['start'] as int,
    end: json['end'] as int,
    lemma: json['lemma'] as String? ?? '',
    unitId: json['unit_id'] as String? ?? '',
    translation: json['translation'] as String? ?? '',
    grammar: json['grammar'] is Map
        ? Map<String, dynamic>.from(json['grammar'] as Map)
        : const {},
  );

  final String surface;
  final int start;
  final int end;
  final String lemma;
  final String unitId;
  final String translation;
  final Map<String, dynamic> grammar;
}

@immutable
class ReadingSentence {
  const ReadingSentence({
    required this.id,
    required this.speaker,
    required this.text,
    required this.translation,
    required this.tokens,
  });

  factory ReadingSentence.fromJson(Map<String, dynamic> json) =>
      ReadingSentence(
        id: json['id'] as String,
        speaker: json['speaker'] as String? ?? '',
        text: json['text'] as String,
        translation: localizedText(json['translations']),
        tokens: jsonMapList(json['tokens'])
            .map(ReadingToken.fromJson)
            .toList(growable: false),
      );

  final String id;
  final String speaker;
  final String text;
  final String translation;
  final List<ReadingToken> tokens;
}

@immutable
class QuestionChoice {
  const QuestionChoice({required this.id, required this.text});

  factory QuestionChoice.fromJson(Map<String, dynamic> json) => QuestionChoice(
    id: json['id'] as String? ?? localizedText(json['text']),
    text: localizedText(json['text']),
  );

  final String id;
  final String text;
}

@immutable
class LessonQuestion {
  const LessonQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.choices,
    required this.acceptedAnswers,
    this.correctChoiceId,
    this.evidenceId,
  });

  factory LessonQuestion.fromJson(Map<String, dynamic> json) => LessonQuestion(
    id: json['id'] as String,
    type: json['type'] as String,
    prompt: localizedText(json['prompt']),
    choices: jsonMapList(json['choices'])
        .map(QuestionChoice.fromJson)
        .toList(growable: false),
    acceptedAnswers: List<String>.from(
      json['accepted_answers'] as List? ?? const [],
    ),
    correctChoiceId: json['correct_choice_id'] as String?,
    evidenceId:
        json['evidence_sentence_id'] as String? ??
        json['evidence_line_id'] as String?,
  );

  final String id;
  final String type;
  final String prompt;
  final List<QuestionChoice> choices;
  final List<String> acceptedAnswers;
  final String? correctChoiceId;
  final String? evidenceId;

  String get answerLabel {
    if (correctChoiceId != null) {
      return choices
          .firstWhere(
            (choice) => choice.id == correctChoiceId,
            orElse: () => const QuestionChoice(id: '', text: ''),
          )
          .text;
    }
    return acceptedAnswers.isEmpty ? '' : acceptedAnswers.first;
  }

  bool isCorrect(String answer) {
    final normalized = _normalize(answer);
    if (correctChoiceId != null) {
      final match = choices.where((choice) => choice.id == correctChoiceId);
      return match.isNotEmpty && _normalize(match.first.text) == normalized;
    }
    return acceptedAnswers.any((item) => _normalize(item) == normalized);
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'[.!?]$'), '');
}

@immutable
class PlacementChoice {
  const PlacementChoice({required this.id, required this.text});

  factory PlacementChoice.fromJson(Map<String, dynamic> json) =>
      PlacementChoice(
        id: json['id'] as String,
        text: localizedText(json['text']),
      );

  final String id;
  final String text;
}

@immutable
class PlacementQuestion {
  const PlacementQuestion({
    required this.id,
    required this.prompt,
    required this.choices,
    required this.correctChoiceId,
  });

  factory PlacementQuestion.fromJson(Map<String, dynamic> json) =>
      PlacementQuestion(
        id: json['id'] as String,
        prompt: localizedText(json['prompt']),
        choices: jsonMapList(json['choices'])
            .map(PlacementChoice.fromJson)
            .toList(growable: false),
        correctChoiceId: json['correct_choice_id'] as String,
      );

  final String id;
  final String prompt;
  final List<PlacementChoice> choices;
  final String correctChoiceId;

  bool isCorrect(String choiceId) => choiceId == correctChoiceId;
}

@immutable
class LessonPlacementTest {
  const LessonPlacementTest({
    required this.lessonId,
    required this.lessonNumber,
    required this.title,
    required this.questions,
  });

  factory LessonPlacementTest.fromJson(Map<String, dynamic> json) =>
      LessonPlacementTest(
        lessonId: json['lesson_id'] as String,
        lessonNumber: json['lesson_number'] as int,
        title: localizedText(json['title']),
        questions: jsonMapList(json['questions'])
            .map(PlacementQuestion.fromJson)
            .toList(growable: false),
      );

  final String lessonId;
  final int lessonNumber;
  final String title;
  final List<PlacementQuestion> questions;

  bool isPassed(Map<String, String> answers) => questions.every(
    (question) => question.isCorrect(answers[question.id] ?? ''),
  );
}

@immutable
class LessonGame {
  const LessonGame({
    required this.id,
    required this.type,
    required this.instruction,
    required this.skill,
    required this.raw,
  });

  factory LessonGame.fromJson(Map<String, dynamic> json) => LessonGame(
    id: json['id'] as String,
    type: json['type'] as String,
    instruction: localizedText(json['instruction']),
    skill: json['skill'] as String? ?? '',
    raw: json,
  );

  final String id;
  final String type;
  final String instruction;
  final String skill;
  final Map<String, dynamic> raw;

  List<String> get choices =>
      List<String>.from(raw['choices'] as List? ?? const <String>[]);

  String get answer => raw['answer'] as String? ?? '';
}

typedef Question = LessonQuestion;
typedef Game = LessonGame;

@immutable
class MemoryPair {
  const MemoryPair({
    required this.id,
    required this.word,
    required this.illustration,
    required this.illustrationLabel,
    required this.unitIds,
  });

  factory MemoryPair.fromJson(Map<String, dynamic> json) => MemoryPair(
    id: json['id'] as String,
    word: json['word'] as String,
    illustration: json['illustration'] as String,
    illustrationLabel: localizedText(json['illustration_label']),
    unitIds: List<String>.from(json['unit_ids'] as List? ?? const []),
  );

  final String id;
  final String word;
  final String illustration;
  final String illustrationLabel;
  final List<String> unitIds;
}

@immutable
class LessonMemory {
  const LessonMemory({
    required this.id,
    required this.instruction,
    required this.pairs,
  });

  factory LessonMemory.fromJson(Map<String, dynamic> json) => LessonMemory(
    id: json['id'] as String,
    instruction: localizedText(json['instruction']),
    pairs: jsonMapList(json['pairs'])
        .map(MemoryPair.fromJson)
        .toList(growable: false),
  );

  final String id;
  final String instruction;
  final List<MemoryPair> pairs;
}

@immutable
class Flashcard {
  const Flashcard({
    required this.id,
    required this.unitId,
    required this.front,
    required this.back,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    final front = jsonMap(json['front']);
    final back = jsonMap(json['back']);
    return Flashcard(
      id: json['id'] as String,
      unitId: json['unit_id'] as String,
      front: front['fr-FR'] as String? ?? '',
      back: back['fi-FI'] as String? ?? '',
    );
  }

  final String id;
  final String unitId;
  final String front;
  final String back;
}

@immutable
class LessonAudio {
  const LessonAudio({
    required this.id,
    required this.assetPath,
    required this.duration,
  });

  final String id;
  final String assetPath;
  final Duration duration;
}

@immutable
class LessonStory {
  const LessonStory({
    required this.id,
    required this.title,
    required this.panels,
  });

  factory LessonStory.fromJson(Map<String, dynamic> json) => LessonStory(
    id: json['id'] as String,
    title: localizedText(json['title']),
    panels: jsonMapList(json['panels'])
        .map(StoryPanel.fromJson)
        .toList(growable: false),
  );

  final String id;
  final String title;
  final List<StoryPanel> panels;
}

@immutable
class StoryPanel {
  const StoryPanel({
    required this.id,
    required this.image,
    required this.caption,
    required this.imageLabel,
    required this.bubbles,
  });

  factory StoryPanel.fromJson(Map<String, dynamic> json) => StoryPanel(
    id: json['id'] as String,
    image: json['image'] as String,
    caption: localizedText(json['caption']),
    imageLabel: localizedText(json['image_label']),
    bubbles: jsonMapList(json['bubbles'])
        .map(StoryBubble.fromJson)
        .toList(growable: false),
  );

  final String id;
  final String image;
  final String caption;
  final String imageLabel;
  final List<StoryBubble> bubbles;
}

@immutable
class StoryBubble {
  const StoryBubble({
    required this.lineId,
    required this.speaker,
    required this.anchor,
  });

  factory StoryBubble.fromJson(Map<String, dynamic> json) => StoryBubble(
    lineId: json['line_id'] as String,
    speaker: json['speaker'] as String? ?? '',
    anchor: json['anchor'] as String? ?? '',
  );

  final String lineId;
  final String speaker;
  final String anchor;
}

@immutable
class LessonWriting {
  const LessonWriting({
    required this.id,
    required this.prompt,
    required this.minimumSentences,
    required this.targetUnitIds,
  });

  factory LessonWriting.fromJson(Map<String, dynamic> json) => LessonWriting(
    id: json['id'] as String,
    prompt: localizedText(json['prompt']),
    minimumSentences: json['minimum_sentences'] as int? ?? 1,
    targetUnitIds: List<String>.from(
      json['target_unit_ids'] as List? ?? const [],
    ),
  );

  final String id;
  final String prompt;
  final int minimumSentences;
  final List<String> targetUnitIds;
}

@immutable
class AttemptEvent {
  const AttemptEvent({
    required this.activityType,
    required this.unitIds,
    required this.createdAt,
    this.correct,
    this.help,
    this.rating,
  });

  final String activityType;
  final List<String> unitIds;
  final DateTime createdAt;
  final bool? correct;
  final String? help;
  final String? rating;
}

@immutable
class MasterySnapshot {
  const MasterySnapshot({
    required this.unitId,
    required this.encounters,
    required this.successes,
    required this.helpCount,
  });

  final String unitId;
  final int encounters;
  final int successes;
  final int helpCount;

  String get label {
    if (encounters == 0) return 'À découvrir';
    if (successes >= 2 && helpCount == 0) return 'Solide';
    return 'En consolidation';
  }

  double get progress {
    if (encounters == 0) return 0;
    final value = (successes * 0.34) + ((encounters - helpCount) * 0.08);
    return value.clamp(0.08, 1).toDouble();
  }
}

@immutable
class LessonPackage {
  const LessonPackage({
    required this.id,
    required this.number,
    required this.assetRoot,
    required this.title,
    required this.level,
    required this.objectives,
    required this.activities,
    required this.dialogue,
    required this.units,
    required this.reading,
    required this.openingQuestions,
    required this.readingQuestions,
    required this.memory,
    required this.games,
    required this.transferLines,
    required this.transferQuestions,
    required this.flashcards,
    required this.optionalFlashcardUnitIds,
    required this.fullAudio,
    required this.audioSegments,
    required this.placementTests,
    this.story,
    this.writing,
  });

  final String id;
  final int number;
  final String assetRoot;
  final String title;
  final String level;
  final List<String> objectives;
  final List<SessionActivity> activities;
  final List<DialogueLine> dialogue;
  final List<LanguageUnit> units;
  final List<ReadingSentence> reading;
  final List<LessonQuestion> openingQuestions;
  final List<LessonQuestion> readingQuestions;
  final LessonMemory memory;
  final List<LessonGame> games;
  final List<DialogueLine> transferLines;
  final List<LessonQuestion> transferQuestions;
  final List<Flashcard> flashcards;
  final List<String> optionalFlashcardUnitIds;
  final LessonAudio fullAudio;
  final Map<String, LessonAudio> audioSegments;
  final List<LessonPlacementTest> placementTests;
  final LessonStory? story;
  final LessonWriting? writing;

  int get audioSegmentCount => audioSegments.length;

  List<PlacementQuestion> get placementQuestions =>
      placementTests.expand((test) => test.questions).toList(growable: false);

  List<DialogueLine> get openingLines => dialogue
      .where((line) => line.section == 'opening_conversation')
      .toList(growable: false);

  List<DialogueLine> get roleplayLines => dialogue
      .where(
        (line) =>
            line.section.startsWith('final_conversation') &&
            !line.isInstruction,
      )
      .toList(growable: false);

  List<RecallPair> get activeRecallPairs {
    final section = dialogue
        .where((line) => line.section == 'guided_practice')
        .toList(growable: false);
    final pairs = <RecallPair>[];
    for (var index = 0; index < section.length - 1; index++) {
      if (section[index].intent == 'prompt_learner_response' &&
          !section[index + 1].isInstruction) {
        pairs.add(
          RecallPair(prompt: section[index], answer: section[index + 1]),
        );
      }
    }
    return pairs;
  }

  List<DialogueLine> get guidedLines {
    final section = dialogue
        .where((line) => line.section == 'guided_practice')
        .toList(growable: false);
    final excluded = <String>{};
    for (var index = 0; index < section.length - 1; index++) {
      if (section[index].intent == 'prompt_learner_response' &&
          !section[index + 1].isInstruction) {
        excluded
          ..add(section[index].id)
          ..add(section[index + 1].id);
      }
    }
    return section
        .where((line) => !excluded.contains(line.id))
        .toList(growable: false);
  }

  LanguageUnit? unitById(String id) {
    final matches = units.where((unit) => unit.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  LessonAudio audioForLine(String lineId) {
    final audio = audioSegments[lineId];
    if (audio == null) {
      throw StateError('Aucun audio pour la ligne $lineId.');
    }
    return audio;
  }

  List<LessonAudio> audioForLines(Iterable<DialogueLine> lines) =>
      lines.map((line) => audioForLine(line.id)).toList(growable: false);

  LessonAudio? audioExampleForUnit(String unitId) {
    final candidates = <DialogueLine>[
      ...dialogue,
      ...transferLines,
    ].where((line) => line.unitIds.contains(unitId));
    for (final line in candidates) {
      final audio = audioSegments[line.id];
      if (audio != null) return audio;
    }
    return null;
  }
}
