import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

import '../../../helpers.dart';

void main() {
  group('SheetController.animation', () {
    testWidgets('is 0 when starts in minExtent', (tester) async {
      await tester.pumpApp(
        Sheet(
          minExtent: 100,
          maxExtent: 400,
          initialExtent: 100,
          child: SizedBox(height: 400),
        ),
      );
      expect(tester.getSheetController().animation.value, 0);
    });

    testWidgets('is 1 when starts in maxExtent', (tester) async {
      await tester.pumpApp(
        Sheet(
          minExtent: 100,
          maxExtent: 400,
          initialExtent: 400,
          child: SizedBox(height: 400),
        ),
      );
      expect(tester.getSheetController().animation.value, 1);
    });
    testWidgets('is 0.5 when is between minExtent and maxExtent',
        (tester) async {
      await tester.pumpApp(
        Sheet(
          minExtent: 100,
          maxExtent: 300,
          initialExtent: 200,
          child: SizedBox(height: 300),
        ),
      );

      expect(tester.getSheetController().animation.value, 0.5);
    });

    testWidgets('is 1 when minExtent equals maxExtent', (tester) async {
      await tester.pumpApp(
        Sheet(
          minExtent: 100,
          maxExtent: 100,
          child: SizedBox(height: 100),
        ),
      );
      expect(tester.getSheetController().animation.value, 1);
    });

    testWidgets('updates to 0 when it goes to minExtent', (tester) async {
      await tester.pumpApp(
        Sheet(
          minExtent: 100,
          maxExtent: 400,
          initialExtent: 400,
          fit: SheetFit.expand,
          child: SizedBox(),
        ),
      );
      expect(tester.getSheetController().animation.value, 1);
      tester.getSheetController().relativeJumpTo(0);
      await tester.pumpAndSettle();
      expect(tester.getSheetController().animation.value, 0);
    });

    testWidgets('updates to 1 when it goes to maxExtent', (tester) async {
      await tester.pumpApp(
        Sheet(
          minExtent: 100,
          maxExtent: 400,
          initialExtent: 100,
          child: SizedBox(height: 400),
        ),
      );
      expect(tester.getSheetController().animation.value, 0);
      tester.getSheetController().relativeJumpTo(1);
      expect(tester.getSheetController().animation.value, 1);
    });

    testWidgets('updates linearly', (tester) async {
      await tester.pumpApp(
        Sheet(
          minExtent: 100,
          maxExtent: 300,
          initialExtent: 100,
          child: SizedBox(height: 300),
        ),
      );
      tester.getSheetController().relativeJumpTo(0.5);
      await tester.pumpAndSettle();
      expect(tester.getSheetController().animation.value, 0.5);
    });
  });
}
