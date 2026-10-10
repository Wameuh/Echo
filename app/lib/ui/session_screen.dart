import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/echo_app.dart';
import '../app/echo_theme.dart';
import '../app/route_locations.dart';
import '../controllers/audio_controller.dart';
import '../controllers/session_controller.dart';
import '../data/models.dart';
import 'shared.dart';

const _qaMode = bool.fromEnvironment('ECHO_QA_MODE');

class _LessonSessionScope extends InheritedWidget {
  const _LessonSessionScope({
    required this.lesson,
    required this.session,
    required super.child,
  });

  final LessonPackage lesson;
  final SessionController session;

  static _LessonSessionScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_LessonSessionScope>();
    assert(scope != null, 'Session de leçon absente de l’arbre.');
    return scope!;
  }

  @override
  bool updateShouldNotify(_LessonSessionScope oldWidget) =>
      lesson != oldWidget.lesson || session != oldWidget.session;
}

SessionController _sessionOf(BuildContext context) =>
    _LessonSessionScope.of(context).session;

LessonPackage _lessonOf(BuildContext context) =>
    _LessonSessionScope.of(context).lesson;

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  bool _initialized = false;
  final Set<String> _revealed = <String>{};
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final placement = EchoScope.of(context).placementController;
      final session = EchoScope.of(context).sessionFor(widget.lessonId);
      if (!session.started && !placement.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go(PlacementLocation(widget.lessonId).location);
          }
        });
      } else if (!session.started) {
        session.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = EchoScope.of(context);
    final lesson = scope.lessonById(widget.lessonId);
    final session = scope.sessionFor(widget.lessonId);
    return _LessonSessionScope(
      lesson: lesson,
      session: session,
      child: ListenableBuilder(
        listenable: session,
        builder: (context, _) {
          final activity = session.activity;
          return PopScope(
            onPopInvokedWithResult: (didPop, result) =>
                scope.audioController.stop(),
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  tooltip: 'Quitter la leçon',
                  onPressed: () {
                    scope.audioController.stop();
                    context.go(EchoRoute.today.location);
                  },
                  icon: const Icon(Icons.close),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leçon ${lesson.number}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Partie ${session.activityIndex + 1} sur ${lesson.activities.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                actions: [
                  if (_qaMode)
                    PopupMenuButton<int>(
                      tooltip: 'Accès QA aux parties',
                      icon: const Icon(Icons.science_outlined),
                      onSelected: (index) {
                        scope.audioController.stop();
                        session.goToActivity(index);
                        _returnToTop();
                      },
                      itemBuilder: (context) => [
                        for (
                          var index = 0;
                          index < lesson.activities.length;
                          index++
                        )
                          PopupMenuItem(
                            value: index,
                            child: Text(
                              '${index + 1}. ${_activityTitle(lesson.activities[index].type, lesson)}',
                            ),
                          ),
                      ],
                    ),
                  IconButton(
                    tooltip: 'Changer de thème',
                    onPressed: scope.appController.toggleTheme,
                    icon: const Icon(Icons.contrast),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: session.lessonProgress,
                      minHeight: 5,
                      color: EchoColors.clay,
                      backgroundColor: Theme.of(context).dividerColor,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(
                          MediaQuery.sizeOf(context).width < 600 ? 20 : 36,
                          30,
                          MediaQuery.sizeOf(context).width < 600 ? 20 : 36,
                          30,
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 780),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  _activityEyebrow(activity.type).toUpperCase(),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _activityTitle(activity.type, lesson),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _activityIntro(activity.type),
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: .7),
                                      ),
                                ),
                                const SizedBox(height: 28),
                                _activityBody(context, activity.type),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    _SessionFooter(
                      canGoBack:
                          session.activityIndex > 0 || session.itemIndex > 0,
                      last:
                          session.activityIndex == lesson.activities.length - 1,
                      completed: session.completed,
                      onBack: () {
                        scope.audioController.stop();
                        session.retreat();
                        _returnToTop();
                      },
                      onNext: () {
                        scope.audioController.stop();
                        if (session.activityIndex ==
                            lesson.activities.length - 1) {
                          session.advance();
                          context.go(EchoRoute.progress.location);
                        } else {
                          session.advance();
                          _returnToTop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _returnToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
  }

  Widget _activityBody(BuildContext context, String type) {
    final lesson = _lessonOf(context);
    final session = _sessionOf(context);
    return switch (type) {
      'context' => _ContextActivity(lesson: lesson),
      'global_listening' => _GlobalListening(
        lesson: lesson,
        question:
            lesson.openingQuestions[session.itemIndex == 0
                ? 0
                : session.itemIndex - 1],
        questionPage: session.itemIndex > 0,
      ),
      'active_recall' => _RecallActivity(
        pair: lesson.activeRecallPairs[session.itemIndex],
        index: session.itemIndex,
        total: lesson.activeRecallPairs.length,
        revealed: _revealed.contains(
          lesson.activeRecallPairs[session.itemIndex].answer.id,
        ),
        onReveal: () {
          final pair = lesson.activeRecallPairs[session.itemIndex];
          setState(() => _revealed.add(pair.answer.id));
          session.recordHelp('reveal_model', pair.answer.unitIds);
        },
      ),
      'roleplay' => _RoleplayActivity(
        line: lesson.roleplayLines[session.itemIndex],
        index: session.itemIndex,
        total: lesson.roleplayLines.length,
      ),
      'transition' => _ReadingComicActivity(lesson: lesson),
      'reading' => _ReadingActivity(sentences: lesson.reading),
      'reading_comprehension' => QuestionCard(
        key: ValueKey(lesson.readingQuestions[session.itemIndex].id),
        question: lesson.readingQuestions[session.itemIndex],
        counter: '${session.itemIndex + 1} / ${lesson.readingQuestions.length}',
      ),
      'memory' => MemoryActivity(
        key: ValueKey(lesson.memory.id),
        memory: lesson.memory,
      ),
      'adaptive_games' => GameCard(
        key: ValueKey(lesson.games[session.itemIndex].id),
        game: lesson.games[session.itemIndex],
        counter: '${session.itemIndex + 1} / ${lesson.games.length}',
      ),
      'audio_transfer' => _TransferActivity(
        audio: lesson.audioForLines(lesson.transferLines),
        question: session.itemIndex == 0
            ? null
            : lesson.transferQuestions[session.itemIndex - 1],
        questionIndex: session.itemIndex,
        questionTotal: lesson.transferQuestions.length,
      ),
      'guided_writing' => _GuidedWritingActivity(
        key: ValueKey(lesson.writing?.id),
        writing: lesson.writing!,
      ),
      'selective_flashcards' => _FlashcardActivity(
        card: lesson.flashcards[session.itemIndex],
        audio: lesson.audioExampleForUnit(
          lesson.flashcards[session.itemIndex].unitId,
        ),
        index: session.itemIndex,
        total: lesson.flashcards.length,
        revealed: _revealed.contains(lesson.flashcards[session.itemIndex].id),
        onReveal: () => setState(
          () => _revealed.add(lesson.flashcards[session.itemIndex].id),
        ),
        onAssess: (rating) {
          final card = lesson.flashcards[session.itemIndex];
          session.assess([card.unitId], rating);
          session.advance();
          _returnToTop();
        },
      ),
      'summary_and_spacing' => const _SummaryActivity(),
      _ => const Text('Cette partie est indisponible.'),
    };
  }
}

class _SessionFooter extends StatelessWidget {
  const _SessionFooter({
    required this.canGoBack,
    required this.last,
    required this.completed,
    required this.onBack,
    required this.onNext,
  });

  final bool canGoBack;
  final bool last;
  final bool completed;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final iconsOnly =
            constraints.maxWidth < 380 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.4;
        return Row(
          children: [
            if (iconsOnly)
              Tooltip(
                message: 'Précédent',
                child: OutlinedButton(
                  onPressed: canGoBack ? onBack : null,
                  child: const Icon(Icons.arrow_back),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: canGoBack ? onBack : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Précédent'),
              ),
            const Spacer(),
            if (iconsOnly)
              Tooltip(
                message: last ? 'Voir mes acquis' : 'Suivant',
                child: FilledButton(
                  onPressed: completed ? null : onNext,
                  child: Icon(
                    last ? Icons.celebration_outlined : Icons.arrow_forward,
                  ),
                ),
              )
            else
              FilledButton.icon(
                onPressed: completed ? null : onNext,
                iconAlignment: IconAlignment.end,
                icon: Icon(
                  last ? Icons.celebration_outlined : Icons.arrow_forward,
                ),
                label: Text(last ? 'Voir mes acquis' : 'Suivant'),
              ),
          ],
        );
      },
    ),
  );
}

class _ContextActivity extends StatelessWidget {
  const _ContextActivity({required this.lesson});
  final LessonPackage lesson;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      EchoCard(
        color: EchoColors.pine,
        editorial: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WaveDecoration(color: EchoColors.lichen),
            const SizedBox(height: 20),
            Text(
              lesson.number == 1
                  ? 'Anna arrive dans un café à Helsinki.'
                  : lesson.title,
              style: Theme.of(context).textTheme.headlineLarge
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              lesson.number == 1
                  ? 'Mikko l’accueille. Ils font connaissance et parlent de leur pays, de leur ville et de leur travail.'
                  : lesson.objectives.first,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 17,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          EchoBadge(label: '2 personnages'),
          const EchoBadge(label: 'Helsinki'),
          EchoBadge(label: 'Leçon ${lesson.number}'),
        ],
      ),
    ],
  );
}

class _ReadingComicActivity extends StatefulWidget {
  const _ReadingComicActivity({required this.lesson});
  final LessonPackage lesson;

  @override
  State<_ReadingComicActivity> createState() => _ReadingComicActivityState();
}

class _ReadingComicActivityState extends State<_ReadingComicActivity> {
  static const _pauseBetweenPanels = Duration(seconds: 5);

  final Set<int> _translations = {};
  AudioController? _audioController;
  Timer? _advanceTimer;
  int _panel = 0;
  int? _handledCompletionPanel;
  bool _initialPlaybackScheduled = false;
  bool _autoReading = true;
  bool _waitingForNextPanel = false;
  bool _sequenceComplete = false;

  DialogueLine _line(String id) =>
      widget.lesson.openingLines.firstWhere((line) => line.id == id);

  List<_ComicBeat> get _beats => widget.lesson.story!.panels
      .map(
        (panel) => _ComicBeat(
          asset: '${widget.lesson.assetRoot}/${panel.image}',
          caption: panel.caption,
          imageLabel: panel.imageLabel,
          lines: panel.bubbles
              .map((bubble) => _line(bubble.lineId))
              .toList(growable: false),
        ),
      )
      .toList(growable: false);

  List<LessonAudio> get _currentAudio =>
      widget.lesson.audioForLines(_beats[_panel].lines);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextController = EchoScope.of(context).audioController;
    if (!identical(_audioController, nextController)) {
      _audioController?.removeListener(_handleAudioChange);
      _audioController = nextController..addListener(_handleAudioChange);
    }
    if (!_initialPlaybackScheduled) {
      _initialPlaybackScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_playCurrentPanel());
      });
    }
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _audioController?.removeListener(_handleAudioChange);
    super.dispose();
  }

  void _handleAudioChange() {
    final controller = _audioController;
    if (!_autoReading ||
        controller == null ||
        _handledCompletionPanel == _panel ||
        !controller.isActive(_currentAudio) ||
        !controller.completed) {
      return;
    }

    _handledCompletionPanel = _panel;
    if (_panel == _beats.length - 1) {
      if (mounted) {
        setState(() {
          _autoReading = false;
          _waitingForNextPanel = false;
          _sequenceComplete = true;
        });
      }
      return;
    }

    if (mounted) setState(() => _waitingForNextPanel = true);
    _advanceTimer?.cancel();
    _advanceTimer = Timer(_pauseBetweenPanels, () {
      if (!mounted || !_autoReading) return;
      setState(() {
        _panel += 1;
        _waitingForNextPanel = false;
        _handledCompletionPanel = null;
      });
      unawaited(_playCurrentPanel());
    });
  }

  Future<void> _playCurrentPanel() async {
    final controller = _audioController;
    if (!mounted || !_autoReading || controller == null) return;
    _advanceTimer?.cancel();
    setState(() {
      _waitingForNextPanel = false;
      _sequenceComplete = false;
      _handledCompletionPanel = null;
    });
    try {
      await controller.play(_currentAudio);
    } catch (_) {
      if (!mounted) return;
      setState(() => _autoReading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Le navigateur a bloqué le démarrage automatique. Appuie sur « Démarrer la lecture ».',
          ),
        ),
      );
    }
  }

  void _showPanel(int panel) {
    if (panel < 0 || panel >= _beats.length || panel == _panel) return;
    _advanceTimer?.cancel();
    setState(() {
      _panel = panel;
      _autoReading = true;
      _waitingForNextPanel = false;
      _sequenceComplete = false;
      _handledCompletionPanel = null;
    });
    unawaited(_playCurrentPanel());
  }

  void _toggleAutoReading() {
    final controller = _audioController;
    if (_autoReading) {
      _advanceTimer?.cancel();
      setState(() {
        _autoReading = false;
        _waitingForNextPanel = false;
      });
      if (controller != null) unawaited(controller.pause());
      return;
    }

    setState(() {
      if (_sequenceComplete) _panel = 0;
      _autoReading = true;
      _sequenceComplete = false;
      _handledCompletionPanel = null;
    });
    unawaited(_playCurrentPanel());
  }

  @override
  Widget build(BuildContext context) {
    final beats = _beats;
    final beat = beats[_panel];
    final translationsVisible = _translations.contains(_panel);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            EchoBadge(
              label: widget.lesson.story!.title.toUpperCase(),
              color: EchoColors.lichen,
            ),
            const EchoBadge(label: 'HISTOIRE EN BD'),
            EchoBadge(
              label: _sequenceComplete
                  ? 'LECTURE TERMINÉE'
                  : _waitingForNextPanel
                  ? 'PAUSE DE 5 S'
                  : _autoReading
                  ? 'LECTURE AUTOMATIQUE'
                  : 'LECTURE EN PAUSE',
              color: _autoReading ? EchoColors.sky : EchoColors.clay,
            ),
          ],
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 240),
          child: EchoCard(
            key: ValueKey(_panel),
            padding: EdgeInsets.zero,
            editorial: true,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ComicScene(
                    beat: beat,
                    panel: _panel,
                    panelCount: beats.length,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          beat.caption,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 18),
                        if (translationsVisible) ...[
                          _ComicTranslation(lines: beat.lines),
                          const SizedBox(height: 10),
                        ],
                        AudioPlayerCard(
                          audio: widget.lesson.audioForLines(beat.lines),
                          compact: true,
                          label: 'Écouter cette scène',
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            key: ValueKey('comic-translation-$_panel'),
                            onPressed: () => setState(() {
                              if (translationsVisible) {
                                _translations.remove(_panel);
                              } else {
                                _translations.add(_panel);
                              }
                            }),
                            icon: Icon(
                              translationsVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.translate,
                            ),
                            label: Text(
                              translationsVisible
                                  ? 'Masquer la traduction'
                                  : 'Voir la traduction',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            IconButton.outlined(
              tooltip: 'Case précédente',
              onPressed: _panel == 0 ? null : () => _showPanel(_panel - 1),
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: Semantics(
                label: 'Case ${_panel + 1} sur ${beats.length}',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var index = 0; index < beats.length; index++)
                      AnimatedContainer(
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 180),
                        width: index == _panel ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: index == _panel
                              ? EchoColors.clay
                              : Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            IconButton.filled(
              tooltip: 'Case suivante',
              onPressed: _panel == beats.length - 1
                  ? null
                  : () => _showPanel(_panel + 1),
              icon: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          key: const ValueKey('comic-auto-reading-toggle'),
          onPressed: _toggleAutoReading,
          icon: Icon(
            _autoReading
                ? Icons.pause_circle_outline
                : Icons.play_circle_outline,
          ),
          label: Text(
            _autoReading
                ? _waitingForNextPanel
                      ? 'Interrompre la pause'
                      : 'Suspendre la lecture automatique'
                : _sequenceComplete
                ? 'Rejouer la BD'
                : 'Démarrer la lecture automatique',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Après chaque scène, la suivante démarre automatiquement après 5 secondes. Les traductions restent cachées tant que tu ne les demandes pas.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ComicBeat {
  const _ComicBeat({
    required this.asset,
    required this.caption,
    required this.imageLabel,
    required this.lines,
  });

  final String asset;
  final String caption;
  final String imageLabel;
  final List<DialogueLine> lines;
}

class _ComicScene extends StatelessWidget {
  const _ComicScene({
    required this.beat,
    required this.panel,
    required this.panelCount,
  });

  final _ComicBeat beat;
  final int panel;
  final int panelCount;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.maxWidth;
      final accessibleLayout = MediaQuery.textScalerOf(context).scale(1) > 1.3;
      final image = Semantics(
        image: true,
        label: beat.imageLabel,
        child: ExcludeSemantics(
          child: Image.asset(
            beat.asset,
            width: size,
            height: size,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
      );
      if (accessibleLayout) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(aspectRatio: 1, child: image),
            ColoredBox(
              color: EchoColors.oat,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                child: Column(
                  children: [
                    for (final line in beat.lines) ...[
                      _ComicBubble(line: line),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }
      return SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            for (var index = 0; index < beat.lines.length; index++)
              _PositionedComicBubble(
                line: beat.lines[index],
                index: index,
                total: beat.lines.length,
              ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: EchoColors.paper.withValues(alpha: .94),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${panel + 1} / $panelCount',
                  style: const TextStyle(
                    color: EchoColors.pine,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _PositionedComicBubble extends StatelessWidget {
  const _PositionedComicBubble({
    required this.line,
    required this.index,
    required this.total,
  });

  final DialogueLine line;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final anna = line.speaker == 'anna';
    final edge = 12.0;
    final double? top;
    final double? bottom;
    if (total == 3 && index == 1) {
      top = null;
      bottom = 105;
    } else if (index == 0) {
      top = 54;
      bottom = null;
    } else {
      top = null;
      bottom = 14;
    }
    return Positioned(
      top: top,
      bottom: bottom,
      left: anna ? edge : null,
      right: anna ? null : edge,
      width: MediaQuery.sizeOf(context).width < 380 ? 230 : 280,
      child: _ComicBubble(line: line, compact: true),
    );
  }
}

class _ComicBubble extends StatelessWidget {
  const _ComicBubble({required this.line, this.compact = false});

  final DialogueLine line;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final anna = line.speaker == 'anna';
    final foreground = anna
        ? Theme.of(context).colorScheme.onSurface
        : Colors.white;
    return Align(
      alignment: anna ? Alignment.centerLeft : Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: compact ? 1 : .9,
        child: Semantics(
          label: '${_speaker(line.speaker)}, ${line.text}',
          child: Container(
            padding: compact
                ? const EdgeInsets.fromLTRB(13, 10, 13, 11)
                : const EdgeInsets.fromLTRB(16, 13, 16, 14),
            decoration: BoxDecoration(
              color: compact
                  ? EchoColors.paper.withValues(alpha: .96)
                  : anna
                  ? EchoColors.clay.withValues(alpha: .14)
                  : EchoColors.pine,
              border: compact
                  ? Border.all(color: EchoColors.pine, width: 2)
                  : null,
              boxShadow: compact
                  ? const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : null,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(anna ? 5 : 20),
                bottomRight: Radius.circular(anna ? 20 : 5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _speaker(line.speaker),
                  style: TextStyle(
                    color: compact
                        ? anna
                              ? EchoColors.clay
                              : EchoColors.pine
                        : anna
                        ? EchoColors.clay
                        : EchoColors.lichen,
                    fontSize: compact ? 9 : 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  line.text,
                  style:
                      (compact
                              ? Theme.of(context).textTheme.titleMedium
                              : Theme.of(context).textTheme.titleLarge)
                          ?.copyWith(
                            color: compact ? EchoColors.ink : foreground,
                            fontFamily: 'Newsreader',
                            height: 1.05,
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComicTranslation extends StatelessWidget {
  const _ComicTranslation({required this.lines});

  final List<DialogueLine> lines;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: EchoColors.sky.withValues(alpha: .2),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < lines.length; index++) ...[
          Text(
            '${_speaker(lines[index].speaker)} · ${lines[index].translation}',
          ),
          if (index != lines.length - 1) const SizedBox(height: 8),
        ],
      ],
    ),
  );
}

class _GlobalListening extends StatelessWidget {
  const _GlobalListening({
    required this.lesson,
    required this.question,
    required this.questionPage,
  });
  final LessonPackage lesson;
  final LessonQuestion question;
  final bool questionPage;

  @override
  Widget build(BuildContext context) {
    if (!questionPage) {
      return _AudioOnlyActivity(
        audio: [lesson.fullAudio],
        playerLabel: 'Piste complète',
        instruction: lesson.number == 1
            ? 'Tu entendras Anna et Mikko. Laisse la piste te guider, réponds et répète à voix haute pendant les pauses.'
            : 'Laisse la piste te guider. Réponds et répète à voix haute pendant les pauses, puis écoute les modèles.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EchoBadge(label: 'APRÈS L’ÉCOUTE', color: EchoColors.sky),
        const SizedBox(height: 14),
        QuestionCard(
          key: ValueKey(question.id),
          question: question,
          autoAdvanceOnCorrect: true,
        ),
      ],
    );
  }
}

class _AudioOnlyActivity extends StatelessWidget {
  const _AudioOnlyActivity({
    required this.audio,
    required this.playerLabel,
    required this.instruction,
  });

  final List<LessonAudio> audio;
  final String playerLabel;
  final String instruction;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AudioPlayerCard(audio: audio, label: playerLabel, preload: true),
      const SizedBox(height: 18),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.hearing_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(instruction)),
        ],
      ),
    ],
  );
}

class _RecallActivity extends StatelessWidget {
  const _RecallActivity({
    required this.pair,
    required this.index,
    required this.total,
    required this.revealed,
    required this.onReveal,
  });
  final RecallPair pair;
  final int index;
  final int total;
  final bool revealed;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final session = _sessionOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Counter(value: '${index + 1} / $total'),
        const SizedBox(height: 12),
        EchoCard(
          color: Theme.of(context).brightness == Brightness.dark
              ? EchoColors.nightCard
              : EchoColors.lichen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'À TOI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                pair.prompt.text,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              if (!revealed)
                FilledButton.tonalIcon(
                  onPressed: onReveal,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Voir le modèle'),
                ),
              if (revealed) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  pair.answer.text,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (pair.answer.translation.isNotEmpty)
                  Text(pair.answer.translation),
                const SizedBox(height: 14),
                AudioPlayerCard(
                  audio: [
                    EchoScope.of(context).lesson.audioForLine(pair.answer.id),
                  ],
                  compact: true,
                  label: 'Écouter le modèle',
                ),
              ],
            ],
          ),
        ),
        if (revealed) ...[
          const SizedBox(height: 18),
          const Text(
            'Comment c’était ?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in const [
                ('forgotten', 'Oublié'),
                ('difficult', 'Difficile'),
                ('hesitant', 'Hésitant'),
                ('easy', 'Facile'),
              ])
                ActionChip(
                  label: Text(entry.$2),
                  onPressed: () =>
                      session.assess(pair.answer.unitIds, entry.$1),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _RoleplayActivity extends StatelessWidget {
  const _RoleplayActivity({
    required this.line,
    required this.index,
    required this.total,
  });
  final DialogueLine line;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final role = line.section.contains('mikko') ? 2 : 1;
    final learnerSpeaker = role == 1 ? 'anna' : 'mikko';
    final learnerTurn = line.speaker == learnerSpeaker;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            EchoBadge(
              label: 'JEU DE RÔLE $role',
              color: role == 1 ? EchoColors.sky : EchoColors.lichen,
            ),
            _Counter(value: '${index + 1} / $total'),
          ],
        ),
        const SizedBox(height: 14),
        EchoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                learnerTurn
                    ? 'À TOI · RÉPONDS EN FINNOIS'
                    : _speaker(line.speaker),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                learnerTurn ? line.translation : line.text,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (!learnerTurn &&
                  line.translation.isNotEmpty &&
                  line.translation != line.text) ...[
                const SizedBox(height: 8),
                Text(line.translation),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        AudioPlayerCard(
          audio: [EchoScope.of(context).lesson.audioForLine(line.id)],
          compact: true,
          label: learnerTurn ? 'Écouter le modèle' : 'Écouter cette réplique',
        ),
        const SizedBox(height: 12),
        Text(
          learnerTurn
              ? 'Dis cette réponse en finnois, puis écoute le modèle si nécessaire. Ta voix n’est ni enregistrée ni évaluée.'
              : 'Écoute ton interlocuteur, puis prépare ta réponse en finnois.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ReadingActivity extends StatefulWidget {
  const _ReadingActivity({required this.sentences});
  final List<ReadingSentence> sentences;

  @override
  State<_ReadingActivity> createState() => _ReadingActivityState();
}

class _ReadingActivityState extends State<_ReadingActivity> {
  final Map<String, TapGestureRecognizer> _recognizers =
      <String, TapGestureRecognizer>{};

  @override
  void dispose() {
    for (final recognizer in _recognizers.values) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      EchoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Touche directement un mot pour afficher sa traduction.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            for (var index = 0; index < widget.sentences.length; index++) ...[
              if (index > 0) const SizedBox(height: 22),
              Text(
                _speaker(widget.sentences[index].speaker),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 7),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                  children: _annotatedTextSpans(widget.sentences[index]),
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );

  List<InlineSpan> _annotatedTextSpans(ReadingSentence sentence) {
    final spans = <InlineSpan>[];
    final tokens = [...sentence.tokens]
      ..sort((a, b) => a.start.compareTo(b.start));
    var cursor = 0;
    for (final token in tokens) {
      if (token.start > cursor) {
        spans.add(TextSpan(text: sentence.text.substring(cursor, token.start)));
      }
      final recognizer = _recognizers.putIfAbsent(
        '${sentence.id}:${token.start}',
        () =>
            TapGestureRecognizer()
              ..onTap = () => _showToken(context, sentence, token),
      );
      spans.add(
        TextSpan(
          text: sentence.text.substring(token.start, token.end),
          semanticsLabel: 'Traduire ${token.surface}',
          recognizer: recognizer,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      cursor = token.end;
    }
    if (cursor < sentence.text.length) {
      spans.add(TextSpan(text: sentence.text.substring(cursor)));
    }
    return spans;
  }

  void _showToken(
    BuildContext context,
    ReadingSentence sentence,
    ReadingToken token,
  ) {
    _sessionOf(context).recordHelp('word_translation', [
      if (token.unitId.isNotEmpty) token.unitId,
    ]);
    _sessionOf(context).recordHelp('sentence_translation', [
      for (final item in sentence.tokens)
        if (item.unitId.isNotEmpty) item.unitId,
    ]);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        token.surface,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fermer',
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Text(
                  token.translation,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (token.lemma.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Forme de base : ${token.lemma}'),
                ],
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 14),
                const Text(
                  'PHRASE COMPLÈTE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(sentence.text),
                const SizedBox(height: 6),
                Text(
                  sentence.translation,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuestionCard extends StatefulWidget {
  const QuestionCard({
    super.key,
    required this.question,
    this.counter,
    this.autoAdvanceOnCorrect = false,
  });
  final LessonQuestion question;
  final String? counter;
  final bool autoAdvanceOnCorrect;

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  final TextEditingController textController = TextEditingController();
  Timer? _advanceTimer;
  String? selected;
  bool? correct;

  @override
  void dispose() {
    _advanceTimer?.cancel();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    return EchoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.counter != null)
            Align(
              alignment: Alignment.centerRight,
              child: _Counter(value: widget.counter!),
            ),
          Text(
            question.prompt,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 18),
          if (question.choices.isNotEmpty)
            ...question.choices.map(
              (choice) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: OutlinedButton(
                  onPressed: correct == null
                      ? () => setState(() => selected = choice.text)
                      : null,
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    backgroundColor: selected == choice.text
                        ? Theme.of(context).colorScheme.primary
                              .withValues(alpha: .12)
                        : null,
                  ),
                  child: Text(choice.text),
                ),
              ),
            )
          else
            TextField(
              controller: textController,
              enabled: correct == null,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(hintText: 'Écris ta réponse…'),
              onSubmitted: (_) => _validate(),
            ),
          const SizedBox(height: 12),
          if (correct == null)
            FilledButton(
              onPressed: (selected != null || question.choices.isEmpty)
                  ? _validate
                  : null,
              child: const Text('Vérifier'),
            ),
          if (correct != null)
            _Feedback(correct: correct!, answer: question.answerLabel),
        ],
      ),
    );
  }

  void _validate() {
    final answer = selected ?? textController.text;
    if (answer.trim().isEmpty) return;
    final result = widget.question.isCorrect(answer);
    _sessionOf(context)
        .recordAnswer(widget.question.id, answer, correct: result);
    setState(() => correct = result);
    if (result && widget.autoAdvanceOnCorrect) {
      _advanceTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) _sessionOf(context).advance();
      });
    }
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.correct, required this.answer});
  final bool correct;
  final String answer;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: correct
          ? EchoColors.lichen
          : EchoColors.clay.withValues(alpha: .24),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          correct ? Icons.check_circle : Icons.refresh,
          color: EchoColors.pine,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            correct
                ? 'Bien vu. Tu peux continuer.'
                : 'Pas encore. Réponse attendue : $answer',
            style: const TextStyle(
              color: EchoColors.pine,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class MemoryActivity extends StatefulWidget {
  const MemoryActivity({super.key, required this.memory});

  final LessonMemory memory;

  @override
  State<MemoryActivity> createState() => _MemoryActivityState();
}

class _MemoryActivityState extends State<MemoryActivity>
    with SingleTickerProviderStateMixin {
  late final List<_MemoryTile> _tiles;
  late final AnimationController _logoController;
  final List<int> _open = <int>[];
  final Set<String> _matched = <String>{};
  bool? _reduceMotion;
  var _locked = false;
  var _attempt = 0;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _tiles = [
      for (final pair in widget.memory.pairs) ...[
        _MemoryTile(pair: pair, wordSide: true),
        _MemoryTile(pair: pair, wordSide: false),
      ],
    ]..shuffle(Random(11));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _logoController
        ..stop()
        ..value = .22;
    } else {
      _logoController.repeat();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => EchoCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.grid_view_rounded),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${_matched.length} paire${_matched.length > 1 ? 's' : ''} sur ${widget.memory.pairs.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final columns = textScale > 1.4
                ? 1
                : constraints.maxWidth >= 680
                ? 3
                : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tiles.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: textScale > 1.4 ? 190 : 172,
              ),
              itemBuilder: (context, index) {
                final tile = _tiles[index];
                final visible =
                    _open.contains(index) || _matched.contains(tile.pair.id);
                return _MemoryCard(
                  key: ValueKey(
                    'memory-card-${tile.pair.id}-${tile.wordSide ? 'word' : 'drawing'}',
                  ),
                  tile: tile,
                  visible: visible,
                  matched: _matched.contains(tile.pair.id),
                  logoAnimation: _logoController,
                  onTap: () => _turn(index),
                );
              },
            );
          },
        ),
        if (_matched.length == widget.memory.pairs.length) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: EchoColors.lichen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: EchoColors.pine),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Toutes les paires sont réunies.',
                    style: TextStyle(
                      color: EchoColors.pine,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );

  Future<void> _turn(int index) async {
    if (_locked ||
        _open.contains(index) ||
        _matched.contains(_tiles[index].pair.id)) {
      return;
    }
    setState(() => _open.add(index));
    if (_open.length < 2) return;

    final first = _tiles[_open.first];
    final second = _tiles[_open.last];
    final match = first.pair.id == second.pair.id;
    final unitIds = <String>{...first.pair.unitIds, ...second.pair.unitIds};
    _attempt++;
    _sessionOf(context).recordAnswer(
      'memory-attempt-$_attempt',
      match ? first.pair.id : 'different-pairs',
      correct: match,
      unitIds: unitIds,
    );

    if (match) {
      setState(() {
        _matched.add(first.pair.id);
        _open.clear();
      });
      return;
    }

    setState(() => _locked = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _open.clear();
      _locked = false;
    });
  }
}

class _MemoryTile {
  const _MemoryTile({required this.pair, required this.wordSide});

  final MemoryPair pair;
  final bool wordSide;
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    super.key,
    required this.tile,
    required this.visible,
    required this.matched,
    required this.logoAnimation,
    required this.onTap,
  });

  final _MemoryTile tile;
  final bool visible;
  final bool matched;
  final Animation<double> logoAnimation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final background = matched
        ? EchoColors.lichen
        : visible
        ? tile.wordSide
              ? Theme.of(context).colorScheme.surface
              : EchoColors.sky
        : EchoColors.pine;
    return Semantics(
      button: true,
      label: visible
          ? tile.wordSide
                ? 'Mot finnois : ${tile.pair.word}'
                : 'Dessin : ${tile.pair.illustrationLabel}'
          : 'Carte cachée',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: visible && !matched
                    ? EchoColors.pine.withValues(alpha: .22)
                    : Colors.transparent,
              ),
            ),
            child: Center(
              child: visible
                  ? tile.wordSide
                        ? FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              tile.pair.word,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: EchoColors.pine,
                                fontFamily: 'Newsreader',
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                          )
                        : Icon(
                            _memoryIcon(tile.pair.illustration),
                            color: EchoColors.pine,
                            size: 56,
                          )
                  : ExcludeSemantics(
                      child: _AnimatedEchoMemoryLogo(animation: logoAnimation),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedEchoMemoryLogo extends StatelessWidget {
  const _AnimatedEchoMemoryLogo({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(
        key: const ValueKey('memory-animated-echo-logo'),
        width: 58,
        height: 42,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) =>
              CustomPaint(painter: _EchoVoiceprintPainter(animation.value)),
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'echo',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'DM Sans',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -.4,
        ),
      ),
    ],
  );
}

class _EchoVoiceprintPainter extends CustomPainter {
  const _EchoVoiceprintPainter(this.progress);

  final double progress;

  static const _baseHeights = <double>[16, 27, 37, 31, 24, 15];

  @override
  void paint(Canvas canvas, Size size) {
    const barWidth = 4.5;
    const gap = 3.2;
    const dotGap = 5.2;
    const dotRadius = 3.2;
    final markWidth =
        (_baseHeights.length * barWidth) +
        ((_baseHeights.length - 1) * gap) +
        dotGap +
        (dotRadius * 2);
    var x = (size.width - markWidth) / 2;
    final centerY = size.height / 2;
    final barPaint = Paint()..color = EchoColors.lichen;

    for (var index = 0; index < _baseHeights.length; index++) {
      final wave = (sin((progress * 2 * pi) + (index * .82)) + 1) / 2;
      final height = _baseHeights[index] * (.68 + (.32 * wave));
      final rect = Rect.fromLTWH(x, centerY - (height / 2), barWidth, height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(barWidth)),
        barPaint,
      );
      x += barWidth + gap;
    }

    final pulse = sin(progress * 2 * pi) * .35;
    canvas.drawCircle(
      Offset(x - gap + dotGap + dotRadius, centerY),
      dotRadius + pulse,
      Paint()..color = EchoColors.clay,
    );
  }

  @override
  bool shouldRepaint(covariant _EchoVoiceprintPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

IconData _memoryIcon(String illustration) => switch (illustration) {
  'wave' => Icons.waving_hand_outlined,
  'coffee' => Icons.local_cafe_outlined,
  'cafe' => Icons.storefront_outlined,
  'city' => Icons.location_city_outlined,
  'work' => Icons.business_center_outlined,
  'thanks' => Icons.volunteer_activism_outlined,
  'person' => Icons.person_outline,
  'name' => Icons.badge_outlined,
  _ => Icons.image_outlined,
};

class GameCard extends StatefulWidget {
  const GameCard({super.key, required this.game, required this.counter});
  final LessonGame game;
  final String counter;

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  final Map<String, String> selections = <String, String>{};
  final List<String> ordered = <String>[];
  final List<String> wordGuesses = <String>[];
  final TextEditingController wordGuessController = TextEditingController();
  String? selected;
  bool? correct;

  @override
  void dispose() {
    wordGuessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EchoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: _Counter(value: widget.counter),
          ),
          Text(
            widget.game.instruction,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 18),
          if (widget.game.type == 'audio_discrimination') ...[
            AudioPlayerCard(
              audio: [
                EchoScope.of(context).lesson.audioForLine(
                  List<String>.from(
                    (widget.game.raw['audio'] as Map)['required_segment_ids']
                        as List,
                  ).first,
                ),
              ],
              compact: true,
              label: 'Phrase à reconnaître',
            ),
            const SizedBox(height: 8),
            Text(
              'Écoute puis choisis la phrase entendue.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
          ],
          _gameBody(context),
          const SizedBox(height: 16),
          if (correct == null)
            FilledButton(
              onPressed: _canValidate ? _validate : null,
              child: const Text('Vérifier'),
            ),
          if (correct != null) ...[
            _Feedback(correct: correct!, answer: _answerLabel),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.replay),
              label: const Text('Recommencer'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _gameBody(BuildContext context) {
    final raw = widget.game.raw;
    switch (widget.game.type) {
      case 'matching_groups':
        final groups = (raw['groups'] as List).cast<Map>();
        final nations = [
          for (final group in groups)
            (group['items'] as List)[1]['text'] as String,
        ];
        final cities = [
          for (final group in groups)
            (group['items'] as List)[2]['text'] as String,
        ];
        return Column(
          children: [
            for (final group in groups)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      (group['items'] as List)[0]['text'] as String,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _DropChoice(
                            value: selections['${group['id']}:nation'],
                            hint: 'Nationalité',
                            values: nations,
                            onChanged: (value) => setState(
                              () => selections['${group['id']}:nation'] = value,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _DropChoice(
                            value: selections['${group['id']}:city'],
                            hint: 'Ville',
                            values: cities,
                            onChanged: (value) => setState(
                              () => selections['${group['id']}:city'] = value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        );
      case 'word_guess':
        final answer = raw['answer'] as String;
        final clue = localizedText(raw['clue']);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Indice : $clue · ${answer.length} lettres',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final guess in wordGuesses) ...[
              _WordGuessRow(guess: guess, answer: answer),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: wordGuessController,
              enabled: correct == null,
              maxLength: answer.length,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              decoration: const InputDecoration(
                hintText: 'Écris le mot finnois…',
              ),
              onChanged: (value) => setState(() => selected = value),
              onSubmitted: (_) {
                if (_canValidate) _validate();
              },
            ),
            const Text(
              'Vert : bonne place · jaune : présente ailleurs · gris : absente.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        );
      case 'matching_pairs':
        final pairs = (raw['pairs'] as List).cast<Map>();
        final rights = [
          for (final pair in pairs.reversed) pair['right'] as String,
        ];
        return Column(
          children: [
            for (final pair in pairs)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      pair['left'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    _DropChoice(
                      value: selections[pair['left']],
                      hint: 'Choisir la réponse',
                      values: rights,
                      onChanged: (value) => setState(
                        () => selections[pair['left'] as String] = value,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      case 'word_order':
        final tiles = List<String>.from(raw['tiles'] as List);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                ordered.isEmpty ? 'Compose la phrase ici…' : ordered.join(' '),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tile in tiles)
                  ActionChip(
                    label: Text(tile),
                    onPressed: ordered.contains(tile)
                        ? null
                        : () => setState(() => ordered.add(tile)),
                  ),
                if (ordered.isNotEmpty)
                  ActionChip(
                    avatar: const Icon(Icons.backspace_outlined, size: 16),
                    label: const Text('Effacer'),
                    onPressed: () => setState(ordered.clear),
                  ),
              ],
            ),
          ],
        );
      case 'cloze':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              raw['prompt'] as String,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in List<String>.from(
                  raw['choices'] as List? ??
                      const <String>['Haluaisin', 'Olen', 'Asutko'],
                ))
                  ChoiceChip(
                    label: Text(value),
                    selected: selected == value,
                    onSelected: (_) => setState(() => selected = value),
                  ),
              ],
            ),
          ],
        );
      default:
        final choices = List<String>.from(
          raw['choices'] as List? ?? const <String>[],
        );
        return Column(
          children: [
            for (final value in choices)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: OutlinedButton(
                  onPressed: () => setState(() => selected = value),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    backgroundColor: selected == value
                        ? Theme.of(context).colorScheme.primary
                              .withValues(alpha: .12)
                        : null,
                  ),
                  child: Text(value),
                ),
              ),
          ],
        );
    }
  }

  bool get _canValidate => switch (widget.game.type) {
    'matching_groups' || 'matching_pairs' => selections.isNotEmpty,
    'word_order' => ordered.isNotEmpty,
    'word_guess' =>
      (selected?.trim().length ?? 0) ==
          (widget.game.raw['answer'] as String).length,
    _ => selected != null,
  };

  String get _answerLabel {
    final raw = widget.game.raw;
    if (widget.game.type == 'audio_discrimination') {
      return '${(raw['choices'] as List).first} (phrase de l’extrait audio)';
    }
    if (widget.game.type == 'matching_groups' ||
        widget.game.type == 'matching_pairs') {
      if (widget.game.type == 'matching_groups') {
        return (raw['groups'] as List)
            .map(
              (group) => ((group as Map)['items'] as List)
                  .map((item) => (item as Map)['text'])
                  .join(' · '),
            )
            .join(' / ');
      }
      return (raw['pairs'] as List)
          .map((pair) => '${(pair as Map)['left']} → ${pair['right']}')
          .join(' / ');
    }
    return raw['answer'] as String? ?? '';
  }

  void _validate() {
    final raw = widget.game.raw;
    var result = false;
    switch (widget.game.type) {
      case 'matching_groups':
        final groups = (raw['groups'] as List).cast<Map>();
        result = groups.every((group) {
          final items = group['items'] as List;
          return selections['${group['id']}:nation'] == items[1]['text'] &&
              selections['${group['id']}:city'] == items[2]['text'];
        });
        break;
      case 'matching_pairs':
        final pairs = (raw['pairs'] as List).cast<Map>();
        result = pairs.every(
          (pair) => selections[pair['left']] == pair['right'],
        );
        break;
      case 'word_order':
        result =
            _normalize(ordered.join(' ')) ==
            _normalize(raw['answer'] as String);
        break;
      case 'audio_discrimination':
        result = selected == (raw['choices'] as List).first;
        break;
      case 'word_guess':
        final guess = selected!.trim().toLowerCase();
        final answer = (raw['answer'] as String).toLowerCase();
        wordGuesses.add(guess);
        result = guess == answer;
        final maxAttempts = raw['max_attempts'] as int? ?? 6;
        _sessionOf(context).recordAnswer(
          widget.game.id,
          guess,
          correct: result,
          unitIds: List<String>.from(
            raw['unit_ids'] as List? ?? const <String>[],
          ),
        );
        if (!result && wordGuesses.length < maxAttempts) {
          wordGuessController.clear();
          setState(() => selected = null);
          return;
        }
        setState(() => correct = result);
        return;
      default:
        result = selected == raw['answer'];
    }
    final unitIds = List<String>.from(
      raw['unit_ids'] as List? ?? const <String>[],
    );
    _sessionOf(context).recordAnswer(
      widget.game.id,
      selected ?? ordered.join(' '),
      correct: result,
      unitIds: unitIds,
    );
    setState(() => correct = result);
  }

  void _reset() => setState(() {
    selections.clear();
    ordered.clear();
    wordGuesses.clear();
    wordGuessController.clear();
    selected = null;
    correct = null;
  });
}

class _WordGuessRow extends StatelessWidget {
  const _WordGuessRow({required this.guess, required this.answer});

  final String guess;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final states = _letterStates(guess.toLowerCase(), answer.toLowerCase());
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var index = 0; index < answer.length; index++)
          Container(
            width: 34,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: switch (states[index]) {
                2 => EchoColors.lichen,
                1 => EchoColors.clay.withValues(alpha: .7),
                _ => Theme.of(context).disabledColor.withValues(alpha: .2),
              },
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              guess[index].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
      ],
    );
  }

  static List<int> _letterStates(String guess, String answer) {
    final states = List<int>.filled(answer.length, 0);
    final remaining = <String, int>{};
    for (var index = 0; index < answer.length; index++) {
      if (guess[index] == answer[index]) {
        states[index] = 2;
      } else {
        remaining[answer[index]] = (remaining[answer[index]] ?? 0) + 1;
      }
    }
    for (var index = 0; index < answer.length; index++) {
      if (states[index] == 2) continue;
      final count = remaining[guess[index]] ?? 0;
      if (count > 0) {
        states[index] = 1;
        remaining[guess[index]] = count - 1;
      }
    }
    return states;
  }
}

