import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../app/echo_app.dart';
import '../app/echo_theme.dart';
import '../app/route_locations.dart';
import '../controllers/audio_controller.dart';
import '../data/models.dart';

class EchoShell extends StatelessWidget {
  const EchoShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const _destinations = <_Destination>[
    _Destination(
      EchoRoute.today,
      'Aujourd’hui',
      Icons.wb_sunny_outlined,
      Icons.wb_sunny,
    ),
    _Destination(EchoRoute.path, 'Parcours', Icons.route_outlined, Icons.route),
    _Destination(
      EchoRoute.library,
      'Bibliothèque',
      Icons.auto_stories_outlined,
      Icons.auto_stories,
    ),
    _Destination(EchoRoute.progress, 'Acquis', Icons.spa_outlined, Icons.spa),
  ];

  int get _index {
    final value = _destinations.indexWhere(
      (item) => location == item.route.location,
    );
    return value < 0 ? 0 : value;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) =>
        _build(context, constraints.maxWidth >= 600),
  );

  Widget _build(BuildContext context, bool wide) {
    final themeButton = IconButton(
      tooltip: Theme.of(context).brightness == Brightness.dark
          ? 'Activer le thème clair'
          : 'Activer le thème sombre',
      onPressed: EchoScope.of(context).appController.toggleTheme,
      icon: Icon(
        Theme.of(context).brightness == Brightness.dark
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
      ),
    );
    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 220,
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: EchoLogo(),
                    ),
                    const SizedBox(height: 42),
                    for (var index = 0; index < _destinations.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _RailItem(
                          destination: _destinations[index],
                          selected: index == _index,
                          onTap: () =>
                              context.go(_destinations[index].route.location),
                        ),
                      ),
                    const Spacer(),
                    Align(alignment: Alignment.centerLeft, child: themeButton),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: Text(
                        'SUOMI · A1\nkirjakieli',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
            Expanded(child: child),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: const EchoLogo(compact: true),
        actions: [themeButton, const SizedBox(width: 8)],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) =>
            context.go(_destinations[index].route.location),
        destinations: [
          for (final destination in _destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination(this.route, this.label, this.icon, this.selectedIcon);
  final EchoRoute route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected
        ? Theme.of(context).colorScheme.primary.withValues(alpha: .12)
        : Colors.transparent,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(
              selected ? destination.selectedIcon : destination.icon,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                destination.label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            if (selected)
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: EchoColors.clay,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class EchoLogo extends StatelessWidget {
  const EchoLogo({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Echo',
    container: true,
    child: ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            Theme.of(context).brightness == Brightness.dark
                ? 'design-showcase/assets/echo-mark-flat.svg'
                : 'design-showcase/assets/echo-mark.svg',
            width: 36,
            height: 36,
            colorFilter: Theme.of(context).brightness == Brightness.dark
                ? const ColorFilter.mode(EchoColors.lichen, BlendMode.srcIn)
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            'echo',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'DM Sans',
              fontSize: compact ? 24 : 28,
              height: 1,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.7,
            ),
          ),
        ],
      ),
    ),
  );
}

class EchoPage extends StatelessWidget {
  const EchoPage({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final horizontal = constraints.maxWidth < 600 ? 20.0 : 42.0;
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontal, 34, horizontal, 48),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(title, style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: .7),
                    ),
                  ),
                ),
                const SizedBox(height: 34),
                ...children,
              ],
            ),
          ),
        ),
      );
    },
  );
}

class EchoDetailScaffold extends StatelessWidget {
  const EchoDetailScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions = const <Widget>[],
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      actions: actions,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: child,
          ),
        ),
      ),
    ),
  );
}

class EchoCard extends StatelessWidget {
  const EchoCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.editorial = false,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final bool editorial;

  @override
  Widget build(BuildContext context) => Card(
    color: color,
    semanticContainer: false,
    shape: editorial
        ? RoundedRectangleBorder(
            side: Theme.of(context).brightness == Brightness.dark
                ? BorderSide(color: EchoColors.paper.withValues(alpha: .14))
                : BorderSide.none,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(30),
            ),
          )
        : null,
    child: Padding(padding: padding ?? const EdgeInsets.all(24), child: child),
  );
}

