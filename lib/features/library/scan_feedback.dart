import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../widgets/playback_actions.dart';
import 'library_repository.dart';

String? describeScan(ScanResult r) {
  final parts = <String>[
    if (r.added > 0) '+${r.added} bài mới',
    if (r.removed > 0) '-${r.removed} bài đã xóa',
    if (r.icloudPending > 0)
      '${r.icloudPending} bài đang tải từ iCloud, kéo để làm mới sau',
    if (r.failedFolders.isNotEmpty)
      'Không mở được: ${r.failedFolders.join(', ')}',
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

Future<void> runScan(BuildContext context, WidgetRef ref) async {
  try {
    final r = await ref.read(scanProvider.notifier).scanAll();
    final msg = r == null ? null : describeScan(r);
    if (msg != null && context.mounted) showMessage(context, msg);
  } catch (e) {
    if (context.mounted) showMessage(context, 'Quét thư mục lỗi: $e');
  }
}

Future<void> addFolder(BuildContext context, WidgetRef ref) async {
  try {
    final id = await ref.read(libraryProvider).pickAndAddFolder();
    if (id != null && context.mounted) showMessage(context, 'Đã thêm thư mục');
  } catch (e) {
    if (context.mounted) showMessage(context, 'Không thêm được thư mục: $e');
  }
}
