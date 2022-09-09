import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

import '../../../helpers.dart';

void main() {
  group('SheetPosition', () {
    testWidgets('can prevent drag', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          child: SizedBox(height: 200),
        ),
      );
      final position = tester.getSheetPosition();
      expect(position.preventingDrag, false);
      position.preventDrag();
      expect(position.preventingDrag, true);
    });

    testWidgets('can stops preventing drag', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          child: SizedBox(height: 200),
        ),
      );
      final position = tester.getSheetPosition();
      position.preventDrag();
      expect(position.preventingDrag, true);
      position.stopPreventingDrag();
      expect(position.preventingDrag, false);
    });
  });
}
