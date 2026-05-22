// OAPagePixelTransition — discretised page transition (fade) using
// `OAStepCurve.step4`. Replaces Material's default fluid transitions for
// the entire app (cf. ADR-006 : no cubic-bezier).
//
// Story 5-5 — Motion system.

import 'package:flutter/material.dart';

import 'oa_animations.dart';

/// `PageTransitionsBuilder` that applies a step-discretised fade-through.
///
/// **Note** : the route's `transitionDuration` is controlled by the
/// `PageRoute` itself (Material default = 300ms). Use [OAMaterialPageRoute]
/// to get the 200ms duration matching `OAAnimationSemantic.base`.
/// When `MediaQuery.disableAnimations == true`, this builder returns the
/// child directly (no `FadeTransition` wrapper).
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
    if (motion.disableAnimations) {
      return child;
    }
    final resolved = motion.resolve(OAAnimationSemantic.base);
    final curved = CurvedAnimation(parent: animation, curve: resolved.curve);
    return FadeTransition(opacity: curved, child: child);
  }
}

/// `transitionDuration` matching `OAAnimationSemantic.base` (200ms). Used by
/// [OAMaterialPageRoute]. Kept as a top-level constant for callers that
/// build their own routes without subclassing.
const Duration oaPageTransitionDuration = Duration(milliseconds: 200);

/// `MaterialPageRoute` flavour that forces the 200ms Open Adventure
/// transition duration. Use this in place of [MaterialPageRoute] when
/// building routes so that AC6 (200ms) is actually honoured (the default
/// Material route uses 300ms).
///
/// Reduce-motion is handled by [OAPagePixelTransition] (the builder skips
/// the `FadeTransition` wrapper), so the route remains a no-op visual when
/// `MediaQuery.disableAnimations == true`.
class OAMaterialPageRoute<T> extends MaterialPageRoute<T> {
  OAMaterialPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Duration get transitionDuration => oaPageTransitionDuration;

  @override
  Duration get reverseTransitionDuration => oaPageTransitionDuration;
}

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
