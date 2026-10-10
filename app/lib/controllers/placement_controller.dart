import 'package:flutter/foundation.dart';

import '../data/models.dart';

class PlacementController extends ChangeNotifier {
  PlacementController(this.tests);

  final List<LessonPlacementTest> tests;
  final Map<String, String> _answers = <String, String>{};
  final Set<String> _skippableLessonIds = <String>{};
  final Set<String> _assessedLessonIds = <String>{};

  bool _completed = false;
  bool _skipped = false;

  bool get completed => _completed;
  bool get skipped => _skipped;
  Map<String, String> get answers => Map.unmodifiable(_answers);
  Set<String> get skippableLessonIds => Set.unmodifiable(_skippableLessonIds);
  Set<String> get assessedLessonIds => Set.unmodifiable(_assessedLessonIds);

  LessonPlacementTest? get recommendedTest {
    for (final test in tests) {
      if (!_skippableLessonIds.contains(test.lessonId)) return test;
    }
    return null;
  }

  bool isLessonSkippable(String lessonId) =>
      _skippableLessonIds.contains(lessonId);

  void complete(Map<String, String> answers) {
    if (_completed) return;
    _answers
      ..clear()
      ..addAll(answers);
    _skippableLessonIds.clear();
    _assessedLessonIds.clear();

    for (final test in tests) {
      final assessed = test.questions.every(
        (question) => answers.containsKey(question.id),
      );
      if (!assessed) continue;
      _assessedLessonIds.add(test.lessonId);
      if (test.isPassed(answers)) {
        _skippableLessonIds.add(test.lessonId);
      }
    }

    _completed = true;
    _skipped = false;
    notifyListeners();
  }

  void skip() {
    if (_completed) return;
    _completed = true;
    _skipped = true;
    notifyListeners();
  }
}
