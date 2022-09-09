// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

import '../../../helpers.dart';
import '../../../screen_size_test.dart';

void main() {
  group('fit', () {
    testWidgets('height is child\'s height', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          child: Container(height: 200),
        ),
      );
      expect(tester.getSheetHeight(), equals(200));
    });

    testWidgets('height is max height when child\'s height is infinite',
        (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          child: Container(height: double.infinity),
        ),
      );
      expect(tester.getSheetHeight(), equals(kScreenHeight));
    });

    testWidgets('hidden by default', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          child: Container(height: 200),
        ),
      );
      expect(tester.getSheetTop(), equals(kScreenRect.bottom));
    });

    testWidgets('max top position is height', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          child: Container(height: 200),
        ),
      );
      expect(tester.getSheetTop(), equals(kScreenRect.bottom));
      tester.getSheetController().relativeJumpTo(1);
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 200));

      tester.getSheetController().jumpTo(200);
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 200));

      tester.getSheetController().jumpTo(300);
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 200));
    });
  });
}
