void main() {}

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:sheet/sheet.dart';

// const double _kHeight = 600;
// const double _kWidth = 800;

// class TestSheet extends StatefulWidget {
//   const TestSheet(
//       {Key? key,
//       this.onButtonPressed,
//       this.itemExtent,
//       this.itemCount = 100,
//       this.initialExtent,
//       this.containerKey,
//       this.onScrollNotification,
//       this.resize = true,
//       this.expanded = true,
//       this.snap,
//       this.scrollable = true,
//       this.stops})
//       : super(key: key);

//   final VoidCallback? onButtonPressed;
//   final int itemCount;
//   final double? initialExtent;
//   final List<double>? stops;
//   final double? itemExtent;
//   final Key? containerKey;
//   final NotificationListenerCallback<ScrollNotification>? onScrollNotification;
//   final bool resize;
//   final bool? snap;
//   final bool expanded;
//   final bool scrollable;

//   @override
//   _TestSheetState createState() => _TestSheetState();
// }

// class _TestSheetState extends State<TestSheet> with TickerProviderStateMixin {
//   late SheetController controller;

//   @override
//   void initState() {
//     controller = SheetController();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Stack(
//         children: <Widget>[
//           TextButton(
//             child: const Text('TapHere'),
//             onPressed: widget.onButtonPressed,
//           ),
//           Sheet(
//             controller: controller,
//             resizable: widget.resize,
//             initialExtent: widget.initialExtent ?? 1,
//             child: Builder(
//               builder: (BuildContext context) {
//                 return NotificationListener<ScrollNotification>(
//                   onNotification: (notification) {
//                     return widget.onScrollNotification?.call(notification) ??
//                         false;
//                   },
//                   child: Container(
//                     key: widget.containerKey,
//                     color: const Color(0xFFABCDEF),
//                     child: ListView.builder(
//                       physics: widget.scrollable
//                           ? null
//                           : NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       primary: true,
//                       itemExtent: widget.itemExtent,
//                       itemCount: widget.itemCount,
//                       itemBuilder: (BuildContext context, int index) =>
//                           Text('Item $index'),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
// }

// Rect rectForExtent(double extent,
//     {double height = _kHeight, bool resizable = false}) {
//   final double topOffset = _kHeight - height * extent;
//   final double bottomOffset =
//       resizable ? _kHeight : _kHeight + height * (1 - extent);
//   return Rect.fromLTRB(0.0, topOffset, _kWidth, bottomOffset);
// }

// void main() {
// // Pumps and ensures that the BottomSheet animates non-linearly.
//   Future<void> _checkNonLinearAnimation(
//       WidgetTester tester, Finder finder) async {
//     final Offset firstPosition = tester.getCenter(finder);
//     await tester.pump(const Duration(milliseconds: 30));
//     final Offset secondPosition = tester.getCenter(finder);
//     await tester.pump(const Duration(milliseconds: 30));
//     final Offset thirdPosition = tester.getCenter(finder);

//     final double dyDelta1 = secondPosition.dy - firstPosition.dy;
//     final double dyDelta2 = thirdPosition.dy - secondPosition.dy;

//     // If the animation were linear, these two values would be the same.
//     expect(dyDelta1, isNot(moreOrLessEquals(dyDelta2, epsilon: 0.1)));
//   } // Pumps and ensures that the BottomSheet animates non-linearly.

//   testWidgets('Linear curve during drag and DecelerateEasing during fling',
//       (WidgetTester tester) async {
//     final GlobalKey key = GlobalKey();
//     await tester.pumpWidget(TestSheet(
//       stops: const <double>[0.1, 1.0],
//       initialExtent: 0.5,
//       itemExtent: 25.0,
//       itemCount: 6,
//       containerKey: key,
//       scrollable: false,
//       // resize: false,
//       snap: true,
//     ));
//     final SheetController controller =
//         Sheet.of(key.currentContext!)!.controller;
//     // Initial position should be 0.5
//     expect(
//         tester.getRect(find.byKey(key)), rectForExtent(0.5, resizable: true));
//     expect(controller.position.animation.value, 0.5);

//     // Drag up should snap to 1.0
//     final Offset firstPosition = tester.getCenter(find.byKey(key));
//     final TestGesture gesture =
//         await tester.startGesture(firstPosition, pointer: 7);
//     await gesture.moveTo(firstPosition - const Offset(0, 20));
//     final Offset secondPosition = tester.getCenter(find.byKey(key));
//     await gesture.moveTo(firstPosition - const Offset(0, 20));
//     final Offset thirdPosition = tester.getCenter(find.byKey(key));

