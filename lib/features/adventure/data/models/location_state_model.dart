import '../../domain/entities/location_state.dart';

class LocationStateModel extends LocationState {
  const LocationStateModel({
    required super.abbrev,
    required super.atloc,
  });

  factory LocationStateModel.fromJson(Map<String, dynamic> json) {
    return LocationStateModel(
      abbrev: json['abbrev'],
      atloc: json['atloc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'abbrev': abbrev,
      'atloc': atloc,
    };
  }

  LocationState toEntity() {
    return LocationState(
      abbrev: abbrev,
      atloc: atloc,
    );
  }

  factory LocationStateModel.fromEntity(LocationState locationState) {
    return LocationStateModel(
      abbrev: locationState.abbrev,
      atloc: locationState.atloc,
    );
  }
}
