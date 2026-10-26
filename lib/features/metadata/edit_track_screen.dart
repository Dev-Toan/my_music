import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/db/database.dart';
import '../../providers.dart';
import '../../widgets/cover_art.dart';
import '../../widgets/playback_actions.dart';

/// Edit display name, artist and cover. Stored in the app DB only; the mp3
/// file itself is never modified.
class EditTrackScreen extends ConsumerWidget {
  const EditTrackScreen({super.key, required this.trackId});
  final int trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(trackProvider(trackId));
    return track.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Lỗi: $e'))),
      data: (t) => t == null
          ? const Scaffold(
              body: Center(child: Text('Bài hát không còn tồn tại')),
            )
          : _EditForm(track: t),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.track});
  final Track track;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  late final _title = TextEditingController(text: widget.track.title);
  late final _artist = TextEditingController(text: widget.track.artist ?? '');
  String? _newCover;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _artist.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 90,
    );
    if (img != null) setState(() => _newCover = img.path);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(libraryProvider)
          .updateMetadata(
            widget.track,
            title: _title.text,
            artist: _artist.text,
            newCoverSource: _newCover,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) showMessage(context, 'Không lưu được: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paths = ref.watch(pathsProvider);
    final cover = _newCover != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_newCover!),
              width: 180,
              height: 180,
              fit: BoxFit.cover,
            ),
          )
        : CoverArt(
            file: paths.absoluteCover(widget.track.coverPath),
            size: 180,
            radius: 12,
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa thông tin'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Lưu'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: GestureDetector(onTap: _pickCover, child: cover),
          ),
          Center(
            child: TextButton.icon(
              onPressed: _pickCover,
              icon: const Icon(Icons.image_outlined),
              label: const Text('Chọn ảnh bìa'),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Tên bài hát'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _artist,
            decoration: const InputDecoration(labelText: 'Ca sĩ'),
          ),
          const SizedBox(height: 24),
          Text(
            'File: ${widget.track.fileName}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
