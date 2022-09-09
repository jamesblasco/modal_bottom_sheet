// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

import '../../../helpers.dart';
import '../../../screen_size_test.dart';

void main() {
  group('SheetController', () {
    const curve = Curves.easeInOut;
    const duration = Duration(milliseconds: 1);
    const child = SizedBox(height: kScreenHeight);

    group('jumpTo', () {
      testWidgets('a custom extent - 400', (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(child: child),
        );

        tester.getSheetController().jumpTo(400);
        expect(tester.getSheetExtent(), 400);
      });

      testWidgets('minExtent', (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            minExtent: 100,
            child: child,
          ),
        );

        tester.getSheetController().jumpTo(100);
        expect(tester.getSheetExtent(), 100);
      });
      testWidgets('maxExtent', (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            maxExtent: 400,
            child: child,
          ),
        );

        tester.getSheetController().jumpTo(400);
        expect(tester.getSheetExtent(), 400);
      });

      testWidgets('less than 0 clamps to 0', (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(child: child),
        );

        tester.getSheetController().jumpTo(-100);
        expect(tester.getSheetExtent(), equals(0));
      });
      testWidgets('less than minExtent clamps to minExtent',
          (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            minExtent: 100,
            initialExtent: 200,
            child: child,
          ),
        );
        expect(tester.getSheetExtent(), equals(200));

        tester.getSheetController().jumpTo(100);
        expect(tester.getSheetExtent(), equals(100));
      });

      testWidgets(
          'more than than screenHeight clamps to screenHeight '
          'if maxExtent is null', (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            child: child,
          ),
        );

        tester.getSheetController().jumpTo(kScreenHeight + 100);
        expect(tester.getSheetExtent(), equals(kScreenHeight));
      });
      testWidgets('more than maxExtent clamps to maxExtent',
          (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            maxExtent: 400,
            child: child,
          ),
        );

        tester.getSheetController().jumpTo(500);
        expect(tester.getSheetExtent(), 400);
      });
    });

    testWidgets('relativeJumpTo', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          initialExtent: 200,
          child: Container(
            height: kScreenHeight,
          ),
        ),
      );

      expect(tester.getSheetExtent(), equals(200));

      tester.getSheetController().relativeJumpTo(1);
      expect(tester.getSheetExtent(), equals(kScreenHeight));

      tester.getSheetController().relativeJumpTo(0.5);
      expect(tester.getSheetExtent(), equals(kScreenHeight / 2));
    });

    testWidgets('animateTo', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          initialExtent: 200,
          child: Container(
            height: kScreenHeight,
          ),
        ),
      );

      expect(tester.getSheetExtent(), equals(200));

      tester
          .getSheetController()
          .animateTo(400, curve: curve, duration: duration);
      await tester.pumpAndSettle();
      final controller = tester.getSheetController();
      expect(tester.getSheetExtent(), equals(400));

      controller.animateTo(-100, curve: curve, duration: duration);
      await tester.pumpAndSettle();

      expect(tester.getSheetExtent(), equals(0));
      controller.animateTo(
        kScreenHeight + 100,
        curve: curve,
        duration: duration,
      );
      await tester.pumpAndSettle();
      expect(tester.getSheetExtent(), equals(kScreenHeight));
    });

    testWidgets('relativeAnimateTo', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          initialExtent: 200,
          child: Container(
            height: kScreenHeight,
          ),
        ),
      );
      final controller = tester.getSheetController();
      expect(tester.getSheetExtent(), equals(200));

      controller.relativeAnimateTo(1, curve: curve, duration: duration);
      await tester.pumpAndSettle();
      expect(tester.getSheetExtent(), equals(kScreenHeight));

      controller.relativeAnimateTo(0.5, curve: curve, duration: duration);
      await tester.pumpAndSettle();
      expect(tester.getSheetExtent(), equals(kScreenHeight * 0.5));
    });

    testWidgets('relativeAnimateTo with min xtent',
        (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          initialExtent: 200,
          child: Container(
            height: kScreenHeight,
          ),
        ),
      );
      final controller = tester.getSheetController();
      expect(tester.getSheetExtent(), equals(200));

      controller.relativeAnimateTo(1, curve: curve, duration: duration);
      await tester.pumpAndSettle();
      expect(tester.getSheetExtent(), equals(kScreenHeight));

      controller.relativeAnimateTo(0.5, curve: curve, duration: duration);
      await tester.pumpAndSettle();
      expect(tester.getSheetExtent(), equals(kScreenHeight * 0.5));
    });
  });
}
