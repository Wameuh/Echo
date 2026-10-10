import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../controllers/app_controller.dart';
import '../controllers/audio_controller.dart';
import '../controllers/placement_controller.dart';
import '../controllers/session_controller.dart';
import '../data/models.dart';
import 'echo_theme.dart';
import 'routes.dart';

class EchoApp extends StatefulWidget {
  const EchoApp({super.key, this.lesson, this.lessons, this.audioPlayback})
    : assert(lesson != null || lessons != null);

  final LessonPackage? lesson;
  final List<LessonPackage>? lessons;
  final AudioPlayback? audioPlayback;

  List<LessonPackage> get availableLessons =>
      lessons ?? <LessonPackage>[lesson!];

  @override
  State<EchoApp> createState() => _EchoAppState();
}

class _EchoAppState extends State<EchoApp> {
  late final AppController appController;
  late final AudioController audioController;
  late final PlacementController placementController;
  late final Map<String, SessionController> sessionControllers;
  late final GoRouter router;

  @override
  void initState() {
    super.initState();
    appController = AppController();
    audioController = AudioController(playback: widget.audioPlayback);
    placementController = PlacementController(
      widget.availableLessons.first.placementTests,
    );
    sessionControllers = {
      for (final lesson in widget.availableLessons)
        lesson.id: SessionController(lesson),
    };
    router = createEchoRouter();
  }

  @override
  void dispose() {
    router.dispose();
    appController.dispose();
    audioController.dispose();
    placementController.dispose();
    for (final controller in sessionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: appController,
    builder: (context, _) => EchoScope(
      lessons: widget.availableLessons,
      appController: appController,
      audioController: audioController,
      placementController: placementController,
      sessionControllers: sessionControllers,
      child: MaterialApp.router(
        title: 'Echo — Finnois débutant',
        debugShowCheckedModeBanner: false,
        theme: echoTheme(Brightness.light),
        darkTheme: echoTheme(Brightness.dark),
        themeMode: appController.themeMode,
        routerConfig: router,
      ),
    ),
  );
}

class EchoScope extends InheritedWidget {
  const EchoScope({
    super.key,
    required this.lessons,
    required this.appController,
    required this.audioController,
    required this.placementController,
    required this.sessionControllers,
    required super.child,
  });

  final List<LessonPackage> lessons;
  final AppController appController;
  final AudioController audioController;
  final PlacementController placementController;
  final Map<String, SessionController> sessionControllers;

  LessonPackage get lesson => lessons.first;
  SessionController get sessionController => sessionFor(lesson.id);

  LessonPackage lessonById(String id) => lessons.firstWhere(
    (lesson) => lesson.id == id,
    orElse: () => throw StateError('Leçon introuvable : $id.'),
  );

  SessionController sessionFor(String lessonId) {
    final controller = sessionControllers[lessonId];
    if (controller == null) {
      throw StateError('Session introuvable : $lessonId.');
    }
    return controller;
  }

  LessonPackage? lessonContainingUnit(String unitId) {
    for (final lesson in lessons) {
      if (lesson.unitById(unitId) != null) return lesson;
    }
    return null;
  }

  static EchoScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<EchoScope>();
    assert(scope != null, 'EchoScope absent de l’arbre.');
    return scope!;
  }

  @override
  bool updateShouldNotify(EchoScope oldWidget) => lessons != oldWidget.lessons;
}
