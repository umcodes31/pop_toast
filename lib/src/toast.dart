import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';

import 'toast_style.dart';
import 'toast_view.dart';

/// A reference to a toast that is visible or waiting in the queue.
class ToastHandle {
  ToastHandle._();

  final Completer<void> _closed = Completer<void>();
  final GlobalKey<ToastViewState> _viewKey = GlobalKey<ToastViewState>();
  late final OverlayState _overlay;
  late final OverlayEntry _entry;

  /// Completes when the toast is gone, or is removed from the queue.
  Future<void> get closed => _closed.future;

  /// Dismisses this toast. Safe to call more than once.
  void dismiss() => Toast._dismiss(this);
}

/// Shows toast messages. One toast is visible at a time; others are queued.
abstract final class Toast {
  /// Pass this to `MaterialApp.navigatorKey` to show toasts without a context.
  ///
  /// If your app already has a navigator key, assign it here instead.
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final Queue<ToastHandle> _queue = Queue<ToastHandle>();
  static ToastHandle? _current;

  /// Shows a text toast.
  ///
  /// Set [replace] to true to clear the visible and queued toasts first.
  /// Do not call this while a widget is building.
  static ToastHandle show(
    String message, {
    BuildContext? context,
    ToastType type = ToastType.plain,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 2),
    ToastStyle style = const ToastStyle(),
    Widget? icon,
    bool dismissOnTap = true,
    bool replace = false,
  }) {
    return showCustom(
      ToastContent(message: message, type: type, style: style, icon: icon),
      context: context,
      position: position,
      duration: duration,
      margin: style.margin,
      dismissOnTap: dismissOnTap,
      replace: replace,
    );
  }

  /// Shows any widget as a toast.
  static ToastHandle showCustom(
    Widget child, {
    BuildContext? context,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 2),
    EdgeInsets margin = const EdgeInsets.all(24),
    bool dismissOnTap = true,
    bool replace = false,
  }) {
    final OverlayState? overlay = context != null
        ? Overlay.maybeOf(context, rootOverlay: true)
        : navigatorKey.currentState?.overlay;
    if (overlay == null) {
      throw FlutterError(
        'Toast could not find an Overlay.\n'
        'Pass a context below a MaterialApp, or set '
        'MaterialApp(navigatorKey: Toast.navigatorKey).',
      );
    }

    final ToastHandle handle = ToastHandle._();
    handle._overlay = overlay;
    handle._entry = OverlayEntry(
      maintainState: true,
      builder: (_) => ToastView(
        key: handle._viewKey,
        position: position,
        duration: duration,
        margin: margin,
        dismissOnTap: dismissOnTap,
        onClosed: () => _finish(handle, removeEntry: true),
        onDisposed: () => _finish(handle, removeEntry: false),
        child: child,
      ),
    );

    if (replace) dismissAll();
    _queue.add(handle);
    _showNext();
    return handle;
  }

  /// Shows an informational toast.
  static ToastHandle info(String message, {BuildContext? context}) =>
      show(message, context: context, type: ToastType.info);

  /// Shows a success toast.
  static ToastHandle success(String message, {BuildContext? context}) =>
      show(message, context: context, type: ToastType.success);

  /// Shows a warning toast.
  static ToastHandle warning(String message, {BuildContext? context}) =>
      show(message, context: context, type: ToastType.warning);

  /// Shows an error toast.
  static ToastHandle error(String message, {BuildContext? context}) =>
      show(message, context: context, type: ToastType.error);

  /// Dismisses the visible toast. The next queued toast then appears.
  static void dismiss() => _current?.dismiss();

  /// Clears the queue and immediately removes the visible toast.
  static void dismissAll() {
    while (_queue.isNotEmpty) {
      _complete(_queue.removeFirst());
    }
    final ToastHandle? current = _current;
    if (current != null) _finish(current, removeEntry: true);
  }

  static void _showNext() {
    // Recover if the visible toast's overlay was destroyed before it was built.
    final ToastHandle? stale = _current;
    if (stale != null && !stale._overlay.mounted) {
      _current = null;
      _complete(stale);
    }
    while (_current == null && _queue.isNotEmpty) {
      final ToastHandle next = _queue.removeFirst();
      if (!next._overlay.mounted) {
        _complete(next);
        continue;
      }
      _current = next;
      next._overlay.insert(next._entry);
    }
  }

  static void _dismiss(ToastHandle handle) {
    if (handle._closed.isCompleted) return;
    if (_queue.remove(handle)) {
      _complete(handle);
      return;
    }
    final ToastViewState? view = handle._viewKey.currentState;
    if (view != null) {
      view.close();
    } else {
      _finish(handle, removeEntry: true);
    }
  }

  static void _finish(ToastHandle handle, {required bool removeEntry}) {
    if (handle._closed.isCompleted || !identical(_current, handle)) return;
    _current = null;
    _complete(handle);
    if (removeEntry) {
      handle._entry
        ..remove()
        ..dispose();
      _showNext();
    } else {
      // The widget tree is being torn down, so wait before inserting again.
      scheduleMicrotask(_showNext);
    }
  }

  static void _complete(ToastHandle handle) {
    if (!handle._closed.isCompleted) handle._closed.complete();
  }
}
