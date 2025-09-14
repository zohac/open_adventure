import 'package:open_adventure/core/error/exceptions.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/location.dart';

/// LookupService provides O(1) name↔id resolution for Locations and Objects.
///
/// This utility is pure Dart and intended for use in repositories or use cases
/// where quick mapping is required. Unknown lookups throw
/// [LookupNotFoundException].
class LookupService {
  final Map<String, int> _locNameToId;
  final Map<int, String> _locIdToName;
  final Map<String, int> _objNameToId;
  final Map<int, String> _objIdToName;

  /// Builds lookup indices from the provided [locations] and [objects].
  LookupService({required List<Location> locations, required List<GameObject> objects})
      : _locNameToId = {for (final l in locations) l.name: l.id},
        _locIdToName = {for (final l in locations) l.id: l.name},
        _objNameToId = {for (final o in objects) o.name: o.id},
        _objIdToName = {for (final o in objects) o.id: o.name};

  /// Returns the location id for [name] or throws [LookupNotFoundException].
  int locationIdFromName(String name) {
    final id = _locNameToId[name];
    if (id == null) {
      throw LookupNotFoundException('Location "$name" not found');
    }
    return id;
  }

  /// Returns the location name for [id] or throws [LookupNotFoundException].
  String locationNameFromId(int id) {
    final name = _locIdToName[id];
    if (name == null) {
      throw LookupNotFoundException('Location id $id not found');
    }
    return name;
  }

  /// Returns the object id for [name] or throws [LookupNotFoundException].
  int objectIdFromName(String name) {
    final id = _objNameToId[name];
    if (id == null) {
      throw LookupNotFoundException('Object "$name" not found');
    }
    return id;
  }

  /// Returns the object name for [id] or throws [LookupNotFoundException].
  String objectNameFromId(int id) {
    final name = _objIdToName[id];
    if (name == null) {
      throw LookupNotFoundException('Object id $id not found');
    }
    return name;
  }
}

