enum EchoRoute {
  today('/today'),
  path('/path'),
  library('/library'),
  progress('/progress');

  const EchoRoute(this.location);
  final String location;
}

sealed class EchoLocation {
  const EchoLocation();
  String get location;
}

final class LessonLocation extends EchoLocation {
  const LessonLocation(this.lessonId);

  static const pattern = '/lesson/:id';
  final String lessonId;

  @override
  String get location => '/lesson/${Uri.encodeComponent(lessonId)}';
}

final class UnitLocation extends EchoLocation {
  const UnitLocation(this.unitId);

  static const pattern = '/unit/:id';
  final String unitId;

  @override
  String get location => '/unit/${Uri.encodeComponent(unitId)}';
}

final class SessionLocation extends EchoLocation {
  const SessionLocation(this.lessonId);

  static const pattern = '/session/:lessonId';
  final String lessonId;

  @override
  String get location => '/session/${Uri.encodeComponent(lessonId)}';
}

final class PlacementLocation extends EchoLocation {
  const PlacementLocation(this.lessonId);

  static const pattern = '/placement/:lessonId';
  final String lessonId;

  @override
  String get location => '/placement/${Uri.encodeComponent(lessonId)}';
}
