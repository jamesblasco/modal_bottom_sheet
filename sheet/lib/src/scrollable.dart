// This file is the same as https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/widgets/scrollable.dart
// Canges done:
//  - Rename file from Scrollable to SheetDraggable
//  - Extend ScrollContext as SheetContext to add initialExtent
//  - Change RawGestureDetector behavior to HitTestBehavior.deferToChild
//      so it can be hit behind the sheet
//  - Change Add MinInteractionZone

// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: always_put_control_body_on_new_line

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sheet/sheet.dart';
import 'package:sheet/src/widgets/min_interaction.dart';

abstract class SheetContext extends ScrollContext {
  double? get initialExtent;
  SheetPosition get position;
}

/// A widget that transform to user drag.
///
/// [SheetScrollable] implements the interaction model for a draggable widget,
/// including gesture recognition, but does not have an opinion about how the
/// viewport, which actually displays the children, is constructed.
///
/// It's rare to construct a [SheetScrollable] directly. Instead, consider [Sheet],
/// which combine dragging, viewporting, and a layout model.
///
/// The static [SheetScrollable.of] and [SheetScrollable.ensureVisible] functions are
/// often used to interact with the [SheetScrollable] widget inside a [Sheet]
class SheetScrollable extends StatefulWidget {
  /// Creates a widget that scrolls.
  ///
  /// The [axisDirection] and [viewportBuilder] arguments must not be null.
  const SheetScrollable({
    Key? key,
    this.axisDirection = AxisDirection.down,
    this.controller,
    this.physics,
    required this.viewportBuilder,
    this.excludeFromSemantics = false,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.restorationId,
    this.scrollBehavior,
    this.initialExtent,
    this.minInteractionExtent = 0,
  })  : assert(semanticChildCount == null || semanticChildCount >= 0),
        super(key: key);

  /// The direction in which this widget scrolls.
  ///
  /// For example, if the [axisDirection] is [AxisDirection.down], increasing
  /// the scroll position will cause content below the bottom of the viewport to
  /// become visible through the viewport. Similarly, if [axisDirection] is
  /// [AxisDirection.right], increasing the scroll position will cause content
  /// beyond the right edge of the viewport to become visible through the
  /// viewport.
  ///
  /// Defaults to [AxisDirection.down].
  final AxisDirection axisDirection;

  /// An object that can be used to control the position to which this widget is
  /// scrolled.
  ///
  /// A [ScrollController] serves several purposes. It can be used to control
  /// the initial scroll position (see [ScrollController.initialScrollOffset]).
  /// It can be used to control whether the scroll view should automatically
  /// save and restore its scroll position in the [PageStorage] (see
  /// [ScrollController.keepScrollOffset]). It can be used to read the current
  /// scroll position (see [ScrollController.offset]), or change it (see
  /// [ScrollController.relativeAnimateTo]).
  ///
  /// See also:
  ///
  ///  * [ensureVisible], which animates the scroll position to reveal a given
  ///    [BuildContext].
  final SheetController? controller;

  /// How the widgets should respond to user input.
  ///
  /// For example, determines how the widget continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions via the physics provided from
  /// the ambient [ScrollConfiguration].
  ///
  /// If an explicit [ScrollBehavior] is provided to [scrollBehavior], the
  /// [ScrollPhysics] provided by that behavior will take precedence after
  /// [physics].
  ///
  /// The physics can be changed dynamically, but new physics will only take
  /// effect if the _class_ of the provided object changes. Merely constructing
  /// a new instance with a different configuration is insufficient to cause the
  /// physics to be reapplied. (This is because the final object used is
  /// generated dynamically, which can be relatively expensive, and it would be
  /// inefficient to speculatively create this object each frame to see if the
  /// physics should be updated.)
  ///
  /// See also:
  ///
  ///  * [AlwaysScrollableScrollPhysics], which can be used to indicate that the
  ///    scrollable should react to scroll requests (and possible overscroll)
  ///    even if the scrollable's contents fit without scrolling being necessary.
  final ScrollPhysics? physics;

