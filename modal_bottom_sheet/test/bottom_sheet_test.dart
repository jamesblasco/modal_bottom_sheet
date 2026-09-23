import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

void main() {
  testWidgets('relayouts the foreground without rebuilding its layout widgets',
      (tester) async {
    final animation = ModalBottomSheet.createAnimationController(tester);
    final replacement = ModalBottomSheet.createAnimationController(tester);
    final scroll = ScrollController();
    addTearDown(animation.dispose);
    addTearDown(replacement.dispose);
    addTearDown(scroll.dispose);
    const contentKey = ValueKey('foreground content');

    Widget host(AnimationController controller, {bool expanded = false}) {
      return MaterialApp(
        home: ModalBottomSheet(
          animationController: controller,
          animationCurve: Curves.linear,
          scrollController: scroll,
          expanded: expanded,
          enableDrag: false,
          onClosing: () {},
          child: const SizedBox(key: contentKey, height: 200),
        ),
      );
    }

    await tester.pumpWidget(host(animation));
    final layouts = find.descendant(
      of: find.byType(ModalBottomSheet),
      matching: find.byType(CustomSingleChildLayout),
    );
    final layoutWidget = tester.widget<CustomSingleChildLayout>(layouts);
    final layout =
        tester.renderObject<RenderCustomSingleChildLayoutBox>(layouts);
    final height = layout.size.height;
    for (final progress in [0.25, 0.5, 1.0, 0.75, 0.0]) {
      animation.value = progress;
      await tester.pump();
      expect(tester.widget(layouts), same(layoutWidget));
      expect(tester.getTopLeft(find.byKey(contentKey)).dy,
          closeTo(height - 200 * progress, 0.001));
    }

    // The drag path changes the curve without rebuilding the sheet.
    tester
        .state<ModalBottomSheetState>(find.byType(ModalBottomSheet))
        .animationCurve = Curves.easeIn;
    animation.value = 0.5;
    await tester.pump();
    expect(tester.getTopLeft(find.byKey(contentKey)).dy,
        closeTo(height - 200 * Curves.easeIn.transform(0.5), 0.001));

    replacement.value = 1;
    await tester.pumpWidget(host(replacement, expanded: true));
    expect(tester.getSize(find.byKey(contentKey)).height, height);
    expect(tester.getTopLeft(find.byKey(contentKey)).dy, 0);
    animation.value = 0.8;
    expect(layout.debugNeedsLayout, isFalse);
    replacement.value = 0.5;
    expect(layout.debugNeedsLayout, isTrue);
    await tester.pump();
    expect(tester.getTopLeft(find.byKey(contentKey)).dy,
        closeTo(height * (1 - Curves.easeIn.transform(0.5)), 0.001));

    await tester.pumpWidget(const SizedBox());
    replacement.value = 0.25;
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('preserves bounce geometry with stable foreground layout widgets',
      (tester) async {
    final animation = ModalBottomSheet.createAnimationController(tester)
      ..value = 1;
    final scroll = ScrollController();
    addTearDown(animation.dispose);
    addTearDown(scroll.dispose);
    const contentKey = ValueKey('bouncing foreground');
    await tester.pumpWidget(MaterialApp(
      home: ModalBottomSheet(
        animationController: animation,
        scrollController: scroll,
        expanded: true,
        onClosing: () {},
        child: const SizedBox.expand(
          key: contentKey,
          child: ColoredBox(color: Colors.blue),
        ),
      ),
    ));
    final layouts = find.descendant(
      of: find.byType(ModalBottomSheet),
      matching: find.byType(CustomSingleChildLayout),
    );
    final widgets = tester.widgetList(layouts).toList();
    final initialBounds = tester.getRect(find.byKey(contentKey));
    final gesture = await tester.startGesture(initialBounds.center);
    await gesture.moveBy(const Offset(0, -40));
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();
    final stretchedBounds = tester.getRect(find.byKey(contentKey));
    expect(stretchedBounds.height, greaterThan(initialBounds.height));
    expect(stretchedBounds.height, lessThanOrEqualTo(initialBounds.height + 8));
    expect(stretchedBounds.bottom, closeTo(initialBounds.bottom, 0.001));
    await gesture.up();
    for (var frame = 0; frame < 4; frame++) {
      await tester.pump(const Duration(milliseconds: 40));
      final current = tester.widgetList(layouts).toList();
      for (var index = 0; index < widgets.length; index++) {
        expect(current[index], same(widgets[index]));
      }
    }
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(contentKey)), initialBounds);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

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

  testWidgets('does not rebuild the custom container on every transition tick',
      (tester) async {
    late BuildContext hostContext;
    late Animation<double> routeAnimation;
    var containerBuilds = 0;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        hostContext = context;
        return const SizedBox.expand();
      }),
    ));

    final sheet = showCustomModalBottomSheet<void>(
      context: hostContext,
      duration: const Duration(seconds: 1),
      builder: (context) {
        routeAnimation = ModalRoute.of(context)!.animation!;
        return const SizedBox(height: 200);
      },
      containerWidget: (context, animation, child) {
        containerBuilds++;
        return Material(child: child);
      },
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    final initialBuilds = containerBuilds;
    expect(initialBuilds, greaterThan(0));
    for (var frame = 0; frame < 4; frame++) {
      await tester.pump(const Duration(milliseconds: 40));
      expect(routeAnimation.value, greaterThan(0));
      expect(routeAnimation.value, lessThan(1));
      expect(containerBuilds, initialBuilds);
    }

    await tester.pumpAndSettle();
    Navigator.of(hostContext).pop();
    await tester.pumpAndSettle();
    await sheet;
  });

  testWidgets('consults the current PopScope state before drag dismissal',
      (tester) async {
    late BuildContext hostContext;
    final canPop = ValueNotifier(true);
    addTearDown(canPop.dispose);
    const sheetKey = ValueKey('guarded sheet');
    var blockedPops = 0;
    var successfulPops = 0;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        hostContext = context;
        return const SizedBox.expand();
      }),
    ));

    final sheet = showCupertinoModalBottomSheet<void>(
      context: hostContext,
      builder: (_) => ValueListenableBuilder<bool>(
        valueListenable: canPop,
        builder: (context, canPop, child) => PopScope<void>(
          canPop: canPop,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              successfulPops++;
            } else {
              blockedPops++;
            }
          },
          child: child!,
        ),
        child: const SizedBox(
          key: sheetKey,
          height: 300,
          child: ColoredBox(color: Colors.blue),
        ),
      ),
    );
    await tester.pumpAndSettle();

    canPop.value = false;
    await tester.pump();
    await tester.dragFrom(
      tester.getTopLeft(find.byKey(sheetKey)) + const Offset(40, 40),
      const Offset(0, 240),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(sheetKey), findsOneWidget);
    expect(blockedPops, greaterThan(0));
    expect(successfulPops, 0);

    canPop.value = true;
    await tester.pump();
    await tester.dragFrom(
      tester.getTopLeft(find.byKey(sheetKey)) + const Offset(40, 40),
      const Offset(0, 240),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(sheetKey), findsNothing);
    expect(successfulPops, 1);
    await sheet;
    expect(tester.takeException(), isNull);
  });

  group('Cupertino background transitions on Android', () {
    testWidgets('preserves geometry and transformed hit testing',
        (tester) async {
      final animation = _TrackingAnimation();
      final bodyKey = GlobalKey();
      final buttonKey = GlobalKey();
      var taps = 0;

      await tester.pumpWidget(_cupertinoTransitionApp(
        animation: animation,
        child: SizedBox.expand(
          key: bodyKey,
          child: Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () => taps++,
              child: SizedBox(
                key: buttonKey,
                width: 80,
                height: 80,
                child: const ColoredBox(color: Colors.blue),
              ),
            ),
          ),
        ),
      ));

      final initialBounds = tester.getRect(find.byKey(bodyKey));
      animation.value = 0.5;
      await tester.pump();

      final progress = Curves.easeOut.transform(0.5);
      final scale = 1 - progress / 10;
      final bounds = tester.getRect(find.byKey(bodyKey));
      expect(
          bounds.left,
          closeTo(initialBounds.left + initialBounds.width * (1 - scale) / 2,
              0.001));
      expect(bounds.top, closeTo(initialBounds.top + progress * 24, 0.001));
      expect(bounds.width, closeTo(initialBounds.width * scale, 0.001));
      expect(bounds.height, closeTo(initialBounds.height * scale, 0.001));

      final buttonBounds = tester.getRect(find.byKey(buttonKey));
      await tester
          .tapAt(Offset(buttonBounds.right - 4, buttonBounds.center.dy));
      expect(taps, 1);
    });

    testWidgets(
        'does not rebuild or repaint a static background on animation ticks',
        (tester) async {
      final animation = _TrackingAnimation();
      var builds = 0;
      var paints = 0;
      await tester.pumpWidget(_cupertinoTransitionApp(
        animation: animation,
        child: Builder(builder: (context) {
          CupertinoTheme.of(context);
          builds++;
          return CustomPaint(
            painter: _RecordingPainter(() => paints++),
            child: const SizedBox.expand(),
          );
        }),
      ));

      final initialBuilds = builds;
      final initialPaints = paints;
      expect(initialBuilds, greaterThan(0));
      expect(initialPaints, greaterThan(0));
      for (final progress in [0.2, 0.5, 0.8, 1.0, 0.6, 0.0]) {
        animation.value = progress;
        await tester.pump();
        expect(builds, initialBuilds);
        expect(paints, initialPaints);
      }
    });

    testWidgets('detaches animation listeners when replaced or unmounted',
        (tester) async {
      final first = _TrackingAnimation();
      final second = _TrackingAnimation();
      const body = SizedBox.expand();

      await tester
          .pumpWidget(_cupertinoTransitionApp(animation: first, child: body));
      expect(first.valueListeners, isNotEmpty);

      await tester
          .pumpWidget(_cupertinoTransitionApp(animation: second, child: body));
      expect(first.valueListeners, isEmpty);
      expect(first.statusListeners, isEmpty);
      expect(second.valueListeners, isNotEmpty);

      first.value = 0.5;
      second.value = 0.5;
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      expect(second.valueListeners, isEmpty);
      expect(second.statusListeners, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keyboard insets do not rebuild the background theme subtree',
        (tester) async {
      final animation = _TrackingAnimation();
      final keyboardInsets = ValueNotifier(EdgeInsets.zero);
      addTearDown(keyboardInsets.dispose);
      var builds = 0;
      await tester.pumpWidget(_cupertinoTransitionApp(
        animation: animation,
        keyboardInsets: keyboardInsets,
        child: Builder(builder: (context) {
          CupertinoTheme.of(context);
          builds++;
          return const SizedBox.expand();
        }),
      ));

      final initialBuilds = builds;
      for (final height in [100.0, 200.0, 300.0, 0.0]) {
        keyboardInsets.value = EdgeInsets.only(bottom: height);
        await tester.pump();
        expect(builds, initialBuilds);
      }
    });

    for (final useScaffold in [true, false]) {
      testWidgets(
          'ignores Hero offstage progress for ${useScaffold ? 'scaffold' : 'external'} backgrounds',
          (tester) async {
        final externalAnimation = AnimationController(vsync: tester);
        addTearDown(externalAnimation.dispose);
        late BuildContext scaffoldContext;
        late AnimationController backgroundAnimation;
        late ModalRoute<dynamic> sheetRoute;
        await tester.pumpWidget(MaterialApp(
          home: CupertinoScaffold(
            body: Builder(builder: (context) {
              scaffoldContext = context;
              backgroundAnimation = useScaffold
                  ? CupertinoScaffold.of(context)!.animation!
                  : externalAnimation;
              return const SizedBox.expand();
            }),
          ),
        ));

        final progress = <double>[];
        void recordProgress() => progress.add(backgroundAnimation.value);
        backgroundAnimation.addListener(recordProgress);
        Widget buildSheet(BuildContext context) {
          sheetRoute = ModalRoute.of(context)!;
          return const SizedBox(height: 200);
        }

        final result = useScaffold
            ? CupertinoScaffold.showCupertinoModalBottomSheet<void>(
                context: scaffoldContext,
                builder: buildSheet,
              )
            : showCupertinoModalBottomSheet<void>(
                context: scaffoldContext,
                secondAnimation: externalAnimation,
                builder: buildSheet,
              );
        await tester.pump();
        expect(backgroundAnimation.value, 0);
        expect(progress, everyElement(0.0));
        await tester.pump(const Duration(milliseconds: 40));
        final beforeOffstage = backgroundAnimation.value;
        expect(beforeOffstage, greaterThan(0));
        expect(beforeOffstage, lessThan(1));

        sheetRoute.offstage = true;
        expect(sheetRoute.animation!.value, 1);
        expect(backgroundAnimation.value, beforeOffstage);
        sheetRoute.offstage = false;
        expect(backgroundAnimation.value, beforeOffstage);

        for (var frame = 0; frame < 8; frame++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(backgroundAnimation.value, 1);
        expect(progress, orderedEquals([...progress]..sort()));
        backgroundAnimation.removeListener(recordProgress);
        Navigator.of(scaffoldContext).pop();
        await tester.pumpAndSettle();
        await result;
        await tester.pumpWidget(const SizedBox.shrink());
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
        'keeps the background scaled until the last scaffold sheet exits',
        (tester) async {
      late BuildContext scaffoldContext;
      late AnimationController backgroundAnimation;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: CupertinoScaffold(
          body: Builder(builder: (context) {
            scaffoldContext = context;
            backgroundAnimation = CupertinoScaffold.of(context)!.animation!;
            return const SizedBox.expand();
          }),
        ),
      ));

      final firstSheet = CupertinoScaffold.showCupertinoModalBottomSheet<void>(
        context: scaffoldContext,
        builder: (_) => const SizedBox(height: 200),
      );
      await tester.pumpAndSettle();
      expect(backgroundAnimation.value, 1);

      final secondSheet = CupertinoScaffold.showCupertinoModalBottomSheet<void>(
        context: scaffoldContext,
        builder: (_) => const SizedBox(height: 200),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(backgroundAnimation.value, 1);
      await tester.pumpAndSettle();

      Navigator.of(scaffoldContext).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(backgroundAnimation.value, 1);
      await tester.pumpAndSettle();
      await secondSheet;
      expect(backgroundAnimation.value, 1);

      Navigator.of(scaffoldContext).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(backgroundAnimation.value, greaterThan(0));
      expect(backgroundAnimation.value, lessThan(1));
      await tester.pumpAndSettle();
      await firstSheet;
      expect(backgroundAnimation.value, 0);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
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

Widget _cupertinoTransitionApp({
  required Animation<double> animation,
  required Widget child,
  ValueNotifier<EdgeInsets>? keyboardInsets,
}) {
  final route = CupertinoModalBottomSheetRoute<void>(
    expanded: true,
    builder: (_) => const SizedBox.shrink(),
  );
  return MaterialApp(
    theme: ThemeData(platform: TargetPlatform.android),
    home: Builder(builder: (context) {
      final transition =
          route.getPreviousRouteTransition(context, animation, child);
      if (keyboardInsets != null) {
        return ValueListenableBuilder<EdgeInsets>(
          valueListenable: keyboardInsets,
          child: transition,
          builder: (context, insets, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: const EdgeInsets.only(top: 24),
              viewInsets: insets,
            ),
            child: child!,
          ),
        );
      }
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: const EdgeInsets.only(top: 24),
        ),
        child: transition,
      );
    }),
  );
}

class _TrackingAnimation extends Animation<double> {
  final valueListeners = <VoidCallback>[];
  final statusListeners = <AnimationStatusListener>[];
  double _value = 0;

  @override
  double get value => _value;

  set value(double value) {
    final previousStatus = status;
    _value = value;
    for (final listener in List<VoidCallback>.of(valueListeners)) {
      listener();
    }
    if (status != previousStatus) {
      for (final listener
          in List<AnimationStatusListener>.of(statusListeners)) {
        listener(status);
      }
    }
  }

  @override
  AnimationStatus get status => value == 0
      ? AnimationStatus.dismissed
      : value == 1
          ? AnimationStatus.completed
          : AnimationStatus.forward;

  @override
  void addListener(VoidCallback listener) => valueListeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => valueListeners.remove(listener);

  @override
  void addStatusListener(AnimationStatusListener listener) =>
      statusListeners.add(listener);

  @override
  void removeStatusListener(AnimationStatusListener listener) =>
      statusListeners.remove(listener);
}

class _RecordingPainter extends CustomPainter {
  const _RecordingPainter(this.onPaint);

  final VoidCallback onPaint;

  @override
  void paint(Canvas canvas, Size size) {
    onPaint();
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.blue);
  }

  @override
  bool shouldRepaint(_RecordingPainter oldDelegate) => false;
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
