import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class BottomModalScrollPhysics extends ScrollPhysics {
  /// Creates scroll physics that prevent the scroll offset from exceeding the
  /// top bound of the modal.
  const BottomModalScrollPhysics({ScrollPhysics parent})
      : super(parent: parent);

  @override
  BottomModalScrollPhysics applyTo(ScrollPhysics ancestor) {

    return BottomModalScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double value) {
    assert(() {
      if (value == position.pixels) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              '$runtimeType.applyPhysicsToUserOffset() was called redundantly.'),
          ErrorDescription(
              'The proposed new position, $value, is exactly equal to the current position of the '
              'given ${position.runtimeType}, ${position.pixels}.\n'
              'The applyBoundaryConditions method should only be called when the value is '
              'going to actually change the pixels, otherwise it is redundant.'),
          DiagnosticsProperty<ScrollPhysics>(
              'The physics object in question was', this,
              style: DiagnosticsTreeStyle.errorProperty),
          DiagnosticsProperty<ScrollMetrics>(
              'The position object in question was', position,
              style: DiagnosticsTreeStyle.errorProperty)
        ]);
      }
      return true;
    }());
    final direction = position.axisDirection;
    // Normal vertical scroll
    if (direction == AxisDirection.down) {
      if (value < position.pixels &&
          position.pixels <= position.minScrollExtent) // underscroll
        return value - position.pixels;

      if (value < position.minScrollExtent &&
          position.minScrollExtent < position.pixels) // hit top edge
        return value - position.minScrollExtent;
    }
    // Reversed vertical scroll
    else if (direction == AxisDirection.up) {
      final pixels =  position.maxScrollExtent - position.pixels;
      if (value < pixels &&
          pixels <= position.minScrollExtent) // underscroll
        return value - pixels;

      if (value < position.minScrollExtent &&
          position.minScrollExtent < pixels) // hit top edge
        return value - position.minScrollExtent;
    }
    if (parent != null) return super.applyPhysicsToUserOffset(position, value);
    return 0.0;
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
              'going to actually change the pixels, otherwise it is redundant.'),
          DiagnosticsProperty<ScrollPhysics>(
              'The physics object in question was', this,
              style: DiagnosticsTreeStyle.errorProperty),
          DiagnosticsProperty<ScrollMetrics>(
              'The position object in question was', position,
              style: DiagnosticsTreeStyle.errorProperty)
        ]);
      }
      return true;
    }());
    final direction = position.axisDirection;
    // Normal vertical scroll
    if (direction == AxisDirection.down) {
      if (value < position.pixels &&
          position.pixels <= position.minScrollExtent) // underscroll
        return 0.0;

      if (value < position.minScrollExtent &&
          position.minScrollExtent < position.pixels) // hit top edge
        return 0.0;
    }
    // Reversed vertical scroll
    else if (direction == AxisDirection.up) {
      if (position.maxScrollExtent <= position.pixels &&
          position.pixels < value) // overscroll
        return 0.0;

      if (position.pixels < position.maxScrollExtent &&
          position.maxScrollExtent < value) // hit bottom edge
        return 0.0;
    }
    if (parent != null) return super.applyBoundaryConditions(position, value);
    return 0.0;
  }
}
