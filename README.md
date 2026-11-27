# pop_toast

Lightweight, customizable toast messages for Flutter. Written in pure Dart on
top of Flutter's `Overlay`, with no native code.

## Features

- Plain, info, success, warning and error types
- Top, center and bottom positions; stays above the keyboard
- Queue (one toast at a time) with an optional `replace`
- Custom styles, icons or a completely custom widget
- Call with or without a `BuildContext`
- Announced as a live region to screen readers

## Install

```sh
flutter pub add pop_toast
```

The built-in icons use the Material icon font, so keep
`uses-material-design: true` in your app's `pubspec.yaml`.

## Setup

To call toasts without a context, add the navigator key:

```dart
MaterialApp(
  navigatorKey: Toast.navigatorKey,
  home: const HomePage(),
);
```

If you already have a navigator key (for example with `go_router`), assign it
before creating your router: `Toast.navigatorKey = myKey;`

You can skip setup and pass `context:` to each call instead.

## Usage

```dart
import 'package:pop_toast/pop_toast.dart';

Toast.show('Hello!');
Toast.success('Saved');
Toast.error('Upload failed', context: context);

Toast.show(
  'No internet connection',
  type: ToastType.warning,
  position: ToastPosition.top,
  duration: const Duration(seconds: 4),
  replace: true,
);

Toast.show(
  'Styled',
  style: const ToastStyle(backgroundColor: Colors.deepPurple),
);

final handle = Toast.show('Working...', duration: const Duration(minutes: 1));
handle.dismiss();

Toast.dismiss(); // visible toast only
Toast.dismissAll(); // visible and queued
```

Use `Toast.showCustom(myWidget)` to display your own widget. For widgets with
buttons, pass `dismissOnTap: false`.

Toasts are drawn inside your app, so they cannot appear while the app is in the
background. Do not call `Toast.show` while a widget is building.
