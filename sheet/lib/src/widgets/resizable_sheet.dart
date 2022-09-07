// ignore_for_file: always_put_control_body_on_new_line

import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:sheet/sheet.dart';

/// A widget that allows to resize the child according to offset
/// of a sheet
///
/// See also:
///
///  * [Sheet], that uses this widget to allow resizable sheet child
class ResizableSheetChild extends SingleChildRenderObjectWidget {
  const ResizableSheetChild({
    Key? key,
    this.minExtent = 0,
    required this.offset,
    required Widget child,
    required this.resizable,
  }) : super(key: key, child: child);

  final double minExtent;
  final bool resizable;
  final ViewportOffset offset;

  @override
  RenderResizableSheetChildBox createRenderObject(BuildContext context) {
    return RenderResizableSheetChildBox(
      offset: offset,
      minExtent: minExtent,
      resizable: resizable,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderResizableSheetChildBox renderObject) {
    // Order dependency: The offset setter reads the axis direction.
    renderObject
      ..offset = offset
      ..minExtent = minExtent
      ..resizable = resizable;
  }
}

class RenderResizableSheetChildBox extends RenderShiftedBox {
  RenderResizableSheetChildBox({
    required ViewportOffset offset,
    required double minExtent,
    RenderBox? child,
    bool resizable = true,
  })  : _offset = offset,
        _minExtent = minExtent,
        _resizable = resizable,
        super(child);

  ViewportOffset get offset => _offset;
  ViewportOffset _offset;
  set offset(ViewportOffset value) {
    if (value == _offset) return;
    if (attached) _offset.removeListener(_hasScrolled);
    _offset = value;
    if (attached) _offset.addListener(_hasScrolled);
    if (!resizable) return;
    markNeedsLayout();
  }

  bool get resizable => _resizable;
  bool _resizable;
  set resizable(bool value) {
    if (value == _resizable) return;
    _resizable = value;
    markNeedsLayout();
  }

  double get minExtent => _minExtent;
  double _minExtent;
  set minExtent(double value) {
    if (value == _minExtent) return;
    _minExtent = value;
    if (!resizable) return;
    markNeedsLayout();
  }

  void _hasScrolled() {
    if (!resizable) return;
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _offset.addListener(_hasScrolled);
  }

  @override
  void detach() {
    _offset.removeListener(_hasScrolled);
    super.detach();
  }

  @override
  void performLayout() {
    final BoxParentData childParentData = child!.parentData! as BoxParentData;

    // If not resizable we send constraints to child and
    // parent size is the same as child
    if (!resizable) {
      child!.layout(
        constraints,
        parentUsesSize: true,
      );
      size = child!.size;
      childParentData.offset = Offset.zero;
      return;
    }

    // The height of the child will be the maximun between the offset pixels
    // and the minExtent
    final double extent = max(_offset.pixels, minExtent);

    child!.layout(
      BoxConstraints(
        maxHeight: extent,
        minHeight: extent,
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
      ),
      parentUsesSize: true,
    );

    if (!constraints.hasTightHeight) {
      size = Size(
          child!.size.width, constraints.constrainHeight(child!.size.height));
      childParentData.offset = Offset.zero;
    } else {
      size = constraints.biggest;
      childParentData.offset = Offset.zero;
    }
  }
}
