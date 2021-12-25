
import 'package:flutter/cupertino.dart';

class CustomBouncingScrollPhysics extends BouncingScrollPhysics {

  const CustomBouncingScrollPhysics({
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  CustomBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomBouncingScrollPhysics(
      parent: buildParent(ancestor),
    );
  }
  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.pixels && position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    return 0.0;
  }
}
