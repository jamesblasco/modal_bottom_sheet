import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

import '../helpers.dart';
import '../screen_size_test.dart';

void main() {
  group('SheetPhysics', () {
    testWidgets('NeverDraggableSheetPhysics', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          physics: const NeverDraggableSheetPhysics(parent: null),
          initialExtent: kScreenSize.height,
          fit: SheetFit.expand,
          child: Container(
            color: Colors.red,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(Container)), kScreenRect);
      await tester.drag(find.byType(Container), const Offset(0, 100));
      expect(tester.getRect(find.byType(Container)), kScreenRect);
    });

    testWidgets('AlwaysDraggableSheetPhysics', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          physics: const AlwaysDraggableSheetPhysics(),
          initialExtent: kScreenSize.height,
          fit: SheetFit.expand,
          child: Container(
            color: Colors.red,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(Container)), kScreenRect);
      await tester.drag(find.byType(Container), const Offset(0, 100));
      expect(tester.getRect(find.byType(Container)),
          kScreenRect.translate(0, 100));
    });

    testWidgets('SnapSheetPhysics', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          physics: const SnapSheetPhysics(stops: <double>[0, 1]),
          initialExtent: kScreenSize.height,
          fit: SheetFit.expand,
          child: Container(
            color: Colors.red,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSheetTop(), isZero);
      expect(tester.getSheetHeight(), kScreenSize.height);

      await tester.dragSheet(300);
      await tester.pumpAndSettle();
      expect(tester.getSheetTop(), kScreenSize.height);
    });
  });
}
