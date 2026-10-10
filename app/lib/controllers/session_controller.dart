import 'package:flutter/foundation.dart';

import '../data/models.dart';

class SessionController extends ChangeNotifier {
  SessionController(this.lesson);

  final LessonPackage lesson;
  final List<AttemptEvent> _attempts = <AttemptEvent>[];
  final Map<String, String> _answers = <String, String>{};

  int _activityIndex = 0;
  int _itemIndex = 0;
  bool _started = false;
  bool _completed = false;

  int get activityIndex => _activityIndex;
  int get itemIndex => _itemIndex;
  bool get started => _started;
  bool get completed => _completed;
  List<AttemptEvent> get attempts => List.unmodifiable(_attempts);
  Map<String, String> get answers => Map.unmodifiable(_answers);
  SessionActivity get activity => lesson.activities[_activityIndex];
  double get lessonProgress =>
      ((_activityIndex + (_itemIndex / itemCount)) / lesson.activities.length)
          .clamp(0, 1)
          .toDouble();
  int get itemCount => itemCountFor(_activityIndex);

  void start({int activity = 0}) {
    _started = true;
    _completed = false;
    _activityIndex = activity.clamp(0, lesson.activities.length - 1);
    _itemIndex = 0;
    notifyListeners();
  }

  void goToActivity(int activity) {
    _started = true;
    _activityIndex = activity.clamp(0, lesson.activities.length - 1);
    _itemIndex = 0;
    notifyListeners();
  }

  void advance() {
    if (_itemIndex + 1 < itemCount) {
      _itemIndex++;
    } else if (_activityIndex + 1 < lesson.activities.length) {
      _activityIndex++;
      _itemIndex = 0;
    } else {
      _completed = true;
    }
    notifyListeners();
  }

  void retreat() {
    if (_itemIndex > 0) {
      _itemIndex--;
    } else if (_activityIndex > 0) {
      _activityIndex--;
      _itemIndex = itemCountFor(_activityIndex) - 1;
    }
    notifyListeners();
  }

  void recordAnswer(
    String id,
    String answer, {
    required bool correct,
    Iterable<String> unitIds = const <String>[],
  }) {
    _answers[id] = answer;
    _attempts.add(
      AttemptEvent(
        activityType: activity.type,
        unitIds: unitIds.toList(growable: false),
        createdAt: DateTime.now(),
        correct: correct,
      ),
    );
    notifyListeners();
  }

  void recordHelp(String help, Iterable<String> unitIds) {
    _attempts.add(
      AttemptEvent(
        activityType: activity.type,
        unitIds: unitIds.toList(growable: false),
        createdAt: DateTime.now(),
        help: help,
      ),
    );
    notifyListeners();
  }

  void assess(Iterable<String> unitIds, String rating) {
    _attempts.add(
      AttemptEvent(
        activityType: activity.type,
        unitIds: unitIds.toList(growable: false),
        createdAt: DateTime.now(),
        correct: rating == 'easy' || rating == 'hesitant',
        rating: rating,
      ),
    );
    notifyListeners();
  }

  MasterySnapshot masteryFor(String unitId) {
    final events = _attempts
        .where((event) => event.unitIds.contains(unitId))
        .toList(growable: false);
    return MasterySnapshot(
      unitId: unitId,
      encounters: events.length,
      successes: events.where((event) => event.correct == true).length,
      helpCount: events.where((event) => event.help != null).length,
    );
  }

  int nextEncounterDays(String unitId) {
    final snapshot = masteryFor(unitId);
    if (snapshot.encounters == 0) return 0;
    if (snapshot.label == 'Solide') return 7;
    return snapshot.helpCount > 0 ? 1 : 3;
  }

  int itemCountFor(int index) => switch (lesson.activities[index].type) {
    'global_listening' => lesson.openingQuestions.length + 1,
    'active_recall' => lesson.activeRecallPairs.length,
    'roleplay' => lesson.roleplayLines.length,
    'reading_comprehension' => lesson.readingQuestions.length,
    'adaptive_games' => lesson.games.length,
    'audio_transfer' => lesson.transferQuestions.length + 1,
    'selective_flashcards' => lesson.flashcards.length,
    _ => 1,
  };
}
