import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/utils/normalize_vi.dart';
import '../../providers.dart';
import '../../widgets/track_tile.dart';

final _searchResultsProvider = StreamProvider.family<List<Track>, String>((
  ref,
  query,
) {
  if (query.isEmpty) return Stream.value(const []);
  return ref
      .watch(databaseProvider)
      .watchSearch(query)
      .map(
        (list) => List.of(list)..sort((a, b) => compareVi(a.title, b.title)),
      );
});

/// Type to search; accents are optional ("nhac buon" finds "Nhạc Buồn").
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(_searchResultsProvider(_query));
    final folders = {
      for (final f in ref.watch(foldersProvider).value ?? const <Folder>[])
        f.id: f.displayName,
    };

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Tên bài, ca sĩ, tên file…',
            border: InputBorder.none,
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
          onChanged: (v) => setState(() => _query = normalizeVi(v)),
        ),
      ),
      body: results.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (list) {
          if (_query.isEmpty) {
            return const Center(child: Text('Gõ để tìm trong mọi thư mục'));
          }
          if (list.isEmpty) {
            return const Center(child: Text('Không tìm thấy bài nào'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => TrackTile(
              track: list[i],
              siblings: list,
              subtitlePrefix: folders[list[i].folderId],
            ),
          );
        },
      ),
    );
  }
}