  /// Builds the viewport through which the scrollable content is displayed.
  ///
  /// A typical viewport uses the given [ViewportOffset] to determine which part
  /// of its content is actually visible through the viewport.
  ///
  /// See also:
  ///
  ///  * [Viewport], which is a viewport that displays a list of slivers.
  ///  * [ShrinkWrappingViewport], which is a viewport that displays a list of
  ///    slivers and sizes itself based on the size of the slivers.
  final ViewportBuilder viewportBuilder;

  /// Whether the scroll actions introduced by this [SheetScrollable] are exposed
  /// in the semantics tree.
  ///
  /// Text fields with an overflow are usually scrollable to make sure that the
  /// user can get to the beginning/end of the entered text. However, these
  /// scrolling actions are generally not exposed to the semantics layer.
  ///
  /// See also:
  ///
  ///  * [GestureDetector.excludeFromSemantics], which is used to accomplish the
  ///    exclusion.
  final bool excludeFromSemantics;

  /// The number of children that will contribute semantic information.
  ///
  /// The value will be null if the number of children is unknown or unbounded.
  ///
  /// Some subtypes of [ScrollView] can infer this value automatically. For
  /// example [ListView] will use the number of widgets in the child list,
  /// while the [ListView.separated] constructor will use half that amount.
  ///
  /// For [CustomScrollView] and other types which do not receive a builder
  /// or list of widgets, the child count must be explicitly provided.
  ///
  /// See also:
  ///
  ///  * [CustomScrollView], for an explanation of scroll semantics.
  ///  * [SemanticsConfiguration.scrollChildCount], the corresponding semantics property.
  final int? semanticChildCount;

  // TODO(jslavitz): Set the DragStartBehavior default to be start across all widgets.
  /// {@template flutter.widgets.scrollable.dragStartBehavior}
  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], scrolling drag behavior will
  /// begin upon the detection of a drag gesture. If set to
  /// [DragStartBehavior.down] it will begin when a down event is first detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///  * [DragGestureRecognizer.dragStartBehavior], which gives an example for
  ///    the different behaviors.
  ///
  /// {@endtemplate}
  final DragStartBehavior dragStartBehavior;

  /// {@template flutter.widgets.scrollable.restorationId}
  /// Restoration ID to save and restore the scroll offset of the scrollable.
  ///
  /// If a restoration id is provided, the scrollable will persist its current
  /// scroll offset and restore it during state restoration.
  ///
  /// The scroll offset is persisted in a [RestorationBucket] claimed from
  /// the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  /// {@endtemplate}
  final String? restorationId;

  /// {@macro flutter.widgets.shadow.scrollBehavior}
  ///
  /// [SheetBehaviour]s also provide [SheetPhysics]. If an explicit
  /// [ScrollPhysics] is provided in [physics], it will take precedence,
  /// followed by [scrollBehavior], and then the inherited ancestor
  /// [SheetBehaviour].
  final SheetBehaviour? scrollBehavior;

  final double? initialExtent;

  final double minInteractionExtent;

  /// The axis along which the scroll view scrolls.
  ///
  /// Determined by the [axisDirection].
  Axis get axis => axisDirectionToAxis(axisDirection);

  @override
  SheetState createState() => SheetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<AxisDirection>('axisDirection', axisDirection));
    properties.add(DiagnosticsProperty<ScrollPhysics>('physics', physics));
    properties.add(StringProperty('restorationId', restorationId));
  }

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
    final _ScrollableScope? widget =
        context.dependOnInheritedWidgetOfExactType<_ScrollableScope>();
    return widget?.scrollable;
  }

  /// Scrolls the scrollables that enclose the given context so as to make the
  /// given context visible.
  static Future<void> ensureVisible(
    BuildContext context, {
    double alignment = 0.0,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
    ScrollPositionAlignmentPolicy alignmentPolicy =
        ScrollPositionAlignmentPolicy.explicit,
  }) {
    final List<Future<void>> futures = <Future<void>>[];

    // The `targetRenderObject` is used to record the first target renderObject.
    // If there are multiple scrollable widgets nested, we should let
    // the `targetRenderObject` as visible as possible to improve the user experience.
    // Otherwise, let the outer renderObject as visible as possible maybe cause
    // the `targetRenderObject` invisible.
    // Also see https://github.com/flutter/flutter/issues/65100
    RenderObject? targetRenderObject;
    SheetState? scrollable = SheetScrollable.of(context);
    while (scrollable != null) {
      futures.add(scrollable.position.ensureVisible(
        context.findRenderObject()!,
        alignment: alignment,
        duration: duration,
        curve: curve,
        alignmentPolicy: alignmentPolicy,
        targetRenderObject: targetRenderObject,
      ));

      targetRenderObject = targetRenderObject ?? context.findRenderObject();
      context = scrollable.context;
      scrollable = SheetScrollable.of(context);
    }

    if (futures.isEmpty || duration == Duration.zero) {
      return Future<void>.value();
    }
    if (futures.length == 1) return futures.single;
    return Future.wait<void>(futures).then<void>((List<void> _) => null);
  }
}

