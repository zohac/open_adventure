import 'package:flutter/material.dart';

/// Utility translating domain-provided icon names to Material icons.
class IconsHelper {
  /// Resolves a [IconData] for the provided [iconName].
  static IconData iconForName(String iconName) {
    switch (iconName) {
      case 'arrow_upward':
        return Icons.arrow_upward;
      case 'arrow_downward':
        return Icons.arrow_downward;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'arrow_back':
        return Icons.arrow_back;
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'undo':
        return Icons.undo;
      case 'redo':
        return Icons.redo;
      case 'north_east':
        return Icons.north_east;
      case 'north_west':
        return Icons.north_west;
      case 'south_east':
        return Icons.south_east;
      case 'south_west':
        return Icons.south_west;
      case 'visibility':
        return Icons.visibility;
      case 'map':
        return Icons.map_outlined;
      case 'inventory':
        return Icons.inventory_2_outlined;
      case 'search':
        return Icons.search;
      case 'file_upload':
        return Icons.upload;
      case 'file_download':
        return Icons.download;
      case 'flash_on':
        return Icons.flash_on;
      case 'flash_off':
        return Icons.flash_off;
      case 'lock_open':
        return Icons.lock_open;
      case 'lock':
        return Icons.lock;
      default:
        return Icons.directions_walk;
    }
  }
}
