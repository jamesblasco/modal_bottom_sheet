import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

@immutable
class SliverContainer extends RenderObjectWidget {
  SliverContainer(
      {Key key,
      this.padding = EdgeInsets.zero,
      this.margin = EdgeInsets.zero,
      this.borderRadius,
      this.decoration,
      this.foregroundDecoration,
      this.sliver})
      : super(key: key);

  final EdgeInsets margin;

  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Decoration decoration;
  final Decoration foregroundDecoration;
  final Widget sliver;

  Widget get child => SliverPadding(padding: padding + margin, sliver: sliver);

  Container get backgroundDecorationBox => Container(decoration: decoration);

  Container get foregroundDecorationBox =>
      Container(decoration: foregroundDecoration);

  @override
  _RenderSliverGroup createRenderObject(BuildContext context) {
    return _RenderSliverGroup(
        margin: this.margin, borderRadius: this.borderRadius, padding: padding);
  }

  @override
  _SliverGroupElement createElement() => _SliverGroupElement(this);

  @override
  void updateRenderObject(
      BuildContext context, _RenderSliverGroup renderObject) {
    renderObject
      ..margin = margin
      ..padding = padding
      ..borderRadius = borderRadius;
  }
}

class _SliverGroupElement extends RenderObjectElement {
  _SliverGroupElement(SliverContainer widget) : super(widget);

  Element _backgroundDecoration;
  Element _foregroundDecoration;
  Element _sliver;

  @override
  SliverContainer get widget => super.widget;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_backgroundDecoration != null) visitor(_backgroundDecoration);
    if (_foregroundDecoration != null) visitor(_foregroundDecoration);
    if (_sliver != null) visitor(_sliver);
  }

  @override
  void forgetChild(Element child) {
    if (child == _backgroundDecoration) _backgroundDecoration = null;
    if (child == _foregroundDecoration) _foregroundDecoration = null;
    if (child == _sliver) _sliver = null;
    super.forgetChild(child);
  }

  @override
  void mount(Element parent, newSlot) {
    super.mount(parent, newSlot);
    _backgroundDecoration =
        updateChild(_backgroundDecoration, widget.backgroundDecorationBox, 0);
    _foregroundDecoration =
        updateChild(_foregroundDecoration, widget.foregroundDecorationBox, 1);
    _sliver = updateChild(_sliver, widget.child, 2);
  }

  @override
  void update(RenderObjectWidget newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _backgroundDecoration =
        updateChild(_backgroundDecoration, widget.backgroundDecorationBox, 0);
    _foregroundDecoration =
        updateChild(_foregroundDecoration, widget.foregroundDecorationBox, 1);
    _sliver = updateChild(_sliver, widget.child, 2);
  }

  @override
  void insertChildRenderObject(RenderObject child, int slot) {
    final _RenderSliverGroup renderObject = this.renderObject;
    if (slot == 0) renderObject.decoration = child;
    if (slot == 1) renderObject.foregroundDecoration = child;
    if (slot == 2) renderObject.child = child;
    assert(renderObject == this.renderObject);
  }

  @override
  void moveChildRenderObject(RenderObject child, slot) {
    assert(false);
  }

  @override
  void removeChildRenderObject(RenderObject child) {
    final _RenderSliverGroup renderObject = this.renderObject;
    if (renderObject.decoration == child) renderObject.decoration = null;
    if (renderObject.foregroundDecoration == child)
      renderObject.foregroundDecoration = null;
    if (renderObject.child == child) renderObject.child = null;
    assert(renderObject == this.renderObject);
  }
}

class _RenderSliverGroup extends RenderSliver with RenderSliverHelpers {
  _RenderSliverGroup(
      {EdgeInsetsGeometry margin,
      EdgeInsetsGeometry padding,
      BorderRadius borderRadius,
      RenderBox decoration,
      RenderBox foregroundDecoration,
      RenderSliver child}) {
    this.margin = margin;
    this.padding = padding;
    this.borderRadius = borderRadius;
    this.foregroundDecoration = foregroundDecoration;
    this.decoration = decoration;
    this.child = child;
  }

  RRect _clipRRect;

  EdgeInsetsGeometry get padding => _padding;
  EdgeInsetsGeometry _padding;

  set padding(EdgeInsetsGeometry value) {
    assert(value != null);
    assert(value.isNonNegative);
    if (_padding == value) return;
    _padding = value;
    markNeedsLayout();
  }

  EdgeInsetsGeometry get margin => _margin;
  EdgeInsetsGeometry _margin;

  set margin(EdgeInsetsGeometry value) {
    assert(value != null);
    assert(value.isNonNegative);
    if (_margin == value) return;
    _margin = value;
    markNeedsLayout();
  }

  BorderRadiusGeometry get borderRadius => _borderRadius;
  BorderRadiusGeometry _borderRadius;

  set borderRadius(BorderRadiusGeometry value) {
    if (value == _borderRadius) return;
    _borderRadius = value;
    markNeedsPaint();
  }

  RenderBox get decoration => _decoration;
  RenderBox _decoration;

  set decoration(RenderBox value) {
    if (_decoration != null) dropChild(_decoration);
    _decoration = value;
    if (_decoration != null) adoptChild(_decoration);
  }

  RenderBox get foregroundDecoration => _foregroundDecoration;
  RenderBox _foregroundDecoration;