// Enable Scrollable.of() to work as if ScrollableState was an inherited widget.
// ScrollableState.build() always rebuilds its _ScrollableScope.
class _ScrollableScope extends InheritedWidget {
  const _ScrollableScope({
    Key? key,
    required this.scrollable,
    required this.position,
    required Widget child,
  }) : super(key: key, child: child);

  final SheetState scrollable;
  final ScrollPosition position;

  @override
  bool updateShouldNotify(_ScrollableScope old) {
    return position != old.position;
  }
}

/// State object for a [SheetScrollable] widget.
///
/// To manipulate a [SheetScrollable] widget's scroll position, use the object
/// obtained from the [position] property.
///
/// To be informed of when a [SheetScrollable] widget is scrolling, use a
/// [NotificationListener] to listen for [ScrollNotification] notifications.
///
/// This class is not intended to be subclassed. To specialize the behavior of a
/// [SheetScrollable], provide it with a [ScrollPhysics].
class SheetState extends State<SheetScrollable>
    with TickerProviderStateMixin, RestorationMixin
    implements SheetContext {
  /// The manager for this [SheetScrollable] widget's viewport position.
  ///
  /// To control what kind of [ScrollPosition] is created for a [SheetScrollable],
  /// provide it with custom [ScrollController] that creates the appropriate
  /// [ScrollPosition] in its [ScrollController.createScrollPosition] method.
  @override
  SheetPosition get position => _position!;
  SheetPosition? _position;

  final _RestorableScrollOffset _persistedScrollOffset =
      _RestorableScrollOffset();

  @override
  AxisDirection get axisDirection => widget.axisDirection;

  late SheetBehaviour _configuration;
  ScrollPhysics? _physics;
  SheetController? _fallbackScrollController;

  SheetController get controller => _effectiveScrollController;

  SheetController get _effectiveScrollController =>
      widget.controller ?? _fallbackScrollController!;

  // Only call this from places that will definitely trigger a rebuild.
  void _updatePosition() {
    _configuration = widget.scrollBehavior ?? SheetBehaviour();
    _physics = _configuration.getScrollPhysics(context);
    if (widget.physics != null) {
      _physics = widget.physics!.applyTo(_physics);
    } else if (widget.scrollBehavior != null) {
      _physics =
          widget.scrollBehavior!.getScrollPhysics(context).applyTo(_physics);
    }
    final ScrollPosition? oldPosition = _position;
    if (oldPosition != null) {
      _effectiveScrollController.detach(oldPosition);
      // It's important that we not dispose the old position until after the
      // viewport has had a chance to unregister its listeners from the old
      // position. So, schedule a microtask to do it.
      scheduleMicrotask(oldPosition.dispose);
    }

    _position = _effectiveScrollController.createScrollPosition(
        _physics!, this, oldPosition);
    assert(_position != null);

    _effectiveScrollController.attach(position);
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_persistedScrollOffset, 'offset');
    assert(_position != null);
    if (_persistedScrollOffset.value != null) {
      position.restoreOffset(_persistedScrollOffset.value!,
          initialRestore: initialRestore);
    }
  }

  @override
  void saveOffset(double offset) {
    assert(debugIsSerializableForRestoration(offset));
    _persistedScrollOffset.value = offset;
    // [saveOffset] is called after a scrolling ends and it is usually not
    // followed by a frame. Therefore, manually flush restoration data.
    ServicesBinding.instance.restorationManager.flushData();
  }

  @override
  void initState() {
    if (widget.controller == null) {
      _fallbackScrollController = SheetController();
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _updatePosition();
    super.didChangeDependencies();
  }

  bool _shouldSheetPhysicsUpdate(
      ScrollPhysics? newPhysics, ScrollPhysics? oldPhysics) {
    if (newPhysics is! SheetPhysics || oldPhysics is! SheetPhysics) {
      return false;
    }
    return newPhysics.shouldReload(oldPhysics);
  }

  bool _shouldUpdatePosition(SheetScrollable oldWidget) {
    ScrollPhysics? newPhysics =
        widget.physics ?? widget.scrollBehavior?.getScrollPhysics(context);
    ScrollPhysics? oldPhysics = oldWidget.physics ??
        oldWidget.scrollBehavior?.getScrollPhysics(context);
    do {
      if (newPhysics?.runtimeType != oldPhysics?.runtimeType ||
          _shouldSheetPhysicsUpdate(newPhysics, oldPhysics)) return true;
      newPhysics = newPhysics?.parent;
      oldPhysics = oldPhysics?.parent;
    } while (newPhysics != null || oldPhysics != null);

    return widget.controller?.runtimeType != oldWidget.controller?.runtimeType;
  }

  @override
  void didUpdateWidget(SheetScrollable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        // The old controller was null, meaning the fallback cannot be null.
        // Dispose of the fallback.
        assert(_fallbackScrollController != null);
        assert(widget.controller != null);
        _fallbackScrollController!.detach(position);
        _fallbackScrollController!.dispose();
        _fallbackScrollController = null;
      } else {
        // The old controller was not null, detach.
        oldWidget.controller?.detach(position);
        if (widget.controller == null) {
          // If the new controller is null, we need to set up the fallback
          // ScrollController.
          _fallbackScrollController = SheetController();
        }
      }
      // Attach the updated effective scroll controller.
      _effectiveScrollController.attach(position);
    }

    if (_shouldUpdatePosition(oldWidget)) _updatePosition();
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!.detach(position);
    } else {
      _fallbackScrollController?.detach(position);
      _fallbackScrollController?.dispose();
    }

    position.dispose();
    _persistedScrollOffset.dispose();
    super.dispose();
  }

  // SEMANTICS

  final GlobalKey _scrollSemanticsKey = GlobalKey();

  @override
  @protected
  void setSemanticsActions(Set<SemanticsAction> actions) {
    if (_gestureDetectorKey.currentState != null) {
      _gestureDetectorKey.currentState!.replaceSemanticsActions(actions);
    }
  }

  // GESTURE RECOGNITION AND POINTER IGNORING

  final GlobalKey<RawGestureDetectorState> _gestureDetectorKey =
      GlobalKey<RawGestureDetectorState>();
  final GlobalKey _ignorePointerKey = GlobalKey();

  // This field is set during layout, and then reused until the next time it is set.
  Map<Type, GestureRecognizerFactory> _gestureRecognizers =
      const <Type, GestureRecognizerFactory>{};
  bool _shouldIgnorePointer = false;

  bool? _lastCanDrag;
  Axis? _lastAxisDirection;

  @override
  @protected
  void setCanDrag(bool canDrag) {
    if (canDrag == _lastCanDrag &&
        (!canDrag || widget.axis == _lastAxisDirection)) return;
    if (!canDrag) {
      _gestureRecognizers = const <Type, GestureRecognizerFactory>{};
      // Cancel the active hold/drag (if any) because the gesture recognizers
      // will soon be disposed by our RawGestureDetector, and we won't be
      // receiving pointer up events to cancel the hold/drag.
      _handleDragCancel();
    } else {
      switch (widget.axis) {
        case Axis.vertical:
          _gestureRecognizers = <Type, GestureRecognizerFactory>{
            VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(),
              (VerticalDragGestureRecognizer instance) {
                instance
                  ..onDown = _handleDragDown
                  ..onStart = _handleDragStart
                  ..onUpdate = _handleDragUpdate
                  ..onEnd = _handleDragEnd
                  ..onCancel = _handleDragCancel
                  ..minFlingDistance = _physics?.minFlingDistance
                  ..minFlingVelocity = _physics?.minFlingVelocity
                  ..maxFlingVelocity = _physics?.maxFlingVelocity
                  ..velocityTrackerBuilder =
                      _configuration.velocityTrackerBuilder(context)
                  ..dragStartBehavior = widget.dragStartBehavior;
              },
            ),
          };
          break;
        case Axis.horizontal:
          _gestureRecognizers = <Type, GestureRecognizerFactory>{
            HorizontalDragGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<
                    HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer(),
              (HorizontalDragGestureRecognizer instance) {
                instance
                  ..onDown = _handleDragDown
                  ..onStart = _handleDragStart
                  ..onUpdate = _handleDragUpdate
                  ..onEnd = _handleDragEnd
                  ..onCancel = _handleDragCancel
                  ..minFlingDistance = _physics?.minFlingDistance
                  ..minFlingVelocity = _physics?.minFlingVelocity
                  ..maxFlingVelocity = _physics?.maxFlingVelocity
                  ..velocityTrackerBuilder =
                      _configuration.velocityTrackerBuilder(context)
                  ..dragStartBehavior = widget.dragStartBehavior;
              },
            ),
          };
          break;
      }
    }
    _lastCanDrag = canDrag;
    _lastAxisDirection = widget.axis;
    if (_gestureDetectorKey.currentState != null) {
      _gestureDetectorKey.currentState!
          .replaceGestureRecognizers(_gestureRecognizers);
    }
  }

  @override
  TickerProvider get vsync => this;

  @override
  @protected
  void setIgnorePointer(bool value) {
    if (_shouldIgnorePointer == value) return;
    _shouldIgnorePointer = value;
    if (_ignorePointerKey.currentContext != null) {
      final RenderIgnorePointer renderBox = _ignorePointerKey.currentContext!
          .findRenderObject()! as RenderIgnorePointer;
      renderBox.ignoring = _shouldIgnorePointer;
    }
  }

  @override
  BuildContext? get notificationContext => _gestureDetectorKey.currentContext;

  @override
  BuildContext get storageContext => context;

  // TOUCH HANDLERS

  Drag? _drag;
  ScrollHoldController? _hold;

  void _handleDragDown(DragDownDetails details) {
    assert(_drag == null);
    assert(_hold == null);
    _hold = position.hold(_disposeHold);
  }

  void _handleDragStart(DragStartDetails details) {
    // It's possible for _hold to become null between _handleDragDown and
    // _handleDragStart, for example if some user code calls jumpTo or otherwise
    // triggers a new activity to begin.
    assert(_drag == null);
    _drag = position.drag(details, _disposeDrag);
    assert(_drag != null);
    assert(_hold == null);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    _drag?.update(details);
  }

  void _handleDragEnd(DragEndDetails details) {
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    _drag?.end(details);
    assert(_drag == null);
  }

  void _handleDragCancel() {
    // _hold might be null if the drag started.
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    _hold?.cancel();
    _drag?.cancel();
    assert(_hold == null);
    assert(_drag == null);
  }

  void _disposeHold() {
    _hold = null;
  }

  void _disposeDrag() {
    _drag = null;
  }

  // SCROLL WHEEL

  // Returns the offset that should result from applying [event] to the current
  // position, taking min/max scroll extent into account.
  double _targetScrollOffsetForPointerScroll(double delta) {
    return math.min(
      math.max(position.pixels + delta, position.minScrollExtent),
      position.maxScrollExtent,
    );
  }

  // Returns the delta that should result from applying [event] with axis and
  // direction taken into account.
  double _pointerSignalEventDelta(PointerScrollEvent event) {
    double delta = widget.axis == Axis.horizontal
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;

    if (axisDirectionIsReversed(widget.axisDirection)) {
      delta *= -1;
    }
    return delta;
  }

  void _receivedPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && _position != null) {
      if (_physics != null && !_physics!.shouldAcceptUserOffset(position)) {
        return;
      }
      final double delta = _pointerSignalEventDelta(event);
      final double targetScrollOffset =
          _targetScrollOffsetForPointerScroll(delta);
      // Only express interest in the event if it would actually result in a scroll.
      if (delta != 0.0 && targetScrollOffset != position.pixels) {
        GestureBinding.instance.pointerSignalResolver
            .register(event, _handlePointerScroll);
      }
    }
  }

  void _handlePointerScroll(PointerEvent event) {
    assert(event is PointerScrollEvent);
    final double delta = _pointerSignalEventDelta(event as PointerScrollEvent);
    final double targetScrollOffset =
        _targetScrollOffsetForPointerScroll(delta);
    if (delta != 0.0 && targetScrollOffset != position.pixels) {
      position.pointerScroll(delta);
    }
  }

  // DESCRIPTION

  @override
  Widget build(BuildContext context) {
    assert(_position != null);
    // _ScrollableScope must be placed above the BuildContext returned by notificationContext
    // so that we can get this ScrollableState by doing the following:
    //
    // ScrollNotification notification;
    // Scrollable.of(notification.context)
    //
    // Since notificationContext is pointing to _gestureDetectorKey.context, _ScrollableScope
    // must be placed above the widget using it: RawGestureDetector
    Widget result = _ScrollableScope(
      scrollable: this,
      position: position,
      // TODO(ianh): Having all these global keys is sad.
      child: Listener(
        onPointerSignal: _receivedPointerSignal,
        child: RawGestureDetector(
          key: _gestureDetectorKey,
          gestures: _gestureRecognizers,
          behavior: HitTestBehavior.deferToChild,
          excludeFromSemantics: widget.excludeFromSemantics,
          child: Semantics(
            explicitChildNodes: !widget.excludeFromSemantics,
            child: MinInteractionZone(
              extent: widget.minInteractionExtent,
              direction: flipAxisDirection(widget.axisDirection),
              child: IgnorePointer(
                ignoring: false,
                // Using ignore pointer will prioritize this scroll to the inner one
                // key: _ignorePointerKey,
                // ignoring: _shouldIgnorePointer,
                //ignoringSemantics: false,
                child: widget.viewportBuilder(context, position),
              ),
            ),
          ),
        ),
      ),
    );

    if (!widget.excludeFromSemantics) {
      result = _ScrollSemantics(
        key: _scrollSemanticsKey,
        child: result,
        position: position,
        allowImplicitScrolling: _physics!.allowImplicitScrolling,
        semanticChildCount: widget.semanticChildCount,
      );
    }

    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ScrollPosition>('position', position));
    properties
        .add(DiagnosticsProperty<ScrollPhysics>('effective physics', _physics));
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  double? get initialExtent => widget.initialExtent;
}

