// ignore_for_file: always_put_control_body_on_new_line

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sheet/src/widgets/resizable_sheet.dart';
import 'package:sheet/src/widgets/scroll_to_top_status_handler.dart';

import '../sheet.dart';

/// How to size the content of a [Sheet].
///
/// This enum is used with [Sheet.fit] to control
/// how the [BoxConstraints] passed from the sheet to the sheet's child
/// are adjusted.
///
/// See also:
///
///  * [Sheet], the widget that uses this.
enum SheetFit {
  /// The constraints passed to the child from the sheet are loosened.
  ///
  /// For example, if the sheet has expand constraints with 600 high, this would allow the child of the sheet to have any
  /// height from zero to maximun available.
  loose,

  /// The constraints passed to the stack from its parent are tightened to the
  /// biggest size allowed.
  ///
  /// For example, if the sheet has loose constraints with a height in the
  /// range 0 to 600, then the child of the shhet would all be sized
  /// as 600 high.
  expand,
}

typedef SheetDecorationBuilder = Widget Function(
    BuildContext context, Widget child);

/// A material design bottom sheet.
///
/// There are two kinds of bottom sheets in material design:
///
///  * _Persistent_. A persistent bottom sheet shows information that
///    supplements the primary content of the app. A persistent bottom sheet
///    remains visible even when the user interacts with other parts of the app.
///    Persistent bottom sheets can be created and displayed with the
///    [Sheet] widget
///
///  * _Modal_. A modal bottom sheet is an alternative to a menu or a dialog and
///    prevents the user from interacting with the rest of the app. Modal bottom
///    sheets can be created and displayed with the [SheetRoute] route
///
/// The [Sheet] can be added inside a Stack above the content.
///
/// By default the bottom sheet inherits the values provided by the
/// material theme and prioritize the ones passed in the constructor.
/// Use [Sheet.raw] if you wish to remove the Material appareance and
/// build your own
///
/// See also:
///
///  * [SheetRoute], which can be used to display a modal bottom
///    sheet route.
///  * <https://material.io/design/components/sheets-bottom.html>
class Sheet extends StatelessWidget {
  /// Creates a material bottom sheet.
  const Sheet({
    super.key,
    required this.child,
    this.controller,
    this.physics,
    this.initialExtent,
    this.minExtent,
    this.maxExtent,
    this.minInteractionExtent = 20.0,
    this.backgroundColor,
    this.clipBehavior,
    this.shape,
    this.elevation,
    this.fit = SheetFit.loose,
    this.resizable = false,
    this.padding = EdgeInsets.zero,
    this.minResizableExtent,
  }) : decorationBuilder = null;

  /// Creates a bottom sheet with no default appearance.
  const Sheet.raw({
    super.key,
    required this.child,
    SheetDecorationBuilder? decorationBuilder,
    this.controller,
    this.physics,
    this.initialExtent,
    this.minExtent,
    this.maxExtent,
    this.minInteractionExtent = 20.0,
    this.fit = SheetFit.loose,
    this.resizable = false,
    this.padding = EdgeInsets.zero,
    this.minResizableExtent,
  })  : decorationBuilder = decorationBuilder ?? _emptyDecorationBuilder,
        shape = null,
        elevation = null,
        backgroundColor = null,
        clipBehavior = null;

  final Widget child;

  /// {@macro flutter.widgets.sheet.physics}
  final SheetPhysics? physics;

  /// {@macro flutter.widgets.sheet.controller}
  final SheetController? controller;

  /// Empty space to surround the [child].
  final EdgeInsets padding;

  /// The inital height to use when displaying the widget.
  ///
  /// This value will be clamped between [minExtent] and [maxExtent]
  ///
  /// The default value is `0`.
  final double? initialExtent;

  /// The minimum height to use when displaying the widget.
  ///
  /// The default value is `0`.
  final double? minExtent;

  /// The maximum height to use when displaying the widget.
  ///
  /// This value will be clamped to be as maximun the parent container's height
  ///
  /// The default value is `double.infinity`.
  final double? maxExtent;

  /// The height area of the minimun interaction zone to allow to
  /// drag up the sheet when it is closed
  ///
  /// The default value is `0`.
  final double minInteractionExtent;

  /// If true, the content of the sheet will be resized to fit the
  /// available visible space.
  /// If false, the content of the sheet will keep the same size and
  /// be translated vertically
  ///
  /// The default value is `false`.
  final bool resizable;

