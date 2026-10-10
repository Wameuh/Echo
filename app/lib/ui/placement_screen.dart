import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/echo_app.dart';
import '../app/echo_theme.dart';
import '../app/route_locations.dart';
import '../data/models.dart';
import 'shared.dart';

class PlacementScreen extends StatefulWidget {
  const PlacementScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends State<PlacementScreen> {
  final Map<String, String> _answers = <String, String>{};
  final ScrollController _scrollController = ScrollController();
  var _quizStarted = false;
  var _testIndex = 0;
  var _questionIndex = 0;
  String? _selectedChoiceId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = EchoScope.of(context);
    final placement = scope.placementController;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour à l’accueil',
          onPressed: () => context.go(EchoRoute.today.location),
          icon: const Icon(Icons.close),
        ),
        title: const Text(
          'Test de placement',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Changer de thème',
            onPressed: scope.appController.toggleTheme,
            icon: const Icon(Icons.contrast),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            MediaQuery.sizeOf(context).width < 600 ? 20 : 42,
            28,
            MediaQuery.sizeOf(context).width < 600 ? 20 : 42,
            42,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: placement.completed
                  ? _PlacementResult(
                      onContinue: _continueAfterPlacement,
                      onReviewFirstLesson:
                          placement.isLessonSkippable(widget.lessonId)
                          ? _reviewFirstLesson
                          : null,
                    )
                  : _quizStarted
                  ? _question(placement.tests)
                  : _PlacementIntroduction(
                      lessonCount: placement.tests.length,
                      onStart: _startQuiz,
                      onSkip: _skipPlacement,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _question(List<LessonPlacementTest> tests) {
    final test = tests[_testIndex];
    final question = test.questions[_questionIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value:
              (test.lessonNumber - 1 + ((_questionIndex + 1) / 2)) /
              tests.length,
          minHeight: 5,
          borderRadius: BorderRadius.circular(4),
          color: EchoColors.clay,
          backgroundColor: Theme.of(context).dividerColor,
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EchoBadge(label: 'LEÇON ${test.lessonNumber}'),
                  const SizedBox(height: 8),
                  Text(
                    test.title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${_questionIndex + 1} / ${test.questions.length}',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(question.prompt, style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 12),
        Text(
          'Les deux réponses de cette leçon doivent être justes pour pouvoir la passer.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),
        EchoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final choice in question.choices)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton.icon(
                    key: ValueKey('placement-${question.id}-${choice.id}'),
                    onPressed: () =>
                        setState(() => _selectedChoiceId = choice.id),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      backgroundColor: _selectedChoiceId == choice.id
                          ? Theme.of(context).colorScheme.primary
                                .withValues(alpha: .12)
                          : null,
                    ),
                    icon: Icon(
                      _selectedChoiceId == choice.id
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                    ),
                    label: Text(choice.text),
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _selectedChoiceId == null
                    ? null
                    : () => _nextQuestion(tests),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continuer'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _nextQuestion(List<LessonPlacementTest> tests) {
    final test = tests[_testIndex];
    final question = test.questions[_questionIndex];
    _answers[question.id] = _selectedChoiceId!;

    if (_questionIndex + 1 < test.questions.length) {
      setState(() {
        _questionIndex++;
        _selectedChoiceId = null;
      });
      _returnToTop();
      return;
    }

    final passed = test.isPassed(_answers);
    if (passed && _testIndex + 1 < tests.length) {
      setState(() {
        _testIndex++;
        _questionIndex = 0;
        _selectedChoiceId = null;
      });
      _returnToTop();
      return;
    }

    EchoScope.of(context).placementController.complete(_answers);
    setState(() {});
    _returnToTop();
  }

  void _startQuiz() {
    setState(() => _quizStarted = true);
    _returnToTop();
  }

  void _returnToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
  }

  void _skipPlacement() {
    final scope = EchoScope.of(context);
    final session = scope.sessionFor(widget.lessonId);
    scope.placementController.skip();
    session.start();
    context.go(SessionLocation(widget.lessonId).location);
  }

  void _continueAfterPlacement() {
    final scope = EchoScope.of(context);
    final session = scope.sessionFor(widget.lessonId);
    if (scope.placementController.recommendedTest?.lessonNumber == 1) {
      session.start();
      context.go(SessionLocation(widget.lessonId).location);
      return;
    }
    context.go(EchoRoute.path.location);
  }

  void _reviewFirstLesson() {
    final session = EchoScope.of(context).sessionFor(widget.lessonId);
    session.start();
    context.go(SessionLocation(widget.lessonId).location);
  }
}

class _PlacementIntroduction extends StatelessWidget {
  const _PlacementIntroduction({
    required this.lessonCount,
    required this.onStart,
    required this.onSkip,
  });

  final int lessonCount;
  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const EchoBadge(label: 'NOUVEAU PARCOURS', color: EchoColors.lichen),
      const SizedBox(height: 20),
      Text(
        'Trouvons ton point de départ',
        style: Theme.of(context).textTheme.displayLarge,
      ),
      const SizedBox(height: 16),
      Text(
        'Chaque leçon propose deux questions. Une leçon entièrement réussie peut être passée ; le test s’arrête dès qu’il trouve la première leçon utile.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 28),
      EchoCard(
        color: Theme.of(context).brightness == Brightness.dark
            ? EchoColors.nightCard
            : EchoColors.sky,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.route_outlined, size: 32),
            const SizedBox(height: 16),
            Text(
              'Jusqu’à ${lessonCount * 2} questions',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Le test est facultatif et ne retire jamais l’accès aux leçons passées.',
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      FilledButton.icon(
        onPressed: onStart,
        icon: const Icon(Icons.fact_check_outlined),
        label: const Text('Évaluer mon niveau'),
      ),
      const SizedBox(height: 10),
      TextButton(
        onPressed: onSkip,
        child: const Text('Je débute, commencer sans test'),
      ),
    ],
  );
}

class _PlacementResult extends StatelessWidget {
  const _PlacementResult({
    required this.onContinue,
    required this.onReviewFirstLesson,
  });

  final VoidCallback onContinue;
  final VoidCallback? onReviewFirstLesson;

  @override
  Widget build(BuildContext context) {
    final scope = EchoScope.of(context);
    final placement = scope.placementController;
    final skipped = placement.skippableLessonIds;
    final assessed = placement.assessedLessonIds;
    final recommended = placement.recommendedTest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.auto_awesome, color: EchoColors.clay, size: 46),
        const SizedBox(height: 18),
        Text(
          recommended == null
              ? 'Tu maîtrises déjà ce parcours'
              : 'Commence par la leçon ${recommended.lessonNumber}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 12),
        Text(
          skipped.isEmpty
              ? 'Aucune leçon n’est retirée de ton parcours.'
              : '${skipped.length} leçon${skipped.length > 1 ? 's' : ''} peu${skipped.length > 1 ? 'vent' : 't'} être passée${skipped.length > 1 ? 's' : ''}. Elles restent accessibles à tout moment.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),
        for (final test in placement.tests)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EchoCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    skipped.contains(test.lessonId)
                        ? Icons.check_circle
                        : assessed.contains(test.lessonId)
                        ? Icons.play_circle_outline
                        : Icons.more_horiz,
                    color: skipped.contains(test.lessonId)
                        ? EchoColors.pine
                        : EchoColors.clay,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Leçon ${test.lessonNumber} · ${test.title}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          skipped.contains(test.lessonId)
                              ? 'Non nécessaire · accessible en révision'
                              : assessed.contains(test.lessonId)
                              ? 'Point de départ conseillé'
                              : 'Non évaluée',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: onContinue,
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward),
          label: Text(
            recommended?.lessonNumber == 1
                ? 'Commencer la leçon 1'
                : 'Voir mon parcours',
          ),
        ),
        if (onReviewFirstLesson != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onReviewFirstLesson,
            child: const Text('Revoir quand même la leçon 1'),
          ),
        ],
      ],
    );
  }
}