//     final double dyDelta1 = secondPosition.dy - firstPosition.dy;
//     final double dyDelta2 = thirdPosition.dy - secondPosition.dy;

//     // If the animation were linear, these two values would be the same.
//     expect(dyDelta1, moreOrLessEquals(dyDelta2, epsilon: 0.1));

//     await gesture.up();

//     await _checkNonLinearAnimation(tester, find.byKey(key));

//     await tester.pumpAndSettle();

//     expect(controller.animation.value, 1.0);
//     expect(tester.getRect(find.byKey(key)), rectForExtent(1, resizable: true));
//     return;
//   });

//   group('SnapSheet - Resizable', () {
//     testWidgets('Default initial extent at 1.0', (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpSheetScaffold(
//         Sheet(
//           child: SizedBox.expand(
//             key: key,
//             child: Container(),
//           ),
//         ),
//       );
//       await tester.pumpAndSettle();

//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 0.0, _kWidth, _kHeight));
//     });

//     testWidgets('Custom initial extent at 0.5', (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         initialExtent: 0.5,
//         itemExtent: 25.0,
//         containerKey: key,
//         snap: true,
//       ));

//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       // Initial position should be 0.5
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, _kHeight * 0.5, _kWidth, _kHeight));
//       await tester.drag(find.text('Item 5'), const Offset(0, -125));
//       await tester.pumpAndSettle();

//       // Should not drag up as 0.5 is the only position allowed
//       expect(controller.animation.value, 0.5);
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, _kHeight * 0.5, _kWidth, _kHeight));
//       await tester.drag(find.text('Item 5'), const Offset(0, 125));
//       await tester.pumpAndSettle();
//       // Should not drag down as 0.5 is the only position allowed
//       expect(controller.animation.value, 0.5);
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, _kHeight * 0.5, _kWidth, _kHeight));
//     });

//     testWidgets('Stops at 0.1 and 1.0, default initial extent 0.5',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0.1, 1.0],
//         initialExtent: 0.5,
//         itemExtent: 25.0,
//         containerKey: key,
//         snap: true,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       // Initial position should be 0.5
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, _kHeight * 0.5, _kWidth, _kHeight));
//       expect(controller.animation.value, 0.5);

//       // Drag up should snap to 1.0
//       await tester.drag(find.text('Item 5'), const Offset(0, -125));
//       await tester.pumpAndSettle();
//       expect(controller.animation.value, 1.0);
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 0.0, _kWidth, _kHeight));

//       // Drag down should snap to 0.1
//       await tester.drag(find.text('Item 5'), const Offset(0, 400));
//       await tester.pumpAndSettle();
//       expect(controller.animation.value, 0.1);
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, _kHeight * 0.9, _kWidth, _kHeight));
//     });

//     testWidgets('Scrolls correctly to last stop when is < 1.0',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0, 0.6],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         containerKey: key,
//         snap: true,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, _kHeight * 0.75, _kWidth, _kHeight));
//       await tester.drag(find.text('Item 5'), const Offset(0, -125));
//       await tester.pumpAndSettle();
//       print(controller.animation.value);
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, _kHeight * 0.4, _kWidth, _kHeight));
//     });

//     testWidgets('Scrolls correctly to last stop when is == 1.0',
//         (WidgetTester tester) async {
//       const Key key = ValueKey<String>('container');
//       await tester.pumpWidget(const TestSheet(
//         stops: <double>[0, 1.0],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         containerKey: key,
//         snap: true,
//       ));

//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, _kHeight * 0.75, _kWidth, _kHeight));
//       await tester.drag(find.text('Item 5'), const Offset(0, -125));
//       await tester.pumpAndSettle();
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 0.0, _kWidth, _kHeight));
//     });

//     testWidgets('Scrolls correctly to first stop', (WidgetTester tester) async {
//       const Key key = ValueKey<String>('container');
//       await tester.pumpWidget(const TestSheet(
//         stops: <double>[0.1, 1.0],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         containerKey: key,
//         snap: true,
//       ));

//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, _kHeight * 0.75, _kWidth, _kHeight));
//       await tester.drag(find.text('Item 5'), const Offset(0, 125));
//       await tester.pumpAndSettle();
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, _kHeight * 0.9, _kWidth, _kHeight));
//     });

//     testWidgets('SheetController - set sheet extent',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0, 1.0],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         containerKey: key,
//         snap: true,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;

