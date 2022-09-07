import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// {@template flutter.widgets.sheet.physics}
/// Determines the physics of a [Sheet] widget.
///
/// For example, determines how the [Sheet] will behave when the user
/// reaches the maximum drag extent or when the user stops dragging.
/// {@endtemplate}
mixin SheetPhysics on ScrollPhysics {
  bool shouldReload(covariant ScrollPhysics old) => false;
}

/// Sheet physics that does not allow the user to drag a sheet.
class NeverDraggableSheetPhysics extends NeverScrollableScrollPhysics
    with SheetPhysics {
  const NeverDraggableSheetPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  NeverDraggableSheetPhysics applyTo(ScrollPhysics? ancestor) {
    return NeverDraggableSheetPhysics(parent: buildParent(ancestor));
  }
}

/// Sheet physics that always lets the user to drag a sheet.
class AlwaysDraggableSheetPhysics extends AlwaysScrollableScrollPhysics
    with SheetPhysics {
  /// Creates scroll physics that always lets the user scroll.
  const AlwaysDraggableSheetPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  AlwaysDraggableSheetPhysics applyTo(ScrollPhysics? ancestor) {
    return AlwaysDraggableSheetPhysics(parent: buildParent(ancestor));
  }
}

/// Creates sheet physics that bounce back from the edge.
class BouncingSheetPhysics extends ScrollPhysics with SheetPhysics {
  /// Creates sheet physics that bounce back from the edge.
  const BouncingSheetPhysics({
    ScrollPhysics? parent,
    this.overflowViewport = false,
  }) : super(parent: parent);

  final bool overflowViewport;

  @override
  BouncingSheetPhysics applyTo(ScrollPhysics? ancestor) {
    return BouncingSheetPhysics(
        parent: buildParent(ancestor), overflowViewport: overflowViewport);
  }

  @override
  bool shouldReload(covariant ScrollPhysics old) {
    return old is BouncingSheetPhysics &&
        old.overflowViewport != overflowViewport;
  }

  /// The multiple applied to overscroll to make it appear that scrolling past
  /// the edge of the scrollable contents is harder than scrolling the list.
  /// This is done by reducing the ratio of the scroll effect output vs the
  /// scroll gesture input.
  ///
  /// This factor starts at 0.52 and progressively becomes harder to overscroll
  /// as more of the area past the edge is dragged in (represented by an increasing
  /// `overscrollFraction` which starts at 0 when there is no overscroll).
  double frictionFactor(double overscrollFraction) =>
      0.1 * math.pow(1 - overscrollFraction, 4);

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    if (!position.outOfRange) {
      return offset;
    }

    final double overscrollPastStart =
        math.max(position.minScrollExtent - position.pixels, 0.0);
    final double overscrollPastEnd =
        math.max(position.pixels - position.maxScrollExtent, 0.0);
    final double overscrollPast =
        math.max(overscrollPastStart, overscrollPastEnd);
    final bool easing = (overscrollPastStart > 0.0 && offset < 0.0) ||
        (overscrollPastEnd > 0.0 && offset > 0.0);

    final double friction = easing
        // Apply less resistance when easing the overscroll vs tensioning.
        ? frictionFactor(
            (overscrollPast - offset.abs()) / position.viewportDimension)
        : frictionFactor(overscrollPast / position.viewportDimension);
    final double direction = offset.sign;

