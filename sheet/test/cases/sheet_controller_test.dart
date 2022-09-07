// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

import '../helpers.dart';
import '../screen_size_test.dart';

void main() {
  group('SheetController', () {
    testWidgets('jumpTo', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpApp(
        Sheet(
          initialExtent: 200,
          child: Container(
            key: key,
            height: kScreenRect.height,
          ),
        ),
      );

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 200));

      tester.getSheetController().jumpTo(400);

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), kScreenRect.height - 400);

      tester.getSheetController().jumpTo(-100);

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(kScreenRect.height));

      tester.getSheetController().jumpTo(kScreenRect.height + 100);

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(0));
    });

    testWidgets('relativeJumpTo', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpApp(
        Sheet(
          initialExtent: 200,
          child: Container(
            key: key,
            height: kScreenRect.height,
          ),
        ),
      );

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 200));

      tester.getSheetController().relativeJumpTo(1);

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(0));

      tester.getSheetController().relativeJumpTo(0.5);

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom / 2));
    });

    testWidgets('animateTo', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpApp(
        Sheet(
          initialExtent: 200,
          child: Container(
            key: key,
            height: kScreenRect.height,
          ),
        ),
      );

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(kScreenRect.height - 200));

      tester.getSheetController().animateTo(400,
          curve: Curves.easeInOut, duration: const Duration(milliseconds: 1));
      await tester.pumpAndSettle();

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 400));

      tester.getSheetController().animateTo(-100,
          curve: Curves.easeInOut, duration: const Duration(milliseconds: 1));
      await tester.pumpAndSettle();

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom));
      tester.getSheetController().animateTo(kScreenRect.height + 100,
          curve: Curves.easeInOutCirc,
          duration: const Duration(milliseconds: 1));
      await tester.pumpAndSettle();

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(0));
    });

    testWidgets('relativeAnimateTo', (WidgetTester tester) async {
      final GlobalKey key = GlobalKey();

      await tester.pumpApp(
        Sheet(
          initialExtent: 200,
          child: Container(
            key: key,
            height: kScreenRect.height,
          ),
        ),
      );

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom - 200));

      tester.getSheetController().relativeAnimateTo(1,
          curve: Curves.easeInOut, duration: const Duration(milliseconds: 1));
      await tester.pumpAndSettle();

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(0));

      tester.getSheetController().relativeAnimateTo(0.5,
          curve: Curves.easeInOut, duration: const Duration(milliseconds: 1));
      await tester.pumpAndSettle();

      expect(tester.getSheetSize(), equals(kScreenRect.size));
      expect(tester.getSheetTop(), equals(kScreenRect.bottom / 2));
    });
  });
}
