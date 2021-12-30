// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

final Rect screenRect = Offset.zero & Size(800, 600);

void main() {
  final Key key = Key('Sheet');

  group('Sheet', () {
    testWidgets('renders', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          child: Text('Sheet'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sheet'), findsOneWidget);
    });

    group('Initial Extent', () {
      final Size sheetSize = screenRect.size;

      testWidgets('default is Zero', (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            child: Container(key: key, height: screenRect.height),
          ),
        );
        final Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(sheetSize));
        expect(rect.topLeft, equals(screenRect.bottomLeft));
      });
      testWidgets('can be zero', (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            initialExtent: 0,
            child: Container(key: key, height: screenRect.height),
          ),
        );
        final Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(sheetSize));
        expect(rect.topLeft, equals(screenRect.bottomLeft));
      });
      testWidgets('can be full screen', (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            initialExtent: screenRect.height,
            child: Container(key: key, height: screenRect.height),
          ),
        );
        final Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(sheetSize));
        expect(rect.topLeft, equals(Offset.zero));
      });

      testWidgets('bigget than screen defaults to full screen',
          (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            initialExtent: 800,
            maxExtent: 600,
            child: Container(key: key, height: screenRect.height),
          ),
        );
        final Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(sheetSize));
        expect(rect.topLeft, equals(Offset.zero));
      });

      testWidgets('can be a custom number (200)', (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            initialExtent: 200,
            child: Container(key: key, height: screenRect.height),
          ),
        );
        await tester.pumpAndSettle();
        final Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(sheetSize));
        expect(rect.left, equals(0));
        expect(rect.top, equals(screenRect.bottom - 200));
      });
    });

    group('Resizable', () {
      testWidgets('Initial extent - 0 (None)', (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            resizable: true,
            initialExtent: 0,
            child: Container(
              key: key,
            ),
          ),
        );
        final Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size.height, equals(0));
        expect(rect.top, equals(screenRect.bottom));
      });

      testWidgets('Initial extent - 600 (Full)', (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            resizable: true,
            initialExtent: 600,
            child: Container(
              key: key,
            ),
          ),
        );
        final Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size.height, equals(600));
        expect(rect.top, equals(screenRect.bottom - 600));
      });

      testWidgets('Initial extent - 200 (Arbitrary)',
          (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            resizable: true,
            initialExtent: 200,
            child: Container(
              key: key,
            ),
          ),
        );
        final Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size.height, equals(200));
        expect(rect.top, equals(screenRect.bottom - 200));
      });

      testWidgets('Initial extent zero - fit (Arbitrary)',
          (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            fit: SheetFit.loose,
            child: Container(
              key: key,
              child: const Text('Item'),
            ),
          ),
        );
        final Rect rect = tester.getRect(find.byKey(key));
        final double textHeight = tester.getRect(find.text('Item')).height;
        expect(textHeight, isNonZero);
        expect(rect.size.height, equals(textHeight));
        expect(rect.top, equals(screenRect.bottom));
      });

      testWidgets('Initial extent - fit (Arbitrary)',
          (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            fit: SheetFit.loose,
            initialExtent: 100,
            child: Container(
              key: key,
              child: const Text('Item'),
            ),
          ),
        );
        final Rect rect = tester.getRect(find.byKey(key));
        final double textHeight = tester.getRect(find.text('Item')).height;
        expect(textHeight, isNonZero);
        expect(rect.size.height, equals(textHeight));
        expect(rect.top, equals(screenRect.bottom - 100));
      });

      testWidgets(
          'Sheet size is same as minResizableExtent when current extent is less than it ',
          (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            resizable: true,
            minExtent: 0,
            maxExtent: 600,
            initialExtent: 600,
            minResizableExtent: 200,
            child: Container(
              key: key,
              width: double.infinity,
            ),
          ),
        );
        Rect rect = tester.getRect(find.byKey(key));
        expect(rect.height, equals(600),
            reason: 'Height should be same as initialExtent');
        expect(rect.width, equals(screenRect.width));
        expect(rect.top, equals(0),
            reason: 'It should be positioned with a initialExtent');

        // ignore: always_specify_types
        await tester.dragFrom(
          tester.getTopLeft(find.byKey(key)),
          const Offset(0.0, 500.0),
          touchSlopY: 0.0,
        );
        await tester.pumpAndSettle();
        rect = tester.getRect(find.byKey(key));
        expect(rect.top, screenRect.bottom - 100,
            reason: 'It should be positioned with a initialExtent');
        expect(rect.height, equals(200),
            reason: 'Height should be same as minResizableExtent');
      });
    });

    group('Controller', () {
      testWidgets('jumpTo', (WidgetTester tester) async {
        final GlobalKey key = GlobalKey();

        await tester.pumpApp(
          Sheet(
            initialExtent: 200,
            child: Container(
              key: key,
              height: screenRect.height,
            ),
          ),
        );
        Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(screenRect.bottom - 200));

        Sheet.of(key.currentContext!)!.controller.jumpTo(400);
        rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, screenRect.height - 400);

        Sheet.of(key.currentContext!)!.controller.jumpTo(-100);
        rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(screenRect.height));

        Sheet.of(key.currentContext!)!
            .controller
            .jumpTo(screenRect.height + 100);
        rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(0));
      });

      testWidgets('relativeJumpTo', (WidgetTester tester) async {
        final GlobalKey key = GlobalKey();

        await tester.pumpApp(
          Sheet(
            initialExtent: 200,
            child: Container(
              key: key,
              height: screenRect.height,
            ),
          ),
        );
        Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(screenRect.bottom - 200));

        Sheet.of(key.currentContext!)!.controller.relativeJumpTo(1);
        rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(0));

        Sheet.of(key.currentContext!)!.controller.relativeJumpTo(0.5);
        rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(screenRect.bottom / 2));
      });

      testWidgets('animateTo', (WidgetTester tester) async {
        final GlobalKey key = GlobalKey();

        await tester.pumpApp(
          Sheet(
            initialExtent: 200,
            child: Container(
              key: key,
              height: screenRect.height,
            ),
          ),
        );
        Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.topLeft, equals(Offset(0, screenRect.height - 200)));

        Sheet.of(key.currentContext!)!.controller.animateTo(400,
            curve: Curves.easeInOut, duration: const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
        rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(screenRect.bottom - 400));

        Sheet.of(key.currentContext!)!.controller.animateTo(-100,
            curve: Curves.easeInOut, duration: const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
        rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(screenRect.bottom));
        Sheet.of(key.currentContext!)!.controller.animateTo(
            screenRect.height + 100,
            curve: Curves.easeInOutCirc,
            duration: const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
        rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(0));
      });

      testWidgets('relativeAnimateTo', (WidgetTester tester) async {
        final GlobalKey key = GlobalKey();

        await tester.pumpApp(
          Sheet(
            initialExtent: 200,
            child: Container(
              key: key,
              height: screenRect.height,
            ),
          ),
        );
        Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(screenRect.bottom - 200));

        Sheet.of(key.currentContext!)!.controller.relativeAnimateTo(1,
            curve: Curves.easeInOut, duration: const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
        rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(0));

        Sheet.of(key.currentContext!)!.controller.relativeAnimateTo(0.5,
            curve: Curves.easeInOut, duration: const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
        rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(screenRect.bottom / 2));
      });
    });

    group('Drag', () {
      testWidgets('Linear drag', (WidgetTester tester) async {
        final GlobalKey key = GlobalKey();

        await tester.pumpApp(
          Sheet(
            initialExtent: 400,
            child: Container(
              key: key,
              height: screenRect.height,
            ),
          ),
        );
        Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(screenRect.height - 400));

        await tester.drag(find.byType(Sheet), const Offset(0.0, -200.0),
            touchSlopY: 0.0);
        await tester.pumpAndSettle();
        rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(0));

        await tester.drag(find.byType(Sheet), const Offset(0.0, 600.0),
            touchSlopY: 0.0);
        await tester.pumpAndSettle();
        rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(600));
      });

      testWidgets('Linear drag overflow top', (WidgetTester tester) async {
        final GlobalKey key = GlobalKey();

        await tester.pumpApp(
          Sheet(
            initialExtent: 400,
            child: Container(
              key: key,
              height: screenRect.height,
            ),
          ),
        );
        Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(screenRect.height - 400));

        await tester.drag(find.byType(Sheet), const Offset(0.0, -300.0),
            touchSlopY: 0.0);
        await tester.pumpAndSettle();
        rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.topLeft, equals(Offset(0, 0)));
      });

      testWidgets('Linear drag overflow top with max extent',
          (WidgetTester tester) async {
        final GlobalKey key = GlobalKey();

        await tester.pumpApp(
          Sheet(
            maxExtent: 500,
            initialExtent: 400,
            child: Container(
              key: key,
              height: 500,
            ),
          ),
        );
        Rect rect = tester.getRect(find.byKey(key));
        expect(rect.height, equals(500));
        expect(rect.top, equals(screenRect.bottom - 400));

        await tester.drag(find.byType(Sheet), const Offset(0.0, -300.0),
            touchSlopY: 0.0);
        await tester.pumpAndSettle();
        rect = tester.getRect(find.byKey(key));
        expect(rect.height, equals(500));
        expect(rect.top, equals(100));
      });

      testWidgets('Linear drag overflow bottom with min extent',
          (WidgetTester tester) async {
        final GlobalKey key = GlobalKey();

        await tester.pumpApp(
          Sheet(
            initialExtent: 400,
            minExtent: 200,
            child: Container(
              key: key,
              height: screenRect.height,
            ),
          ),
        );
        Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(screenRect.bottom - 400));

        await tester.drag(find.byType(Sheet), const Offset(0.0, 600.0),
            touchSlopY: 0.0);
        await tester.pumpAndSettle();
        rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(screenRect.bottom - 200));
      });

      testWidgets('Linear drag overflow bottom', (WidgetTester tester) async {
        final GlobalKey key = GlobalKey();

        await tester.pumpApp(
          Sheet(
            initialExtent: 400,
            child: Container(
              key: key,
              height: screenRect.height,
            ),
          ),
        );
        Rect rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(screenRect.bottom - 400));

        await tester.drag(find.byType(Sheet), const Offset(0.0, 600.0),
            touchSlopY: 0.0);
        await tester.pumpAndSettle();
        rect = tester.getRect(find.byKey(key));
        expect(rect.size, equals(screenRect.size));
        expect(rect.top, equals(screenRect.bottom));
      });
    });
  });
}

extension on WidgetTester {
  Future<void> pumpApp(Widget child) async {
    await pumpWidget(
      MaterialApp(home: child),
    );
  }
}
