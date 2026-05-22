// Open Adventure color tokens — port of `design_handoff_open_adventure/tokens.css`.
//
// Theme: "Carnet d'explorateur sous la lanterne". Dark only (ADR-003).
// Consumed via `Theme.of(context).extension<OAColors>()` or
// `context.oaColors` (see [`build_context_x.dart`]).

import 'package:flutter/material.dart';

@immutable
class OAInkPalette {
  const OAInkPalette({
    required this.voidColor,
    required this.deep,
    required this.mid,
    required this.raised,
    required this.line,
    required this.hairline,
  });

  /// `--c-ink-void` — deepest darkness, full-screen base.
  final Color voidColor;

  /// `--c-ink-deep` — primary background.
  final Color deep;

  /// `--c-ink-mid` — panels, cards.
  final Color mid;

  /// `--c-ink-raised` — raised surface, hover.
  final Color raised;

  /// `--c-ink-line` — subtle borders.
  final Color line;

  /// `--c-ink-hairline` — divider lines.
  final Color hairline;

  OAInkPalette copyWith({
    Color? voidColor,
    Color? deep,
    Color? mid,
    Color? raised,
    Color? line,
    Color? hairline,
  }) {
    return OAInkPalette(
      voidColor: voidColor ?? this.voidColor,
      deep: deep ?? this.deep,
      mid: mid ?? this.mid,
      raised: raised ?? this.raised,
      line: line ?? this.line,
      hairline: hairline ?? this.hairline,
    );
  }

  static OAInkPalette lerp(OAInkPalette a, OAInkPalette b, double t) {
    return OAInkPalette(
      voidColor: Color.lerp(a.voidColor, b.voidColor, t)!,
      deep: Color.lerp(a.deep, b.deep, t)!,
      mid: Color.lerp(a.mid, b.mid, t)!,
      raised: Color.lerp(a.raised, b.raised, t)!,
      line: Color.lerp(a.line, b.line, t)!,
      hairline: Color.lerp(a.hairline, b.hairline, t)!,
    );
  }
}

@immutable
class OATealPalette {
  const OATealPalette({
    required this.mist,
    required this.deep,
    required this.glow,
  });

  /// `--c-teal-mist` — secondary text, idle icons.
  final Color mist;

  /// `--c-teal-deep` — secondary surface tint.
  final Color deep;

  /// `--c-teal-glow` — cool interactive (links, toggles).
  final Color glow;

  OATealPalette copyWith({Color? mist, Color? deep, Color? glow}) {
    return OATealPalette(
      mist: mist ?? this.mist,
      deep: deep ?? this.deep,
      glow: glow ?? this.glow,
    );
  }

  static OATealPalette lerp(OATealPalette a, OATealPalette b, double t) {
    return OATealPalette(
      mist: Color.lerp(a.mist, b.mist, t)!,
      deep: Color.lerp(a.deep, b.deep, t)!,
      glow: Color.lerp(a.glow, b.glow, t)!,
    );
  }
}

@immutable
class OAPaperPalette {
  const OAPaperPalette({
    required this.bright,
    required this.warm,
    required this.faded,
    required this.ink,
  });

  /// `--c-paper-bright` — H1/display, max contrast.
  final Color bright;

  /// `--c-paper-warm` — body text.
  final Color warm;

  /// `--c-paper-faded` — tertiary text, captions.
  final Color faded;

  /// `--c-paper-ink` — faded ink, watermarks.
  final Color ink;

  OAPaperPalette copyWith({
    Color? bright,
    Color? warm,
    Color? faded,
    Color? ink,
  }) {
    return OAPaperPalette(
      bright: bright ?? this.bright,
      warm: warm ?? this.warm,
      faded: faded ?? this.faded,
      ink: ink ?? this.ink,
    );
  }

  static OAPaperPalette lerp(OAPaperPalette a, OAPaperPalette b, double t) {
    return OAPaperPalette(
      bright: Color.lerp(a.bright, b.bright, t)!,
      warm: Color.lerp(a.warm, b.warm, t)!,
      faded: Color.lerp(a.faded, b.faded, t)!,
      ink: Color.lerp(a.ink, b.ink, t)!,
    );
  }
}

@immutable
class OAAmberPalette {
  const OAAmberPalette({
    required this.glow,
    required this.base,
    required this.deep,
    required this.shadow,
    required this.halo,
  });

  /// `--c-amber-glow` — lantern highlight.
  final Color glow;

  /// `--c-amber` — primary accent.
  final Color base;

  /// `--c-amber-deep` — pressed amber.
  final Color deep;

  /// `--c-amber-shadow` — amber shadow tone.
  final Color shadow;

  /// `--c-amber-halo` — lamp light wash (translucent).
  final Color halo;

