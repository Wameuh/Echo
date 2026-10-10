import 'dart:convert';

import 'package:flutter/services.dart';

import 'models.dart';

class LessonRepository {
  LessonRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const _courseRoot = 'assets/lessons/Suomi/Beginner';
  final AssetBundle _bundle;

  Future<LessonPackage> loadLesson1() => loadLesson(1);

  Future<LessonPackage> loadLesson2() => loadLesson(2);

  Future<List<LessonPackage>> loadLessons({
    List<int> lessonNumbers = const [1, 2],
  }) => Future.wait(lessonNumbers.map(loadLesson));

  Future<LessonPackage> loadLesson(int number) async {
    final source = _LessonSource.forNumber(number);
    final root = '$_courseRoot/Lesson$number';
    final files = await Future.wait([
      _readAt(root, 'content.json'),
      _readAt(root, 'session.json'),
      _readAt(root, 'units.json'),
      _readAt(root, 'localization/fr-FR.json'),
      _readAt(root, source.reading),
      _readAt(root, 'comprehension/opening-audio.json'),
      _readAt(root, source.readingComprehension),
      _readAt(root, 'games/practice-set-01.json'),
      _readAt(root, source.transfer),
      _readAt(root, 'flashcards.json'),
      _readAt(root, 'audio/manifest.json'),
      _readCourse('placement.json'),
      _readAt(root, 'story/story.json'),
      if (source.writing case final path?) _readAt(root, path),
    ]);

    final content = files[0];
    final session = files[1];
    final units = files[2];
    final localization = files[3];
    final reading = files[4];
    final opening = files[5];
    final comprehension = files[6];
    final games = files[7];
    final transfer = files[8];
    final flashcards = files[9];
    final manifest = files[10];
    final placement = files[11];
    final story = files[12];
    final writing = source.writing == null ? null : files[13];

    if (localization['strings'] is! Map) {
      throw const FormatException(
        'Le fichier fr-FR ne contient pas de chaînes.',
      );
    }

    final audioSegments = <String, LessonAudio>{
      for (final segment in jsonMapList(manifest['segments']))
        segment['line_id'] as String: _audioFromManifest(segment, root: root),
    };
    final lesson = jsonMap(content['lesson']);
    final normalizedActivities = jsonMapList(session['activities'])
        // Le format v2 sépare la question d'ouverture. L'interface du MVP la
        // présente déjà juste après la piste complète, dans la même activité.
        .where((activity) => activity['type'] != 'opening_comprehension')
        .map((activity) {
          final normalized = Map<String, dynamic>.from(activity);
          if (normalized['type'] == 'audio_lesson') {
            normalized['type'] = 'global_listening';
          }
          return SessionActivity.fromJson(normalized);
        })
        .toList(growable: false);
    final audioIndex = normalizedActivities.indexWhere(
      (activity) => activity.type == 'global_listening',
    );
    final activities = audioIndex <= 0
        ? normalizedActivities
        : <SessionActivity>[
            normalizedActivities[audioIndex],
            ...normalizedActivities.where(
              (activity) => activity.type != 'global_listening',
            ),
          ];

    final package = LessonPackage(
      id: lesson['id'] as String,
      number: lesson['number'] as int? ?? number,
      assetRoot: root,
      title: lesson['title'] as String,
      level: lesson['level'] as String,
      objectives: List<String>.from(
        lesson['learning_objectives'] as List? ?? const [],
      ),
      activities: activities,
      dialogue: jsonMapList(content['dialogue'])
          .map(DialogueLine.fromJson)
          .toList(growable: false),
      units: jsonMapList(units['units'])
          .map(LanguageUnit.fromJson)
          .toList(growable: false),
      reading: jsonMapList(reading['sentences'])
          .map(ReadingSentence.fromJson)
          .toList(growable: false),
      openingQuestions: jsonMapList(opening['questions'])
          .map(LessonQuestion.fromJson)
          .toList(growable: false),
      readingQuestions: jsonMapList(comprehension['questions'])
          .map(LessonQuestion.fromJson)
          .toList(growable: false),
      memory: LessonMemory.fromJson(jsonMap(games['memory'])),
      games: jsonMapList(games['games'])
          .map(LessonGame.fromJson)
          .toList(growable: false),
      transferLines: jsonMapList(transfer['lines'])
          .map(_transferLine)
          .toList(growable: false),
      transferQuestions: jsonMapList(transfer['questions'])
          .map(LessonQuestion.fromJson)
          .toList(growable: false),
      flashcards: jsonMapList(flashcards['cards'])
          .map(Flashcard.fromJson)
          .toList(growable: false),
      optionalFlashcardUnitIds: List<String>.from(
        flashcards['optional_candidates'] as List? ?? const [],
      ),
      fullAudio: _audioFromManifest(
        jsonMap(manifest['full']),
        root: root,
        id: 'lesson$number-full',
      ),
      audioSegments: Map.unmodifiable(audioSegments),
      placementTests: jsonMapList(placement['lesson_tests'])
          .map(LessonPlacementTest.fromJson)
          .toList(growable: false),
      story: LessonStory.fromJson(story),
      writing: writing == null ? null : LessonWriting.fromJson(writing),
    );
    _validate(package);
    return package;
  }

  Future<Map<String, dynamic>> _readAt(String root, String path) async {
    final text = await _bundle.loadString('$root/$path');
    return Map<String, dynamic>.from(jsonDecode(text) as Map);
  }

  Future<Map<String, dynamic>> _readCourse(String path) =>
      _readAt(_courseRoot, path);