    return direction * _applyFriction(overscrollPast, offset.abs(), friction);
  }

  static double _applyFriction(
    double extentOutside,
    double absDelta,
    double gamma,
  ) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit) {
        return absDelta * gamma;
      }
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    assert(() {
      if (value == position.pixels) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              '$runtimeType.applyBoundaryConditions() was called redundantly.'),
          ErrorDescription(
            'The proposed new position, $value, is exactly equal to the current position of the '
            'given ${position.runtimeType}, ${position.pixels}.\n'
            'The applyBoundaryConditions method should only be called when the value is '
            'going to actually change the pixels, otherwise it is redundant.',
          ),
          DiagnosticsProperty<ScrollPhysics>(
              'The physics object in question was', this,
              style: DiagnosticsTreeStyle.errorProperty),
          DiagnosticsProperty<ScrollMetrics>(
              'The position object in question was', position,
              style: DiagnosticsTreeStyle.errorProperty),
        ]);
      }
      return true;
    }());
    if (!overflowViewport) {
      // overscroll
      if (position.viewportDimension <= position.pixels &&
          position.pixels < value) {
        return value - position.pixels;
      }
      // hit top edge
      if (value < position.viewportDimension &&
          position.viewportDimension < position.pixels) {
        return value - position.viewportDimension;
      }
    }
    // underscroll
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    // hit bottom edge
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value) {
      return value - position.maxScrollExtent;
    }
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (position.outOfRange) {
      return BouncingScrollSimulation(
        spring: const SpringDescription(
          mass: 1.2,
          stiffness: 200.0,
          damping: 25,
        ),
        position: position.pixels,
        velocity: velocity,
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
      );
    }
    return super.createBallisticSimulation(position, velocity);
  }

  // The ballistic simulation here decelerates more slowly than the one for
  // ClampingScrollPhysics so we require a more deliberate input gesture
  // to trigger a fling.
  @override
  double get minFlingVelocity => kMinFlingVelocity * 2.0;

  // Methodology:
  // 1- Use https://github.com/flutter/platform_tests/tree/master/scroll_overlay to test with
  //    Flutter and platform scroll views superimposed.
  // 3- If the scrollables stopped overlapping at any moment, adjust the desired
  //    output value of this function at that input speed.
  // 4- Feed new input/output set into a power curve fitter. Change function
  //    and repeat from 2.
  // 5- Repeat from 2 with medium and slow flings.
  /// Momentum build-up function that mimics iOS's scroll speed increase with repeated flings.
  ///
  /// The velocity of the last fling is not an important factor. Existing speed
  /// and (related) time since last fling are factors for the velocity transfer
  /// calculations.
  @override
  double carriedMomentum(double existingVelocity) {
    return existingVelocity.sign *
        math.min(0.000816 * math.pow(existingVelocity.abs(), 1.967).toDouble(),
            40000.0);
  }

  // Eyeballed from observation to counter the effect of an unintended scroll
  // from the natural motion of lifting the finger after a scroll.
  @override
  double get dragStartDistanceMotionThreshold => 3.5;
}

/// Creates sheet physics that has no momentum after the user stops dragging.
class NoMomentumSheetPhysics extends ScrollPhysics with SheetPhysics {
  /// Creates sheet physics that has no momentum after the user stops dragging.
  const NoMomentumSheetPhysics({
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  NoMomentumSheetPhysics applyTo(ScrollPhysics? ancestor) {
    return NoMomentumSheetPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // underscroll
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) {
      // overscroll
      return value - position.pixels;
    }
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      // hit top edge
      return value - position.minScrollExtent;
    }
    if (position.pixels < position.maxScrollExtent &&
        position.maxScrollExtent < value) {
      // hit bottom edge
      return value - position.maxScrollExtent;
    }
    return 0.0;

    // if (position.viewportDimension <= position.pixels &&
    //     position.pixels < value) // hit top edge
    //   return value - position.pixels;
    // if (position.pixels < 0 && position.pixels > value) // hit bottom edge
    //   return value - position.pixels;
    // return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (position.outOfRange) {
      double? end;
      if (position.pixels > position.maxScrollExtent) {
        end = position.maxScrollExtent;
      } else if (position.pixels < position.minScrollExtent) {
        end = position.minScrollExtent;
      }
      assert(end != null);
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        end!,
        math.min(0.0, velocity),
        tolerance: tolerance,
      );
    }
    return null;
  }
}

class ClampingSheetPhysics extends ScrollPhysics with SheetPhysics {
  /// Creates sheet physics that has no momentum after the user stops dragging.
  const ClampingSheetPhysics({
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  ClampingSheetPhysics applyTo(ScrollPhysics? ancestor) {
    return ClampingSheetPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    assert(() {
      if (value == position.pixels) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              '$runtimeType.applyBoundaryConditions() was called redundantly.'),
          ErrorDescription(
            'The proposed new position, $value, is exactly equal to the current position of the '
            'given ${position.runtimeType}, ${position.pixels}.\n'
            'The applyBoundaryConditions method should only be called when the value is '
            'going to actually change the pixels, otherwise it is redundant.',
          ),
          DiagnosticsProperty<ScrollPhysics>(
              'The physics object in question was', this,
              style: DiagnosticsTreeStyle.errorProperty),
          DiagnosticsProperty<ScrollMetrics>(
              'The position object in question was', position,
              style: DiagnosticsTreeStyle.errorProperty),
        ]);
      }
      return true;
    }());
    // hit top edge
    if (position.viewportDimension <= position.pixels &&
        position.pixels < value) {
      return value - position.pixels;
    }
    // hit bottom edge
    if (position.pixels < 0 && position.pixels > value) {
      return value - position.pixels;
    }
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (position.outOfRange) {
      double? end;
      if (position.pixels > position.maxScrollExtent) {
        end = position.maxScrollExtent;
      }
      if (position.pixels < position.minScrollExtent) {
        end = position.minScrollExtent;
      }
      assert(end != null);
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        end!,
        math.min(0.0, velocity),
        tolerance: tolerance,
      );
    }
    if (velocity.abs() < tolerance.velocity) {
      return null;
    }
    if (velocity > 0.0 && position.pixels >= position.maxScrollExtent) {
      return null;
    }
    if (velocity < 0.0 && position.pixels <= position.minScrollExtent) {
      return null;
    }
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      tolerance: tolerance,
    );
  }
}

