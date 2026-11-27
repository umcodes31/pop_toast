import 'package:flutter/widgets.dart';

/// The kind of message, which selects the default color and icon.
enum ToastType {
  /// A neutral message with no icon.
  plain,

  /// An informational message.
  info,

  /// A successful action.
  success,

  /// Something that needs attention.
  warning,

  /// A failed action.
  error,
}

/// Where the toast appears on screen.
enum ToastPosition {
  /// Near the top, below the status bar.
  top,

  /// In the middle of the screen.
  center,

  /// Near the bottom, above the keyboard if it is open.
  bottom,
}

/// Visual settings for a toast. Any null color falls back to the type default.
@immutable
class ToastStyle {
  /// Creates a toast style.
  const ToastStyle({
    this.backgroundColor,
    this.foregroundColor = const Color(0xFFFFFFFF),
    this.textStyle,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.margin = const EdgeInsets.all(24),
    this.maxWidth = 480,
    this.elevation = 4,
  });

  /// Background color of the toast.
  final Color? backgroundColor;

  /// Color of the text and icon.
  final Color foregroundColor;

  /// Extra text styling, merged over the default.
  final TextStyle? textStyle;

  /// Corner radius.
  final BorderRadius borderRadius;

  /// Space inside the toast.
  final EdgeInsets padding;

  /// Space between the toast and the screen edges.
  final EdgeInsets margin;

  /// Maximum width, useful on tablets, desktop and web.
  final double maxWidth;

  /// Shadow depth.
  final double elevation;
}
