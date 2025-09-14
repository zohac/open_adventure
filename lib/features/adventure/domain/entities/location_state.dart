import 'package:equatable/equatable.dart';

class LocationState extends Equatable {
  final int abbrev;
  final int atloc;

  const LocationState({
    required this.abbrev,
    required this.atloc,
  });

  @override
  List<Object?> get props => [abbrev, atloc];

}
