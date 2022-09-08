import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

import '../../helpers.dart';

void main() {
  group('SheetMediaQuery', () {
    testWidgets('top padding is zero if sheet is not inside top safe area',
        (tester) async {
      final childKey = UniqueKey();
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.only(top: 20)),
            child: Sheet(
              child: SheetMediaQuery(
                child: SizedBox.expand(key: childKey),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byKey(childKey));
      expect(MediaQuery.of(context).padding.top, 0);
    });

    testWidgets(
        'top padding is same as top safe area if sheet is fully open '
        'before viewportDimension is rendered', (tester) async {
      // viewportDimension is not available in first frame
      final childKey = UniqueKey();
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.only(top: 20)),
            child: Sheet(
              initialExtent: 600,
              child: SheetMediaQuery(
                child: SizedBox.expand(key: childKey),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byKey(childKey));
      expect(MediaQuery.of(context).padding.top, 20);
    });

    testWidgets(
        'top padding is same as top safe area if sheet is fully open '
        'after viewportDimension is rendered', (tester) async {
      final childKey = UniqueKey();
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.only(top: 20)),
            child: Sheet(
              child: SheetMediaQuery(
                child: SizedBox.expand(key: childKey),
              ),
            ),
          ),
        ),
      );
      tester.getSheetController().relativeJumpTo(1);
      await tester.pumpAndSettle();
      final context = tester.element(find.byKey(childKey));
      expect(MediaQuery.of(context).padding.top, 20);
    });

    testWidgets('top padding increase is lineal', (tester) async {
      final offsetToTest = 10.0;
      final childKey = UniqueKey();
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.only(top: 20)),
            child: Sheet(
              initialExtent: 600 - offsetToTest,
              child: SizedBox(
                child: SheetMediaQuery(
                  child: SizedBox.expand(key: childKey),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byKey(childKey));
      expect(MediaQuery.of(context).padding.top, 20 - offsetToTest);
    });
  });
}
