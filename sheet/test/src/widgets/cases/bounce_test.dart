// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

import '../../../helpers.dart';
import '../../../screen_size_test.dart';

void main() {
  group('bounce', () {
    testWidgets('fit: can bounce top', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          initialExtent: double.infinity,
          physics: BouncingSheetPhysics(),
          child: Container(height: 200),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSheetHeight(), equals(200));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 200));
      await tester.dragSheet(-100);
      await tester.pump();
      expect(tester.getSheetHeight(), greaterThan(200));
    });

    testWidgets('fit: with max extent: can bounce top',
        (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          maxExtent: 200,
          initialExtent: double.infinity,
          physics: BouncingSheetPhysics(),
          child: Container(height: 200),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSheetHeight(), equals(200));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 200));
      await tester.dragSheet(-100);
      await tester.pump();
      expect(tester.getSheetHeight(), greaterThan(200));
    });

    testWidgets('fit: with min extent: can bounce bottom',
        (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          minExtent: 150,
          initialExtent: double.infinity,
          physics: BouncingSheetPhysics(),
          child: Container(height: 200),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSheetHeight(), equals(200));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 200));
      await tester.dragSheet(100);
      await tester.pump();
      expect(tester.getSheetTop(), greaterThan(kScreenRect.bottom - 150));
    });

    testWidgets('expanded: with max extent: can bounce top',
        (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          fit: SheetFit.expand,
          maxExtent: 200,
          initialExtent: double.infinity,
          physics: BouncingSheetPhysics(),
          child: Container(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSheetHeight(), equals(200));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 200));
      await tester.dragSheet(-100);
      await tester.pump();
      expect(tester.getSheetHeight(), greaterThan(200));
    });

    testWidgets('expanded: with min extent: can bounce bottom',
        (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          fit: SheetFit.expand,
          minExtent: 150,
          maxExtent: 200,
          initialExtent: double.infinity,
          physics: BouncingSheetPhysics(),
          child: Container(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSheetHeight(), equals(200));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 200));
      await tester.dragSheet(100);
      await tester.pump();
      expect(tester.getSheetTop(), greaterThan(kScreenRect.bottom - 150));
    });

    testWidgets('expanded: does not bounce outside viewport by default',
        (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          fit: SheetFit.expand,
          initialExtent: double.infinity,
          physics: BouncingSheetPhysics(),
          child: Container(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSheetHeight(), equals(kScreenHeight));
      expect(tester.getSheetTop(), equals(0));
      await tester.dragSheet(-100);
      await tester.pump();
      expect(tester.getSheetHeight(), equals(kScreenHeight));
    });

    testWidgets('expanded: can bounce top when overflowViewport is true',
        (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          fit: SheetFit.expand,
          initialExtent: double.infinity,
          physics: BouncingSheetPhysics(
            overflowViewport: true,
          ),
          child: Container(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSheetHeight(), equals(kScreenHeight));
      expect(tester.getSheetTop(), equals(0));
      await tester.dragSheet(-100);
      await tester.pump();
      expect(tester.getSheetHeight(), greaterThan(kScreenHeight));
    });
  });
}