/// With [_ScrollSemantics] certain child [SemanticsNode]s can be
/// excluded from the scrollable area for semantics purposes.
///
/// Nodes, that are to be excluded, have to be tagged with
/// [RenderViewport.excludeFromScrolling] and the [RenderAbstractViewport] in
/// use has to add the [RenderViewport.useTwoPaneSemantics] tag to its
/// [SemanticsConfiguration] by overriding
/// [RenderObject.describeSemanticsConfiguration].
///
/// If the tag [RenderViewport.useTwoPaneSemantics] is present on the viewport,
/// two semantics nodes will be used to represent the [Scrollable]: The outer
/// node will contain all children, that are excluded from scrolling. The inner
/// node, which is annotated with the scrolling actions, will house the
/// scrollable children.
class _ScrollSemantics extends SingleChildRenderObjectWidget {
  const _ScrollSemantics({
    Key? key,
    required this.position,
    required this.allowImplicitScrolling,
    required this.semanticChildCount,
    Widget? child,
  })  : assert(semanticChildCount == null || semanticChildCount >= 0),
        super(key: key, child: child);

  final ScrollPosition position;
  final bool allowImplicitScrolling;
  final int? semanticChildCount;

  @override
  _RenderScrollSemantics createRenderObject(BuildContext context) {
    return _RenderScrollSemantics(
      position: position,
      allowImplicitScrolling: allowImplicitScrolling,
      semanticChildCount: semanticChildCount,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderScrollSemantics renderObject) {
    renderObject
      ..allowImplicitScrolling = allowImplicitScrolling
      ..position = position
      ..semanticChildCount = semanticChildCount;
  }
}

class _RenderScrollSemantics extends RenderProxyBox {
  _RenderScrollSemantics({
    required ScrollPosition position,
    required bool allowImplicitScrolling,
    required int? semanticChildCount,
    RenderBox? child,
  })  : _position = position,
        _allowImplicitScrolling = allowImplicitScrolling,
        _semanticChildCount = semanticChildCount,
        super(child) {
    position.addListener(markNeedsSemanticsUpdate);
  }

