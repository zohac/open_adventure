import 'package:flutter/foundation.dart';

/// Abstraction over Flutter's [compute] to ease testing.
abstract class IsolateExecutor {
  Future<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message, {String? debugLabel});
}

/// Default executor delegating to Flutter's [compute].
class FlutterIsolateExecutor implements IsolateExecutor {
  const FlutterIsolateExecutor();

  @override
  Future<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message, {String? debugLabel}) {
    return foundationCompute(callback, message, debugLabel: debugLabel);
  }
}

// Wrapper to avoid import name clash if needed.
Future<R> foundationCompute<Q, R>(ComputeCallback<Q, R> callback, Q message, {String? debugLabel}) {
  return compute(callback, message, debugLabel: debugLabel);
}

