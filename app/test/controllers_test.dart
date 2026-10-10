import 'dart:async';

import 'package:echo/controllers/audio_controller.dart';
import 'package:echo/controllers/placement_controller.dart';
import 'package:echo/controllers/session_controller.dart';
import 'package:echo/data/lesson_repository.dart';
import 'package:echo/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LessonPackage lesson;

  setUpAll(() async {
    lesson = await LessonRepository().loadLesson1();
  });

  group('SessionController', () {
    test('navigue dans les 11 parties et leurs éléments', () {
      final audioIndex = lesson.activities.indexWhere(
        (activity) => activity.type == 'global_listening',
      );
      final controller = SessionController(lesson)..start(activity: audioIndex);
      expect(controller.itemCount, 2);
      controller.advance();
      expect(controller.itemIndex, 1);
      controller.advance();
      expect(controller.activity.type, 'context');
      controller.advance();
      expect(controller.activity.type, 'roleplay');
      expect(controller.itemIndex, 0);
      expect(controller.itemCount, 16);
      final memoryIndex = lesson.activities.indexWhere(
        (activity) => activity.type == 'memory',
      );
      controller.goToActivity(memoryIndex);
      expect(controller.itemCount, 1);
      final flashcardIndex = lesson.activities.indexWhere(
        (activity) => activity.type == 'selective_flashcards',
      );
      controller.goToActivity(flashcardIndex);
      expect(controller.itemCount, 11);
      controller.retreat();
      expect(controller.activityIndex, flashcardIndex - 1);
      expect(controller.itemIndex, 2);
    });

    test('enregistre réponses, aides, autoévaluations et acquis', () {
      final comprehensionIndex = lesson.activities.indexWhere(
        (activity) => activity.type == 'reading_comprehension',
      );
      final controller = SessionController(lesson)
        ..start(activity: comprehensionIndex);
      const unit = 'fi.construction.olen';
      controller.recordAnswer('q1', 'oui', correct: true, unitIds: [unit]);
      controller.recordHelp('word_translation', [unit]);
      controller.assess([unit], 'easy');

      final snapshot = controller.masteryFor(unit);
      expect(snapshot.encounters, 3);
      expect(snapshot.successes, 2);
      expect(snapshot.helpCount, 1);
      expect(snapshot.label, 'En consolidation');
      expect(controller.nextEncounterDays(unit), 1);

      const autonomousUnit = 'fi.greeting.hei';
      controller.recordAnswer(
        'q2',
        'du café',
        correct: true,
        unitIds: [autonomousUnit],
      );
      controller.assess([autonomousUnit], 'easy');
      expect(controller.masteryFor(autonomousUnit).label, 'Solide');
    });

    test('repart de zéro avec une nouvelle session après rechargement', () {
      final first = SessionController(lesson)..start();
      first.recordAnswer('q', 'x', correct: true, unitIds: ['fi.greeting.hei']);
      expect(first.attempts, isNotEmpty);

      final reloaded = SessionController(lesson);
      expect(reloaded.started, isFalse);
      expect(reloaded.attempts, isEmpty);
      expect(reloaded.masteryFor('fi.greeting.hei').encounters, 0);
    });
  });

  group('PlacementController', () {
    test('le diagnostic passe les leçons réussies et s’arrête à la première lacune', () {
      final controller = PlacementController(lesson.placementTests);
      final firstTest = lesson.placementTests[0];
      final secondTest = lesson.placementTests[1];
      final answers = {
        for (final question in firstTest.questions)
          question.id: question.correctChoiceId,
        secondTest.questions.first.id: secondTest.questions.first.choices
            .firstWhere(
              (choice) =>
                  choice.id != secondTest.questions.first.correctChoiceId,
            )
            .id,
        secondTest.questions.last.id: secondTest.questions.last.correctChoiceId,
      };

      controller.complete(answers);

      expect(controller.completed, isTrue);
      expect(controller.skippableLessonIds, {firstTest.lessonId});
      expect(controller.assessedLessonIds, {
        firstTest.lessonId,
        secondTest.lessonId,
      });
      expect(controller.recommendedTest?.lessonNumber, 2);
      expect(controller.answers, hasLength(4));
    });

    test('un sans-faute permet de passer les dix leçons', () {
      final controller = PlacementController(lesson.placementTests);
      controller.complete({
        for (final question in lesson.placementQuestions)
          question.id: question.correctChoiceId,
      });

      expect(controller.skippableLessonIds, hasLength(10));
      expect(controller.assessedLessonIds, hasLength(10));
      expect(controller.recommendedTest, isNull);
    });

    test('ignorer le diagnostic conserve le parcours complet', () {
      final controller = PlacementController(lesson.placementTests)..skip();

      expect(controller.skipped, isTrue);
      expect(controller.skippableLessonIds, isEmpty);
      expect(controller.assessedLessonIds, isEmpty);
      expect(controller.answers, isEmpty);
    });
  });

  group('AudioController', () {
    test(
      'précharge sans lire et réutilise le buffer au premier clic',
      () async {
        final playback = _FakePlayback();
        final controller = AudioController(playback: playback);
        const audio = LessonAudio(
          id: 'lesson-full',
          assetPath: 'assets/audio/full.wav',
          duration: Duration(minutes: 8),
        );

        await controller.preload([audio]);
        expect(playback.loadedAssets, [audio.assetPath]);
        expect(playback.loadCalls, 1);
        expect(controller.isActive([audio]), isTrue);
        expect(controller.isPlaying, isFalse);

        await controller.toggle([audio]);
        expect(playback.loadCalls, 1);
        expect(controller.isPlaying, isTrue);
        controller.dispose();
      },
    );

    test('gère lecture, pause, recherche et arrêt exclusif', () async {
      final playback = _FakePlayback();
      final controller = AudioController(playback: playback);
      const first = LessonAudio(
        id: 'line-001',
        assetPath: 'assets/audio/line-001.wav',
        duration: Duration(seconds: 3),
      );
      const second = LessonAudio(
        id: 'line-002',
        assetPath: 'assets/audio/line-002.wav',
        duration: Duration(seconds: 5),
      );

      await controller.toggle([first]);
      expect(playback.loadedAssets, [first.assetPath]);
      expect(controller.isPlaying, isTrue);
      expect(controller.isActive([first]), isTrue);

      await controller.toggle([first]);
      expect(playback.pauseCalls, 1);
      await controller.seek(const Duration(seconds: 2));
      expect(playback.position, const Duration(seconds: 2));

      await controller.play([first, second]);
      expect(playback.loadedAssets, [first.assetPath, second.assetPath]);
      expect(controller.duration, const Duration(seconds: 8));

      await controller.seek(const Duration(seconds: 6));
      expect(playback.currentIndexValue, 1);
      expect(playback.position, const Duration(seconds: 3));
      expect(controller.position, const Duration(seconds: 6));

      playback.completedValue = true;
      await controller.toggle([first, second]);
      expect(playback.loadCalls, 3);
      controller.dispose();
      expect(playback.disposed, isTrue);
    });
  });
}