  /// Whether this render object is excluded from the semantic tree.
  ScrollPosition get position => _position;
  ScrollPosition _position;
  set position(ScrollPosition value) {
    if (value == _position) return;
    _position.removeListener(markNeedsSemanticsUpdate);
    _position = value;
    _position.addListener(markNeedsSemanticsUpdate);
    markNeedsSemanticsUpdate();
  }

  /// Whether this node can be scrolled implicitly.
  bool get allowImplicitScrolling => _allowImplicitScrolling;
  bool _allowImplicitScrolling;
  set allowImplicitScrolling(bool value) {
    if (value == _allowImplicitScrolling) return;
    _allowImplicitScrolling = value;
    markNeedsSemanticsUpdate();
  }

  int? get semanticChildCount => _semanticChildCount;
  int? _semanticChildCount;
  set semanticChildCount(int? value) {
    if (value == semanticChildCount) return;
    _semanticChildCount = value;
    markNeedsSemanticsUpdate();
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isSemanticBoundary = true;
    if (position.haveDimensions) {
      config
        ..hasImplicitScrolling = allowImplicitScrolling
        ..scrollPosition = _position.pixels
        ..scrollExtentMax = _position.maxScrollExtent
        ..scrollExtentMin = _position.minScrollExtent
        ..scrollChildCount = semanticChildCount;
    }
  }

