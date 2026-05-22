// Widget Gallery — catalogue debug des atomes UI Open Adventure.
// Visible uniquement en `kDebugMode` (cf. lib/main.dart route conditionnelle).
// Story 5-4 — Atomes UI partagés.

import 'package:flutter/material.dart';

import '../../core/theme/build_context_x.dart';
import '../../core/widgets/oa_icon.dart';
import '../../core/widgets/oa_item_sprite.dart';
import '../../core/widgets/oa_pill.dart';
import '../../core/widgets/oa_scene_frame.dart';
import '../../core/widgets/oa_stamp.dart';

class WidgetGalleryPage extends StatelessWidget {
  const WidgetGalleryPage({super.key});

  static const String routeName = '/debug/gallery';

  @override
  Widget build(BuildContext context) {
    final spacing = context.oaSpacing;
    final typo = context.oaTypography;
    final colors = context.oaColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OA · widget gallery (debug)'),
      ),
      body: ListView(
        padding: EdgeInsets.all(spacing.s4),
        children: <Widget>[
          Text('OAStamp', style: typo.display.m),
          SizedBox(height: spacing.s2),
          OAStamp(
            label: 'Primary action',
            onPressed: () {},
            iconLeading: Icons.arrow_forward,
          ),
          SizedBox(height: spacing.s2),
          OAStamp(
            label: 'Secondary',
            variant: OAStampVariant.secondary,
            onPressed: () {},
          ),
          SizedBox(height: spacing.s2),
          OAStamp(
            label: 'Ghost',
            variant: OAStampVariant.ghost,
            onPressed: () {},
          ),
          SizedBox(height: spacing.s2),
          const OAStamp(label: 'Disabled', onPressed: null),
          SizedBox(height: spacing.s2),
          OAStamp(
            label: 'Full width — large',
            fullWidth: true,
            size: OAStampSize.large,
            onPressed: () {},
          ),
          SizedBox(height: spacing.s6),

          Text('OAPill', style: typo.display.m),
          SizedBox(height: spacing.s2),
          Wrap(
            spacing: spacing.s2,
            runSpacing: spacing.s2,
            children: const <Widget>[
              OAPill(label: 'NEUTRAL'),
              OAPill(label: 'AMBER', tone: OAPillTone.amber),
              OAPill(label: 'TEAL', tone: OAPillTone.teal),
              OAPill(label: 'DANGER', tone: OAPillTone.danger),
              OAPill(label: 'SUCCESS', tone: OAPillTone.success),
              OAPill(label: 'MAGIC', tone: OAPillTone.magic),
              OAPill(label: 'TREASURE', tone: OAPillTone.treasure),
              OAPill(label: 'DENSE', dense: true),
            ],
          ),
          SizedBox(height: spacing.s6),

          Text('OAIcon', style: typo.display.m),
          SizedBox(height: spacing.s2),
          Row(
            children: <Widget>[
              const OAIcon(Icons.star, size: OAIconSize.s),
              SizedBox(width: spacing.s3),
              const OAIcon(Icons.star, size: OAIconSize.m),
              SizedBox(width: spacing.s3),
              const OAIcon(Icons.star, size: OAIconSize.l),
              SizedBox(width: spacing.s3),
              const OAIcon(Icons.star, size: OAIconSize.xl),
            ],
          ),
          SizedBox(height: spacing.s6),

          Text('OASceneFrame', style: typo.display.m),
          SizedBox(height: spacing.s2),
          OASceneFrame(
            locationName: 'HALL DES BRUMES',
            lampHaloIntensity: 0.7,
            child: ColoredBox(color: colors.ink.deep),
          ),
          SizedBox(height: spacing.s6),

          Text('OAItemSprite', style: typo.display.m),
          SizedBox(height: spacing.s2),
          SizedBox(
            height: 96,
            child: Row(
              children: <Widget>[
                for (final tone in OAItemTone.values) ...<Widget>[
                  SizedBox(
                    width: 80,
                    child: OAItemSprite(
                      image: const AssetImage(
                        // Placeholder ; remplacé par les assets réels en 5-12.
                        'assets/data/locations.json',
                      ),
                      label: tone.name,
                      tone: tone,
                      onTap: () {},
                      badgeCount: tone == OAItemTone.amber ? 3 : null,
                    ),
                  ),
                  SizedBox(width: spacing.s2),
                ],
              ],
            ),
          ),
          SizedBox(height: spacing.s8),
        ],
      ),
    );
  }
}