class _FakePlayback implements AudioPlayback {
  final StreamController<Object?> changes =
      StreamController<Object?>.broadcast();
  bool playingValue = false;
  bool completedValue = false;
  Duration positionValue = Duration.zero;
  Duration? durationValue = const Duration(seconds: 12);
  int? currentIndexValue = 0;
  List<String> loadedAssets = const [];
  int loadCalls = 0;
  int pauseCalls = 0;
  int stopCalls = 0;
  bool disposed = false;

  @override
  bool get playing => playingValue;
  @override
  bool get completed => completedValue;
  @override
  Duration get position => positionValue;
  @override
  Duration? get duration => durationValue;
  @override
  int? get currentIndex => currentIndexValue;
  @override
  List<Stream<Object?>> get changeStreams => [changes.stream];

  @override
  Future<void> load(List<String> assetPaths) async {
    loadedAssets = List.unmodifiable(assetPaths);
    currentIndexValue = 0;
    positionValue = Duration.zero;
    completedValue = false;
    loadCalls++;
  }

  @override
  Future<void> play() async {
    playingValue = true;
    changes.add(null);
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    playingValue = false;
    changes.add(null);
  }

  @override
  Future<void> seek(Duration position, {int? index}) async {
    positionValue = position;
    if (index != null) currentIndexValue = index;
    changes.add(null);
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    playingValue = false;
    changes.add(null);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await changes.close();
  }
}
