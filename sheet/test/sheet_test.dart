// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

import 'helpers.dart';

final Rect screenRect = Offset.zero & Size(800, 600);

void main() {
  group('Sheet', () {
    testWidgets('renders', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          child: Text('Sheet'),
        ),
      );
      await tester.pumpAndSettle();
      expect(findSheet(), findsOneWidget);
      expect(find.text('Sheet'), findsOneWidget);
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
