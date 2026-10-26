import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/filename_parser.dart';
import '../../providers.dart';
import '../../widgets/cover_art.dart';
import '../../widgets/playback_actions.dart';
import 'youtube_service.dart';

/// Paste a YouTube link, then play it as a stream or download the audio.
class YoutubeScreen extends ConsumerStatefulWidget {
  const YoutubeScreen({super.key});

  @override
  ConsumerState<YoutubeScreen> createState() => _YoutubeScreenState();
}

class _YoutubeScreenState extends ConsumerState<YoutubeScreen> {
  final _link = TextEditingController();
  YoutubeVideoInfo? _info;
  bool _loading = false;

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      if (mounted) showMessage(context, 'Clipboard đang trống');
      return;
    }
    _link.text = text;
    await _lookup();
  }

  Future<void> _lookup() async {
    final link = _link.text.trim();
    if (link.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _info = null;
    });
    try {
      final info = await ref.read(youtubeProvider).lookup(link);
      if (mounted) setState(() => _info = info);
    } on FormatException catch (e) {
      if (mounted) showMessage(context, e.message);
    } catch (e) {
      if (mounted) showMessage(context, 'Không lấy được video: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(youtubeHistoryProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _link,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _lookup(),
            decoration: InputDecoration(
              hintText: 'Dán link YouTube',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _lookup,
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _loading ? null : _paste,
            icon: const Icon(Icons.content_paste),
            label: const Text('Dán từ clipboard'),
          ),
          const SizedBox(height: 16),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_info != null) _VideoCard(info: _info!),
          if (history.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Đã dán gần đây',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (final h in history)
              Dismissible(
                key: ValueKey('yt-${h.id}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) =>
                    ref.read(databaseProvider).deleteHistory(h.id),
                background: Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete_outline),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CoverArt(url: h.thumbnailUrl, size: 48),
                  title: Text(
                    h.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    h.downloadedTrackId != null
                        ? '${h.author} · Đã tải'
                        : h.author,
                    maxLines: 1,
                  ),
                  onTap: () =>
                      setState(() => _info = YoutubeVideoInfo.fromHistory(h)),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _VideoCard extends ConsumerWidget {
  const _VideoCard({required this.info});
  final YoutubeVideoInfo info;

  Future<void> _playNow(
    BuildContext context,
    WidgetRef ref,
    int? trackId,
  ) async {
    final handler = ref.read(audioHandlerProvider);
    // Prefer the downloaded copy: works offline and needs no URL resolving.
    if (trackId != null) {
      final t = await ref.read(databaseProvider).trackById(trackId);
      if (t != null) {
        final e = await ref.read(libraryProvider).entryFor(t);
        if (e != null) return handler.playEntries([e], 0);
      }
    }
    await handler.playEntries([info.toStreamEntry()], 0);
  }

  Future<void> _download(BuildContext context, WidgetRef ref) async {
    try {
      final id = await ref.read(downloadsProvider.notifier).start(info);
      if (id != null && context.mounted) {
        showMessage(context, 'Đã tải xong: ${info.title}');
      }
    } catch (e) {
      if (context.mounted) showMessage(context, 'Tải về thất bại: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(downloadsProvider)[info.id];
    final history = ref.watch(youtubeHistoryProvider).value ?? const [];
    final downloadedId = history
        .where((h) => h.videoId == info.id)
        .firstOrNull
        ?.downloadedTrackId;
    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              info.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.smart_display, size: 64),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.title, style: text.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${info.author} · ${formatDuration(info.duration)}',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 12),
                if (progress != null) ...[
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Đang tải ${(progress * 100).toStringAsFixed(0)}%'),
                      const Spacer(),
                      TextButton(
                        onPressed: () => ref
                            .read(downloadsProvider.notifier)
                            .cancel(info.id),
                        child: const Text('Hủy'),
                      ),
                    ],
                  ),
                ],
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _playNow(context, ref, downloadedId),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Phát ngay'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: (progress != null || downloadedId != null)
                            ? null
                            : () => _download(context, ref),
                        icon: Icon(
                          downloadedId != null
                              ? Icons.download_done
                              : Icons.download,
                        ),
                        label: Text(downloadedId != null ? 'Đã tải' : 'Tải về'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
