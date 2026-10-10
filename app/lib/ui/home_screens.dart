import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/echo_app.dart';
import '../app/echo_theme.dart';
import '../app/route_locations.dart';
import '../data/models.dart';
import 'shared.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = EchoScope.of(context);
    return ListenableBuilder(
      listenable: scope.sessionController,
      builder: (context, _) {
        final session = scope.sessionController;
        final started = session.started && !session.completed;
        return EchoPage(
          eyebrow: _todayLabel(),
          title: session.completed
              ? 'Hyvin tehty !'
              : 'On se retrouve au café ?',
          subtitle: session.completed
              ? 'La première leçon est terminée. Tes acquis sont prêts à être revus.'
              : 'Une séance courte pour écouter, répondre et faire connaissance en finnois.',
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 720;
                final hero = _TodayHero(
                  started: started,
                  completed: session.completed,
                  progress: session.lessonProgress,
                );
                final aside = const _TodayAside();
                return compact
                    ? Column(
                        children: [hero, const SizedBox(height: 18), aside],
                      )
                    : IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(flex: 3, child: hero),
                            const SizedBox(width: 18),
                            Expanded(flex: 2, child: aside),
                          ],
                        ),
                      );
              },
            ),
            const SizedBox(height: 34),
            Text(
              'Ce que tu vas travailler',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _SkillTile(
                  Icons.hearing_outlined,
                  'Comprendre',
                  'une première rencontre',
                ),
                _SkillTile(
                  Icons.record_voice_over_outlined,
                  'Répondre',
                  'sans modèle visible',
                ),
                _SkillTile(
                  Icons.menu_book_outlined,
                  'Lire',
                  'une scène au travail',
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TodayHero extends StatelessWidget {
  const _TodayHero({
    required this.started,
    required this.completed,
    required this.progress,
  });

  final bool started;
  final bool completed;
  final double progress;

  @override
  Widget build(BuildContext context) => EchoCard(
    color: EchoColors.pine,
    editorial: true,
    padding: const EdgeInsets.all(28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: EchoBadge(label: 'LEÇON 1', color: EchoColors.lichen),
              ),
            ),
            SizedBox(
              width: 88,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: WaveDecoration(color: EchoColors.clay),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'Rencontrer quelqu’un\ndans un café',
          style: Theme.of(context).textTheme.headlineLarge
              ?.copyWith(color: Colors.white, fontSize: 40),
        ),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _LightMeta(Icons.schedule, '12 min'),
            _LightMeta(Icons.headphones, 'Audio + lecture'),
            _LightMeta(Icons.translate, 'Finnois A1'),
          ],
        ),
        if (started) ...[
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            borderRadius: BorderRadius.circular(4),
            backgroundColor: Colors.white24,
            color: EchoColors.lichen,
          ),
        ],
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: () {
            final scope = EchoScope.of(context);
            final session = scope.sessionController;
            final lesson = scope.lesson;
            if (!started &&
                !completed &&
                !scope.placementController.completed) {
              context.push(PlacementLocation(lesson.id).location);
              return;
            }
            if (!started || completed) session.start();
            context.push(SessionLocation(lesson.id).location);
          },
          style: FilledButton.styleFrom(
            backgroundColor: EchoColors.lichen,
            foregroundColor: EchoColors.pine,
          ),
          icon: Icon(started ? Icons.play_arrow : Icons.headphones),
          label: Text(
            completed
                ? 'Rejouer la leçon'
                : started
                ? 'Reprendre'
                : 'Commencer',
          ),
        ),
      ],
    ),
  );
}

class _TodayAside extends StatelessWidget {
  const _TodayAside();

  @override
  Widget build(BuildContext context) => EchoCard(
    color: Theme.of(context).brightness == Brightness.dark
        ? EchoColors.nightCard
        : EchoColors.sky,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lightbulb_outline, size: 30),
        const SizedBox(height: 24),
        Text(
          'Aujourd’hui, écoute d’abord.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        const Text(
          'Tu n’as pas besoin de tout comprendre. Laisse les voix installer le rythme, puis Echo te guidera.',
        ),
        const SizedBox(height: 22),
        TextButton.icon(
          onPressed: () => context.push(
            LessonLocation(EchoScope.of(context).lesson.id).location,
          ),
          icon: const Icon(Icons.info_outline),
          label: const Text('Voir le détail'),
        ),
      ],
    ),
  );
}

