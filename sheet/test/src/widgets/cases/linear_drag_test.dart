import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

import '../../../helpers.dart';
import '../../../screen_size_test.dart';

void main() {
  group('Sheet linear drags', () {
    testWidgets('moves expected offset', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          initialExtent: 400,
          child: Container(height: kScreenRect.height),
        ),
      );
      final double topOffset = kScreenRect.bottom - 400;
      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(topOffset));

      await tester.dragSheet(-topOffset); // Drags to the top
      await tester.pumpAndSettle();

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(0));

      await tester.dragSheet(kScreenHeight); // Drags all the way down
      await tester.pumpAndSettle();

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom));
    });

    testWidgets('moves maximun the available viewport',
        (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          initialExtent: 400,
          child: Container(
            height: kScreenRect.height,
          ),
        ),
      );
      final double topOffset = kScreenRect.bottom - 400;
      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(topOffset));

      // Drags 100 more than needed to reach top
      await tester.dragSheet(-topOffset - 100);
      await tester.pumpAndSettle();

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(0));
    });

    testWidgets('moves down no more than the bottom of the screen',
        (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          initialExtent: 400,
          child: Container(height: kScreenRect.height),
        ),
      );

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 400));

      // Drags 100 more than needed to reach bottom
      await tester.dragSheet(400 + 100);
      await tester.pumpAndSettle();

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom));
    });

    testWidgets('does not move more than max extent',
        (WidgetTester tester) async {
      const double height = 500;
      await tester.pumpApp(
        Sheet(
          maxExtent: height,
          initialExtent: 400,
          child: Container(
            height: height,
          ),
        ),
      );

      expect(tester.getSheetHeight(), equals(height));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 400));

      await tester.dragSheet(-600.0); // We drag way more than the top
      await tester.pumpAndSettle();

      expect(tester.getSheetHeight(), equals(height));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - height));
    });

    testWidgets('does not move less than min extent',
        (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          initialExtent: 400,
          minExtent: 200,
          child: Container(
            height: kScreenRect.height,
          ),
        ),
      );

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 400));
      // We drag way more than to reach the bottom
      await tester.dragSheet(600.0);
      await tester.pumpAndSettle();

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 200));
    });
  });
}
