import 'package:flutter_test/flutter_test.dart';
import 'package:my_music/core/audio/queue_entry.dart';
import 'package:my_music/core/utils/filename_parser.dart';
import 'package:my_music/core/utils/normalize_vi.dart';
import 'package:my_music/core/utils/youtube_link.dart';

void main() {
  group('parseFileName', () {
    test('splits "Artist - Title"', () {
      expect(
        parseFileName('Sơn Tùng - Lạc Trôi.mp3'),
        const ParsedName('Lạc Trôi', 'Sơn Tùng'),
      );
    });
    test('accepts en dash and underscores', () {
      expect(
        parseFileName('Den_Vau – Bai Nay Chill Phet.mp3'),
        const ParsedName('Bai Nay Chill Phet', 'Den Vau'),
      );
    });
    test('falls back to the base name', () {
      expect(
        parseFileName('nhac-buon-2024.mp3'),
        const ParsedName('nhac-buon-2024', null),
      );
    });
  });

  test('sanitizeFileName strips illegal characters', () {
    expect(sanitizeFileName('a/b:c*?"<>|d'), 'a b c d');
    expect(sanitizeFileName('   '), 'audio');
  });

  test('formatDuration', () {
    expect(formatDuration(const Duration(seconds: 65)), '01:05');
    expect(formatDuration(const Duration(hours: 1, seconds: 3)), '1:00:03');
    expect(formatDuration(null), '--:--');
  });

  group('normalizeVi', () {
    test('removes accents, đ and case', () {
      expect(normalizeVi('Nhạc Buồn'), 'nhac buon');
      expect(normalizeVi('ĐÔNG  Đến'), 'dong den');
    });
    test('compareVi sorts accented words with their base letters', () {
      final list = ['Ước', 'Anh', 'Ăn', 'Bé']..sort(compareVi);
      expect(list.first, anyOf('Anh', 'Ăn'));
      expect(list.last, 'Ước');
    });
  });

  group('extractYoutubeId', () {
    const id = 'dQw4w9WgXcQ';
    for (final link in [
      'https://www.youtube.com/watch?v=$id',
      'https://youtube.com/watch?v=$id&list=RD123&t=42s',
      'https://m.youtube.com/watch?v=$id',
      'https://music.youtube.com/watch?v=$id&si=abc',
      'https://youtu.be/$id?si=xyz',
      'https://www.youtube.com/shorts/$id',
      'https://www.youtube.com/embed/$id',
      'youtu.be/$id',
      id,
    ]) {
      test(link, () => expect(extractYoutubeId(link), id));
    }
    test('rejects non-YouTube links', () {
      expect(extractYoutubeId('https://example.com/watch?v=$id'), isNull);
      expect(extractYoutubeId('hello'), isNull);
    });
  });

  group('QueueMath', () {
    test('playNextIndex inserts after current', () {
      expect(QueueMath.playNextIndex(2, 5), 3);
      expect(QueueMath.playNextIndex(4, 5), 5);
      expect(QueueMath.playNextIndex(null, 5), 5);
    });
    test('clampSeek keeps within bounds', () {
      const d = Duration(seconds: 100);
      expect(
        QueueMath.clampSeek(
          const Duration(seconds: 3),
          const Duration(seconds: -5),
          d,
        ),
        Duration.zero,
      );
      expect(
        QueueMath.clampSeek(
          const Duration(seconds: 97),
          const Duration(seconds: 5),
          d,
        ),
        d,
      );
      expect(
        QueueMath.clampSeek(
          const Duration(seconds: 50),
          const Duration(seconds: 5),
          d,
        ),
        const Duration(seconds: 55),
      );
    });
    test('indexAfterMove tracks the current item', () {
      expect(QueueMath.indexAfterMove(2, 2, 0), 0);
      expect(QueueMath.indexAfterMove(2, 0, 3), 1);
      expect(QueueMath.indexAfterMove(2, 4, 1), 3);
      expect(QueueMath.indexAfterMove(2, 4, 3), 2);
    });
  });

  test('QueueEntry json round-trip drops transient fields', () {
    const e = QueueEntry(
      trackId: 7,
      title: 'A',
      artist: 'B',
      filePath: '/x.mp3',
    );
    final back = QueueEntry.fromJson(e.toJson());
    expect(back.id, 't:7');
    expect(back.filePath, isNull);
    expect(back.isStream, isFalse);
  });
}
