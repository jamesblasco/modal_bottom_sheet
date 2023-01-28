import 'package:flutter/widgets.dart';
import 'package:sheet/sheet.dart';

/// A [ScrollController] suitable for use in a [SheetPrimaryScrollPosition] created
/// by a [Sheet].
///
/// If a [Sheet] contains content that is exceeds the height
/// of its container, this controller will allow the sheet to both be dragged to
/// fill the container and then scroll the child content.
///
/// See also:
///
///  * [SheetPrimaryScrollPosition], which manages the positioning logic for
///    this controller.
///  * [PrimarySheetController], which can be used to establish a
///    [_SheetScrollController] as the primary controller for
///    descendants.
class SheetPrimaryScrollController extends ScrollController {
  SheetPrimaryScrollController({
    double initialScrollOffset = 0.0,
    String? debugLabel,
    required this.sheetContext,
  }) : super(
          debugLabel: debugLabel,
          initialScrollOffset: initialScrollOffset,
        );

  final SheetContext sheetContext;

  @override
  SheetPrimaryScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return SheetPrimaryScrollPosition(
      physics: physics,
      context: context,
      oldPosition: oldPosition,
      sheetContext: sheetContext,
    );
  }
}

class _SheetScrollActivity extends ScrollActivity {
  _SheetScrollActivity(SheetPosition delegate) : super(delegate);

  @override
  bool get isScrolling => true;

  @override
  bool get shouldIgnorePointer => false;

  @override
  double get velocity => 0;
}

/// A scroll position that manages scroll activities for
/// [_SheetScrollController].
///
/// This class is a concrete subclass of [ScrollPosition] logic that handles a
/// single [ScrollContext], such as a [Scrollable]. An instance of this class
/// manages [ScrollActivity] instances, which changes the
/// [SheetPrimaryScrollPosition.currentExtent] or visible content offset in the
/// [Scrollable]'s [Viewport]
///
/// See also:
///
///  * [_SheetScrollController], which uses this as its [ScrollPosition].
class SheetPrimaryScrollPosition extends ScrollPositionWithSingleContext {
  SheetPrimaryScrollPosition({
    required ScrollPhysics physics,
    required ScrollContext context,
    double initialPixels = 0.0,
    bool keepScrollOffset = true,
    required this.sheetContext,
    ScrollPosition? oldPosition,
    String? debugLabel,
  }) : super(
          physics: physics,
          context: context,
          initialPixels: initialPixels,
          keepScrollOffset: keepScrollOffset,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
        );

  final SheetContext sheetContext;
  SheetPosition get sheetPosition => sheetContext.position;

  bool sheetShouldSheetAcceptUserOffser(double delta) {
    // Can drag down if list already on the top
    final bool canDragForward = delta >= 0 && pixels <= minScrollExtent;

    // Can drag up if sheet is not yet on top and list is already on top
    final bool canDragBackwards = delta < 0 &&
        sheetPosition.pixels < sheetPosition.maxScrollExtent &&
        pixels <= minScrollExtent;

    return sheetPosition.physics.shouldAcceptUserOffset(sheetPosition) &&
        (canDragForward || canDragBackwards);
  }

  @override
  void applyUserOffset(double delta) {
    if (sheetPosition.preventingDrag) {
      return;
    }
    if (sheetShouldSheetAcceptUserOffser(delta)) {
      final double pixels = sheetPosition.pixels -
          sheetPosition.physics.applyPhysicsToUserOffset(sheetPosition, delta);

      sheetPosition.forcePixels(
        pixels.clamp(
            sheetPosition.minScrollExtent, sheetPosition.maxScrollExtent),
      );
      sheetPosition.beginActivity(_SheetScrollActivity(sheetPosition));
      return;
    } else {
      super.applyUserOffset(delta);
      sheetPosition.goIdle();
    }
  }

  @override
  void goBallistic(double velocity) {
    if (sheetPosition.preventingDrag) {
      beginActivity(
        BallisticScrollActivity(
          this,
          ScrollSpringSimulation(
            SpringDescription.withDampingRatio(
              mass: 0.5,
              stiffness: 100.0,
              ratio: 1.1,
            ),
            pixels,
            0,
            velocity,
          ),
          context.vsync,
          true,
        ),
      );

      return;
    }

    final bool sheetDragging = sheetPosition.activity!.isScrolling;
    if (sheetDragging &&
        sheetPosition.hasContentDimensions &&
        !sheetPosition.preventingDrag &&
        sheetPosition.activity!.isScrolling) {
      sheetPosition.goBallistic(velocity);
    } else {
      sheetPosition.goIdle();
    }

    if (!sheetDragging) {
      super.goBallistic(velocity);
      return;
    } else if (velocity > 0.0 &&
            sheetPosition.pixels >= sheetPosition.maxScrollExtent ||
        (velocity < 0.0 && pixels > 0)) {
      //   super.goBallistic(velocity);
      return;
    } else if (outOfRange) {
      beginActivity(
        BallisticScrollActivity(
          this,
          ScrollSpringSimulation(
            SpringDescription.withDampingRatio(
              mass: 0.5,
              stiffness: 100.0,
              ratio: 1.1,
            ),
            pixels,
            0,
            velocity,
          ),
          context.vsync,
          true,
        ),
      );
      return;
    }

    goIdle();
  }

  //@override
  //double get pixels => super.pixels + viewportDimension;
}
