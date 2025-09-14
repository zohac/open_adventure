// lib/core/error/failures.dart

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object?> get props => [];
}

/// DataFailure represents a typed failure for data layer issues
/// such as missing/corrupted assets or parse errors.
class DataFailure extends Failure {
  /// Human-readable message.
  final String message;

  /// Optional underlying cause (exception type/value).
  final Object? cause;

  DataFailure(this.message, {this.cause});

  @override
  List<Object?> get props => [message, cause];

  @override
  String toString() => 'DataFailure($message)';
}