  SemanticsNode? _innerNode;

  @override
  void assembleSemanticsNode(SemanticsNode node, SemanticsConfiguration config,
      Iterable<SemanticsNode> children) {
    if (children.isEmpty ||
        !children.first.isTagged(RenderViewport.useTwoPaneSemantics)) {
      super.assembleSemanticsNode(node, config, children);
      return;
    }

    _innerNode ??= SemanticsNode(showOnScreen: showOnScreen);
    _innerNode!
      ..isMergedIntoParent = node.isPartOfNodeMerging
      ..rect = node.rect;

    int? firstVisibleIndex;
    final List<SemanticsNode> excluded = <SemanticsNode>[_innerNode!];
    final List<SemanticsNode> included = <SemanticsNode>[];
    for (final SemanticsNode child in children) {
      assert(child.isTagged(RenderViewport.useTwoPaneSemantics));
      if (child.isTagged(RenderViewport.excludeFromScrolling)) {
        excluded.add(child);
      } else {
        if (!child.hasFlag(SemanticsFlag.isHidden)) {
          firstVisibleIndex ??= child.indexInParent;
        }
        included.add(child);
      }
    }
    config.scrollIndex = firstVisibleIndex;
    node.updateWith(config: null, childrenInInversePaintOrder: excluded);
    _innerNode!
        .updateWith(config: config, childrenInInversePaintOrder: included);
  }