/// Creates snapping physics for a [Sheet].
///
/// When the user stops dragging, the sheet will be snapped to one
/// of closest value inside the [stops] list
///
/// If [relative] is true, this values must be between 0 and 1, where
/// 0 represent the sheet totally hidden and 1 fully visible.
///
/// If [relative] is false, the values are real pixels and will be clamped
/// to [Sheet.minExtent] and [Sheet.maxExtent]
///
class SnapSheetPhysics extends ScrollPhysics with SheetPhysics {
  /// Creates snapping physics for a [Sheet].
  const SnapSheetPhysics({
    ScrollPhysics? parent,
    this.stops = const <double>[],
    this.relative = true,
  }) : super(parent: parent);

  /// Positions where the sheet could be snapped once the user stops
  /// dragging
  final List<double> stops;

  /// If [relative] is true, this values must be between 0 and 1, where
  /// 0 represent the sheet totally hidden and 1 fully visible.
  ///
  /// If [relative] is false, the values are real pixels and will be clamped
  /// to [Sheet.minExtent] and [Sheet.maxExtent]
  ///
  /// The default values is `false`
  final bool relative;

  @override
  SnapSheetPhysics applyTo(ScrollPhysics? ancestor) {
    return SnapSheetPhysics(
      parent: buildParent(ancestor),
      stops: stops,
      relative: relative,
    );
  }

  @override
  bool shouldReload(covariant ScrollPhysics old) {
    return old is SnapSheetPhysics &&
        (old.relative != relative || !listEquals(old.stops, stops));
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    int page = _getPage(position) ?? 0;

    final double targetPixels =
        getPixelsFromPage(position, page.clamp(0, stops.length - 1));

    if (targetPixels > position.pixels && velocity < -tolerance.velocity) {
      page -= 1;
    } else if (targetPixels < position.pixels &&
        velocity > tolerance.velocity) {
      page += 1;
    }

    return getPixelsFromPage(position, page.clamp(0, stops.length - 1));
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    // if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
    //     (velocity >= 0.0 && position.pixels >= position.maxScrollExtent))
    //   return super.createBallisticSimulation(position, velocity);
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        const SpringDescription(damping: 25, stiffness: 200, mass: 1.2),
        position.pixels,
        target,
        velocity.clamp(-200, 200),
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;

  int getPageFromPixels(double pixels, double extent) {
    final double actual = math.max(0.0, pixels) / math.max(1.0, extent);
    final int round = _nearestStopForExtent(actual);
    //final double round = actual.roundToDouble();
    if ((actual - round).abs() < precisionErrorTolerance) {
      return round;
    }
    return round;
  }

  int _nearestStopForExtent(double extent) {
    if (stops.isEmpty) {
      return 0;
    }
    final int stop = stops.asMap().entries.reduce(
      (MapEntry<int, double> prev, MapEntry<int, double> curr) {
        return (curr.value - extent).abs() < (prev.value - extent).abs()
            ? curr
            : prev;
      },
    ).key;
    return stop;
  }

  double extentFor(ScrollMetrics position) {
    if (relative) {
      return position.maxScrollExtent;
    }
    return 1;
  }

  double getPixelsFromPage(ScrollMetrics position, int page) {
    if (stops[page].isInfinite) {
      return position.maxScrollExtent;
    }
    return stops[page] * extentFor(position);
  }

  int? _getPage(ScrollMetrics position) {
    assert(
      !position.hasPixels || position.hasContentDimensions,
      'Page value is only available after content dimensions are established.',
    );
    return !position.hasPixels
        ? null
        : getPageFromPixels(
            position.pixels
                .clamp(position.minScrollExtent, position.maxScrollExtent),
            extentFor(position),
          );
  }
}

/// Describes how [SheetScrollable] widgets should behave.
class SheetBehaviour extends ScrollBehavior {
  static const SheetPhysics _clampingPhysics =
      NoMomentumSheetPhysics(parent: RangeMaintainingScrollPhysics());

  @override
  SheetPhysics getScrollPhysics(BuildContext context) {
    return _clampingPhysics;
  }
}
