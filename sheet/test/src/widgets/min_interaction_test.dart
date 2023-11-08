// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet/src/widgets/min_interaction.dart';

import '../../screen_size_test.dart';

extension on WidgetTester {
  Future<void> pumpInteractionZone({
    required AxisDirection direction,
    required double interationZoneExtent,
    required VoidCallback onTap,
  }) {
    return pumpWidget(
      GestureDetector(
        onTap: onTap,
        child: MinInteractionZone(
          direction: direction,
          extent: interationZoneExtent,
          child: Container(
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}

void main() {
  late VoidCallback mockOnTap;

  setUp(() {
    mockOnTap = MockVoidCallback().call;
    when(mockOnTap).thenAnswer((_) {});
  });

  group('MinInteractionZone', () {
    group('with extent detects pointer', () {
      const double interationZoneExtent = 100.0;
      group('AxisDirection.down', () {
        const AxisDirection direction = AxisDirection.down;
        testWidgets('Pointer at top left', (WidgetTester tester) async {
          await tester.pumpInteractionZone(
            direction: direction,
            interationZoneExtent: interationZoneExtent,
            onTap: mockOnTap,
          );

          await tester.tapAt(Offset(0, 0));
          verify(mockOnTap).called(1);
        });

        testWidgets('Pointer at top right', (WidgetTester tester) async {
          await tester.pumpInteractionZone(
            direction: direction,
            interationZoneExtent: interationZoneExtent,
            onTap: mockOnTap,
          );

          await tester.tapAt(Offset(kScreenSize.width - 0.1, 0));
          verify(mockOnTap).called(1);
        });

        testWidgets('Pointer at center', (WidgetTester tester) async {
          await tester.pumpInteractionZone(
            direction: direction,
            interationZoneExtent: interationZoneExtent,
            onTap: mockOnTap,
          );

          await tester
              .tapAt(Offset(kScreenSize.width / 2, interationZoneExtent / 2));
          verify(mockOnTap).called(1);
        });
        testWidgets('Pointer at bottom left', (WidgetTester tester) async {
          await tester.pumpInteractionZone(
            direction: direction,
            interationZoneExtent: interationZoneExtent,
            onTap: mockOnTap,
          );
          await tester.tapAt(Offset(0, interationZoneExtent - 0.1));
          verify(mockOnTap).called(1);
        });

        testWidgets('Pointer at bottom right', (WidgetTester tester) async {
          await tester.pumpInteractionZone(
            direction: direction,
            interationZoneExtent: interationZoneExtent,
            onTap: mockOnTap,
          );
          await tester.tapAt(
              Offset(kScreenSize.width - 0.1, interationZoneExtent - 0.1));
          verify(mockOnTap).called(1);
        });
      });

      for (final AxisDirection direction in AxisDirection.values) {
        group('$direction', () {
          final Rect interactionRect = <AxisDirection, Rect>{
            AxisDirection.up:
                Offset(0, kScreenSize.height - interationZoneExtent) &
                    Size(kScreenSize.width, interationZoneExtent),
            AxisDirection.down:
                Offset.zero & Size(kScreenSize.width, interationZoneExtent),
            AxisDirection.right:
                Offset.zero & Size(interationZoneExtent, kScreenSize.height),
            AxisDirection.left:
                Offset(kScreenSize.width - interationZoneExtent, 0) &
                    Size(interationZoneExtent, kScreenSize.height),
          }[direction]!;

          group('Pointer detected inside', () {
            final Rect insideArea =
                EdgeInsets.all(0.1).deflateRect(interactionRect);
            testWidgets('at top left', (WidgetTester tester) async {
              await tester.pumpInteractionZone(
                direction: direction,
                interationZoneExtent: interationZoneExtent,
                onTap: mockOnTap,
              );
              await tester.tapAt(insideArea.topLeft);
              verify(mockOnTap).called(1);
            });

            testWidgets('at top right', (WidgetTester tester) async {
              await tester.pumpInteractionZone(
                direction: direction,
                interationZoneExtent: interationZoneExtent,
                onTap: mockOnTap,
              );
              await tester.tapAt(insideArea.topRight);
              verify(mockOnTap).called(1);
            });

            testWidgets('at center', (WidgetTester tester) async {
              await tester.pumpInteractionZone(
                direction: direction,
                interationZoneExtent: interationZoneExtent,
                onTap: mockOnTap,
              );
              await tester.tapAt(insideArea.center);
              verify(mockOnTap).called(1);
            });
            testWidgets('at bottom left', (WidgetTester tester) async {
              await tester.pumpInteractionZone(
                direction: direction,
                interationZoneExtent: interationZoneExtent,
                onTap: mockOnTap,
              );
              await tester.tapAt(insideArea.bottomLeft);
              verify(mockOnTap).called(1);
            });

            testWidgets('at bottom right', (WidgetTester tester) async {
              await tester.pumpInteractionZone(
                direction: direction,
                interationZoneExtent: interationZoneExtent,
                onTap: mockOnTap,
              );
              await tester.tapAt(insideArea.bottomRight);
              verify(mockOnTap).called(1);
            });
          });
          group('Pointer not detected outside', () {
            final Rect outsideArea =
                EdgeInsets.all(0.1).inflateRect(interactionRect);
            testWidgets('at top left', (WidgetTester tester) async {
              await tester.pumpInteractionZone(
                direction: direction,
                interationZoneExtent: interationZoneExtent,
                onTap: mockOnTap,
              );
              await tester.tapAt(outsideArea.topLeft);
              verifyNever(mockOnTap);
            });

            testWidgets('at top right', (WidgetTester tester) async {
              await tester.pumpInteractionZone(
                direction: direction,
                interationZoneExtent: interationZoneExtent,
                onTap: mockOnTap,
              );
              await tester.tapAt(outsideArea.topRight);
              verifyNever(mockOnTap);
            });

            testWidgets('at bottom left', (WidgetTester tester) async {
              await tester.pumpInteractionZone(
                direction: direction,
                interationZoneExtent: interationZoneExtent,
                onTap: mockOnTap,
              );
              await tester.tapAt(outsideArea.bottomLeft);
              verifyNever(mockOnTap);
            });

            testWidgets('at bottom right', (WidgetTester tester) async {
              await tester.pumpInteractionZone(
                direction: direction,
                interationZoneExtent: interationZoneExtent,
                onTap: mockOnTap,
              );
              await tester.tapAt(outsideArea.bottomRight);
              verifyNever(mockOnTap);
            });
          });
        });
      }
    });

    group('MinInteractionZone no detects pointer outside of zone', () {
      testWidgets('Axis done', (WidgetTester tester) async {
        await tester.pumpInteractionZone(
          direction: AxisDirection.down,
          interationZoneExtent: 0,
          onTap: mockOnTap,
        );
        await tester.tapAt(Offset(20, 20));
        verifyNever(mockOnTap);
      });
    });

    group('Updates render object values', () {
      testWidgets('AxisDirection', (WidgetTester tester) async {
        late StateSetter setState;
        AxisDirection direction = AxisDirection.down;
        await tester.pumpWidget(
          StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
            setState = stateSetter;
            return MinInteractionZone(
              direction: direction,
              extent: 200,
              child: Container(
                width: double.infinity,
              ),
            );
          }),
        );
        final MinInteractionPaddingRenderBox renderObject =
            tester.renderObject<MinInteractionPaddingRenderBox>(
                find.byType(MinInteractionZone));
        expect(renderObject.direction, direction);

        direction = AxisDirection.up;
        setState(() {});
        await tester.pump();
        expect(renderObject.direction, direction);
      });

      testWidgets('extent', (WidgetTester tester) async {
        late StateSetter setState;
        double extent = 200;
        await tester.pumpWidget(
          StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
            setState = stateSetter;
            return MinInteractionZone(
              direction: AxisDirection.down,
              extent: extent,
              child: Container(
                width: double.infinity,
              ),
            );
          }),
        );
        final MinInteractionPaddingRenderBox renderObject =
            tester.renderObject<MinInteractionPaddingRenderBox>(
                find.byType(MinInteractionZone));
        expect(renderObject.extent, extent);

        extent = 300;
        setState(() {});
        await tester.pump();
        expect(renderObject.extent, extent);
      });
    });
  });
}

class _VoidCallback {
  void call() {}
}

class MockVoidCallback extends Mock implements _VoidCallback {}
