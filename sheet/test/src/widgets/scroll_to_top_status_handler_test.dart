import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/src/widgets/scroll_to_top_status_handler.dart';

void main() {
  testWidgets('Tap status bar scrolls primary scroll controller',
      (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    await tester.pumpWidget(MaterialApp(
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: const EdgeInsets.all(20),
          ),
          child: child!,
        );
      },
      home: PrimaryScrollController(
        controller: controller,
        child: ScrollToTopStatusBarHandler(
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
}
