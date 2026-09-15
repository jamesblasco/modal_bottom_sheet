import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/route.dart';

import '../../helpers.dart';

void main() {
  group('SheetRoute', () {
    testWidgets('renders', (WidgetTester tester) async {
      await tester.pumpApp(SizedBox());

      Navigator.of(tester.contextForRootNavigator).push(
        SheetRoute(builder: (context) => Text('Sheet')),
      );
      await tester.pumpAndSettle();
      expect(findSheet(), findsOneWidget);
      expect(find.text('Sheet'), findsOneWidget);
    });

    testWidgets('with a custom initialExtent stays open instead of snapping shut',
        (WidgetTester tester) async {
      await tester.pumpApp(SizedBox());

      Navigator.of(tester.contextForRootNavigator).push(
        SheetRoute<void>(
          initialExtent: 0.3,
          builder: (context) => Text('Sheet'),
        ),
      );
      await tester.pumpAndSettle();
      expect(findSheet(), findsOneWidget);
    });
  });

  group('SheetPage', () {
    testWidgets('renders', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) {
          return Navigator(
            pages: [
              MaterialPage(child: SizedBox()),
              SheetPage(child: Text('Sheet')),
            ],
            onPopPage: (route, result) => false,
          );
        },
      ));
      await tester.pumpAndSettle();
      expect(findSheet(), findsOneWidget);
      expect(find.text('Sheet'), findsOneWidget);
    });
  });
}
