// Open Adventure typography tokens — port of `tokens.css` (`--f-*`, `--t-*`).
//
// Three families embarquées (`pubspec.yaml`), zéro `google_fonts` runtime
// (offline-only). Consommé via `context.oaTypography`.

import 'package:flutter/material.dart';

/// Font family constants (declared once, used everywhere).
abstract final class OAFontFamily {
  /// `--f-display` — Pixelify Sans (pixel chrome, titres).
  static const String display = 'PixelifySans';

  /// `--f-caps` — Silkscreen (caps lock micro-labels, tags).
  static const String caps = 'Silkscreen';

  /// `--f-body` — DM Sans (descriptions, long-form).
  static const String body = 'DMSans';

  /// `--f-mono` — JetBrains Mono (fallback monospace). Non embarquée pour
  /// l'instant ; Flutter retombera sur la fonte mono système.
  static const String mono = 'JetBrainsMono';
}

@immutable
class OADisplayStyles {
  const OADisplayStyles({
    required this.xl,
    required this.l,
    required this.m,
    required this.s,
  });

  /// `--t-display-xl` 40px — hero titles, game title.
  final TextStyle xl;

  /// `--t-display-l` 28px — location names.
  final TextStyle l;

  /// `--t-display-m` 22px — section heads.
  final TextStyle m;

  /// `--t-display-s` 18px — sub-heads.
  final TextStyle s;

  OADisplayStyles copyWith({
    TextStyle? xl,
    TextStyle? l,
    TextStyle? m,
    TextStyle? s,
  }) {
    return OADisplayStyles(
      xl: xl ?? this.xl,
      l: l ?? this.l,
      m: m ?? this.m,
      s: s ?? this.s,
    );
  }

  static OADisplayStyles lerp(
    OADisplayStyles a,
    OADisplayStyles b,
    double t,
  ) {
    return OADisplayStyles(
      xl: TextStyle.lerp(a.xl, b.xl, t)!,
      l: TextStyle.lerp(a.l, b.l, t)!,
      m: TextStyle.lerp(a.m, b.m, t)!,
      s: TextStyle.lerp(a.s, b.s, t)!,
    );
  }
}

@immutable
class OACapsStyles {
  const OACapsStyles({required this.m, required this.s});

  /// `--t-caps-m` 12px — status pills, tabs.
  final TextStyle m;

  /// `--t-caps-s` 10px — micro-labels.
  final TextStyle s;

  OACapsStyles copyWith({TextStyle? m, TextStyle? s}) {
    return OACapsStyles(m: m ?? this.m, s: s ?? this.s);
  }

  static OACapsStyles lerp(OACapsStyles a, OACapsStyles b, double t) {
    return OACapsStyles(
      m: TextStyle.lerp(a.m, b.m, t)!,
      s: TextStyle.lerp(a.s, b.s, t)!,
    );
  }
}

@immutable
class OABodyStyles {
  const OABodyStyles({required this.l, required this.m, required this.s});

  /// `--t-body-l` 17px — description, long-form.
  final TextStyle l;

  /// `--t-body-m` 15px — default body.
  final TextStyle m;

  /// `--t-body-s` 13px — secondary body.
  final TextStyle s;

  OABodyStyles copyWith({TextStyle? l, TextStyle? m, TextStyle? s}) {
    return OABodyStyles(
      l: l ?? this.l,
      m: m ?? this.m,
      s: s ?? this.s,
    );
  }

  static OABodyStyles lerp(OABodyStyles a, OABodyStyles b, double t) {
    return OABodyStyles(
      l: TextStyle.lerp(a.l, b.l, t)!,
      m: TextStyle.lerp(a.m, b.m, t)!,
      s: TextStyle.lerp(a.s, b.s, t)!,
    );
  }
}

/// Typography tokens exposed as a [ThemeExtension].
@immutable
class OATypography extends ThemeExtension<OATypography> {
  const OATypography({
    required this.display,
    required this.caps,
    required this.body,
    required this.action,
    required this.mono,
  });

  final OADisplayStyles display;
  final OACapsStyles caps;
  final OABodyStyles body;

  /// `--t-action` 16px — action button label.
  final TextStyle action;

  /// `--f-mono` styled as `--t-body-s`.
  final TextStyle mono;

  /// Canonical typography (port direct de `tokens.css`).
  static const OATypography standard = OATypography(
    display: OADisplayStyles(
      xl: TextStyle(
        fontFamily: OAFontFamily.display,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.05,
        letterSpacing: 0.8, // 0.02em * 40
      ),
      l: TextStyle(
        fontFamily: OAFontFamily.display,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: 0.28, // 0.01em * 28
      ),
      m: TextStyle(
        fontFamily: OAFontFamily.display,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.15,
      ),
      s: TextStyle(
        fontFamily: OAFontFamily.display,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
    ),
    caps: OACapsStyles(
      m: TextStyle(
        fontFamily: OAFontFamily.caps,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.96, // 0.08em * 12
      ),
      s: TextStyle(
        fontFamily: OAFontFamily.caps,
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.0, // 0.1em * 10
      ),
    ),
    body: OABodyStyles(
      l: TextStyle(
        fontFamily: OAFontFamily.body,
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.55,
      ),
      m: TextStyle(
        fontFamily: OAFontFamily.body,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      s: TextStyle(
        fontFamily: OAFontFamily.body,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
    ),
    action: TextStyle(
      fontFamily: OAFontFamily.display,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    mono: TextStyle(
      fontFamily: OAFontFamily.mono,
      fontSize: 13,
      fontWeight: FontWeight.w400,
    ),
  );

  @override
  OATypography copyWith({
    OADisplayStyles? display,
    OACapsStyles? caps,
    OABodyStyles? body,
    TextStyle? action,
    TextStyle? mono,
  }) {
    return OATypography(
      display: display ?? this.display,
      caps: caps ?? this.caps,
      body: body ?? this.body,
      action: action ?? this.action,
      mono: mono ?? this.mono,
    );
  }

  @override
  OATypography lerp(ThemeExtension<OATypography>? other, double t) {
    if (other is! OATypography) return this;
    return OATypography(
      display: OADisplayStyles.lerp(display, other.display, t),
      caps: OACapsStyles.lerp(caps, other.caps, t),
      body: OABodyStyles.lerp(body, other.body, t),
      action: TextStyle.lerp(action, other.action, t)!,
      mono: TextStyle.lerp(mono, other.mono, t)!,
    );
  }
}
