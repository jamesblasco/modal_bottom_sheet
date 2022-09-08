import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

void main() {
  group('Sheet', () {
    testWidgets('default has material appareance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sheet(
            child: SizedBox(),
          ),
        ),
      );
      expect(find.byType(Material), findsOneWidget);
      final material = tester.widget<Material>(find.byType(Material));
      expect(
        material.color,
        ThemeData.fallback().bottomSheetTheme.backgroundColor,
      );
    });

    testWidgets('Sheet uses bottomSheetTheme by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sheet(
            child: SizedBox(),
          ),
        ),
      );

      final material = tester.widget<Material>(find.byType(Material));
      expect(
        material.color,
        ThemeData.fallback().bottomSheetTheme.backgroundColor,
      );

      expect(
        material.shape,
        ThemeData.fallback().bottomSheetTheme.shape,
      );
      expect(material.elevation, 0);
      expect(material.clipBehavior, Clip.none);
    });

    testWidgets('.raw has no material appareance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Sheet.raw(
            child: SizedBox(),
          ),
        ),
      );
      expect(find.byType(Material), findsNothing);
    });
  });
}