class _DropChoice extends StatelessWidget {
  const _DropChoice({
    required this.value,
    required this.hint,
    required this.values,
    required this.onChanged,
  });
  final String? value;
  final String hint;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(hintText: hint),
    items: [
      for (final item in values)
        DropdownMenuItem(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
  );
}

class _TransferActivity extends StatelessWidget {
  const _TransferActivity({
    required this.audio,
    required this.question,
    required this.questionIndex,
    required this.questionTotal,
  });
  final List<LessonAudio> audio;
  final LessonQuestion? question;
  final int questionIndex;
  final int questionTotal;

  @override
  Widget build(BuildContext context) {
    final currentQuestion = question;
    if (currentQuestion == null) {
      return _AudioOnlyActivity(
        audio: audio,
        playerLabel: 'Nouvelle conversation',
        instruction: 'Écoute ces nouvelles voix sans lire. La question arrivera sur la page suivante.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EchoBadge(label: 'APRÈS L’ÉCOUTE', color: EchoColors.sky),
        const SizedBox(height: 14),
        QuestionCard(
          key: ValueKey(currentQuestion.id),
          question: currentQuestion,
          counter: '$questionIndex / $questionTotal',
        ),
      ],
    );
  }
}

class _FlashcardActivity extends StatelessWidget {
  const _FlashcardActivity({
    required this.card,
    required this.audio,
    required this.index,
    required this.total,
    required this.revealed,
    required this.onReveal,
    required this.onAssess,
  });
  final Flashcard card;
  final LessonAudio? audio;
  final int index;
  final int total;
  final bool revealed;
  final VoidCallback onReveal;
  final ValueChanged<String> onAssess;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Counter(value: '${index + 1} / $total'),
        const SizedBox(height: 12),
        Semantics(
          button: true,
          label: revealed
              ? 'Carte retournée : ${card.back}'
              : 'Retourner la carte',
          child: InkWell(
            onTap: revealed ? null : onReveal,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              constraints: const BoxConstraints(minHeight: 270),
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                color: EchoColors.pine,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    revealed ? 'FINNOIS' : 'FRANÇAIS',
                    style: const TextStyle(
                      color: EchoColors.lichen,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    revealed ? card.back : card.front,
                    style: Theme.of(context).textTheme.displayMedium
                        ?.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (!revealed)
                    const Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Icon(Icons.touch_app, color: Colors.white60),
                        Text(
                          'Toucher pour retourner',
                          style: TextStyle(color: Colors.white60),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  if (revealed && audio != null)
                    AudioPlayerCard(
                      audio: [audio!],
                      compact: true,
                      label: 'Exemple audio',
                    ),
                ],
              ),
            ),
          ),
        ),
        if (revealed) ...[
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                label: const Text('À revoir'),
                onPressed: () => onAssess('difficult'),
              ),
              ActionChip(
                label: const Text('Presque'),
                onPressed: () => onAssess('hesitant'),
              ),
              ActionChip(
                label: const Text('Facile'),
                onPressed: () => onAssess('easy'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _GuidedWritingActivity extends StatefulWidget {
  const _GuidedWritingActivity({super.key, required this.writing});

  final LessonWriting writing;

  @override
  State<_GuidedWritingActivity> createState() => _GuidedWritingActivityState();
}

class _GuidedWritingActivityState extends State<_GuidedWritingActivity> {
  final TextEditingController _controller = TextEditingController();
  bool _saved = false;

  int get _sentenceCount => _controller.text
      .split(RegExp(r'[.!?\n]+'))
      .where((part) => part.trim().isNotEmpty)
      .length;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final complete = _sentenceCount >= widget.writing.minimumSentences;
    _sessionOf(context).recordAnswer(
      widget.writing.id,
      text,
      correct: complete,
      unitIds: widget.writing.targetUnitIds,
    );
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      EchoCard(
        color: Theme.of(context).brightness == Brightness.dark
            ? EchoColors.nightCard
            : EchoColors.sky,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.edit_note_outlined, size: 34),
            const SizedBox(height: 14),
            Text(
              widget.writing.prompt,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      TextField(
        key: const ValueKey('guided-writing-field'),
        controller: _controller,
        minLines: 5,
        maxLines: 9,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'Ta réponse en finnois',
          hintText: 'Hyvää päivää! Mitä kuuluu?',
          helperText:
              '${widget.writing.minimumSentences} phrases minimum · rien n’est envoyé',
          alignLabelWithHint: true,
        ),
        onChanged: (_) => setState(() => _saved = false),
      ),
      const SizedBox(height: 14),
      FilledButton.icon(
        onPressed: _controller.text.trim().isEmpty ? null : _save,
        icon: const Icon(Icons.check),
        label: const Text('Enregistrer ma réponse'),
      ),
      if (_saved) ...[
        const SizedBox(height: 12),
        Text(
          _sentenceCount >= widget.writing.minimumSentences
              ? 'Réponse enregistrée pour cette session.'
              : 'Réponse enregistrée. Ajoute encore une phrase pour atteindre la consigne.',
          textAlign: TextAlign.center,
        ),
      ],
    ],
  );
}

class _SummaryActivity extends StatelessWidget {
  const _SummaryActivity();

