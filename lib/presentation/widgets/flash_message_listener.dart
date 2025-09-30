import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_adventure/application/controllers/game_controller.dart';
import 'package:open_adventure/l10n/app_localizations.dart';

/// Bridges the [GameController] flash message stream with a floating banner.
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

  /// Key applied to the floating flash surface for widget tests.
  @visibleForTesting
  static const Key flashMessageKey = ValueKey<String>('flash_message_overlay');

  @override
  State<FlashMessageListener> createState() => _FlashMessageListenerState();
}

class _FlashMessageListenerState extends State<FlashMessageListener> {
  String? _visibleMessage;
  String? _lastHandledMessage;
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
      _lastHandledMessage = null;
      _visibleMessage = null;
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
      _lastHandledMessage = null;
      return;
    }
    if (message == _lastHandledMessage && message == _visibleMessage) {
      return;
    }
    _lastHandledMessage = message;
    _showMessage(message);
    scheduleMicrotask(() {
      if (!mounted) {
        return;
      }
      if (widget.controller.value.flashMessage == message) {
        widget.controller.clearFlashMessage();
      }
    });
  }

  void _showMessage(String message) {
    _cancelAutoDismiss();
    if (!mounted) {
      return;
    }
    setState(() {
      _visibleMessage = message;
    });
    _autoDismissTimer = Timer(const Duration(seconds: 4), _hideMessage);
  }

  void _hideMessage() {
    _cancelAutoDismiss();
    if (!mounted || _visibleMessage == null) {
      return;
    }
    setState(() {
      _visibleMessage = null;
    });
    _lastHandledMessage = null;
  }

  void _cancelAutoDismiss() {
    if (_autoDismissTimer?.isActive ?? false) {
      _autoDismissTimer!.cancel();
    }
    _autoDismissTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final String? message = _visibleMessage;
    final l10n = AppLocalizations.of(context);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: message == null,
            child: SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          final slideAnimation = animation.drive(
                            Tween<Offset>(
                              begin: const Offset(0, -0.1),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeOutCubic)),
                          );
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slideAnimation,
                              child: child,
                            ),
                          );
                        },
                    layoutBuilder:
                        (Widget? currentChild, List<Widget> previousChildren) {
                          return Stack(
                            alignment: Alignment.topCenter,
                            children: <Widget>[
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          );
                        },
                    child: message == null
                        ? const SizedBox.shrink()
                        : _FloatingFlashBanner(
                            key: ValueKey<String>(message),
                            message: message,
                            dismissLabel: l10n.flashDismissLabel,
                            onDismissed: _hideMessage,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingFlashBanner extends StatelessWidget {
  const _FloatingFlashBanner({
    super.key,
    required this.message,
    required this.dismissLabel,
    required this.onDismissed,
  });

  final String message;
  final String dismissLabel;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Material(
        key: FlashMessageListener.flashMessageKey,
        elevation: 6,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        color: colorScheme.secondaryContainer,
        child: Semantics(
          liveRegion: true,
          container: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(child: Text(message, style: textTheme.bodyMedium)),
                const SizedBox(width: 12),
                TextButton(onPressed: onDismissed, child: Text(dismissLabel)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