//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, _kHeight * 0.75, _kWidth, _kHeight));
//       controller.jumpTo(0.5);
//       await tester.pumpAndSettle();
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, _kHeight * 0.5, _kWidth, _kHeight));
//     });

//     testWidgets('SheetController - animate sheet extent',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0, 1.0],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         containerKey: key,
//         snap: true,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, _kHeight * 0.75, _kWidth, _kHeight));
//       controller.relativeAnimateTo(0.5,
//           curve: Curves.linear, duration: Duration(milliseconds: 400));
//       await tester.pumpAndSettle();
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, _kHeight * 0.5, _kWidth, _kHeight));
//     });

//     testWidgets('SheetController - animate to nearest stop',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0, 1.0],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         containerKey: key,
//         snap: true,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, _kHeight * 0.75, _kWidth, _kHeight));
//       controller.relativeAnimateTo(0.5,
//           curve: Curves.linear, duration: Duration(milliseconds: 400));
//       await tester.pumpAndSettle();
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 0, _kWidth, _kHeight));
//     });
//   });

//   group('SnapSheet - Expanded', () {
//     testWidgets('Default initial extent at 1.0', (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         itemExtent: 25.0,
//         containerKey: key,
//         resize: false,
//         snap: true,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 0.0, _kWidth, _kHeight));
//       await tester.drag(find.text('Item 5'), const Offset(0, -125));
//       await tester.pumpAndSettle();
//       expect(controller.animation.value, 1.0);
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 0.0, _kWidth, _kHeight));
//       await tester.drag(find.text('Item 5'), const Offset(0, 125));
//       await tester.pumpAndSettle();
//       expect(controller, 1.0);
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 0.0, _kWidth, _kHeight));
//     });

//     testWidgets('Custom initial extent at 0.5', (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         initialExtent: 0.5,
//         itemExtent: 25.0,
//         containerKey: key,
//         resize: false,
//         snap: true,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       // Initial position should be 0.5
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 300.0, _kWidth, 900.0));
//       await tester.drag(find.text('Item 5'), const Offset(0, -125));
//       await tester.pumpAndSettle();
//       // Should not drag up as 0.5 is the only position allowed
//       expect(controller.animation.value, 0.5);
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 300.0, _kWidth, 900.0));
//       await tester.drag(find.text('Item 5'), const Offset(0, 125));
//       await tester.pumpAndSettle();
//       // Should not drag down as 0.5 is the only position allowed
//       expect(controller.animation.value, 0.5);
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 300.0, _kWidth, 900.0));
//     });

//     testWidgets('Stops at 0.1 and 1.0, default initial extent 0.5',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0.1, 1.0],
//         initialExtent: 0.5,
//         itemExtent: 25.0,
//         containerKey: key,
//         resize: false,
//         snap: true,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       // Initial position should be 0.5
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 300.0, _kWidth, 900.0));
//       expect(controller.animation.value, 0.5);

//       // Drag up should snap to 1.0
//       await tester.drag(find.text('Item 5'), const Offset(0, -125));
//       await tester.pumpAndSettle();
//       expect(controller.animation.value, 1.0);
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 0.0, _kWidth, _kHeight));

//       // Drag down should snap to 0.1
//       await tester.drag(find.text('Item 5'), const Offset(0, 400));
//       await tester.pumpAndSettle();
//       expect(controller.animation.value, 0.1);
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 540.0, _kWidth, 1140.0));
//     });

//     testWidgets('Scrolls correctly to last stop when is < 1.0',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0, 0.6],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         containerKey: key,
//         resize: false,
//         snap: true,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 450.0, _kWidth, 1050.0));
//       await tester.drag(find.text('Item 5'), const Offset(0, -125));
//       await tester.pumpAndSettle();
//       print(controller.animation.value);
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 240.0, _kWidth, 840.0));
//     });

//     testWidgets('Scrolls correctly to last stop when is == 1.0',
//         (WidgetTester tester) async {
//       const Key key = ValueKey<String>('container');
//       await tester.pumpWidget(const TestSheet(
//         stops: <double>[0, 1.0],
//         initialExtent: .5,
//         itemExtent: 25.0,
//         containerKey: key,
//         resize: false,
//         snap: true,
//       ));

//       expect(
//           tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(
//               0.0, _kHeight * 0.5, _kWidth, _kHeight + _kHeight * 0.5));
//       await tester.drag(find.text('Item 5'), const Offset(0, -125));
//       await tester.pumpAndSettle();
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 0.0, _kWidth, _kHeight));
//     });

