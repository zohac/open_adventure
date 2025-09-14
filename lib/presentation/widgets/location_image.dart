// lib/presentation/widgets/location_image.dart
// Scene image widget for locations with pixel-art friendly rendering.

import 'package:flutter/material.dart';
import 'package:open_adventure/core/utils/location_image.dart';
import 'package:open_adventure/presentation/widgets/pixel_canvas.dart';

class LocationImage extends StatelessWidget {
  const LocationImage({
    super.key,
    this.mapTag,
    this.name,
    this.id,
    this.aspectRatio = 16 / 9,
    this.backgroundColor = Colors.black,
    this.semanticsLabel,
    this.enablePixelCanvas = true,
  });

  final String? mapTag;
  final String? name;
  final int? id;
  final double aspectRatio;
  final Color backgroundColor;
  final String? semanticsLabel;
  final bool enablePixelCanvas;

  @override
  Widget build(BuildContext context) {
    final String key = computeLocationImageKey(mapTag: mapTag, name: name, id: id);
    final String path = imageAssetPathFromKey(key);

    Widget img = Image.asset(
      path,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.none,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );

    if (enablePixelCanvas) {
      img = PixelCanvas(
        backgroundColor: backgroundColor,
        child: img,
      );
    }

    return Semantics(
      label: semanticsLabel ?? name ?? mapTag ?? 'scene image',
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: img,
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: backgroundColor.withOpacity(0.2),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, color: Colors.white54, size: 24),
    );
  }
}

