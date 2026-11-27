// Internal widgets. Not exported from the package.
import 'dart:async';

import 'package:flutter/widgets.dart';

import 'toast_style.dart';

// Material icon font glyphs, declared here to avoid importing Material.
// They are const so that icon tree shaking keeps working.
const IconData _infoIcon = IconData(0xe33d, fontFamily: 'MaterialIcons');
const IconData _successIcon = IconData(0xe15a, fontFamily: 'MaterialIcons');
const IconData _warningIcon = IconData(0xf02a0, fontFamily: 'MaterialIcons');
const IconData _errorIcon = IconData(0xe238, fontFamily: 'MaterialIcons');

/// Handles position, animation and auto-dismiss.
class ToastView extends StatefulWidget {
  const ToastView({
    super.key,
    required this.child,
    required this.position,
    required this.duration,
    required this.margin,
    required this.dismissOnTap,
    required this.onClosed,
    required this.onDisposed,
  });

  final Widget child;
  final ToastPosition position;
  final Duration duration;
  final EdgeInsets margin;
  final bool dismissOnTap;
  final VoidCallback onClosed;
  final VoidCallback onDisposed;

  @override
  State<ToastView> createState() => ToastViewState();
}

class ToastViewState extends State<ToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  Timer? _timer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(widget.duration, close);
  }

  Future<void> close() async {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();
    // orCancel throws if the widget is disposed mid-animation.
    try {
      await _controller.reverse().orCancel;
    } on TickerCanceled {
      return;
    }
    if (mounted) widget.onClosed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    widget.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Alignment alignment = switch (widget.position) {
      ToastPosition.top => Alignment.topCenter,
      ToastPosition.center => Alignment.center,
      ToastPosition.bottom => Alignment.bottomCenter,
    };
    final Offset begin = switch (widget.position) {
      ToastPosition.top => const Offset(0, -0.3),
      ToastPosition.center => Offset.zero,
      ToastPosition.bottom => const Offset(0, 0.3),
    };

    return Positioned.fill(
      child: Padding(
        // Keeps the toast above the on-screen keyboard.
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: widget.margin,
            child: Align(
              alignment: alignment,
              child: FadeTransition(
                opacity: _controller,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: begin,
                    end: Offset.zero,
                  ).animate(_controller),
                  child: Semantics(
                    container: true,
                    liveRegion: true,
                    child: GestureDetector(
                      onTap: widget.dismissOnTap ? close : null,
                      // Overlays have no text theme of their own.
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          color: Color(0xFF000000),
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The default look of a text toast.
class ToastContent extends StatelessWidget {
  const ToastContent({
    super.key,
    required this.message,
    required this.type,
    required this.style,
    this.icon,
  });

  final String message;
  final ToastType type;
  final ToastStyle style;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final (Color color, IconData? iconData) = switch (type) {
      ToastType.plain => (const Color(0xFF323232), null),
      ToastType.info => (const Color(0xFF1565C0), _infoIcon),
      ToastType.success => (const Color(0xFF2E7D32), _successIcon),
      ToastType.warning => (const Color(0xFFA84300), _warningIcon),
      ToastType.error => (const Color(0xFFC62828), _errorIcon),
    };
    final Widget? leading =
        icon ?? (iconData == null ? null : Icon(iconData, size: 20));

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: style.maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.backgroundColor ?? color,
          borderRadius: style.borderRadius,
          boxShadow: <BoxShadow>[
            if (style.elevation > 0)
              BoxShadow(
                color: const Color(0x40000000),
                blurRadius: style.elevation * 2,
                offset: Offset(0, style.elevation / 2),
              ),
          ],
        ),
        child: Padding(
          padding: style.padding,
          child: IconTheme.merge(
            data: IconThemeData(color: style.foregroundColor),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (leading != null) ...<Widget>[
                  leading,
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: style.foregroundColor,
                      fontSize: 14,
                    ).merge(style.textStyle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