  OAAmberPalette copyWith({
    Color? glow,
    Color? base,
    Color? deep,
    Color? shadow,
    Color? halo,
  }) {
    return OAAmberPalette(
      glow: glow ?? this.glow,
      base: base ?? this.base,
      deep: deep ?? this.deep,
      shadow: shadow ?? this.shadow,
      halo: halo ?? this.halo,
    );
  }

  static OAAmberPalette lerp(OAAmberPalette a, OAAmberPalette b, double t) {
    return OAAmberPalette(
      glow: Color.lerp(a.glow, b.glow, t)!,
      base: Color.lerp(a.base, b.base, t)!,
      deep: Color.lerp(a.deep, b.deep, t)!,
      shadow: Color.lerp(a.shadow, b.shadow, t)!,
      halo: Color.lerp(a.halo, b.halo, t)!,
    );
  }
}

@immutable
class OASemanticColors {
  const OASemanticColors({
    required this.treasure,
    required this.danger,
    required this.success,
    required this.magic,
  });

  /// `--c-treasure` — gold, treasures, score.
  final Color treasure;

  /// `--c-danger` — hostile, danger, low lamp.
  final Color danger;

  /// `--c-success` — discovery, success.
  final Color success;

  /// `--c-magic` — incantations, mystical.
  final Color magic;

  OASemanticColors copyWith({
    Color? treasure,
    Color? danger,
    Color? success,
    Color? magic,
  }) {
    return OASemanticColors(
      treasure: treasure ?? this.treasure,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      magic: magic ?? this.magic,
    );
  }

  static OASemanticColors lerp(
    OASemanticColors a,
    OASemanticColors b,
    double t,
  ) {
    return OASemanticColors(
      treasure: Color.lerp(a.treasure, b.treasure, t)!,
      danger: Color.lerp(a.danger, b.danger, t)!,
      success: Color.lerp(a.success, b.success, t)!,
      magic: Color.lerp(a.magic, b.magic, t)!,
    );
  }
}

/// Open Adventure color tokens, exposed as a [ThemeExtension].
///
/// Mirror of `design_handoff_open_adventure/tokens.css` (color section).
/// Access via `Theme.of(context).extension<OAColors>()!` or the
/// convenience getter `context.oaColors`.
@immutable
class OAColors extends ThemeExtension<OAColors> {
  const OAColors({
    required this.ink,
    required this.teal,
    required this.paper,
    required this.amber,
    required this.semantic,
  });

  final OAInkPalette ink;
  final OATealPalette teal;
  final OAPaperPalette paper;
  final OAAmberPalette amber;
  final OASemanticColors semantic;

  /// Canonical dark palette (Open Adventure 2026).
  static const OAColors dark = OAColors(
    ink: OAInkPalette(
      voidColor: Color(0xFF06101A),
      deep: Color(0xFF0D1D2D),
      mid: Color(0xFF16304A),
      raised: Color(0xFF1F4267),
      line: Color(0xFF2A5478),
      hairline: Color(0xFF1A3A5A),
    ),
    teal: OATealPalette(
      mist: Color(0xFF5A8FA8),
      deep: Color(0xFF2A4D6E),
      glow: Color(0xFF4EC5B8),
    ),
    paper: OAPaperPalette(
      bright: Color(0xFFFAF2DD),
      warm: Color(0xFFF0E4CC),
      faded: Color(0xFFC8B896),
      ink: Color(0xFF7A6A4E),
    ),
    amber: OAAmberPalette(
      glow: Color(0xFFFFC070),
      base: Color(0xFFF0A040),
      deep: Color(0xFFC97432),
      shadow: Color(0xFF8A4A1A),
      halo: Color.fromRGBO(240, 160, 64, 0.22),
    ),
    semantic: OASemanticColors(
      treasure: Color(0xFFD4A84A),
      danger: Color(0xFFD44A3A),
      success: Color(0xFF6EA34A),
      magic: Color(0xFF9870C4),
    ),
  );

  @override
  OAColors copyWith({
    OAInkPalette? ink,
    OATealPalette? teal,
    OAPaperPalette? paper,
    OAAmberPalette? amber,
    OASemanticColors? semantic,
  }) {
    return OAColors(
      ink: ink ?? this.ink,
      teal: teal ?? this.teal,
      paper: paper ?? this.paper,
      amber: amber ?? this.amber,
      semantic: semantic ?? this.semantic,
    );
  }

  @override
  OAColors lerp(ThemeExtension<OAColors>? other, double t) {
    if (other is! OAColors) return this;
    return OAColors(
      ink: OAInkPalette.lerp(ink, other.ink, t),
      teal: OATealPalette.lerp(teal, other.teal, t),
      paper: OAPaperPalette.lerp(paper, other.paper, t),
      amber: OAAmberPalette.lerp(amber, other.amber, t),
      semantic: OASemanticColors.lerp(semantic, other.semantic, t),
    );
  }
}
