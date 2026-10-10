import 'dart:async';

import 'package:echo/app/echo_app.dart';
import 'package:echo/controllers/audio_controller.dart';
import 'package:echo/data/lesson_repository.dart';
import 'package:echo/data/models.dart';
import 'package:echo/ui/home_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LessonPackage lesson;
  late LessonPackage lesson2;

  setUpAll(() async {
    lesson = await LessonRepository().loadLesson1();
    lesson2 = await LessonRepository().loadLesson2();
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearTextScaleFactorTestValue();
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearAccessibilityFeaturesTestValue();
  });

  testWidgets('navigation, recherche, filtres et favoris fonctionnent', (
    tester,
  ) async {
    await _pumpEcho(tester, lesson, const Size(390, 844));
    expect(find.text('On se retrouve au café ?'), findsOneWidget);
    expect(find.text('echo'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny), findsOneWidget);

    await tester.tap(find.text('Bibliothèque'));
    await tester.pumpAndSettle();
    expect(find.text('Tes ressources'.toUpperCase()), findsOneWidget);
    expect(find.byIcon(Icons.auto_stories), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'travail');
    await tester.pump();
    expect(find.text('Une rencontre au travail'), findsOneWidget);
    expect(find.text('Dialogue principal'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pump();
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.tap(find.text('Audio'));
    await tester.pump();
    expect(find.text('Une rencontre au travail'), findsNothing);
    expect(find.text('Dialogue principal'), findsOneWidget);

    await tester.tap(find.text('Parcours'));
    await tester.pumpAndSettle();
    expect(find.text('Ton parcours'), findsOneWidget);
    expect(find.text('À venir'), findsNWidgets(9));

    await tester.tap(find.text('Acquis'));
    await tester.pumpAndSettle();
    expect(find.text('Tes acquis'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la leçon 2 ouvre son audio et sa BD depuis le parcours', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      EchoApp(lessons: [lesson, lesson2], audioPlayback: _SilentPlayback()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Parcours'));
    await tester.pumpAndSettle();
    expect(find.text('Disponible'), findsNWidgets(2));

    await tester.ensureVisible(find.text('Saluer et demander des nouvelles'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saluer et demander des nouvelles'));
    await tester.pumpAndSettle();
    expect(find.text('Leçon 2'), findsOneWidget);
    expect(find.text(lesson2.title), findsOneWidget);
    expect(find.text('Leçon audio complète'), findsOneWidget);

    await tester.ensureVisible(find.text('Passer à la lecture'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Passer à la lecture'));
    await tester.pumpAndSettle();
    expect(find.text('UNE JOURNÉE DE SALUTATIONS'), findsOneWidget);
    expect(find.text('Hyvää huomenta.'), findsOneWidget);
    expect(
      find.image(
        const AssetImage(
          'assets/lessons/Suomi/Beginner/Lesson2/art/comic-01-morning.png',
        ),
      ),
      findsOneWidget,
    );

    final scope = tester.widget<EchoScope>(find.byType(EchoScope));
    expect(scope.sessionFor(lesson2.id).started, isTrue);
    expect(scope.sessionController.started, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rendu compact, large, texte à 200 % et mouvement réduit', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(
          disableAnimations: true,
          reduceMotion: true,
        );
    await _pumpEcho(tester, lesson, const Size(320, 800));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
    expect(tester.takeException(), isNull);

    for (final destination in ['Parcours', 'Bibliothèque', 'Acquis']) {
      await tester.tap(find.text(destination).last);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: '$destination à 320 px et texte à 200 %',
      );
    }

    tester.platformDispatcher.textScaleFactorTestValue = 1;
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('SUOMI · A1\nkirjakieli'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('parcours de leçon, correction immédiate et thème sombre', (
    tester,
  ) async {
    final playback = _SilentPlayback();
    await _pumpEcho(
      tester,
      lesson,
      const Size(430, 900),
      audioPlayback: playback,
    );
    await tester.ensureVisible(find.text('Commencer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();
    expect(find.text('Trouvons ton point de départ'), findsOneWidget);
    await tester.ensureVisible(find.text('Je débute, commencer sans test'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Je débute, commencer sans test'));
    await tester.pumpAndSettle();
    expect(find.text('Leçon audio'), findsOneWidget);
    expect(find.textContaining('Partie 1 sur 11'), findsOneWidget);
    expect(find.textContaining('Anna et Mikko'), findsOneWidget);
    expect(find.byTooltip('Écouter'), findsOneWidget);
    expect(playback.loadedAssets, [lesson.fullAudio.assetPath]);
    expect(playback.playingValue, isFalse);
    expect(find.text('Afficher la transcription'), findsNothing);
    expect(find.text('à Helsinki'), findsNothing);
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('à Helsinki'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('à Helsinki'));
    await tester.ensureVisible(find.text('Vérifier'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vérifier'));
    await tester.pump();
    expect(find.textContaining('Pas encore'), findsOneWidget);
    expect(find.textContaining('Indice dans la scène'), findsNothing);

    await tester.tap(find.byTooltip('Changer de thème'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'une bonne réponse audio reste affichée deux secondes puis avance',
    (tester) async {
      await _pumpEcho(tester, lesson, const Size(430, 900));
      final scope = EchoScope.of(tester.element(find.byType(TodayScreen)));
      scope.placementController.skip();
      scope.sessionController.start();
      await tester.pump();
      await tester.ensureVisible(find.text('Reprendre'));
      await tester.tap(find.text('Reprendre'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('à Londres'));
      await tester.pump();
      await tester.tap(find.text('Vérifier'));
      await tester.pump();
      expect(find.textContaining('Bien vu'), findsOneWidget);
      expect(scope.sessionController.activityIndex, 0);
      expect(scope.sessionController.itemIndex, 1);

      await tester.pump(const Duration(milliseconds: 1999));
      expect(scope.sessionController.activityIndex, 0);
      await tester.pump(const Duration(milliseconds: 101));
      expect(scope.sessionController.activityIndex, 1);
      expect(find.text('La scène et les personnages'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'le jeu de rôle donne la consigne en français sans ligne de narrateur',
    (tester) async {
      await _pumpEcho(tester, lesson, const Size(430, 900));
      final scope = EchoScope.of(tester.element(find.byType(TodayScreen)));
      final roleplayIndex = lesson.activities.indexWhere(
        (activity) => activity.type == 'roleplay',
      );
      scope.placementController.skip();
      scope.sessionController.start(activity: roleplayIndex);
      await tester.pump();
      await tester.ensureVisible(find.text('Reprendre'));
      await tester.tap(find.text('Reprendre'));
      await tester.pumpAndSettle();

      expect(find.text('NARRATEUR'), findsNothing);
      scope.sessionController.advance();
      await tester.pumpAndSettle();
      final learnerLine = lesson.roleplayLines[1];
      expect(find.text('À TOI · RÉPONDS EN FINNOIS'), findsOneWidget);
      expect(find.text(learnerLine.translation), findsOneWidget);
      expect(find.text(learnerLine.text), findsNothing);
      expect(find.text('NARRATEUR'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('le premier jeu entraîne un mot finnois sans menus déroulants', (
    tester,
  ) async {
    await _pumpEcho(tester, lesson, const Size(430, 900));
    final scope = EchoScope.of(tester.element(find.byType(TodayScreen)));
    final gamesIndex = lesson.activities.indexWhere(
      (activity) => activity.type == 'adaptive_games',
    );
    scope.placementController.skip();
    scope.sessionController.start(activity: gamesIndex);
    await tester.pump();
    await tester.ensureVisible(find.text('Reprendre'));
    await tester.tap(find.text('Reprendre'));
    await tester.pumpAndSettle();

    expect(find.textContaining('finlandais / finlandaise'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    await tester.enterText(find.byType(TextField), 'suomalainen');
    await tester.ensureVisible(find.text('Vérifier'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vérifier'));
    await tester.pump();
    expect(find.textContaining('Bien vu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'le placement passe les leçons réussies puis recommande la première lacune',
    (tester) async {
      await _pumpEcho(tester, lesson, const Size(390, 844));
      await tester.ensureVisible(find.text('Commencer'));
      await tester.tap(find.text('Commencer'));
      await tester.pumpAndSettle();

      expect(find.text('Trouvons ton point de départ'), findsOneWidget);
      expect(find.text('NOUVEAU PARCOURS'), findsOneWidget);
      await tester.ensureVisible(find.text('Évaluer mon niveau'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Évaluer mon niveau'));
      await tester.pumpAndSettle();

      final firstTest = lesson.placementTests[0];
      final secondTest = lesson.placementTests[1];
      final testedQuestions = [...firstTest.questions, ...secondTest.questions];
      for (var index = 0; index < testedQuestions.length; index++) {
        final question = testedQuestions[index];
        final choiceId = index == 2
            ? question.choices
                  .firstWhere((choice) => choice.id != question.correctChoiceId)
                  .id
            : question.correctChoiceId;
        expect(find.text(question.prompt), findsOneWidget);
        await tester.ensureVisible(
          find.byKey(ValueKey('placement-${question.id}-$choiceId')),
        );
        await tester.tap(
          find.byKey(ValueKey('placement-${question.id}-$choiceId')),
        );
        await tester.pump();
        await tester.ensureVisible(find.text('Continuer'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continuer'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Commence par la leçon 2'), findsOneWidget);
      expect(find.textContaining('1 leçon peut être passée'), findsOneWidget);
      final placement = EchoScope.of(
        tester.element(find.text('Voir mon parcours')),
      ).placementController;
      expect(placement.skippableLessonIds, {firstTest.lessonId});
      expect(placement.recommendedTest?.lessonNumber, 2);

      await tester.ensureVisible(find.text('Voir mon parcours'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Voir mon parcours'));
      await tester.pumpAndSettle();
      expect(find.text('Non nécessaire'), findsOneWidget);

      await tester.tap(find.text(PathScreen.titles.first));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Commencer la leçon'));
      await tester.tap(find.text('Commencer la leçon'));
      await tester.pumpAndSettle();
      expect(find.text('Leçon audio'), findsOneWidget);
      expect(find.text('Partie 1 sur 11'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('le diagnostic reste lisible à 320 px avec le texte à 200 %', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await _pumpEcho(tester, lesson, const Size(320, 800));
    await tester.ensureVisible(find.text('Commencer'));
    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();

    expect(find.text('Trouvons ton point de départ'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Évaluer mon niveau'));
    await tester.tap(find.text('Évaluer mon niveau'));
    await tester.pumpAndSettle();

    expect(find.text(lesson.placementQuestions.first.prompt), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('les 11 parties rendent à 320 px avec un texte à 200 %', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(
          disableAnimations: true,
          reduceMotion: true,
        );
    await _pumpEcho(tester, lesson, const Size(320, 800));
    final scope = EchoScope.of(tester.element(find.byType(TodayScreen)));
    final session = scope.sessionController;
    scope.placementController.skip();
    session.start();
    await tester.pump();
    await tester.ensureVisible(find.text('Reprendre'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reprendre'));
    await tester.pumpAndSettle();

    const titles = <String>[
      'Leçon audio',
      'La scène et les personnages',
      'Deux jeux de rôle',
      'Passer à la lecture',
      'Une rencontre au travail',
      'Comprendre le texte',
      'Memory',
      'Jouer avec la langue',
      'Sofia et Daniel',
      'Ancrer l’essentiel',
      'Ton bilan',
    ];
    for (var index = 0; index < titles.length; index++) {
      session.goToActivity(index);
      await tester.pumpAndSettle();
      expect(find.text(titles[index]), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Partie ${index + 1}');
    }
  });

  testWidgets(
    'la BD lit chaque scène puis attend 5 secondes avant la suivante',
    (tester) async {
      final playback = _SilentPlayback();
      await _pumpEcho(
        tester,
        lesson,
        const Size(430, 900),
        audioPlayback: playback,
      );
      final scope = EchoScope.of(tester.element(find.byType(TodayScreen)));
      final transitionIndex = lesson.activities.indexWhere(
        (activity) => activity.type == 'transition',
      );
      scope.placementController.skip();
      scope.sessionController.start(activity: transitionIndex);
      await tester.pump();
      await tester.ensureVisible(find.text('Reprendre'));
      await tester.tap(find.text('Reprendre'));
      await tester.pumpAndSettle();

      expect(find.text('Passer à la lecture'), findsOneWidget);
      expect(find.text('LA RENCONTRE AU CAFÉ'), findsOneWidget);
      expect(find.text('LECTURE AUTOMATIQUE'), findsOneWidget);
      expect(find.text('Hei. Oletko sinä Anna?'), findsOneWidget);
      expect(
        playback.loadedAssets,
        lesson
            .audioForLines([lesson.openingLines[1], lesson.openingLines[2]])
            .map((audio) => audio.assetPath)
            .toList(),
      );

      playback.complete();
      await tester.pump();
      await tester.pump();
      expect(find.text('PAUSE DE 5 S'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      expect(find.text('Hei. Oletko sinä Anna?'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(find.text('Minun nimeni on Mikko.'), findsOneWidget);
      expect(find.text('LECTURE AUTOMATIQUE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('la lecture annotée ouvre les aides contextuelles', (
    tester,
  ) async {
    await _pumpEcho(tester, lesson, const Size(390, 844));
    final session = EchoScope.of(tester.element(find.byType(TodayScreen)))
        .sessionController;
    final readingIndex = lesson.activities.indexWhere(
      (activity) => activity.type == 'reading',
    );
    session.start(activity: readingIndex);
    await tester.pump();
    await tester.ensureVisible(find.text('Reprendre'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reprendre'));
    await tester.pumpAndSettle();

    expect(find.text('Une rencontre au travail'), findsOneWidget);
    expect(find.byType(ActionChip), findsNothing);
    expect(find.text('Traduire la phrase'), findsNothing);
    final firstSentence = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text
              .toPlainText(includeSemanticsLabels: false)
              .startsWith('Hei! Minun nimeni'),
    );
    expect(firstSentence, findsOneWidget);
    final firstSentenceWidget = tester.widget<RichText>(firstSentence);
    final interactiveSpans = _textSpans(firstSentenceWidget.text)
        .where((span) => span.recognizer != null);
    expect(interactiveSpans, isNotEmpty);
    expect(
      interactiveSpans.every(
        (span) => span.style?.decoration != TextDecoration.underline,
      ),
      isTrue,
    );
    await tester.tapAt(tester.getTopLeft(firstSentence) + const Offset(8, 12));
    await tester.pumpAndSettle();
    expect(find.text('bonjour'), findsOneWidget);
    expect(find.text('PHRASE COMPLÈTE'), findsOneWidget);
    expect(
      find.text('Bonjour ! Je m’appelle Laura. Je suis finlandaise.'),
      findsOneWidget,
    );
    expect(find.text('Voir cette unité'), findsNothing);
    expect(session.attempts.where((event) => event.help != null).length, 2);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('le Memory associe un mot finnois à un dessin', (tester) async {
    await _pumpEcho(tester, lesson, const Size(320, 800));
    final session = EchoScope.of(tester.element(find.byType(TodayScreen)))
        .sessionController;
    final memoryIndex = lesson.activities.indexWhere(
      (activity) => activity.type == 'memory',
    );
    session.start(activity: memoryIndex);
    await tester.pump();
    await tester.ensureVisible(find.text('Reprendre'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('Reprendre'));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Memory'), findsOneWidget);
    expect(find.text('Pratique guidée'), findsNothing);
    expect(find.text('0 paire sur 6'), findsOneWidget);
    expect(find.text('kahvi'), findsNothing);
    expect(
      find.byKey(const ValueKey('memory-animated-echo-logo')),
      findsNWidgets(12),
    );
    final wordCard = find.byKey(const ValueKey('memory-card-memory-sina-word'));
    await tester.ensureVisible(wordCard);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(wordCard);
    await tester.pump();
    expect(find.text('sinä'), findsOneWidget);
    final drawingCard = find.byKey(
      const ValueKey('memory-card-memory-sina-drawing'),
    );
    await tester.ensureVisible(drawingCard);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(drawingCard);
    await tester.pump();
    expect(find.text('1 paire sur 6'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('une évaluation de flashcard passe directement à la suivante', (
    tester,
  ) async {
    await _pumpEcho(tester, lesson, const Size(390, 844));
    final session = EchoScope.of(tester.element(find.byType(TodayScreen)))
        .sessionController;
    final flashcardIndex = lesson.activities.indexWhere(
      (activity) => activity.type == 'selective_flashcards',
    );
    session.start(activity: flashcardIndex);
    await tester.pump();
    await tester.ensureVisible(find.text('Reprendre'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reprendre'));
    await tester.pumpAndSettle();

    expect(find.text('1 / ${lesson.flashcards.length}'), findsOneWidget);
    expect(find.text(lesson.flashcards.first.front), findsOneWidget);
    await tester.tap(find.text(lesson.flashcards.first.front));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Facile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Facile'));
    await tester.pumpAndSettle();

    expect(find.text('2 / ${lesson.flashcards.length}'), findsOneWidget);
    expect(find.text(lesson.flashcards[1].front), findsOneWidget);
    expect(session.itemIndex, 1);
    expect(session.attempts.last.rating, 'easy');

    session.goToActivity(flashcardIndex);
    for (var index = 1; index < lesson.flashcards.length; index++) {
      session.advance();
    }
    await tester.pumpAndSettle();
    expect(
      find.text('${lesson.flashcards.length} / ${lesson.flashcards.length}'),
      findsOneWidget,
    );
    await tester.tap(find.text(lesson.flashcards.last.front));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('À revoir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('À revoir'));
    await tester.pumpAndSettle();

    expect(find.text('Ton bilan'), findsOneWidget);
    expect(session.attempts.last.rating, 'difficult');
    expect(tester.takeException(), isNull);
  });
}

Iterable<TextSpan> _textSpans(InlineSpan root) sync* {
  if (root case final TextSpan span) {
    yield span;
    for (final child in span.children ?? const <InlineSpan>[]) {
      yield* _textSpans(child);
    }
  }
}

Future<void> _pumpEcho(
  WidgetTester tester,
  LessonPackage lesson,
  Size size, {
  AudioPlayback? audioPlayback,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    EchoApp(lesson: lesson, audioPlayback: audioPlayback ?? _SilentPlayback()),
  );
  await tester.pumpAndSettle();
}

class _SilentPlayback implements AudioPlayback {
  final StreamController<Object?> changes =
      StreamController<Object?>.broadcast();
  bool playingValue = false;
  bool completedValue = false;
  Duration positionValue = Duration.zero;
  List<String> loadedAssets = const [];

  @override
  bool get playing => playingValue;
  @override
  bool get completed => completedValue;
  @override
  Duration get position => positionValue;
  @override
  Duration? get duration => const Duration(seconds: 12);
  @override
  int? get currentIndex => 0;
  @override
  List<Stream<Object?>> get changeStreams => [changes.stream];
  @override
  Future<void> load(List<String> assetPaths) async {
    loadedAssets = List.unmodifiable(assetPaths);
    completedValue = false;
    positionValue = Duration.zero;
  }

  @override
  Future<void> play() async {
    playingValue = true;
    completedValue = false;
  }

  @override
  Future<void> pause() async => playingValue = false;
  @override
  Future<void> seek(Duration position, {int? index}) async =>
      positionValue = position;
  @override
  Future<void> stop() async {
    playingValue = false;
    completedValue = false;
  }

  @override
  Future<void> dispose() => changes.close();

  void complete() {
    playingValue = false;
    completedValue = true;
    changes.add(null);
  }
}
