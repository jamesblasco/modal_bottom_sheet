import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

import '../../../helpers.dart';
import '../../../screen_size_test.dart';

void main() {
  group('Sheet with resizable', () {
    testWidgets('has zero height when child has zero height',
        (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          resizable: true,
          initialExtent: 0,
          child: Container(),
        ),
      );

      expect(tester.getSheetHeight(), equals(0));
    });
    testWidgets('can have zero initial extent', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          resizable: true,
          initialExtent: 0,
          child: Container(),
        ),
      );

      expect(tester.getSheetTop(), equals(kScreenRect.bottom));
    });

    testWidgets('can have a initial extent same as screen heigth',
        (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          resizable: true,
          initialExtent: 600,
          child: Container(),
        ),
      );

      expect(tester.getSheetHeight(), equals(600));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 600));
    });

    testWidgets('can have a custom extent', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          resizable: true,
          initialExtent: 200,
          child: Container(),
        ),
      );

      expect(tester.getSheetHeight(), equals(200));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 200));
    });

    testWidgets(
        'height is same as minResizableExtent when current extent is less than it ',
        (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          resizable: true,
          minExtent: 0,
          maxExtent: 600,
          initialExtent: 600,
          minResizableExtent: 200,
          child: Container(
            width: double.infinity,
          ),
        ),
      );

      expect(tester.getSheetHeight(), equals(600),
          reason: 'Height should be same as initialExtent');
      expect(tester.getSheetTop(), equals(0),
          reason: 'It should be positioned with a initialExtent');

      await tester.dragFrom(
        tester.getTopLeft(findSheet()),
        const Offset(0.0, 500.0),
        touchSlopY: 0.0,
      );
      await tester.pumpAndSettle();
      expect(tester.getSheetTop(), kScreenRect.bottom - 100,
          reason: 'It should be positioned with a initialExtent');
      expect(tester.getSheetHeight(), equals(200),
          reason: 'Height should be same as minResizableExtent');
    });
  });

  group('Sheet with SheetFit.loose', () {
    testWidgets('has same height as child', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          fit: SheetFit.loose,
          child: Container(
            child: const Text('Item'),
          ),
        ),
      );

      final double textHeight = tester.getRect(find.text('Item')).height;
      expect(textHeight, isNonZero);
      expect(tester.getSheetHeight(), equals(textHeight));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom));
    });

    testWidgets('can have custom initial extent', (WidgetTester tester) async {
      const String text = 'Item\nItem\nItem\nItem\n';
      await tester.pumpApp(
        Sheet(
          fit: SheetFit.loose,
          initialExtent: 20,
          child: Container(
            child: const Text(text),
          ),
        ),
      );

      final double textHeight = tester.getRect(find.text(text)).height;
      expect(textHeight, isNonZero);
      expect(tester.getSheetHeight(), equals(textHeight));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 20));
    });
  });
}
