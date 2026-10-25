import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

void main() {
  testWidgets(
    'keeps the default secondary transition dismissed for modal routes',
    (tester) async {
      final transitionsBuilder = _RecordingPageTransitionsBuilder();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            platform: TargetPlatform.android,
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: transitionsBuilder,
              },
            ),
          ),
          onGenerateRoute: (_) => MaterialWithModalsPageRoute<void>(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showMaterialModalBottomSheet<void>(
                  context: context,
                  builder: (_) => const SizedBox(height: 100),
                ),
                child: const Text('Open modal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(_textButtonWithText('Open modal'));
      await tester.pump();

      expect(transitionsBuilder.secondaryAnimation.value, 0);
      expect(
        transitionsBuilder.secondaryAnimation.status,
        AnimationStatus.dismissed,
      );
    },
  );

  group('status bar tap', () {
    Future<void> openModal(WidgetTester tester, WidgetBuilder builder) async {
      tester.view.padding = const FakeViewPadding(top: 60);
      addTearDown(tester.view.resetPadding);

      await _pumpWidget(
        tester: tester,
        onPressed: (context) => showCupertinoModalBottomSheet<void>(
          context: context,
          builder: builder,
        ),
      );
      await tester.tap(_textButtonWithText('Press me'));
      await tester.pumpAndSettle();
    }

    Future<void> tapStatusBar(WidgetTester tester) async {
      await tester.tapAt(const Offset(100, 5));
      await tester.pumpAndSettle();
    }

    testWidgets('does not throw when the sheet has no scroll view',
        (tester) async {
      await openModal(tester, (_) => const SizedBox(height: 300));

      await tapStatusBar(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets('scrolls the sheet content back to the top', (tester) async {
      await openModal(
        tester,
        (context) => ListView.builder(
          controller: ModalScrollController.of(context),
          itemExtent: 50,
          itemCount: 100,
          itemBuilder: (_, index) => Text('Item $index'),
        ),
      );

      final controller =
          tester.widget<Scrollable>(find.byType(Scrollable).last).controller!;
      controller.jumpTo(500);
      await tester.pump();

      await tapStatusBar(tester);

      expect(tester.takeException(), isNull);
      expect(controller.offset, 0);
    });
  });

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

class _RecordingPageTransitionsBuilder extends PageTransitionsBuilder {
  Animation<double> secondaryAnimation = kAlwaysDismissedAnimation;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    this.secondaryAnimation = secondaryAnimation;
    return child;
  }
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