  /// If resizable true, the minimun height that the sheet can be.
  /// The content of the sheet will be resized to fit the
  /// available visible space until this value, after that will be
  /// translated keeping this minimun height.
  ///
  /// The default value is `0`.
  final double? minResizableExtent;

  /// How to size the child in the sheet.
  ///
  /// The constraints passed into the [Sheet] from its parent are either
  /// loosened ([SheetFit.loose]) or tightened to their biggest size
  /// ([SheetFit.expand]).
  final SheetFit fit;

  /// The state from the closest instance of this class that encloses the given context.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ScrollableState scrollable = Scrollable.of(context);
  /// ```
  ///
  /// Calling this method will create a dependency on the closest [SheetScrollable]
  /// in the [context], if there is one.
  static SheetState? of(BuildContext context) {
    return SheetScrollable.of(context);
  }

  /// The bottom sheet's background color.
  ///
  /// Defines the bottom sheet's [Material.color].
  ///
  /// Defaults to null and falls back to [Material]'s default.
  final Color? backgroundColor;

  /// The z-coordinate at which to place this material relative to its parent.
  ///
  /// This controls the size of the shadow below the material.
  ///
  /// Defaults to 0. The value is non-negative.
  final double? elevation;

  /// The shape of the bottom sheet.
  ///
  /// Defines the bottom sheet's [Material.shape].
  ///
  /// Defaults to null and falls back to [Material]'s default.
  final ShapeBorder? shape;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defines the bottom sheet's [Material.clipBehavior].
  ///
  /// Use this property to enable clipping of content when the bottom sheet has
  /// a custom [shape] and the content can extend past this shape. For example,
  /// a bottom sheet with rounded corners and an edge-to-edge [Image] at the
  /// top.
  ///
  /// If this property is null then [BottomSheetThemeData.clipBehavior] of
  /// [ThemeData.bottomSheetTheme] is used. If that's null then the behavior
  /// will be [Clip.none].
  final Clip? clipBehavior;

  /// Wraps the child in a custom sheet decoration appareance
  /// If null, the sheet has material appareance
  ///
  /// The default value is null.
  final SheetDecorationBuilder? decorationBuilder;