class _LightMeta extends StatelessWidget {
  const _LightMeta(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 17, color: Colors.white70),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class _SkillTile extends StatelessWidget {
  const _SkillTile(this.icon, this.title, this.subtitle);
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: MediaQuery.sizeOf(context).width < 600 ? double.infinity : 280,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class PathScreen extends StatelessWidget {
  const PathScreen({super.key});

  static const titles = <String>[
    'Rencontrer quelqu’un dans un café',
    'Saluer et demander des nouvelles',
    'Nombres et commander au café',
    'Demander son chemin',
    'L’heure et les rendez-vous',
    'Acheter des vêtements',
    'Commander au restaurant',
    'Arriver à l’hôtel',
    'Acheter un billet de train',
    'Proposer une activité',
  ];

  @override
  Widget build(BuildContext context) {
    final scope = EchoScope.of(context);
    final placement = scope.placementController;
    final lessonsByNumber = {
      for (final lesson in scope.lessons) lesson.number: lesson,
    };
    return ListenableBuilder(
      listenable: placement,
      builder: (context, _) => EchoPage(
        eyebrow: 'Finnois A1 · kirjakieli',
        title: 'Ton parcours',
        subtitle: 'Une progression par situations concrètes. Les leçons 1 et 2 sont ouvertes ; les suivantes arrivent bientôt.',
        children: [
          EchoCard(
            color: Theme.of(context).brightness == Brightness.dark
                ? EchoColors.nightCard
                : EchoColors.lichen,
            child: Row(
              children: [
                const Icon(Icons.route_outlined, size: 34),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Débutant · 10 leçons',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Langue standard finnoise · situations du quotidien',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(
            titles.length,
            (index) => _LessonRow(
              index: index,
              title: titles[index],
              lessonId: lessonsByNumber[index + 1]?.id,
              unnecessary: placement.isLessonSkippable(
                'suomi-beginner-lesson-${index + 1}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.index,
    required this.title,
    required this.lessonId,
    required this.unnecessary,
  });
  final int index;
  final String title;
  final String? lessonId;
  final bool unnecessary;

  @override
  Widget build(BuildContext context) {
    final available = lessonId != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: available
              ? () => context.push(LessonLocation(lessonId!).location)
              : null,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final number = Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: unnecessary
                        ? EchoColors.lichen
                        : available
                        ? EchoColors.clay
                        : Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                );
                final status = EchoBadge(
                  label: unnecessary
                      ? 'Non nécessaire'
                      : available
                      ? 'Disponible'
                      : 'À venir',
                );
                final trailing = Icon(
                  unnecessary
                      ? Icons.check_circle_outline
                      : available
                      ? Icons.chevron_right
                      : Icons.lock_outline,
                  size: 20,
                );
                if (constraints.maxWidth < 360) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [number, const Spacer(), trailing]),
                      const SizedBox(height: 14),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Align(alignment: Alignment.centerLeft, child: status),
                    ],
                  );
                }
                return Row(
                  children: [
                    number,
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    status,
                    const SizedBox(width: 8),
                    trailing,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

enum _LibraryFilter { all, audio, reading }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String query = '';
  _LibraryFilter filter = _LibraryFilter.all;

  @override
  Widget build(BuildContext context) {
    final scope = EchoScope.of(context);
    const items = <_LibraryItem>[
      _LibraryItem(
        'dialogue',
        'Dialogue principal',
        'Laura et James au café',
        _LibraryFilter.audio,
        Icons.headphones,
      ),
      _LibraryItem(
        'reading',
        'Une rencontre au travail',
        'Lecture interactive · 6 phrases',
        _LibraryFilter.reading,
        Icons.menu_book,
      ),
      _LibraryItem(
        'transfer',
        'Sofia et Daniel',
        'Nouvelle voix, même situation',
        _LibraryFilter.audio,
        Icons.graphic_eq,
      ),
    ];
    final visible = items
        .where((item) {
          final matchesFilter =
              filter == _LibraryFilter.all || item.type == filter;
          final needle = query.trim().toLowerCase();
          return matchesFilter &&
              (needle.isEmpty ||
                  '${item.title} ${item.subtitle}'.toLowerCase().contains(
                    needle,
                  ));
        })
        .toList(growable: false);
    return EchoPage(
      eyebrow: 'Tes ressources',
      title: 'Bibliothèque',
      subtitle: 'Retrouve les scènes de la leçon, cherche un contenu et garde tes favoris pendant cette visite.',
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Chercher une scène ou une lecture…',
          ),
          onChanged: (value) => setState(() => query = value),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in const <(_LibraryFilter, String)>[
              (_LibraryFilter.all, 'Tout'),
              (_LibraryFilter.audio, 'Audio'),
              (_LibraryFilter.reading, 'Lecture'),
            ])
              FilterChip(
                label: Text(entry.$2),
                selected: filter == entry.$1,
                onSelected: (_) => setState(() => filter = entry.$1),
              ),
          ],
        ),
        const SizedBox(height: 24),
        ListenableBuilder(
          listenable: scope.appController,
          builder: (context, _) => Column(
            children: [
              for (final item in visible)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: EchoCard(
                    padding: const EdgeInsets.all(20),
                    child: _LibraryTile(
                      item: item,
                      favorite: scope.appController.isFavorite(item.id),
                      onFavorite: () =>
                          scope.appController.toggleFavorite(item.id),
                      onOpen: () {
                        final targetType = item.id == 'reading'
                            ? 'reading'
                            : item.id == 'transfer'
                            ? 'audio_transfer'
                            : 'global_listening';
                        final targetActivity = scope.lesson.activities
                            .indexWhere(
                              (activity) => activity.type == targetType,
                            );
                        scope.sessionController.start(activity: targetActivity);
                        context.push(SessionLocation(scope.lesson.id).location);
                      },
                    ),
                  ),
                ),
              if (visible.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('Aucun contenu ne correspond à cette recherche.'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LibraryItem {
  const _LibraryItem(this.id, this.title, this.subtitle, this.type, this.icon);
  final String id;
  final String title;
  final String subtitle;
  final _LibraryFilter type;
  final IconData icon;
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({
    required this.item,
    required this.favorite,
    required this.onFavorite,
    required this.onOpen,
  });

  final _LibraryItem item;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final leading = Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: EchoColors.sky,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(item.icon, color: EchoColors.pine),
    );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(item.subtitle),
      ],
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: favorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
          onPressed: onFavorite,
          icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          tooltip: 'Ouvrir',
          onPressed: onOpen,
          style: IconButton.styleFrom(
            backgroundColor: EchoColors.lichen,
            foregroundColor: EchoColors.pine,
          ),
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  leading,
                  const SizedBox(width: 16),
                  Expanded(child: details),
                ],
              ),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          );
        }
        return Row(
          children: [
            leading,
            const SizedBox(width: 16),
            Expanded(child: details),
            const SizedBox(width: 12),
            actions,
          ],
        );
      },
    );
  }
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String filter = 'Tout';

  @override
  Widget build(BuildContext context) {
    final scope = EchoScope.of(context);
    return ListenableBuilder(
      listenable: scope.sessionController,
      builder: (context, _) {
        final rows = scope.lesson.units
            .where((unit) {
              final label = scope.sessionController.masteryFor(unit.id).label;
              return filter == 'Tout' || label == filter;
            })
            .toList(growable: false);
        final encountered = scope.lesson.units
            .where(
              (unit) =>
                  scope.sessionController.masteryFor(unit.id).encounters > 0,
            )
            .length;
        return EchoPage(
          eyebrow: 'Mémoire temporaire',
          title: 'Tes acquis',
          subtitle: encountered == 0
              ? 'Commence la leçon pour faire apparaître tes premières rencontres. Tout repart à zéro au rechargement.'
              : '$encountered unités rencontrées sur ${scope.lesson.units.length}. Les prochaines révisions suivent tes réponses et les aides consultées.',
          children: [
            _ProgressSummary(
              encountered: encountered,
              total: scope.lesson.units.length,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in const [
                  'Tout',
                  'En consolidation',
                  'Solide',
                ])
                  FilterChip(
                    label: Text(value),
                    selected: filter == value,
                    onSelected: (_) => setState(() => filter = value),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            ...rows.map((unit) => _UnitRow(unit: unit)),
            if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Text('Aucune unité dans ce filtre pour le moment.'),
              ),
          ],
        );
      },
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.encountered, required this.total});
  final int encountered;
  final int total;

  @override
  Widget build(BuildContext context) => EchoCard(
    color: Theme.of(context).brightness == Brightness.dark
        ? EchoColors.nightCard
        : EchoColors.sky,
    child: Row(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            value: encountered / total,
            strokeWidth: 8,
            backgroundColor: Colors.white38,
            color: EchoColors.pine,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$encountered / $total unités',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              const Text('Vocabulaire, constructions et expressions'),
            ],
          ),
        ),
      ],
    ),
  );
}

