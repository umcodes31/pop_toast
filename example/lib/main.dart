import 'package:material_ui/material_ui.dart';
import 'package:pop_toast/pop_toast.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Toast.navigatorKey,
      home: Scaffold(
        appBar: AppBar(title: const Text('pop_toast')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FilledButton(
                onPressed: () => Toast.show('Hello!'),
                child: const Text('Plain'),
              ),
              FilledButton(
                onPressed: () => Toast.success('Saved'),
                child: const Text('Success'),
              ),
              FilledButton(
                onPressed: () => Toast.error('Something went wrong'),
                child: const Text('Error'),
              ),
              FilledButton(
                onPressed: () => Toast.show(
                  'At the top',
                  type: ToastType.info,
                  position: ToastPosition.top,
                  replace: true,
                ),
                child: const Text('Top, replace queue'),
              ),
              FilledButton(
                onPressed: () => Toast.showCustom(
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('My own widget'),
                    ),
                  ),
                  position: ToastPosition.center,
                ),
                child: const Text('Custom'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
