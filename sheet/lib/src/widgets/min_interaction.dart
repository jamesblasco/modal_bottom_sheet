import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

/// A widget that add a min interaction zone where hitTestSelf is true
/// This is rarely used by its own
///
/// See also:
///
///  * [Sheet], that uses this widget that enables to drag closed/hidden
/// sheets
class MinInteractionZone extends SingleChildRenderObjectWidget {
  const MinInteractionZone({
    required this.direction,
    required this.extent,
    required Widget child,
  }) : super(child: child);

  final AxisDirection direction;

  final double extent;

  @override
  MinInteractionPaddingRenderBox createRenderObject(BuildContext context) {
    return MinInteractionPaddingRenderBox(direction, extent);
  }

  @override
  void updateRenderObject(
      BuildContext context, MinInteractionPaddingRenderBox renderObject) {
    renderObject
      ..direction = direction
      ..extent = extent;
  }
}

class MinInteractionPaddingRenderBox extends RenderProxyBox {
  MinInteractionPaddingRenderBox(AxisDirection direction, double extent)
      : _direction = direction,
        _extent = extent;

  AxisDirection _direction;
  AxisDirection get direction => _direction;
  set direction(AxisDirection value) {
    // ignore: always_put_control_body_on_new_line
    if (value == _direction) return;
    _direction = value;
  }

  double _extent;
  double get extent => _extent;
  set extent(double value) {
    // ignore: always_put_control_body_on_new_line
    if (value == _extent) return;
    _extent = value;
  }

  @override
  bool hitTestSelf(Offset position) {
    Rect minInteractionZone;
    switch (direction) {
      case AxisDirection.up:
        minInteractionZone =
            Rect.fromLTRB(0, size.height - extent, size.width, size.height);
        break;
      case AxisDirection.down:
        minInteractionZone = Rect.fromLTRB(0, 0, size.width, extent);
        break;
      case AxisDirection.right:
        minInteractionZone = Rect.fromLTRB(0, 0, extent, size.height);
        break;
      case AxisDirection.left:
        minInteractionZone =
            Rect.fromLTRB(size.width - extent, 0, size.width, size.height);
        break;
    }
    return minInteractionZone.contains(position);
  }
}