class EchoBadge extends StatelessWidget {
  const EchoBadge({super.key, required this.label, this.color});
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color:
          color ?? Theme.of(context).colorScheme.primary.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
    ),
  );
}

class AudioPlayerCard extends StatefulWidget {
  const AudioPlayerCard({
    super.key,
    required this.audio,
    this.compact = false,
    this.label,
    this.preload = false,
  }) : assert(audio.length > 0);

  final List<LessonAudio> audio;
  final bool compact;
  final String? label;
  final bool preload;

  @override
  State<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard> {
  AudioController? _controller;
  List<String> _scheduledPaths = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = EchoScope.of(context).audioController;
    _schedulePreload();
  }

  @override
  void didUpdateWidget(AudioPlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _schedulePreload();
  }

  void _schedulePreload() {
    if (!widget.preload || _controller == null) return;
    final paths = widget.audio
        .map((item) => item.assetPath)
        .toList(growable: false);
    if (listEquals(paths, _scheduledPaths)) return;
    _scheduledPaths = List.unmodifiable(paths);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await _controller!.preload(widget.audio);
      } catch (_) {
        // The play button retries and reports the error if preloading failed.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = EchoScope.of(context).audioController;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final active = controller.isActive(widget.audio);
        final loading = controller.isLoading(widget.audio);
        final duration = widget.audio.fold(
          Duration.zero,
          (total, item) => total + item.duration,
        );
        final maxMs = math.max(1, duration.inMilliseconds);
        final position = active ? controller.position : Duration.zero;
        final value = position.inMilliseconds.clamp(0, maxMs);
        final playing = active && controller.isPlaying;
        return Semantics(
          label: widget.label ?? 'Audio de la leçon',
          child: Container(
            padding: EdgeInsets.all(widget.compact ? 14 : 18),
            decoration: BoxDecoration(
              color: EchoColors.pine,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                IconButton.filled(
                  tooltip: playing ? 'Mettre en pause' : 'Écouter',
                  onPressed: () => _guardAudio(
                    context,
                    () => controller.toggle(widget.audio),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: EchoColors.lichen,
                    foregroundColor: EchoColors.pine,
                    minimumSize: Size.square(widget.compact ? 48 : 56),
                  ),
                  icon: loading && !active
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Icon(playing ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final playerLabel =
                              widget.label ??
                              (widget.audio.length == 1
                                  ? 'Écouter'
                                  : 'Écouter la séquence');
                          final timeLabel =
                              '${_durationLabel(position)} / ${_durationLabel(duration)}';
                          final stacked =
                              constraints.maxWidth < 260 ||
                              MediaQuery.textScalerOf(context).scale(1) > 1.4;
                          final title = Text(
                            playerLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          );
                          final time = Text(
                            timeLabel,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          );
                          if (stacked) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                title,
                                const SizedBox(height: 4),
                                time,
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: title),
                              const SizedBox(width: 8),
                              time,
                            ],
                          );
                        },
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          activeTrackColor: EchoColors.lichen,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: EchoColors.paper,
                          overlayColor: EchoColors.sky.withValues(alpha: .2),
                        ),
                        child: Slider(
                          value: value.toDouble(),
                          max: maxMs.toDouble(),
                          onChanged: duration == Duration.zero || !active
                              ? null
                              : (next) => controller.seek(
                                  Duration(milliseconds: next.round()),
                                ),
                        ),
                      ),
                      Text(
                        widget.audio.length == 1
                            ? 'Audio de la leçon'
                            : '${widget.audio.length} extraits enchaînés',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          letterSpacing: .4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> _guardAudio(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de lire cet audio.')),
      );
    }
  }
}

String _durationLabel(Duration value) {
  final minutes = value.inMinutes;
  final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class WaveDecoration extends StatelessWidget {
  const WaveDecoration({super.key, this.color = EchoColors.sky});

  final Color color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: 54,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final height in const <double>[18, 31, 48, 25, 39, 19, 44, 28])
            Container(
              width: 6,
              height: height,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    ),
  );
}
