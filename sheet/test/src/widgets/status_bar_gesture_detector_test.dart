import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/src/widgets/status_bar_gesture_detector.dart';

void main() {
  group('StatusBarGestureDetector', () {
    testWidgets('Tap status bar calls onTap callback',
        (WidgetTester tester) async {
      tester.view.padding = FakeViewPadding(top: 20);
      bool called = false;
      await tester.pumpWidget(MaterialApp(
        home: StatusBarGestureDetector(
          onTap: (_) => called = true,
          child: Container(),
        ),
      ));
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });
    testWidgets('Tap status bar scrolls primary scroll controller',
        (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      tester.view.padding = FakeViewPadding(top: 20);
      await tester.pumpWidget(MaterialApp(
        home: PrimaryScrollController(
          controller: controller,
          child: StatusBarGestureDetector.scrollToTop(
            child: Material(
              child: ListView.builder(
                controller: controller,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(title: Text('Text $index'));
                },
              ),
            ),
          ),
        ),
      ));
      controller.jumpTo(200);
      await tester.pump();
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      expect(controller.position.pixels, isZero);
    });
  });
}