//     testWidgets('Scrolls correctly to first stop', (WidgetTester tester) async {
//       const Key key = ValueKey<String>('container');
//       await tester.pumpWidget(const TestSheet(
//         stops: <double>[0.1, 1.0],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         containerKey: key,
//         resize: false,
//         snap: true,
//       ));

//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 450.0, _kWidth, 1050.0));
//       await tester.drag(find.text('Item 5'), const Offset(0, 125));
//       await tester.pumpAndSettle();
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 540.0, _kWidth, 1140.0));
//     });

//     testWidgets('SheetController - set sheet extent',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0, 1.0],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         containerKey: key,
//         snap: true,
//         resize: false,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       expect(
//           tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(
//               0.0, _kHeight * 0.75, _kWidth, _kHeight + _kHeight * 0.75));
//       controller.jumpTo(0.5);
//       await tester.pumpAndSettle();
//       expect(
//           tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(
//               0.0, _kHeight * 0.5, _kWidth, _kHeight + _kHeight * 0.5));
//     });

//     testWidgets('SheetController - animate sheet extent',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0, 1.0],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         containerKey: key,
//         snap: true,
//         resize: false,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       expect(
//           tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(
//               0.0, _kHeight * 0.75, _kWidth, _kHeight + _kHeight * 0.75));
//       controller.jumpTo(0.5);
//       await tester.pumpAndSettle();
//       expect(
//           tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(
//               0.0, _kHeight * 0.5, _kWidth, _kHeight + _kHeight * 0.5));
//     });

//     testWidgets('SheetController - animate to nearest stop',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0, 1.0],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         containerKey: key,
//         snap: true,
//         resize: false,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       expect(
//           tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(
//               0.0, _kHeight * 0.75, _kWidth, _kHeight + _kHeight * 0.75));
//       controller.jumpTo(0.5);
//       await tester.pumpAndSettle();
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 0, _kWidth, _kHeight));
//     });
//   });

//   group('SnapSheet - Fitted', () {
//     testWidgets('Default initial extent at 1.0', (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         itemExtent: 25.0,
//         itemCount: 6,
//         containerKey: key,
//         resize: false,
//         expanded: false,
//         snap: true,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       // extent 1.0 out of size 6x25.0 = 150;
//       expect(tester.getRect(find.byKey(key)), rectForExtent(1, height: 150));
//       await tester.drag(find.text('Item 5'), const Offset(0, -125));
//       await tester.pumpAndSettle();
//       expect(controller.animation.value, 1.0);
//       expect(tester.getRect(find.byKey(key)), rectForExtent(1, height: 150));
//       await tester.drag(find.text('Item 5'), const Offset(0, 125));
//       await tester.pumpAndSettle();
//       expect(controller.animation.value, 1.0);
//       expect(tester.getRect(find.byKey(key)), rectForExtent(1, height: 150));
//     });

//     testWidgets('Custom initial extent at 0.5', (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         initialExtent: 0.5,
//         itemExtent: 25.0,
//         itemCount: 6,
//         containerKey: key,
//         expanded: false,
//         resize: false,
//         snap: true,
//       ));

//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       // Initial position should be 0.5
//       expect(tester.getRect(find.byKey(key)), rectForExtent(0.5, height: 150));
//       await tester.drag(find.text('Item 5'), const Offset(0, -125));
//       await tester.pumpAndSettle();
//       // Should not drag up as 0.5 is the only position allowed
//       expect(controller.animation.value, 0.5);
//       expect(tester.getRect(find.byKey(key)), rectForExtent(0.5, height: 150));
//       await tester.drag(find.text('Item 5'), const Offset(0, 125));
//       await tester.pumpAndSettle();
//       // Should not drag down as 0.5 is the only position allowed
//       expect(controller.animation.value, 0.5);
//       expect(tester.getRect(find.byKey(key)),
//           const Rect.fromLTRB(0.0, 525.0, _kWidth, 675.0));
//     });

//     testWidgets('Stops at 0.1 and 1.0, default initial extent 0.5',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0.1, 1.0],
//         initialExtent: 0.5,
//         itemExtent: 25.0,
//         itemCount: 6,
//         containerKey: key,
//         expanded: false,
//         resize: false,
//         snap: true,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       // Initial position should be 0.5
//       expect(tester.getRect(find.byKey(key)), rectForExtent(0.5, height: 150));
//       expect(controller.animation.value, 0.5);

