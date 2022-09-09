import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/route.dart';
import 'package:sheet/src/route/cupertino/sheet_route.dart';

import '../../../helpers.dart';

void main() {
  group('CupertinoSheetRoute', () {
    testWidgets('renders', (WidgetTester tester) async {
      await tester.pumpApp(SizedBox());

      Navigator.of(tester.contextForRootNavigator).push(
        CupertinoSheetRoute(builder: (context) => Text('Sheet')),
      );
      await tester.pumpAndSettle();
      expect(findSheet(), findsOneWidget);
      expect(find.text('Sheet'), findsOneWidget);
    });

    testWidgets('animates previous route when using MaterialExtendedPageRoute',
        (WidgetTester tester) async {
      await tester.pumpApp(SizedBox());
      final controller = Navigator.of(tester.contextForRootNavigator);
      controller.push(
        MaterialExtendedPageRoute(builder: (context) => SizedBox()),
      );
      await tester.pumpAndSettle();
      controller.push(
        CupertinoSheetRoute(builder: (context) => Text('Sheet')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoSheetBottomRouteTransition), findsOneWidget);
    });

    testWidgets('animates previous route when using CupertinoExtendedPageRoute',
        (WidgetTester tester) async {
      await tester.pumpApp(SizedBox());
      final controller = Navigator.of(tester.contextForRootNavigator);
      controller.push(
        CupertinoExtendedPageRoute(builder: (context) => SizedBox()),
      );
      await tester.pumpAndSettle();
      controller.push(
        CupertinoSheetRoute(builder: (context) => Text('Sheet')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoSheetBottomRouteTransition), findsOneWidget);
    });
  });

  group('CupertinoSheetPage', () {
    testWidgets('renders', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) {
          return Navigator(
            pages: [
              MaterialPage(child: SizedBox()),
              CupertinoSheetPage(child: Text('Sheet')),
            ],
            onPopPage: (route, result) => false,
          );
        },
      ));
      await tester.pumpAndSettle();
      expect(findSheet(), findsOneWidget);
      expect(find.text('Sheet'), findsOneWidget);
    });

    testWidgets('animates previous route when using MaterialExtendedPage',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) {
          return Navigator(
            pages: [
              MaterialExtendedPage(child: SizedBox()),
              CupertinoSheetPage(child: Text('Sheet')),
            ],
            onPopPage: (route, result) => false,
          );
        },
      ));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoSheetBottomRouteTransition), findsOneWidget);
    });

    testWidgets('animates previous route when using CupertinoExtendedPage',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) {
          return Navigator(
            pages: [
              CupertinoExtendedPage(child: SizedBox()),
              CupertinoSheetPage(child: Text('Sheet')),
            ],
            onPopPage: (route, result) => false,
          );
        },
      ));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoSheetBottomRouteTransition), findsOneWidget);
    });
  });
}
