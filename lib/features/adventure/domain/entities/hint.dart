import 'package:equatable/equatable.dart';

class Hint extends Equatable {
  final bool used;
  final int lc;

  const Hint({
    required this.used,
    required this.lc,
  });

  @override
  List<Object?> get props => [used, lc];
}
