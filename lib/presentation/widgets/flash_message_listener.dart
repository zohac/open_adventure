import 'dart:async';

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
  String? _lastDisplayedMessage;
  Timer? _autoDismissTimer;

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
      _lastDisplayedMessage = null;
      _cancelAutoDismiss();
      widget.controller.addListener(_handleStateChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleStateChange);
    _cancelAutoDismiss();
    super.dispose();
  }

  void _handleStateChange() {
    final String? message = widget.controller.value.flashMessage;
    if (message == null) {
      _lastDisplayedMessage = null;
      _cancelAutoDismiss();
      return;
    }
    if (message == _lastDisplayedMessage) {
      return;
    }
    _lastDisplayedMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) {
        return;
      }
      final l10n = AppLocalizations.of(context);
      messenger.hideCurrentMaterialBanner(
        reason: MaterialBannerClosedReason.hide,
      );
      messenger.showMaterialBanner(
        MaterialBanner(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          contentTextStyle: Theme.of(context).textTheme.bodyMedium,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                messenger.hideCurrentMaterialBanner(
                  reason: MaterialBannerClosedReason.dismiss,
                );
              },
              child: Text(l10n.flashDismissLabel),
            ),
          ],
        ),
      );
      _cancelAutoDismiss();
      _autoDismissTimer = Timer(const Duration(seconds: 4), () {
        if (!mounted) {
          return;
        }
        messenger.hideCurrentMaterialBanner(
          reason: MaterialBannerClosedReason.hide,
        );
      });
      widget.controller.clearFlashMessage();
    });
  }

  void _cancelAutoDismiss() {
    if (_autoDismissTimer?.isActive ?? false) {
      _autoDismissTimer!.cancel();
    }
    _autoDismissTimer = null;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
