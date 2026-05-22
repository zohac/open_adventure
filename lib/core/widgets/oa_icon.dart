// OAIcon — wrapper unifié pour les icônes Open Adventure.
// Story 5-4 — Atomes UI partagés.

import 'package:flutter/material.dart';

import '../theme/build_context_x.dart';

enum OAIconSize { s, m, l, xl }

double oaIconSizeValue(OAIconSize size) {
  switch (size) {
    case OAIconSize.s:
      return 16;
    case OAIconSize.m:
      return 20;
    case OAIconSize.l:
      return 24;
    case OAIconSize.xl:
      return 32;
  }
}

@immutable
class OAIcon extends StatelessWidget {
  const OAIcon(
    this.icon, {
    super.key,
    this.size = OAIconSize.m,
    this.color,
    this.semanticsLabel,
  }) : assert(
          semanticsLabel == null || semanticsLabel.length > 0,
          'OAIcon.semanticsLabel must be null (decorative) or non-empty.',
        );

  final IconData icon;
  final OAIconSize size;

  /// Si `null`, retombe sur `oaColors.paper.warm`.
  final Color? color;

  /// Requis si l'icône porte de l'information (TalkBack/VoiceOver).
  /// Si `null`, l'icône est marquée décorative (`excludeSemantics: true`).
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? context.oaColors.paper.warm;
    final iconWidget = Icon(
      icon,
      size: oaIconSizeValue(size),
      color: resolvedColor,
    );

    if (semanticsLabel == null) {
      return ExcludeSemantics(child: iconWidget);
    }

    return Semantics(
      label: semanticsLabel,
      image: true,
      child: ExcludeSemantics(child: iconWidget),
    );
  }
}