class _UnitRow extends StatelessWidget {
  const _UnitRow({required this.unit});
  final LanguageUnit unit;

  @override
  Widget build(BuildContext context) {
    final session = EchoScope.of(context).sessionController;
    final mastery = session.masteryFor(unit.id);
    final nextDays = session.nextEncounterDays(unit.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.push(UnitLocation(unit.id).location),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final label = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.canonicalForm,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(unit.translation),
                  ],
                );
                final status = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EchoBadge(label: mastery.label),
                    if (nextDays > 0) ...[
                      const SizedBox(height: 5),
                      Text(
                        'À revoir dans $nextDays j',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                );

                if (constraints.maxWidth < 360) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: label),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      const SizedBox(height: 12),
                      status,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: label),
                    status,
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class LessonDetailScreen extends StatelessWidget {
  const LessonDetailScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final scope = EchoScope.of(context);
    final lesson = scope.lessonById(lessonId);
    final session = scope.sessionFor(lessonId);
    final durationMinutes = (lesson.fullAudio.duration.inSeconds / 60).ceil();
    return EchoDetailScaffold(
      title: 'Leçon ${lesson.number}',
      actions: [
        IconButton(
          tooltip: 'Changer de thème',
          onPressed: scope.appController.toggleTheme,
          icon: const Icon(Icons.contrast),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EchoBadge(
            label: 'FINNOIS ${lesson.level} · KIRJAKIELI',
            color: EchoColors.lichen,
          ),
          const SizedBox(height: 18),
          Text(lesson.title, style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 14),
          Text(
            '${lesson.activities.length} parties · environ $durationMinutes minutes d’audio · expression, lecture et mémorisation',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          AudioPlayerCard(
            audio: [lesson.fullAudio],
            label: 'Leçon audio complète',
          ),
          const SizedBox(height: 30),
          Text('Objectifs', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          ...lesson.objectives.map(
            (objective) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.check_circle,
                      color: EchoColors.clay,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(objective)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          Text('Le déroulé', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          ...List.generate(
            lesson.activities.length,
            (index) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(_activityTitle(lesson.activities[index].type)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                session.start(activity: index);
                context.push(SessionLocation(lesson.id).location);
              },
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              if (!session.started && !scope.placementController.completed) {
                context.push(PlacementLocation(lesson.id).location);
                return;
              }
              if (!session.started) {
                session.start();
              }
              context.push(SessionLocation(lesson.id).location);
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Commencer la leçon'),
          ),
        ],
      ),
    );
  }
}

class UnitDetailScreen extends StatelessWidget {
  const UnitDetailScreen({super.key, required this.unitId});
  final String unitId;

  @override
  Widget build(BuildContext context) {
    final scope = EchoScope.of(context);
    final lesson = scope.lessonContainingUnit(unitId);
    final unit = lesson?.unitById(unitId);
    if (unit == null) {
      return const EchoDetailScaffold(
        title: 'Unité',
        child: Text('Cette unité est introuvable.'),
      );
    }
    final examples = <DialogueLine>[
      ...lesson!.dialogue.where((line) => line.unitIds.contains(unit.id)),
      ...lesson.transferLines.where((line) => line.unitIds.contains(unit.id)),
    ].take(3);
    final session = scope.sessionFor(lesson.id);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final mastery = session.masteryFor(unit.id);
        return EchoDetailScaffold(
          title: 'Détail de l’unité',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EchoBadge(label: _unitType(unit.type), color: EchoColors.sky),
              const SizedBox(height: 18),
              Text(
                unit.canonicalForm,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                unit.translation,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  EchoBadge(label: mastery.label),
                  EchoBadge(
                    label:
                        '${mastery.encounters} rencontre${mastery.encounters > 1 ? 's' : ''}',
                  ),
                  EchoBadge(label: unit.register),
                ],
              ),
              const SizedBox(height: 24),
              if (examples.isNotEmpty) ...[
                AudioPlayerCard(
                  audio: [lesson.audioForLine(examples.first.id)],
                  label: 'Exemple audio',
                ),
                const SizedBox(height: 28),
              ],
              Text(
                'Dans la leçon',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              if (examples.isEmpty)
                const Text('Cette unité apparaît dans la lecture interactive.'),
              for (final line in examples)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EchoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.text,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(line.translation),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                mastery.encounters == 0
                    ? 'Prochaine rencontre : pendant la leçon.'
                    : 'Prochaine rencontre suggérée : dans ${session.nextEncounterDays(unit.id)} jour(s).',
              ),
            ],
          ),
        );
      },
    );
  }
}

String _unitType(String type) => switch (type) {
  'construction' => 'Construction',
  'expression' => 'Expression',
  'noun' => 'Nom',
  'adjective' => 'Adjectif',
  'place' => 'Lieu',
  'greeting' => 'Salutation',
  _ => 'Unité',
};

String _activityTitle(String type) => switch (type) {
  'context' => 'La scène et les personnages',
  'global_listening' => 'Leçon audio',
  'active_recall' => 'Rappel actif',
  'roleplay' => 'Deux jeux de rôle',
  'transition' => 'Passer à la lecture',
  'reading' => 'Lecture interactive',
  'reading_comprehension' => 'Compréhension écrite',
  'memory' => 'Memory',
  'adaptive_games' => 'Mini-jeux',
  'audio_transfer' => 'Transfert audio',
  'guided_writing' => 'Production écrite',
  'selective_flashcards' => 'Flashcards',
  'summary_and_spacing' => 'Bilan',
  _ => type,
};

String _todayLabel() {
  const weekdays = [
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
    'dimanche',
  ];
  const months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];
  final now = DateTime.now();
  return '${weekdays[now.weekday - 1]} · ${now.day} ${months[now.month - 1]}';
}