  @override
  void clearSemantics() {
    super.clearSemantics();
    _innerNode = null;
  }
}

/// A typedef for a function that can calculate the offset for a type of scroll
/// increment given a [ScrollIncrementDetails].
///
/// This function is used as the type for [SheetScrollable.incrementCalculator],
/// which is called from a [ScrollAction].
typedef ScrollIncrementCalculator = double Function(
    ScrollIncrementDetails details);

/// Describes the type of scroll increment that will be performed by a
/// [ScrollAction] on a [SheetScrollable].
///
/// This is used to configure a [ScrollIncrementDetails] object to pass to a
/// [ScrollIncrementCalculator] function on a [SheetScrollable].
///
/// {@template flutter.widgets.ScrollIncrementType.intent}
/// This indicates the *intent* of the scroll, not necessarily the size. Not all
/// scrollable areas will have the concept of a "line" or "page", but they can
/// respond to the different standard key bindings that cause scrolling, which
/// are bound to keys that people use to indicate a "line" scroll (e.g.
/// control-arrowDown keys) or a "page" scroll (e.g. pageDown key). It is
/// recommended that at least the relative magnitudes of the scrolls match
/// expectations.
/// {@endtemplate}
enum ScrollIncrementType {
  /// Indicates that the [ScrollIncrementCalculator] should return the scroll
  /// distance it should move when the user requests to scroll by a "line".
  ///
  /// The distance a "line" scrolls refers to what should happen when the key
  /// binding for "scroll down/up by a line" is triggered. It's up to the
  /// [ScrollIncrementCalculator] function to decide what that means for a
  /// particular scrollable.
  line,

