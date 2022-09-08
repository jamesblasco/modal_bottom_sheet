import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

void main() {
  group('DefaultSheetController', () {
    testWidgets('DefaultSheetController injects a SheetController',
        (tester) async {
      final childKey = UniqueKey();
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultSheetController(
            child: SizedBox(key: childKey),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byKey(childKey));
      expect(DefaultSheetController.of(context), isA<SheetController>());
    });

    testWidgets('Sheet uses its SheetController', (tester) async {
      final childKey = UniqueKey();
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultSheetController(
            child: Sheet(
              child: SizedBox(key: childKey),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byKey(childKey));
      final controller = DefaultSheetController.of(context);
      expect(Sheet.of(context)!.controller, controller);
    });

    testWidgets('SheetController is the same between rebuilds', (tester) async {
      final childKey = UniqueKey();
      late StateSetter setState;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(builder: (context, stateSetter) {
            setState = stateSetter;
            return DefaultSheetController(
              child: Sheet(
                child: SizedBox(key: childKey),
              ),
            );
          }),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byKey(childKey));
      final controller = DefaultSheetController.of(context);
      setState(() {});
      await tester.pumpAndSettle();
      expect(DefaultSheetController.of(context), controller);
    });
  });
}
