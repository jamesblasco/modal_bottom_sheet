import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

import '../../../helpers.dart';
import '../../../screen_size_test.dart';

void main() {
  group('Initial extent', () {
    final Size sheetSize = kScreenRect.size;

    testWidgets('default is Zero', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          child: Container(height: kScreenRect.height),
        ),
      );

      expect(tester.getSheetSize(), equals(sheetSize));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom));
    });
    testWidgets('can be zero', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          initialExtent: 0,
          child: Container(height: kScreenRect.height),
        ),
      );

      expect(tester.getSheetSize(), equals(sheetSize));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom));
    });
    testWidgets('can be full screen', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          initialExtent: kScreenRect.height,
          child: Container(height: kScreenRect.height),
        ),
      );

      expect(tester.getSheetSize(), equals(sheetSize));
      expect(tester.getSheetTop(), equals(0));
    });

    testWidgets('bigget than screen defaults to full screen',
        (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          initialExtent: 800,
          maxExtent: 600,
          child: Container(height: kScreenRect.height),
        ),
      );

      expect(tester.getSheetSize(), equals(sheetSize));
      expect(tester.getSheetTop(), equals(0));
    });

    testWidgets('can be a custom number (200)', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          initialExtent: 200,
          child: Container(height: kScreenRect.height),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSheetSize(), equals(sheetSize));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 200));
    });
  });
}