  /// Indicates that the [ScrollIncrementCalculator] should return the scroll
  /// distance it should move when the user requests to scroll by a "page".
  ///
  /// The distance a "page" scrolls refers to what should happen when the key
  /// binding for "scroll down/up by a page" is triggered. It's up to the
  /// [ScrollIncrementCalculator] function to decide what that means for a
  /// particular scrollable.
  page,
}

/// A details object that describes the type of scroll increment being requested
/// of a [ScrollIncrementCalculator] function, as well as the current metrics
/// for the scrollable.
class ScrollIncrementDetails {
  /// A const constructor for a [ScrollIncrementDetails].
  ///
  /// All of the arguments must not be null, and are required.
  const ScrollIncrementDetails({
    required this.type,
    required this.metrics,
  });

  /// The type of scroll this is (e.g. line, page, etc.).
  ///
  /// {@macro flutter.widgets.ScrollIncrementType.intent}
  final ScrollIncrementType type;

  /// The current metrics of the scrollable that is being scrolled.
  final ScrollMetrics metrics;
}

/// An [Intent] that represents scrolling the nearest scrollable by an amount
/// appropriate for the [type] specified.
///
/// The actual amount of the scroll is determined by the
/// [SheetScrollable.incrementCalculator], or by its defaults if that is not
/// specified.
class ScrollIntent extends Intent {
  /// Creates a const [ScrollIntent] that requests scrolling in the given
  /// [direction], with the given [type].
  const ScrollIntent({
    required this.direction,
    this.type = ScrollIncrementType.line,
  });

  /// The direction in which to scroll the scrollable containing the focused
  /// widget.
  final AxisDirection direction;

  /// The type of scrolling that is intended.
  final ScrollIncrementType type;
}

// Not using a RestorableDouble because we want to allow null values and override
// [enabled].
class _RestorableScrollOffset extends RestorableValue<double?> {
  @override
  double? createDefaultValue() => null;

  @override
  void didUpdateValue(double? oldValue) {
    notifyListeners();
  }

  @override
  double fromPrimitives(Object? data) {
    return data! as double;
  }

  @override
  Object? toPrimitives() {
    return value;
  }

  @override
  bool get enabled => value != null;
}