//       // Drag up should snap to 1.0
//       await tester.drag(find.text('Item 0'), const Offset(0, -125));
//       await tester.pumpAndSettle();
//       expect(controller.animation.value, 1.0);
//       expect(tester.getRect(find.byKey(key)), rectForExtent(1.0, height: 150));

//       // Drag down should snap to 0.1
//       await tester.drag(find.text('Item 0'), const Offset(0, 400));
//       await tester.pumpAndSettle();
//       expect(controller.animation.value, 0.1);
//       expect(tester.getRect(find.byKey(key)), rectForExtent(0.1, height: 150));
//     });

//     testWidgets('Scrolls correctly to last stop when is < 1.0',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0, 0.6],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         itemCount: 6,
//         containerKey: key,
//         expanded: false,
//         resize: false,
//         snap: true,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       expect(tester.getRect(find.byKey(key)), rectForExtent(0.25, height: 150));
//       await tester.drag(find.text('Item 0'), const Offset(0, -125));
//       await tester.pumpAndSettle();
//       expect(controller.animation.value, 0.6);
//       expect(tester.getRect(find.byKey(key)), rectForExtent(0.6, height: 150));
//     });

//     testWidgets('Scrolls correctly to last stop when is == 1.0',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0, 1.0],
//         initialExtent: .5,
//         itemExtent: 25.0,
//         itemCount: 6,
//         containerKey: key,
//         expanded: false,
//         resize: false,
//         snap: true,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       expect(tester.getRect(find.byKey(key)), rectForExtent(0.5, height: 150));
//       await tester.drag(find.text('Item 0'), const Offset(0, -125));
//       await tester.pumpAndSettle();
//       expect(controller.animation.value, 1.0);
//       expect(tester.getRect(find.byKey(key)), rectForExtent(1.0, height: 150));
//     });

//     testWidgets('Scrolls correctly to first stop', (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0.1, 1.0],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         itemCount: 6,
//         containerKey: key,
//         expanded: false,
//         resize: false,
//         snap: true,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       expect(tester.getRect(find.byKey(key)), rectForExtent(0.25, height: 150));
//       await tester.drag(find.text('Item 0'), const Offset(0, 125));
//       await tester.pumpAndSettle();
//       expect(controller.animation.value, 0.1);
//       expect(tester.getRect(find.byKey(key)), rectForExtent(0.1, height: 150));
//     });

//     testWidgets('SheetController - set sheet extent',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0, 1.0],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         itemCount: 6,
//         containerKey: key,
//         snap: true,
//         expanded: false,
//         resize: false,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       expect(tester.getRect(find.byKey(key)), rectForExtent(0.25, height: 150));
//       controller.jumpTo(0.5);
//       await tester.pumpAndSettle();

//       expect(tester.getRect(find.byKey(key)), rectForExtent(0.5, height: 150));
//     });

//     testWidgets('SheetController - animate sheet extent',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0, 1.0],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         itemCount: 6,
//         containerKey: key,
//         snap: true,
//         expanded: false,
//         resize: false,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       expect(tester.getRect(find.byKey(key)), rectForExtent(0.25, height: 150));
//       controller.jumpTo(0.5);
//       await tester.pumpAndSettle();
//       expect(tester.getRect(find.byKey(key)), rectForExtent(0.5, height: 150));
//     });

//     testWidgets('SheetController - animate to nearest stop',
//         (WidgetTester tester) async {
//       final GlobalKey key = GlobalKey();
//       await tester.pumpWidget(TestSheet(
//         stops: const <double>[0, 1.0],
//         initialExtent: .25,
//         itemExtent: 25.0,
//         itemCount: 6,
//         containerKey: key,
//         snap: true,
//         expanded: false,
//         resize: false,
//       ));
//       final SheetController controller =
//           Sheet.of(key.currentContext!)!.controller;
//       expect(tester.getRect(find.byKey(key)), rectForExtent(0.25, height: 150));
//       controller.jumpTo(0.5);
//       await tester.pumpAndSettle();
//       expect(tester.getRect(find.byKey(key)), rectForExtent(1, height: 150));
//     });
//   });
// }

// extension on WidgetTester {
//   Future<void> pumpSheetScaffold(Widget sheet) async {
//     await pumpWidget(MaterialApp(
//       home: Stack(
//         children: <Widget>[
//           sheet,
//         ],
//       ),
//     ));
//   }
// }
