// Open Adventure shadow tokens — port of `tokens.css` (`--sh-block-*`).
// Story 5-3 base + Story 5-4 finding R3.
//
// Pixel-art "rubber stamp" offset shadows. Hard offset, blur 0.

import 'package:flutter/material.dart';

@immutable
class OAShadows extends ThemeExtension<OAShadows> {
  const OAShadows({
    required this.blockSmall,
    required this.blockMedium,
    required this.blockLarge,
  });

  /// `--sh-block-sm` — 2dp offset (secondary stamps, item tiles).
  final Offset blockSmall;

  /// `--sh-block-md` — 3dp offset (primary stamps, treasures).
  final Offset blockMedium;

  /// `--sh-block-lg` — 4dp offset (premium / emphasis).
  final Offset blockLarge;

  /// Canonical pixel-art block shadows.
  static const OAShadows standard = OAShadows(
    blockSmall: Offset(2, 2),
    blockMedium: Offset(3, 3),
    blockLarge: Offset(4, 4),
  );

  @override
  OAShadows copyWith({
    Offset? blockSmall,
    Offset? blockMedium,
    Offset? blockLarge,
  }) {
    return OAShadows(
      blockSmall: blockSmall ?? this.blockSmall,
      blockMedium: blockMedium ?? this.blockMedium,
      blockLarge: blockLarge ?? this.blockLarge,
    );
  }

  @override
  OAShadows lerp(ThemeExtension<OAShadows>? other, double t) {
    if (other is! OAShadows) return this;
    return OAShadows(
      blockSmall: Offset.lerp(blockSmall, other.blockSmall, t)!,
      blockMedium: Offset.lerp(blockMedium, other.blockMedium, t)!,
      blockLarge: Offset.lerp(blockLarge, other.blockLarge, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OAShadows &&
        other.blockSmall == blockSmall &&
        other.blockMedium == blockMedium &&
        other.blockLarge == blockLarge;
  }

  @override
  int get hashCode => Object.hash(blockSmall, blockMedium, blockLarge);
}
