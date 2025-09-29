import 'package:flutter/material.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/l10n/app_localizations.dart';

/// Bridges the [GameController] flash message stream with a [SnackBar].
class FlashMessageListener extends StatefulWidget {
  /// Wraps [child] and surfaces controller flash messages across screens.
  const FlashMessageListener({
    super.key,
    required this.controller,
    required this.child,
  });

  /// Source controller exposing the [GameViewState] listenable.
  final GameController controller;

  /// Widget subtree that should react to flash messages.
  final Widget child;

  @override
  State<FlashMessageListener> createState() => _FlashMessageListenerState();
}

class _FlashMessageListenerState extends State<FlashMessageListener> {
  String? _lastDisplayedLabel;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleStateChange);
  }

  @override
  void didUpdateWidget(covariant FlashMessageListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleStateChange);
      _lastDisplayedLabel = null;
      widget.controller.addListener(_handleStateChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleStateChange);
    super.dispose();
  }

  void _handleStateChange() {
    final String? label = widget.controller.value.flashMessageLabel;
    if (label == null) {
      _lastDisplayedLabel = null;
      return;
    }
    if (label == _lastDisplayedLabel) {
      return;
    }
    _lastDisplayedLabel = label;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) {
        return;
      }
      final l10n = AppLocalizations.of(context);
      messenger.hideCurrentSnackBar(reason: SnackBarClosedReason.hide);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.resolveActionLabel(label))),
      );
      widget.controller.clearFlashMessage();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
