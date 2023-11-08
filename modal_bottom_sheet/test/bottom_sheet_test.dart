import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

void main() {
  group(
    'Route.mainState are well-controlled by `mainState`',
    () {
      Future<void> testInitStateAndDispose(
        WidgetTester tester,
        Future<void> Function(BuildContext context, WidgetBuilder builder)
            onPressed,
      ) async {
        int initState = 0, dispose = 0;
        await _pumpWidget(
          tester: tester,
          onPressed: (context) => onPressed(
            context,
            (_) => _TestWidget(
              onInitState: () => initState++,
              onDispose: () => dispose++,
            ),
          ),
        );
        expect(initState, 0);
        await tester.tap(_textButtonWithText('Press me'));
        await tester.pumpAndSettle();
        expect(initState, 1);
        expect(dispose, 0);
        await tester.tap(_textButtonWithText('TestWidget push'));
        await tester.pumpAndSettle();
        expect(initState, 1);
        expect(dispose, 0);
        await tester.tap(_textButtonWithText('TestWidget pushed pop'));
        await tester.pumpAndSettle();
        expect(initState, 1);
        expect(dispose, 0);
        await tester.tap(_textButtonWithText('TestWidget pop'));
        await tester.pumpAndSettle();
        expect(initState, 1);
        expect(dispose, 1);
      }

      testWidgets('with showCupertinoModalBottomSheet', (tester) {
        return testInitStateAndDispose(
          tester,
          (context, builder) => showCupertinoModalBottomSheet(
            context: context,
            builder: builder,
          ),
        );
      });
      testWidgets('with showMaterialModalBottomSheet', (tester) {
        return testInitStateAndDispose(
          tester,
          (context, builder) => showMaterialModalBottomSheet(
            context: context,
            builder: builder,
          ),
        );
      });
    },
  );
}

Future<void> _pumpWidget({
  required WidgetTester tester,
  required void Function(BuildContext context) onPressed,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => onPressed(context),
              child: Text('Press me'),
            ),
          ),
        ),
      ),
    ),
  );
}

Finder _textButtonWithText(String text) {
  return find.widgetWithText(TextButton, text);
}

class _TestWidget extends StatefulWidget {
  const _TestWidget({
    this.onInitState,
    this.onDispose,
  });

  final VoidCallback? onInitState;
  final VoidCallback? onDispose;

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget> {
  @override
  void initState() {
    super.initState();
    widget.onInitState?.call();
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).push(
              defaultPageRoute(
                targetPlatform: Theme.of(context).platform,
                builder: (context) => Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('TestWidget pushed pop'),
                    ),
                  ),
                ),
              ),
            ),
            child: Text('TestWidget push'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('TestWidget pop'),
          ),
        ],
      ),
    );
  }
}

PageRoute<T> defaultPageRoute<T>({
  required TargetPlatform targetPlatform,
  required WidgetBuilder builder,
  RouteSettings? settings,
  bool maintainState = true,
  bool fullscreenDialog = false,
}) {
  switch (targetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return CupertinoPageRoute<T>(
        builder: builder,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      );
    default:
      return MaterialPageRoute<T>(
        builder: builder,
        settings: settings,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
      );
  }
}
