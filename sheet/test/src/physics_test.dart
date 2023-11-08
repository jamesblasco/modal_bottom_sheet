import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

import '../helpers.dart';
import '../screen_size_test.dart';

void main() {
  group('SheetPhysics', () {
    group('NeverDraggableSheetPhysics', () {
      testWidgets('does not scroll', (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            physics: const NeverDraggableSheetPhysics(parent: null),
            initialExtent: kScreenSize.height,
            fit: SheetFit.expand,
            child: Container(
              color: Colors.red,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(find.byType(Container)), kScreenRect);
        await tester.drag(find.byType(Container), const Offset(0, 100));
        expect(tester.getRect(find.byType(Container)), kScreenRect);
      });

      test('should not reload', () async {
        expect(
          const NeverDraggableSheetPhysics()
              .shouldReload(const NeverDraggableSheetPhysics()),
          isFalse,
        );
      });
    });

    group('AlwaysDraggableSheetPhysics', () {
      testWidgets('scrolls', (WidgetTester tester) async {
        await tester.pumpApp(
          Sheet(
            physics: const AlwaysDraggableSheetPhysics(),
            initialExtent: kScreenSize.height,
            fit: SheetFit.expand,
            child: Container(
              color: Colors.red,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(find.byType(Container)), kScreenRect);
        await tester.drag(find.byType(Container), const Offset(0, 100));
        expect(tester.getRect(find.byType(Container)),
            kScreenRect.translate(0, 100));
      });
    });
    group('BouncingSheetPhysics', () {
      late BouncingSheetPhysics physicsUnderTest;

      setUp(() {
        physicsUnderTest = const BouncingSheetPhysics();
      });
      test('should not reload by default', () {
        expect(
          physicsUnderTest.shouldReload(const BouncingSheetPhysics()),
          isFalse,
        );
      });

      test('should reload if params is different', () {
        expect(
          physicsUnderTest.shouldReload(
            const BouncingSheetPhysics(overflowViewport: true),
          ),
          isTrue,
        );
      });

      test('overscroll is progressively harder', () {
        final ScrollMetrics lessOverscrolledPosition = FixedScrollMetrics(
          minScrollExtent: 0.0,
          maxScrollExtent: 1000.0,
          pixels: -20.0,
          viewportDimension: 100.0,
          axisDirection: AxisDirection.down,
          devicePixelRatio: 1,
        );

        final ScrollMetrics moreOverscrolledPosition = FixedScrollMetrics(
          minScrollExtent: 0.0,
          maxScrollExtent: 1000.0,
          pixels: -40.0,
          viewportDimension: 100.0,
          axisDirection: AxisDirection.down,
          devicePixelRatio: 1,
        );

        final double lessOverscrollApplied = physicsUnderTest
            .applyPhysicsToUserOffset(lessOverscrolledPosition, 10.0);

        final double moreOverscrollApplied = physicsUnderTest
            .applyPhysicsToUserOffset(moreOverscrolledPosition, 10.0);

        expect(lessOverscrollApplied, greaterThan(0.1));
        expect(lessOverscrollApplied, lessThan(20.0));

        expect(moreOverscrollApplied, greaterThan(0.1));
        expect(moreOverscrollApplied, lessThan(20.0));

        // Scrolling from a more overscrolled position meets more resistance.
        expect(
          lessOverscrollApplied.abs(),
          greaterThan(moreOverscrollApplied.abs()),
        );
      });

      test('easing an overscroll still has resistance', () {
        final ScrollMetrics overscrolledPosition = FixedScrollMetrics(
          minScrollExtent: 0.0,
          maxScrollExtent: 1000.0,
          pixels: -20.0,
          viewportDimension: 100.0,
          axisDirection: AxisDirection.down,
          devicePixelRatio: 1,
        );

        final double easingApplied = physicsUnderTest.applyPhysicsToUserOffset(
            overscrolledPosition, -10.0);

        expect(easingApplied, lessThan(-0.1));
        expect(easingApplied, greaterThan(-10.0));
      });

      test('no resistance when not overscrolled', () {
        final ScrollMetrics scrollPosition = FixedScrollMetrics(
          minScrollExtent: 0.0,
          maxScrollExtent: 1000.0,
          devicePixelRatio: 1,
          pixels: 300.0,
          viewportDimension: 100.0,
          axisDirection: AxisDirection.down,
        );

        expect(
          physicsUnderTest.applyPhysicsToUserOffset(scrollPosition, 10.0),
          10.0,
        );
        expect(
          physicsUnderTest.applyPhysicsToUserOffset(scrollPosition, -10.0),
          -10.0,
        );
      });

      test('easing an overscroll meets less resistance than tensioning', () {
        final ScrollMetrics overscrolledPosition = FixedScrollMetrics(
          minScrollExtent: 0.0,
          maxScrollExtent: 1000.0,
          pixels: -20.0,
          viewportDimension: 100.0,
          axisDirection: AxisDirection.down,
          devicePixelRatio: 1,
        );

        final double easingApplied = physicsUnderTest.applyPhysicsToUserOffset(
            overscrolledPosition, -10.0);
        final double tensioningApplied = physicsUnderTest
            .applyPhysicsToUserOffset(overscrolledPosition, 10.0);

        expect(easingApplied.abs(), greaterThan(tensioningApplied.abs()));
      });

      test('overscroll a small extent and a big extent works the same way', () {
        final ScrollMetrics smallListOverscrolledPosition = FixedScrollMetrics(
          minScrollExtent: 0.0,
          maxScrollExtent: 10.0,
          pixels: -20.0,
          devicePixelRatio: 1,
          viewportDimension: 100.0,
          axisDirection: AxisDirection.down,
        );

        final ScrollMetrics bigListOverscrolledPosition = FixedScrollMetrics(
          minScrollExtent: 0.0,
          devicePixelRatio: 1,
          maxScrollExtent: 1000.0,
          pixels: -20.0,
          viewportDimension: 100.0,
          axisDirection: AxisDirection.down,
        );

        final double smallListOverscrollApplied = physicsUnderTest
            .applyPhysicsToUserOffset(smallListOverscrolledPosition, 10.0);

        final double bigListOverscrollApplied = physicsUnderTest
            .applyPhysicsToUserOffset(bigListOverscrolledPosition, 10.0);

        expect(smallListOverscrollApplied, equals(bigListOverscrollApplied));

        expect(smallListOverscrollApplied, greaterThan(0.3));
        expect(smallListOverscrollApplied, lessThan(20.0));
      });

      group('applyBoundaryConditions', () {
        test(
            'throws when proposed pixels '
            'are the same as the current ones', () {
          final ScrollMetrics scrollMetrics = FixedScrollMetrics(
            minScrollExtent: 0.0,
            maxScrollExtent: 200.0,
            devicePixelRatio: 1,
            pixels: 10.0,
            viewportDimension: 100.0,
            axisDirection: AxisDirection.down,
          );
          expect(
            () => physicsUnderTest.applyBoundaryConditions(scrollMetrics, 10.0),
            throwsAssertionError,
          );
        });

        group('when overflowViewport', () {
          test('does not appyBoundaryConditions top edge', () {
            const BouncingSheetPhysics physicsUnderTest =
                BouncingSheetPhysics(overflowViewport: true);

            final ScrollMetrics scrollMetrics = FixedScrollMetrics(
              minScrollExtent: 0.0,
              maxScrollExtent: 200.0,
              devicePixelRatio: 1,
              pixels: 120.0,
              viewportDimension: 100.0,
              axisDirection: AxisDirection.down,
            );
            expect(
              physicsUnderTest.applyBoundaryConditions(scrollMetrics, 121.0),
              isZero,
            );
            expect(
              physicsUnderTest.applyBoundaryConditions(scrollMetrics, 119.0),
              isZero,
            );
          });
          test('does appyBoundaryConditions bottom edge', () {
            const BouncingSheetPhysics physicsUnderTest =
                BouncingSheetPhysics(overflowViewport: true);

            final ScrollMetrics scrollMetrics = FixedScrollMetrics(
              minScrollExtent: 0.0,
              maxScrollExtent: 200.0,
              devicePixelRatio: 1,
              pixels: -10.0,
              viewportDimension: 100.0,
              axisDirection: AxisDirection.down,
            );
            expect(
              physicsUnderTest.applyBoundaryConditions(scrollMetrics, -11.0),
              -1,
            );
            expect(
              physicsUnderTest.applyBoundaryConditions(scrollMetrics, -9.0),
              0,
            );
          });
        });
      });

      group('when no overflowViewport appyBoundaryConditions', () {
        test('top edge', () {
          final ScrollMetrics scrollMetrics = FixedScrollMetrics(
            minScrollExtent: 0.0,
            maxScrollExtent: 200.0,
            devicePixelRatio: 1,
            pixels: 120.0,
            viewportDimension: 100.0,
            axisDirection: AxisDirection.down,
          );
          expect(
            physicsUnderTest.applyBoundaryConditions(scrollMetrics, 121.0),
            1,
          );
          expect(
            physicsUnderTest.applyBoundaryConditions(scrollMetrics, 119.0),
            isZero,
          );
        });
        test('bottom edge', () {
          final ScrollMetrics scrollMetrics = FixedScrollMetrics(
            minScrollExtent: 0.0,
            maxScrollExtent: 200.0,
            devicePixelRatio: 1,
            pixels: -10.0,
            viewportDimension: 100.0,
            axisDirection: AxisDirection.down,
          );
          expect(
            physicsUnderTest.applyBoundaryConditions(scrollMetrics, -11.0),
            -1,
          );
          expect(
            physicsUnderTest.applyBoundaryConditions(scrollMetrics, -9.0),
            0,
          );
        });
      });
    });

    group('NoMomentumSheetPhysics', () {
      late NoMomentumSheetPhysics physicsUnderTest;

      setUp(() {
        physicsUnderTest = const NoMomentumSheetPhysics();
      });

      group('clamps with applyBoundaryConditions', () {
        test('top edge', () {
          final ScrollMetrics scrollMetrics = FixedScrollMetrics(
            minScrollExtent: 0.0,
            maxScrollExtent: 200.0,
            devicePixelRatio: 1,
            pixels: 120.0,
            viewportDimension: 100.0,
            axisDirection: AxisDirection.down,
          );
          expect(
            physicsUnderTest.applyBoundaryConditions(scrollMetrics, 201.0),
            1,
          );
          expect(
            physicsUnderTest.applyBoundaryConditions(scrollMetrics, 199.0),
            isZero,
          );
        });
        test('bottom edge', () {
          final ScrollMetrics scrollMetrics = FixedScrollMetrics(
            minScrollExtent: 0.0,
            maxScrollExtent: 200.0,
            devicePixelRatio: 1,
            pixels: -10.0,
            viewportDimension: 100.0,
            axisDirection: AxisDirection.down,
          );
          expect(
            physicsUnderTest.applyBoundaryConditions(scrollMetrics, -11.0),
            -1,
          );
          expect(
            physicsUnderTest.applyBoundaryConditions(scrollMetrics, -9.0),
            0,
          );
        });
      });
    });

    testWidgets('SnapSheetPhysics', (WidgetTester tester) async {
      await tester.pumpApp(
        Sheet(
          physics: const SnapSheetPhysics(stops: <double>[0, 1]),
          initialExtent: kScreenSize.height,
          fit: SheetFit.expand,
          child: Container(
            color: Colors.red,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSheetTop(), isZero);
      expect(tester.getSheetHeight(), kScreenSize.height);

      await tester.dragSheet(300);
      await tester.pumpAndSettle();
      expect(tester.getSheetTop(), kScreenSize.height);
    });
  });
}