  set foregroundDecoration(RenderBox value) {
    if (_foregroundDecoration != null) dropChild(_foregroundDecoration);
    _foregroundDecoration = value;
    if (_foregroundDecoration != null) adoptChild(_foregroundDecoration);
  }

  RenderSliver get child => _child;
  RenderSliver _child;

  set child(RenderSliver value) {
    if (_child != null) dropChild(_child);
    _child = value;
    if (_child != null) adoptChild(_child);
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData)
      child.parentData = new SliverPhysicalParentData();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (_decoration != null) _decoration.attach(owner);
    if (_child != null) _child.attach(owner);
    if (_foregroundDecoration != null) _foregroundDecoration.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    if (_decoration != null) _decoration.detach();
    if (_child != null) _child.detach();
    if (_foregroundDecoration != null) _foregroundDecoration.detach();
  }

  @override
  void redepthChildren() {
    if (_decoration != null) redepthChild(_decoration);
    if (_child != null) redepthChild(_child);
    if (_foregroundDecoration != null) redepthChild(_foregroundDecoration);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (_decoration != null) visitor(_decoration);
    if (_child != null) visitor(_child);
    if (_foregroundDecoration != null) visitor(_foregroundDecoration);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    List<DiagnosticsNode> result = <DiagnosticsNode>[];
    if (decoration != null) {
      result.add(decoration.toDiagnosticsNode(name: 'decoration'));
    }
    if (foregroundDecoration != null) {
      result.add(foregroundDecoration.toDiagnosticsNode(
          name: 'foreground_decoration'));
    }
    if (child != null) {
      result.add(child.toDiagnosticsNode(name: 'child'));
    }
    return result;
  }

  @override
  bool hitTestChildren(HitTestResult result,
      {double mainAxisPosition, double crossAxisPosition}) {
    assert(geometry.hitTestExtent > 0.0);
    return child.hitTest(result,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition);
  }

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry();
      return;
    }
    // child not null
    AxisDirection axisDirection = applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection);
    // layout sliver
    child.layout(constraints, parentUsesSize: true);
    final SliverGeometry childLayoutGeometry = child.geometry;
    geometry = childLayoutGeometry;

    // layout decoration with child size + margin
    //Todo: Support rtl
    EdgeInsets margin = this.margin.resolve(TextDirection.ltr);
    final maxExtent = childLayoutGeometry.maxPaintExtent - margin.horizontal;
    final crossAxisExtent = constraints.crossAxisExtent - margin.vertical;
    if (decoration != null) {
      decoration.layout(
          constraints.asBoxConstraints(
              maxExtent: maxExtent, crossAxisExtent: crossAxisExtent),
          parentUsesSize: true);
    }
    if (foregroundDecoration != null) {
      foregroundDecoration.layout(
          constraints.asBoxConstraints(
              maxExtent: maxExtent, crossAxisExtent: crossAxisExtent),
          parentUsesSize: true);
    }
    // compute decoration offset

    final SliverPhysicalParentData headerParentData = decoration.parentData;
    final SliverPhysicalParentData foregroundParentData =
        foregroundDecoration.parentData;
    double scrollOffset = -constraints.scrollOffset;
    Offset offset;
    switch (axisDirection) {
      case AxisDirection.up:
        offset = Offset(0.0, geometry.paintExtent);
        break;
      case AxisDirection.down:
        offset = Offset(0, scrollOffset);
        break;
      case AxisDirection.left:
        offset = Offset(geometry.paintExtent, 0.0);
        break;
      case AxisDirection.right:
        offset = Offset.zero;
        break;
    }
    offset += Offset(margin.left, margin.top);
    headerParentData.paintOffset = offset;
    foregroundParentData.paintOffset = offset;

    //compute child clip
    if (this.borderRadius != null) {
      BorderRadius borderRadius = this.borderRadius.resolve(TextDirection.ltr);
      _clipRRect = borderRadius.toRRect(Rect.fromLTRB(
          0, 0, constraints.crossAxisExtent, geometry.maxPaintExtent));
      double offSetY = scrollOffset;
      _clipRRect = _clipRRect.shift(Offset(0, offSetY));
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    assert(child != null);
    final SliverPhysicalParentData childParentData = child.parentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry.visible) {
      // paint decoration
      if (decoration != null) {
        final SliverPhysicalParentData childParentData = decoration.parentData;
        context.paintChild(decoration, offset + childParentData.paintOffset);
      }
      // paint child
      if (child != null && child.geometry.visible) {
        final SliverPhysicalParentData childParentData = child.parentData;
        final PaintingContextCallback painter =
            (PaintingContext context, Offset offset) {
          context.paintChild(child, offset);
        };
        if (_clipRRect != null && _clipRRect != RRect.zero) {
          context.pushClipRRect(
            needsCompositing,
            offset + childParentData.paintOffset,
            _clipRRect.outerRect,
            _clipRRect,
            painter,
          );
        } else {
          painter(context, offset + childParentData.paintOffset);
        }
      }
      if (foregroundDecoration != null) {
        final SliverPhysicalParentData childParentData =
            foregroundDecoration.parentData;
        context.paintChild(
            foregroundDecoration, offset + childParentData.paintOffset);
      }
    }
  }
}
