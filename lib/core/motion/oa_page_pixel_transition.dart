// OAPagePixelTransition — discretised page transition (fade) using
// `OAStepCurve.step4`. Replaces Material's default fluid transitions for
// the entire app (cf. ADR-006 : no cubic-bezier).
//
// Story 5-5 — Motion system.

import 'package:flutter/material.dart';

import 'oa_animations.dart';

/// `PageTransitionsBuilder` that applies a step-discretised fade-through.
///
/// The animation duration is **not** controlled here (Flutter's Navigator
/// owns it via `transitionDuration`) — see [oaPageTransitionDuration] for
/// the matching value to pass to your `MaterialPageRoute` or `GoRoute`.
class OAPagePixelTransition extends PageTransitionsBuilder {
  const OAPagePixelTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final motion = OAMotion.of(context);
    final resolved = motion.resolve(OAAnimationSemantic.base);

    final curved = CurvedAnimation(parent: animation, curve: resolved.curve);
    return FadeTransition(opacity: curved, child: child);
  }
}

/// Suggested `transitionDuration` for routes using [OAPagePixelTransition].
/// Mirrors `OAAnimationSemantic.base` (200ms) — kept as a helper because
/// `MaterialPageRoute.transitionDuration` is set per-route, not via theme.
const Duration oaPageTransitionDuration = Duration(milliseconds: 200);

/// Default Material `PageTransitionsTheme` for Open Adventure : every
/// platform uses [OAPagePixelTransition]. Used by `OAThemeData.dark()`.
const PageTransitionsTheme oaPageTransitionsTheme = PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: OAPagePixelTransition(),
    TargetPlatform.iOS: OAPagePixelTransition(),
    TargetPlatform.fuchsia: OAPagePixelTransition(),
    TargetPlatform.linux: OAPagePixelTransition(),
    TargetPlatform.macOS: OAPagePixelTransition(),
    TargetPlatform.windows: OAPagePixelTransition(),
  },
);
