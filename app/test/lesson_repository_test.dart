import 'package:echo/data/lesson_repository.dart';
import 'package:echo/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LessonPackage lesson;

  setUpAll(() async {
    lesson = await LessonRepository().loadLesson1();
  });

  test('charge les 12 sources et résout les références de la leçon', () {
    expect(lesson.id, 'suomi-beginner-lesson-1');
    expect(lesson.activities, hasLength(11));
    expect(lesson.activities.first.type, 'global_listening');
    expect(
      lesson.activities.indexWhere((activity) => activity.type == 'transition'),
      lessThan(
        lesson.activities.indexWhere((activity) => activity.type == 'reading'),
      ),
    );
    expect(lesson.dialogue, hasLength(137));
    expect(lesson.dialogue.first.text, isNot(contains('serveur')));
    expect(lesson.dialogue.any((line) => line.speaker == 'waiter'), isFalse);
    expect(
      lesson.dialogue.any(
        (line) =>
            line.text.contains('kahvia') || line.text.contains('Haluaisin'),
      ),
      isFalse,
    );
    expect(
      lesson.dialogue.where((line) => line.intent == 'practice_pronunciation'),
      hasLength(10),
    );
    expect(lesson.units, hasLength(21));
    expect(lesson.reading, hasLength(6));
    expect(lesson.memory.pairs, hasLength(6));
    expect(lesson.games, hasLength(6));
    expect(lesson.flashcards, hasLength(11));
    for (final card in lesson.flashcards) {
      expect(card.front, isNot(contains('…')));
      expect(card.back, isNot(contains('…')));
      expect(card.front.trim(), matches(RegExp(r'[.!?]$')));
      expect(card.back.trim(), matches(RegExp(r'[.!?]$')));
      expect(
        card.front.trim().split(RegExp(r'\s+')),
        hasLength(greaterThan(1)),
      );
      expect(card.back.trim().split(RegExp(r'\s+')), hasLength(greaterThan(1)));
    }
    expect(lesson.audioSegmentCount, 143);
    expect(lesson.fullAudio.assetPath, endsWith('Lesson1/audio/full.wav'));
    expect(lesson.fullAudio.duration, greaterThan(Duration.zero));
    expect(
      lesson.audioForLine('line-001').assetPath,
      endsWith('Lesson1/audio/segments/line-001.wav'),
    );
    expect(
      lesson.audioForLine('transfer-line-006').assetPath,
      endsWith('Lesson1/audio/segments/transfer-line-006.wav'),
    );
    expect(
      lesson.audioSegments.values.every(
        (audio) => audio.duration > Duration.zero,
      ),
      isTrue,
    );
    expect(lesson.placementTests, hasLength(10));
    expect(lesson.placementQuestions, hasLength(20));
    expect(
      lesson.placementTests.every((test) => test.questions.length == 2),
      isTrue,
    );
    expect(
      lesson.placementTests.map((test) => test.lessonNumber),
      orderedEquals(List.generate(10, (index) => index + 1)),
    );
    expect(
      lesson.placementTests.where(
        (test) => test.lessonId == 'suomi-beginner-lesson-1',
      ),
      hasLength(1),
    );
    expect(
      lesson.activities.any((activity) => activity.type == 'guided_practice'),
      isFalse,
    );
    expect(
      lesson.activities.any((activity) => activity.type == 'active_recall'),
      isFalse,
    );
    expect(
      lesson.activities.any((activity) => activity.type == 'memory'),
      isTrue,
    );

    final referencedIds = <String>{
      for (final line in [...lesson.dialogue, ...lesson.transferLines])
        ...line.unitIds,
      for (final sentence in lesson.reading)
        for (final token in sentence.tokens)
          if (token.unitId.isNotEmpty) token.unitId,
      for (final pair in lesson.memory.pairs) ...pair.unitIds,
      for (final card in lesson.flashcards) card.unitId,
    };
    for (final id in referencedIds) {
      expect(lesson.unitById(id), isNotNull, reason: 'Référence absente : $id');
    }
  });

  test(
    'répartit les lignes visibles sans exposer le narrateur en jeu de rôle',
    () {
      expect(lesson.openingLines, hasLength(11));
      expect(lesson.activeRecallPairs, hasLength(30));
      expect(lesson.guidedLines, hasLength(48));
      expect(lesson.roleplayLines, hasLength(16));
      expect(lesson.roleplayLines.every((line) => !line.isInstruction), isTrue);

      final ids = <String>{
        ...lesson.openingLines.map((line) => line.id),
        ...lesson.guidedLines.map((line) => line.id),
        ...lesson.activeRecallPairs.expand(
          (pair) => [pair.prompt.id, pair.answer.id],
        ),
        ...lesson.roleplayLines.map((line) => line.id),
      };
      expect(ids, hasLength(135));
    },
  );

  test('valide les réponses canoniques', () {
    expect(lesson.openingQuestions.single.isCorrect('à Londres'), isTrue);
    expect(lesson.openingQuestions.single.isCorrect('un billet'), isFalse);
    expect(lesson.readingQuestions.first.isCorrect('Laura'), isTrue);
    expect(lesson.readingQuestions.last.isCorrect('asun lontoossa'), isTrue);
  });

  test(
    'charge la leçon 2 avec son audio, son histoire et son écriture',
    () async {
      final lesson2 = await LessonRepository().loadLesson2();

      expect(lesson2.id, 'suomi-beginner-lesson-2');
      expect(lesson2.number, 2);
      expect(lesson2.activities, hasLength(12));
      expect(lesson2.activities.first.type, 'global_listening');
      expect(lesson2.activities[1].type, 'context');
      expect(
        lesson2.activities.any(
          (activity) => activity.type == 'opening_comprehension',
        ),
        isFalse,
      );
      expect(
        lesson2.activities.any((activity) => activity.type == 'guided_writing'),
        isTrue,
      );
      expect(lesson2.dialogue, hasLength(106));
      expect(lesson2.units, hasLength(10));
      expect(lesson2.games, hasLength(4));
      expect(lesson2.flashcards, hasLength(10));
      expect(lesson2.audioSegmentCount, 114);
      expect(lesson2.fullAudio.duration, const Duration(milliseconds: 447960));
      expect(lesson2.story?.panels, hasLength(4));
      expect(lesson2.story?.panels.first.image, 'art/comic-01-morning.png');
      expect(lesson2.story?.panels.first.bubbles.single.lineId, 'line-002');
      expect(lesson2.writing?.minimumSentences, 2);
    },
  );

  test('charge les deux paquets dans l’ordre du parcours', () async {
    final lessons = await LessonRepository().loadLessons();

    expect(lessons.map((item) => item.number), orderedEquals([1, 2]));
    expect(lessons.map((item) => item.id).toSet(), hasLength(2));
  });
}
