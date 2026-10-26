import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/filename_parser.dart';
import '../../providers.dart';
import '../../widgets/cover_art.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(mediaItemProvider).value;
    final state = ref.watch(playbackStateProvider).value;
    final handler = ref.read(audioHandlerProvider);
    final text = Theme.of(context).textTheme;
    final playing = state?.playing ?? false;
    final ps = state?.processingState;
    final buffering =
        ps == AudioProcessingState.loading ||
        ps == AudioProcessingState.buffering;
    final repeat = state?.repeatMode ?? AudioServiceRepeatMode.none;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
          onPressed: () => context.pop(),
        ),
        title: Text(item?.album ?? '', style: text.titleSmall),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Hàng đợi',
            icon: const Icon(Icons.queue_music_rounded),
            onPressed: () => context.push('/queue'),
          ),
        ],
      ),
      body: item == null
          ? const Center(child: Text('Chưa chọn bài nào'))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(),
                    LayoutBuilder(
                      builder: (_, c) => Hero(
                        tag: 'cover',
                        child: CoverArt.fromUri(
                          item.artUri,
                          size: c.maxWidth.clamp(0, 360),
                          radius: 16,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.artist ?? '',
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SeekBar(duration: item.duration),
                    const SizedBox(height: 8),
                    _Controls(playing: playing, buffering: buffering),
                    const SizedBox(height: 8),
                    _RepeatButton(mode: repeat, onPressed: handler.cycleRepeat),
                    const Spacer(),
                  ],
                ),
              ),
            ),
    );
  }
}

class _Controls extends ConsumerWidget {
  const _Controls({required this.playing, required this.buffering});

  final bool playing;
  final bool buffering;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handler = ref.read(audioHandlerProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: 'Lùi 5 giây',
          iconSize: 30,
          icon: const Icon(Icons.replay_5_rounded),
          onPressed: handler.rewind,
        ),
        IconButton(
          tooltip: 'Bài trước',
          iconSize: 40,
          icon: const Icon(Icons.skip_previous_rounded),
          onPressed: handler.skipToPrevious,
        ),
        SizedBox.square(
          dimension: 76,
          child: buffering
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                )
              : IconButton.filled(
                  iconSize: 48,
                  icon: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                  onPressed: playing ? handler.pause : handler.play,
                ),
        ),
        IconButton(
          tooltip: 'Bài sau',
          iconSize: 40,
          icon: const Icon(Icons.skip_next_rounded),
          onPressed: handler.skipToNext,
        ),
        IconButton(
          tooltip: 'Tới 5 giây',
          iconSize: 30,
          icon: const Icon(Icons.forward_5_rounded),
          onPressed: handler.fastForward,
        ),
      ],
    );
  }
}

class _RepeatButton extends StatelessWidget {
  const _RepeatButton({required this.mode, required this.onPressed});

  final AudioServiceRepeatMode mode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, label, active) = switch (mode) {
      AudioServiceRepeatMode.none => (Icons.repeat_rounded, 'Không lặp', false),
      AudioServiceRepeatMode.one => (
        Icons.repeat_one_rounded,
        'Lặp 1 bài',
        true,
      ),
      _ => (Icons.repeat_rounded, 'Lặp hàng đợi', true),
    };
    final color = active ? scheme.primary : scheme.onSurfaceVariant;
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color)),
    );
  }
}

/// Slider that only seeks when the drag ends, so dragging stays smooth.
class _SeekBar extends ConsumerStatefulWidget {
  const _SeekBar({required this.duration});
  final Duration? duration;

  @override
  ConsumerState<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends ConsumerState<_SeekBar> {
  double? _dragMs;

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final totalMs = (widget.duration?.inMilliseconds ?? 0).toDouble();
    final max = totalMs <= 0 ? 1.0 : totalMs;
    final valueMs = (_dragMs ?? position.inMilliseconds.toDouble()).clamp(
      0.0,
      max,
    );
    final style = Theme.of(context).textTheme.bodySmall;
    return Column(
      children: [
        Slider(
          value: valueMs,
          max: max,
          onChanged: totalMs <= 0 ? null : (v) => setState(() => _dragMs = v),
          onChangeEnd: (v) {
            ref
                .read(audioHandlerProvider)
                .seek(Duration(milliseconds: v.round()));
            setState(() => _dragMs = null);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(Duration(milliseconds: valueMs.round())),
                style: style,
              ),
              Text(formatDuration(widget.duration), style: style),
            ],
          ),
        ),
      ],
    );
  }
}
