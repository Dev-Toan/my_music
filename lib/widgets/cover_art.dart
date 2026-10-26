import 'dart:io';

import 'package:flutter/material.dart';

/// Square cover: local file, else network thumbnail, else a music note.
class CoverArt extends StatelessWidget {
  const CoverArt({
    super.key,
    this.file,
    this.url,
    this.size = 48,
    this.radius = 6,
  });

  final String? file;
  final String? url;
  final double size;
  final double radius;

  factory CoverArt.fromUri(Uri? uri, {double size = 48, double radius = 6}) {
    if (uri == null) return CoverArt(size: size, radius: radius);
    if (uri.isScheme('file')) {
      return CoverArt(file: uri.toFilePath(), size: size, radius: radius);
    }
    return CoverArt(url: uri.toString(), size: size, radius: radius);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.music_note_rounded,
        size: size * 0.5,
        color: scheme.onSurfaceVariant,
      ),
    );
    Widget child = placeholder;
    if (file != null) {
      child = Image.file(
        File(file!),
        fit: BoxFit.cover,
        cacheWidth: (size * 3).round(),
        errorBuilder: (_, _, _) => placeholder,
      );
    } else if (url != null) {
      child = Image.network(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(dimension: size, child: child),
    );
  }
}