  @override
  Widget build(BuildContext context) {
    final session = _sessionOf(context);
    final lesson = _lessonOf(context);
    final successes = session.attempts
        .where((event) => event.correct == true)
        .length;
    final helps = session.attempts.where((event) => event.help != null).length;
    final encountered = lesson.units
        .where((unit) => session.masteryFor(unit.id).encounters > 0)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EchoCard(
          color: EchoColors.lichen,
          editorial: true,
          child: Column(
            children: [
              const Icon(
                Icons.celebration_outlined,
                color: EchoColors.pine,
                size: 54,
              ),
              const SizedBox(height: 16),
              Text(
                'Hyvin tehty !',
                style: Theme.of(context).textTheme.displayMedium
                    ?.copyWith(color: EchoColors.pine),
              ),
              const SizedBox(height: 8),
              Text(
                'Bien joué. Tu as terminé la leçon ${lesson.number}.',
                style: TextStyle(color: EchoColors.pine),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _Stat(value: '$successes', label: 'réussites'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Stat(value: '$encountered', label: 'unités vues'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Stat(value: '$helps', label: 'aides'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Tes prochaines rencontres privilégieront les unités encore hésitantes et changeront de modalité.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => EchoCard(
    padding: const EdgeInsets.all(14),
    child: Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineLarge),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class _Counter extends StatelessWidget {
  const _Counter({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) => Text(
    value,
    style: Theme.of(context).textTheme.bodySmall
        ?.copyWith(fontWeight: FontWeight.w800),
  );
}

String _activityEyebrow(String type) => switch (type) {
  'context' => 'Repères',
  'global_listening' => 'Commencer à l’oral',
  'active_recall' => 'Sans modèle',
  'roleplay' => 'À voix haute',
  'transition' => 'Lecture en BD',
  'reading' => 'Explore le texte',
  'reading_comprehension' => 'Questions',
  'memory' => '6 paires',
  'adaptive_games' => 'Activités',
  'audio_transfer' => 'Nouvelles voix',
  'guided_writing' => 'À l’écrit',
  'selective_flashcards' => 'Cartes',
  'summary_and_spacing' => 'Terminé',
  _ => 'Leçon',
};

String _activityTitle(String type, [LessonPackage? lesson]) => switch (type) {
  'context' => 'La scène et les personnages',
  'global_listening' => 'Leçon audio',
  'active_recall' => 'Rappel actif',
  'roleplay' => 'Deux jeux de rôle',
  'transition' => 'Passer à la lecture',
  'reading' =>
    lesson?.number == 1 ? 'Une rencontre au travail' : 'Lecture en contexte',
  'reading_comprehension' => 'Comprendre le texte',
  'memory' => 'Memory',
  'adaptive_games' => 'Jouer avec la langue',
  'audio_transfer' =>
    lesson?.number == 1 ? 'Sofia et Daniel' : 'Deuxième contexte',
  'guided_writing' => 'Écrire quelques phrases',
  'selective_flashcards' => 'Ancrer l’essentiel',
  'summary_and_spacing' => 'Ton bilan',
  _ => type,
};

String _activityIntro(String type) => switch (type) {
  'context' => 'Retrouve le décor et les personnages que tu viens d’entendre.',
  'global_listening' =>
    'Toute la pratique orale est guidée par la piste complète de la leçon.',
  'active_recall' =>
    'Réponds avant de révéler le modèle, puis évalue ton aisance.',
  'roleplay' =>
    'Entre dans la conversation. Aucune voix n’est enregistrée ni évaluée.',
  'transition' => 'Retrouve la conversation sous forme de BD : chaque image est lue automatiquement, avec 5 secondes avant la suivante.',
  'reading' =>
    'Lis naturellement et touche directement un mot si tu en as besoin.',
  'reading_comprehension' =>
    'Réponds à partir de ce que tu as compris dans le texte.',
  'memory' =>
    'Retourne deux cartes et associe chaque mot finnois à son dessin.',
  'adaptive_games' =>
    'Six formats courts consolident le sens, la forme et l’écoute.',
  'audio_transfer' => 'Même langage, nouveaux personnages. Écoute d’abord ; les questions viennent ensuite.',
  'guided_writing' => 'Réemploie les expressions de la leçon dans une courte production personnelle.',
  'selective_flashcards' =>
    'Retourne chaque carte et indique honnêtement ton niveau de rappel.',
  'summary_and_spacing' =>
    'Echo prépare la suite à partir de tes rencontres de cette session.',
  _ => '',
};

String _speaker(String value) {
  if (value.isEmpty) return 'NARRATION';
  if (value == 'waiter') return 'SERVEUR';
  return value.replaceAll('_', ' ').toUpperCase();
}

String _normalize(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'[.!?]$'), '');
