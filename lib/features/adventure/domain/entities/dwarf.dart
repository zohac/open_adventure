import 'package:equatable/equatable.dart';

class Dwarf extends Equatable {
  final bool seen;
  final int loc;
  final int oldloc;

  const Dwarf({
    required this.seen,
    required this.loc,
    required this.oldloc,
  });

  @override
  List<Object?> get props => [seen, loc, oldloc];
}