  static Widget _emptyDecorationBuilder(BuildContext context, Widget child) {
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final SheetDecorationBuilder decorationBuilder = this.decorationBuilder ??
        (BuildContext context, Widget child) {
          final BottomSheetThemeData bottomSheetTheme =
              Theme.of(context).bottomSheetTheme;
          final Color? color =
              backgroundColor ?? bottomSheetTheme.backgroundColor;
          final double elevation =
              this.elevation ?? bottomSheetTheme.elevation ?? 0;
          final ShapeBorder? shape = this.shape ?? bottomSheetTheme.shape;
          final Clip clipBehavior =
              this.clipBehavior ?? bottomSheetTheme.clipBehavior ?? Clip.none;

          return Material(
            color: color,
            elevation: elevation,
            shape: shape,
            clipBehavior: clipBehavior,
            child: child,
          );
        };
    final SheetController? effectiveController =
        controller ?? DefaultSheetController.of(context);
    final double? initialExtent =
        this.initialExtent?.clamp(minExtent ?? 0, maxExtent ?? double.infinity);
    return SheetScrollable(
      initialExtent: initialExtent,
      minInteractionExtent: minInteractionExtent,
      physics: physics,
      controller: effectiveController,
      axisDirection: AxisDirection.down,
      scrollBehavior: SheetBehaviour(),
      viewportBuilder: (BuildContext context, ViewportOffset offset) {
        return _DefaultSheetScrollController(
          child: ScrollToTopStatusBarHandler(
            child: SheetViewport(
              clipBehavior: Clip.antiAlias,
              axisDirection: AxisDirection.down,
              offset: offset,
              minExtent: minExtent,
              maxExtent: maxExtent,
              fit: fit,
              child: Padding(
                padding: padding,
                child: ResizableSheetChild(
                  resizable: resizable,
                  offset: offset,
                  minExtent: minResizableExtent ?? 0,
                  child: Builder(
                    key: const Key('_sheet_child'),
                    builder: (BuildContext context) {
                      return decorationBuilder(
                        context,
                        child,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DefaultSheetScrollController extends StatelessWidget {
  const _DefaultSheetScrollController({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: SheetScrollable.of(context)!.position.scrollController,
      child: child,
    );
  }
}

/// A [ScrollController] suitable for use in a [SheetPosition] created
/// by a [Sheet].
///
/// If a [Sheet] contains content that is exceeds the height
/// of its container, this controller will allow the sheet to both be dragged to
/// fill the container and then scroll the child content.
///
/// See also:
///
///  * [SheetPosition], which manages the positioning logic for
///    this controller.
class SheetController extends ScrollController {
  SheetController({
    String? debugLabel,
  }) : super(
          debugLabel: debugLabel,
          initialScrollOffset: 0,
        );

  final ProxyAnimation _animation = ProxyAnimation();
  Animation<double> get animation => _animation;

  void updateAnimation() {
    if (hasClients) {
      final ScrollPosition position = positions.first;
      if (position is SheetPosition) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _animation.parent = position.animation;
        });

        return;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animation.parent = kAlwaysDismissedAnimation;
    });
    return;
  }

  @override
  SheetPosition get position {
    return super.position as SheetPosition;
  }

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    updateAnimation();
  }

  @override
  void detach(ScrollPosition position) {
    super.detach(position);
    updateAnimation();
  }

  @override
  SheetPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    final double? initialPixels =
        (context is SheetContext) ? context.initialExtent : null;
    return SheetPosition(
      physics: physics,
      context: context as SheetContext,
      oldPosition: oldPosition,
      initialPixels: initialPixels ?? 0.0,
    );
  }

  Future<void> relativeAnimateTo(double offset,
      {required Duration duration, required Curve curve}) async {
    assert(positions.isNotEmpty,
        'ScrollController not attached to any scroll views.');
    await Future.wait<void>(<Future<void>>[
      for (final ScrollPosition position in positions)
        (position as SheetPosition)
            .relativeAnimateTo(offset, duration: duration, curve: curve),
    ]);
  }

  void relativeJumpTo(double offset) {
    assert(positions.isNotEmpty,
        'ScrollController not attached to any scroll views.');
    for (final ScrollPosition position in positions) {
      (position as SheetPosition).relativeJumpTo(offset);
    }
  }
}

/// A scroll position that manages scroll activities for
/// [_SheetScrollController].
///
/// This class is a concrete subclass of [ScrollPosition] logic that handles a
/// single [ScrollContext], such as a [Scrollable]. An instance of this class
/// manages [ScrollActivity] instances, which changes the
/// [SheetPosition.currentExtent] or visible content offset in the
/// [Scrollable]'s [Viewport]
///
/// See also:
///
///  * [_SheetScrollController], which uses this as its [ScrollPosition].
class SheetPosition extends ScrollPositionWithSingleContext {
  SheetPosition({
    required ScrollPhysics physics,
    required SheetContext context,
    double initialPixels = 0.0,
    bool keepScrollOffset = true,
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

  late final SheetPrimaryScrollController _scrollController =
      SheetPrimaryScrollController(sheetContext: context as SheetContext);

  SheetPrimaryScrollController get scrollController => _scrollController;

  Future<void> relativeAnimateTo(double to,
      {required Duration duration, required Curve curve}) {
    assert(to >= 0 && to <= 1);
    return super.animateTo(
      pixelsFromRelativeOffset(to, minScrollExtent, maxScrollExtent),
      duration: duration,
      curve: curve,
    );
  }

  @override
  Future<void> animateTo(double to,
      {required Duration duration, required Curve curve}) {
    return super.animateTo(to.clamp(minScrollExtent, maxScrollExtent),
        duration: duration, curve: curve);
  }

  void relativeJumpTo(double to) {
    assert(to >= 0 && to <= 1);
    final value =
        pixelsFromRelativeOffset(to, minScrollExtent, maxScrollExtent);
    return super.jumpTo(value);
  }

  @override
  void jumpTo(double value) {
    final double pixels = value.clamp(minScrollExtent, maxScrollExtent);
    return super.jumpTo(pixels);
  }

  bool _preventingDrag = false;
  bool get preventingDrag => _preventingDrag;
  void preventDrag() {
    _preventingDrag = true;
  }

  void stopPreventingDrag() {
    _preventingDrag = false;
  }

  late final AnimationController _controller =
      AnimationController(vsync: context.vsync);

  Animation<double> get animation => _controller;

  @override
  double setPixels(double newPixels) {
    _controller.value = relativeOffsetFromPixels(
      newPixels,
      minScrollExtent,
      maxScrollExtent,
    );
    return super.setPixels(newPixels);
  }

  @override
  void forcePixels(double value) {
    _controller.value = relativeOffsetFromPixels(
      value,
      minScrollExtent,
      maxScrollExtent,
    );
    super.forcePixels(value);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    // Clamp initial extent to maxScrollExtent
    if (!hasContentDimensions) {
      correctPixels(pixels.clamp(minScrollExtent, maxScrollExtent));
      _controller.value = relativeOffsetFromPixels(
        pixels,
        minScrollExtent,
        maxScrollExtent,
      );
    }
    return super.applyContentDimensions(minScrollExtent, maxScrollExtent);
  }

  static double relativeOffsetFromPixels(
    double pixels,
    double minScrollExtent,
    double maxScrollExtent,
  ) {
    if (minScrollExtent == maxScrollExtent) return 1;
    final value =
        ((pixels - minScrollExtent) / (maxScrollExtent - minScrollExtent))
            .clamp(0.0, 1.0);
    return value;
  }

  static double pixelsFromRelativeOffset(
    double offset,
    double minScrollExtent,
    double maxScrollExtent,
  ) {
    return minScrollExtent + offset * (maxScrollExtent - minScrollExtent);
  }
}

class SheetViewport extends SingleChildRenderObjectWidget {
  const SheetViewport({
    Key? key,
    this.axisDirection = AxisDirection.down,
    required this.offset,
    this.minExtent,
    this.maxExtent,
    Widget? child,
    required this.fit,
    required this.clipBehavior,
  }) : super(key: key, child: child);

  final AxisDirection axisDirection;
  final ViewportOffset offset;
  final Clip clipBehavior;
  final double? minExtent;
  final double? maxExtent;
  final SheetFit fit;

  @override
  RenderSheetViewport createRenderObject(BuildContext context) {
    return RenderSheetViewport(
      axisDirection: axisDirection,
      offset: offset,
      clipBehavior: clipBehavior,
      minExtent: minExtent,
      maxExtent: maxExtent,
      fit: fit,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSheetViewport renderObject) {
    // Order dependency: The offset setter reads the axis direction.
    renderObject
      ..axisDirection = axisDirection
      ..offset = offset
      ..clipBehavior = clipBehavior
      ..minExtent = minExtent
      ..maxExtent = maxExtent
      ..fit = fit;
  }
}

class RenderSheetViewport extends RenderBox
    with RenderObjectWithChildMixin<RenderBox>
    implements RenderAbstractViewport {
  RenderSheetViewport({
    AxisDirection axisDirection = AxisDirection.down,
    required ViewportOffset offset,
    double cacheExtent = RenderAbstractViewport.defaultCacheExtent,
    RenderBox? child,
    required Clip clipBehavior,
    SheetFit fit = SheetFit.expand,
    double? minExtent,
    double? maxExtent,
  })  : _axisDirection = axisDirection,
        _offset = offset,
        _fit = fit,
        _minExtent = minExtent,
        _maxExtent = maxExtent,
        _cacheExtent = cacheExtent,
        _clipBehavior = clipBehavior {
    this.child = child;
  }

  AxisDirection get axisDirection => _axisDirection;
  AxisDirection _axisDirection;
  set axisDirection(AxisDirection value) {
    if (value == _axisDirection) return;
    _axisDirection = value;
    markNeedsLayout();
  }

  Axis get axis => axisDirectionToAxis(axisDirection);

  ViewportOffset get offset => _offset;
  ViewportOffset _offset;
  set offset(ViewportOffset value) {
    if (value == _offset) return;
    if (attached) _offset.removeListener(_hasDragged);
    _offset = value;
    if (attached) _offset.addListener(_hasDragged);
    markNeedsLayout();
  }

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  double get cacheExtent => _cacheExtent;
  double _cacheExtent;
  set cacheExtent(double value) {
    if (value == _cacheExtent) return;
    _cacheExtent = value;
    markNeedsLayout();
  }

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  SheetFit get fit => _fit;
  SheetFit _fit;
  set fit(SheetFit value) {
    if (value == _fit) return;
    _fit = value;
    markNeedsLayout();
  }

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.none], and must not be null.
  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior = Clip.none;
  set clipBehavior(Clip value) {
    if (value != _clipBehavior) {
      _clipBehavior = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  void _hasDragged() {
    if (!_isOverflow && offset.pixels > child!.size.height) {
      _childExtentBeforeOverflow ??= child!.size.height;
      _isOverflow = true;
      markNeedsLayout();
    } else if (isOverflow && offset.pixels < _childExtentBeforeOverflow!) {
      _childExtentBeforeOverflow = null;
      _isOverflow = false;
      markNeedsLayout();
    }
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void setupParentData(RenderObject child) {
    // We don't actually use the offset argument in BoxParentData, so let's
    // avoid allocating it at all.
    if (child.parentData is! ParentData) child.parentData = ParentData();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _offset.addListener(_hasDragged);
  }

  @override
  void detach() {
    _offset.removeListener(_hasDragged);
    super.detach();
  }

  @override
  bool get isRepaintBoundary => true;

  double? get minExtent => _minExtent;
  double? _minExtent;
  set minExtent(double? value) {
    if (value != _minExtent) {
      _minExtent = value;
      markNeedsLayout();
    }
  }

  double? get maxExtent => _maxExtent;
  double? _maxExtent;
  set maxExtent(double? value) {
    if (value != _maxExtent) {
      _maxExtent = value;
      markNeedsLayout();
    }
  }

  double get _viewportExtent {
    assert(hasSize);
    switch (axis) {
      case Axis.horizontal:
        return size.width;
      case Axis.vertical:
        return size.height;
    }
  }

  double get _minScrollExtent {
    assert(hasSize);
    return minExtent ?? 0.0;
  }

  double get _maxScrollExtent {
    assert(hasSize);
    if (_childExtentBeforeOverflow != null) return _childExtentBeforeOverflow!;
    if (child == null) return 0.0;
    switch (axis) {
      case Axis.horizontal:
        return math.max(0.0, child!.size.width - size.width);
      case Axis.vertical:
        return math.max(0.0, child!.size.height);
    }
  }

  double? _childExtentBeforeOverflow;
  bool _isOverflow = false;
  bool get isOverflow => _isOverflow;

  //BoxConstraints _getInnerConstraints(BoxConstraints constraints) {
  //  switch (axis) {
  //    case Axis.horizontal:
  //      return constraints.heightConstraints();
  //    case Axis.vertical:
  //      return constraints.widthConstraints();
  //  }
  //}

  @override
  double computeMinIntrinsicWidth(double height) {
    return constraints.maxHeight;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return constraints.maxWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return constraints.maxHeight;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return constraints.maxHeight;
  }

  // We don't override computeDistanceToActualBaseline(), because we
  // want the default behavior (returning null). Otherwise, as you
  // scroll, it would shift in its parent if the parent was baseline-aligned,
  // which makes no sense.

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (child == null) {
      return constraints.smallest;
    }
    return constraints.biggest;
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    if (child == null) {
      size = constraints.smallest;
    } else {
      final bool expand = fit == SheetFit.expand;
      final double maxExtent = this.maxExtent ?? constraints.maxHeight;
      double maxHeight = maxExtent.clamp(0, constraints.maxHeight);
      double minHeight = expand ? maxHeight : 0;

      if (isOverflow) {
        final double overflowHeight =
            _childExtentBeforeOverflow! + offset.pixels;
        maxHeight = overflowHeight;
        minHeight = overflowHeight;
      }

      final BoxConstraints childContstraints = BoxConstraints(
        minHeight: minHeight,
        maxHeight: maxHeight,
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
      );
      child!.layout(childContstraints, parentUsesSize: true);
      size = constraints.biggest;
    }

    offset.applyViewportDimension(_viewportExtent);
    offset.applyContentDimensions(_minScrollExtent, _maxScrollExtent);
  }

  Offset get _paintOffset => _paintOffsetForPosition(offset.pixels);

  Offset _paintOffsetForPosition(double position) {
    switch (axisDirection) {
      case AxisDirection.up:
        return Offset(0.0, position - child!.size.height + size.height);
      case AxisDirection.down:
        return Offset(0.0, -position + size.height);
      case AxisDirection.left:
        return Offset(position - child!.size.width + size.width, 0.0);
      case AxisDirection.right:
        return Offset(-position, 0.0);
    }
  }

  bool _shouldClipAtPaintOffset(Offset paintOffset) {
    assert(child != null);
    return paintOffset.dx < 0 ||
        paintOffset.dy < 0 ||
        paintOffset.dx + child!.size.width > size.width ||
        paintOffset.dy + child!.size.height > size.height;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final Offset paintOffset = _paintOffset;

      void paintContents(PaintingContext context, Offset offset) {
        context.paintChild(child!, offset + paintOffset);
      }

      if (_shouldClipAtPaintOffset(paintOffset) && clipBehavior != Clip.none) {
        _clipRectLayer.layer = context.pushClipRect(
          needsCompositing,
          offset,
          Offset.zero & size,
          paintContents,
          clipBehavior: clipBehavior,
          oldLayer: _clipRectLayer.layer,
        );
      } else {
        _clipRectLayer.layer = null;
        paintContents(context, offset);
      }
    }
  }

  final LayerHandle<ClipRectLayer> _clipRectLayer =
      LayerHandle<ClipRectLayer>();

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    super.dispose();
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final Offset paintOffset = _paintOffset;
    transform.translate(paintOffset.dx, paintOffset.dy);
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject? child) {
    if (child != null && _shouldClipAtPaintOffset(_paintOffset)) {
      return Offset.zero & size;
    }
    return null;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child != null) {
      return result.addWithPaintOffset(
        offset: _paintOffset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset? transformed) {
          assert(transformed == position + -_paintOffset);
          return child!.hitTest(result, position: transformed!);
        },
      );
    }
    return false;
  }

  @override
  RevealedOffset getOffsetToReveal(RenderObject target, double alignment,
      {Rect? rect}) {
    rect ??= target.paintBounds;
    if (target is! RenderBox) {
      return RevealedOffset(offset: offset.pixels, rect: rect);
    }

    final RenderBox targetBox = target;
    final Matrix4 transform = targetBox.getTransformTo(child);
    final Rect bounds = MatrixUtils.transformRect(transform, rect);
    final Size contentSize = child!.size;

    final double leadingScrollOffset;
    final double targetMainAxisExtent;
    final double mainAxisExtent;

    switch (axisDirection) {
      case AxisDirection.up:
        mainAxisExtent = size.height;
        leadingScrollOffset = contentSize.height - bounds.bottom;
        targetMainAxisExtent = bounds.height;
        break;
      case AxisDirection.right:
        mainAxisExtent = size.width;
        leadingScrollOffset = bounds.left;
        targetMainAxisExtent = bounds.width;
        break;
      case AxisDirection.down:
        mainAxisExtent = size.height;
        leadingScrollOffset = bounds.top;
        targetMainAxisExtent = bounds.height;
        break;
      case AxisDirection.left:
        mainAxisExtent = size.width;
        leadingScrollOffset = contentSize.width - bounds.right;
        targetMainAxisExtent = bounds.width;
        break;
    }

    final double targetOffset = leadingScrollOffset -
        (mainAxisExtent - targetMainAxisExtent) * alignment;
    final Rect targetRect = bounds.shift(_paintOffsetForPosition(targetOffset));
    return RevealedOffset(offset: targetOffset, rect: targetRect);
  }

  @override
  void showOnScreen({
    RenderObject? descendant,
    Rect? rect,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
  }) {
    return;
    // TODO(jaime): check showOnScreen method beheves when keyboard appears on
    // the screen
    // if (!offset.allowImplicitScrolling) {
    //   return super.showOnScreen(
    //     descendant: descendant,
    //     rect: rect,
    //     duration: duration,
    //     curve: curve,
    //   );
    // }
    //
    // final Rect? newRect = RenderViewportBase.showInViewport(
    //   descendant: descendant,
    //   viewport: this,
    //   offset: offset,
    //   rect: rect,
    //   duration: duration,
    //   curve: curve,
    // );
    // super.showOnScreen(
    //   rect: newRect,
    //   duration: duration,
    //   curve: curve,
    // );
  }

  @override
  Rect describeSemanticsClip(RenderObject child) {
    switch (axis) {
      case Axis.vertical:
        return Rect.fromLTRB(
          semanticBounds.left,
          semanticBounds.top - cacheExtent,
          semanticBounds.right,
          semanticBounds.bottom + cacheExtent,
        );
      case Axis.horizontal:
        return Rect.fromLTRB(
          semanticBounds.left - cacheExtent,
          semanticBounds.top,
          semanticBounds.right + cacheExtent,
          semanticBounds.bottom,
        );
    }
  }
}
