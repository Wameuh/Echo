import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/home_screens.dart';
import '../ui/placement_screen.dart';
import '../ui/session_screen.dart';
import '../ui/shared.dart';
import 'route_locations.dart';

GoRouter createEchoRouter() => GoRouter(
  initialLocation: EchoRoute.today.location,
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          EchoShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: EchoRoute.today.location,
          builder: (context, state) => const TodayScreen(),
        ),
        GoRoute(
          path: EchoRoute.path.location,
          builder: (context, state) => const PathScreen(),
        ),
        GoRoute(
          path: EchoRoute.library.location,
          builder: (context, state) => const LibraryScreen(),
        ),
        GoRoute(
          path: EchoRoute.progress.location,
          builder: (context, state) => const ProgressScreen(),
        ),
      ],
    ),
    GoRoute(
      path: LessonLocation.pattern,
      builder: (context, state) =>
          LessonDetailScreen(lessonId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: UnitLocation.pattern,
      builder: (context, state) =>
          UnitDetailScreen(unitId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: PlacementLocation.pattern,
      builder: (context, state) =>
          PlacementScreen(lessonId: state.pathParameters['lessonId']!),
    ),
    GoRoute(
      path: SessionLocation.pattern,
      builder: (context, state) =>
          SessionScreen(lessonId: state.pathParameters['lessonId']!),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: FilledButton.icon(
        onPressed: () => context.go(EchoRoute.today.location),
        icon: const Icon(Icons.home_outlined),
        label: const Text('Revenir à l’accueil'),
      ),
    ),
  ),
);