  static LessonAudio _audioFromManifest(
    Map<String, dynamic> json, {
    required String root,
    String? id,
  }) {
    if (json['status'] != 'generated') {
      throw FormatException(
        'Audio non généré : ${id ?? json['line_id'] ?? json['file']}.',
      );
    }
    final file = json['file'] as String;
    final durationMs = json['duration_ms'] as int? ?? 0;
    if (!file.startsWith('audio/') || !file.endsWith('.wav')) {
      throw FormatException('Chemin audio invalide : $file.');
    }
    if (durationMs <= 0) {
      throw FormatException('Durée audio invalide : $file.');
    }
    return LessonAudio(
      id: id ?? json['line_id'] as String,
      assetPath: '$root/$file',
      duration: Duration(milliseconds: durationMs),
    );
  }

  static DialogueLine _transferLine(Map<String, dynamic> json) => DialogueLine(
    id: json['id'] as String,
    section: 'audio_transfer',
    kind: 'target_utterance',
    speaker: json['speaker'] as String,
    language: 'fi-FI',
    text: json['text'] as String,
    intent: 'transfer',
    translation: localizedText(json['translations']),
    unitIds: List<String>.from(json['unit_ids'] as List? ?? const []),
    pauseAfter: Duration.zero,
  );

  static void _validate(LessonPackage package) {
    final placementLessonIds = package.placementTests
        .map((test) => test.lessonId)
        .toSet();
    final placementQuestionIds = package.placementQuestions
        .map((question) => question.id)
        .toSet();
    final dialogueIds = package.dialogue.map((line) => line.id).toSet();
    final expectedAudioIds = <String>{
      ...dialogueIds,
      ...package.transferLines.map((line) => line.id),
    };
    final storyLineIds =
        package.story?.panels
            .expand((panel) => panel.bubbles)
            .map((bubble) => bubble.lineId)
            .toSet() ??
        const <String>{};
    const supportedActivities = <String>{
      'context',
      'global_listening',
      'active_recall',
      'roleplay',
      'transition',
      'reading',
      'reading_comprehension',
      'memory',
      'adaptive_games',
      'audio_transfer',
      'guided_writing',
      'selective_flashcards',
      'summary_and_spacing',
    };
    final checks = <String, bool>{
      'identifiant cohérent': package.id.endsWith('lesson-${package.number}'),
      'activités disponibles': package.activities.isNotEmpty,
      'types d’activité pris en charge': package.activities.every(
        (activity) => supportedActivities.contains(activity.type),
      ),
      'dialogue disponible': package.dialogue.isNotEmpty,
      'unités disponibles': package.units.isNotEmpty,
      'conversation d’ouverture': package.openingLines.isNotEmpty,
      'jeux de rôle': package.roleplayLines.isNotEmpty,
      'lecture disponible': package.reading.isNotEmpty,
      'questions audio disponibles': package.openingQuestions.isNotEmpty,
      'questions de lecture disponibles': package.readingQuestions.isNotEmpty,
      'Memory disponible': package.memory.pairs.isNotEmpty,
      'mini-jeux disponibles': package.games.isNotEmpty,
      'transfert disponible': package.transferLines.isNotEmpty,
      'flashcards disponibles': package.flashcards.isNotEmpty,
      'piste complète disponible':
          package.fullAudio.duration > Duration.zero &&
          package.fullAudio.assetPath.endsWith('/audio/full.wav'),
      'segments audio complets':
          package.audioSegments.keys.toSet().containsAll(expectedAudioIds) &&
          expectedAudioIds.containsAll(package.audioSegments.keys),
      'segments audio disponibles': package.audioSegments.values.every(
        (audio) =>
            audio.duration > Duration.zero && audio.assetPath.endsWith('.wav'),
      ),
      'histoire disponible': package.story?.panels.isNotEmpty ?? false,
      'bulles reliées au dialogue': dialogueIds.containsAll(storyLineIds),
      'images d’histoire valides':
          package.story?.panels.every(
            (panel) =>
                panel.image.startsWith('art/') && panel.image.endsWith('.png'),
          ) ??
          false,
      'production écrite disponible si annoncée':
          !package.activities.any(
            (activity) => activity.type == 'guided_writing',
          ) ||
          package.writing != null,
      '10 tests de placement': package.placementTests.length == 10,
      '20 questions de placement': package.placementQuestions.length == 20,
      'leçons de placement uniques':
          placementLessonIds.length == package.placementTests.length,
      'questions de placement uniques':
          placementQuestionIds.length == package.placementQuestions.length,
      'deux questions par leçon': package.placementTests.every(
        (test) => test.questions.length == 2,
      ),
      'réponses de placement valides': package.placementQuestions.every(
        (question) => question.choices.any(
          (choice) => choice.id == question.correctChoiceId,
        ),
      ),
    };
    final failures = checks.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .join(', ');
    if (failures.isNotEmpty) {
      throw FormatException('Paquet de leçon incomplet : $failures.');
    }
  }
}

class _LessonSource {
  const _LessonSource({
    required this.reading,
    required this.readingComprehension,
    required this.transfer,
    this.writing,
  });

  factory _LessonSource.forNumber(int number) => switch (number) {
    1 => const _LessonSource(
      reading: 'readings/meeting-at-work.json',
      readingComprehension: 'comprehension/meeting-at-work.json',
      transfer: 'transfer/sofia-and-daniel.json',
    ),
    2 => const _LessonSource(
      reading: 'readings/reading.json',
      readingComprehension: 'comprehension/reading.json',
      transfer: 'transfer/transfer.json',
      writing: 'writing/task.json',
    ),
    _ => throw RangeError('La leçon $number n’est pas encore disponible.'),
  };

  final String reading;
  final String readingComprehension;
  final String transfer;
  final String? writing;
}
