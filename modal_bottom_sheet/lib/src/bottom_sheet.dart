// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:modal_bottom_sheet/src/utils/scroll_to_top_status_bar.dart';

import 'package:modal_bottom_sheet/src/utils/bottom_sheet_suspended_curve.dart';

const Curve _decelerateEasing = Cubic(0.0, 0.0, 0.2, 1.0);

const Duration _bottomSheetDuration = Duration(milliseconds: 400);
const double _minFlingVelocity = 500.0;
const double _closeProgressThreshold = 0.6;
const double _willPopThreshold = 0.8;

typedef WidgetWithChildBuilder = Widget Function(
    BuildContext context, Animation<double> animation, Widget child);

/// A custom bottom sheet.
///
/// The [ModalBottomSheet] widget itself is rarely used directly. Instead, prefer to
/// create a modal bottom sheet with [showMaterialModalBottomSheet].
///
/// See also:
///
///  * [showMaterialModalBottomSheet] which can be used to display a modal bottom
///    sheet with Material appareance.
///  * [showCupertinoModalBottomSheet] which can be used to display a modal bottom
///    sheet with Cupertino appareance.
class ModalBottomSheet extends StatefulWidget {
  /// Creates a bottom sheet.
  const ModalBottomSheet({
    super.key,
    required this.animationController,
    this.animationCurve,
    this.enableDrag = true,
    this.containerBuilder,
    this.bounce = true,
    this.shouldClose,
    required this.scrollController,
    required this.expanded,
    required this.onClosing,
    required this.child,
    this.minFlingVelocity = _minFlingVelocity,
    double? closeProgressThreshold,
    @Deprecated('Use preventPopThreshold instead') double? willPopThreshold,
    double? preventPopThreshold,
    this.scrollPhysics,
    this.scrollPhysicsBuilder,
  })  : preventPopThreshold =
            preventPopThreshold ?? willPopThreshold ?? _willPopThreshold,
        closeProgressThreshold =
            closeProgressThreshold ?? _closeProgressThreshold;

  /// The closeProgressThreshold parameter
  /// specifies when the bottom sheet will be dismissed when user drags it.
  final double closeProgressThreshold;

  /// The animation controller that controls the bottom sheet's entrance and
  /// exit animations.
  ///
  /// The BottomSheet widget will manipulate the position of this animation, it
  /// is not just a passive observer.
  final AnimationController animationController;

  /// The curve used by the animation showing and dismissing the bottom sheet.
  ///
  /// If no curve is provided it falls back to `decelerateEasing`.
  final Curve? animationCurve;

  /// Allows the bottom sheet to  go beyond the top bound of the content,
  /// but then bounce the content back to the edge of
  /// the top bound.
  final bool bounce;

  // Force the widget to fill the maximum size of the viewport
  // or if false it will fit to the content of the widget
  final bool expanded;

  final WidgetWithChildBuilder? containerBuilder;

  /// Called when the bottom sheet begins to close.
  ///
  /// A bottom sheet might be prevented from closing (e.g., by user
  /// interaction) even after this callback is called. For this reason, this
  /// callback might be call multiple times for a given bottom sheet.
  final Function() onClosing;

  // If shouldClose is null is ignored.
  // If returns true => The dialog closes
  // If returns false => The dialog cancels close
  // Notice that if shouldClose is not null, the dialog will go back to the
  // previous position until the function is solved
  final Future<bool> Function()? shouldClose;

  /// A builder for the contents of the sheet.
  ///
  final Widget child;

  /// The default scroll physics for underlaying scroll views
  /// When set, we are able to change to the NeverScrollableScrollPhysics() while
  /// we are dragging the bottom sheet with scrollview
  final ScrollPhysics? scrollPhysics;

  final ScrollPhysics Function(bool canScroll, ScrollPhysics parent)? scrollPhysicsBuilder;

  /// If true, the bottom sheet can be dragged up and down and dismissed by
  /// swiping downwards.
  ///
  /// Default is true.
  final bool enableDrag;

  final ScrollController scrollController;

  /// The minFlingVelocity parameter
  /// Determines how fast the sheet should be flinged before closing.
  final double minFlingVelocity;

  /// The preventPopThreshold parameter
  /// Determines how far the sheet should be flinged before closing.
  final double preventPopThreshold;

  @override
  ModalBottomSheetState createState() => ModalBottomSheetState();

  /// Creates an [AnimationController] suitable for a
  /// [ModalBottomSheet.animationController].
  ///
  /// This API available as a convenience for a Material compliant bottom sheet
  /// animation. If alternative animation durations are required, a different
  /// animation controller could be provided.
  static AnimationController createAnimationController(
    TickerProvider vsync, {
    Duration? duration,
  }) {
    return AnimationController(
      duration: duration ?? _bottomSheetDuration,
      debugLabel: 'BottomSheet',
      vsync: vsync,
    );
  }
}

class ModalBottomSheetState extends State<ModalBottomSheet>
    with TickerProviderStateMixin {
  final GlobalKey _childKey = GlobalKey(debugLabel: 'BottomSheet child');
  final GlobalKey _contentKey = GlobalKey(debugLabel: 'BottomSheet content');

  ScrollController get _scrollController => widget.scrollController;

  late AnimationController _bounceDragController;

  double? get _childHeight {
    final childContext = _childKey.currentContext;
    final renderBox = childContext?.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }


  double? get _contentHeight {
    final childContext = _contentKey.currentContext;
    final renderBox = childContext?.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  bool get _dismissUnderway =>
      widget.animationController.status == AnimationStatus.reverse;

  // Detect if user is dragging.
  // Used on NotificationListener to detect if ScrollNotifications are
  // before or after the user stop dragging
  bool _isDragging = false;

  // Indicates if the scrollbar is scrollable
  // when we start a drag event, we are always scrollable
  bool _canScroll = true;
  bool _isScrolling = false;
  ScrollDirection _scrollDirection = ScrollDirection.idle;

  bool get hasReachedWillPopThreshold =>
      widget.animationController.value < _willPopThreshold;

  bool get hasReachedCloseThreshold {
    final childHeight = _childHeight;
    final contentHeight = _contentHeight;

    if (contentHeight == null || childHeight == null || childHeight <= contentHeight) {
      return widget.animationController.value < widget.closeProgressThreshold;
    }

    // When the content view is smaller that the child view
    // we need to change the animation value to account for
    // the height difference between the viewport and the content
    final closeProgressThreshold = widget.closeProgressThreshold;

    final value = (widget.animationController.value - _lowerBound) / (1 - _lowerBound);

    return value < closeProgressThreshold;
  }

  double get _lowerBound {
    if (_contentHeight == null || _childHeight == null) {
      return 1;
    }
    return (_contentHeight! / _childHeight!).clamp(0.0, 1.0);
  }

  void _close() {
    _isDragging = false;
    widget.onClosing();
  }

  void _cancelClose() {
    widget.animationController.forward().then((value) {
      // When using WillPop, animation doesn't end at 1.
      // Check more in detail the problem
      if (!widget.animationController.isCompleted) {
        widget.animationController.value = 1;
      }
    });
    _bounceDragController.reverse();
  }

  bool _isCheckingShouldClose = false;

  FutureOr<bool> shouldClose() async {
    if (_isCheckingShouldClose) return false;
    if (widget.shouldClose == null) return false;
    _isCheckingShouldClose = true;
    final result = await widget.shouldClose?.call();
    _isCheckingShouldClose = false;
    return result ?? false;
  }

  ParametricCurve<double> animationCurve = Curves.linear;

  void _handleDragUpdate(double primaryDelta) async {
    animationCurve = Curves.linear;
    assert(widget.enableDrag, 'Dragging is disabled');

    if (_dismissUnderway) {
      return;
    }

    // Abort if the scrollbar is scrollable
    if (_canScroll && _isScrolling) {
      return;
    }

    _isDragging = true;

    final progress = primaryDelta / (_childHeight ?? primaryDelta);

    if (widget.shouldClose != null && hasReachedWillPopThreshold) {
      _cancelClose();
      final canClose = await shouldClose();
      if (canClose) {
        _close();
        return;
      } else {
        _cancelClose();
      }
    }

    // Bounce top
    final bounce = widget.bounce == true;
    final shouldBounce = _bounceDragController.value > 0;
    final isBouncing = (widget.animationController.value - progress) > 1;
    if (bounce && (shouldBounce || isBouncing)) {
      _bounceDragController.value -= progress * 10;
      return;
    }

    widget.animationController.value -= progress;
  }

  void _handleDragEnd(double velocity) async {
    assert(widget.enableDrag, 'Dragging is disabled');

    animationCurve = BottomSheetSuspendedCurve(
      widget.animationController.value,
      curve: _defaultCurve,
    );

    if (_dismissUnderway || !_isDragging) return;
    _isDragging = false;
    _canScroll = true;
    _bounceDragController.reverse();

    Future<void> tryClose() async {
      if (widget.shouldClose != null) {
        _cancelClose();
        bool canClose = await shouldClose();
        if (canClose) {
          _close();
        }
      } else {
        _close();
      }
    }

    // If speed is bigger than _minFlingVelocity try to close it
    if (velocity > widget.minFlingVelocity) {
      tryClose();
    } else if (hasReachedCloseThreshold) {
      if (widget.animationController.value > 0.0) {
        widget.animationController.fling(velocity: -1.0);
      }
      tryClose();
    } else {
      _cancelClose();
    }
  }

  Curve get _defaultCurve => widget.animationCurve ?? _decelerateEasing;

  late final VerticalDragGestureRecognizer _verticalDragRecognizer;

  void _handleRawDragUpdate(DragUpdateDetails details) {
    _handleDragUpdate(details.delta.dy);
  }

  void _handleRawDragEnd(DragEndDetails details) {
    _handleDragEnd(details.primaryVelocity ?? 0);
  }

  bool _handleScrollNotification(ScrollNotification notification) {

    if (notification is UserScrollNotification) {
      _scrollDirection = notification.direction;
    }

    if (notification is ScrollEndNotification) {
      _isScrolling = false;
    } else if (notification is ScrollStartNotification){
      _isScrolling = true;
    }

    if (notification is OverscrollNotification || notification is ScrollUpdateNotification) {
      final downwards = _scrollDirection == ScrollDirection.forward;
      final atEdge = notification.metrics.atEdge;

      // disable scrolling when we are at the edge
      if (downwards && atEdge && _canScroll) {
        setState(() {
          _canScroll = false;
        });
      } else if (!downwards && atEdge && !_canScroll) {
        setState(() {
          _canScroll = true;
        });
      }
    }
    return false;
  }

  @override
  void initState() {
    animationCurve = _defaultCurve;
    _bounceDragController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _verticalDragRecognizer = _AllowMultipleVerticalDragGestureRecognizer();
    _verticalDragRecognizer.onUpdate = _handleRawDragUpdate;
    _verticalDragRecognizer.onEnd = _handleRawDragEnd;

    // Todo: Check if we can remove scroll Controller
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bounceAnimation = CurvedAnimation(
      parent: _bounceDragController,
      curve: Curves.easeOutSine,
    );

    var child = widget.child;
    if (widget.containerBuilder != null) {
      child = widget.containerBuilder!(
        context,
        widget.animationController,
        child,
      );
    }

    child = AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, Widget? child) {
        assert(child != null);
        final animationValue = animationCurve.transform(
          widget.animationController.value,
        );

        final draggableChild = !widget.enableDrag
            ? child
            : KeyedSubtree(
                key: _childKey,
                child: AnimatedBuilder(
                  animation: bounceAnimation,
                  builder: (context, _) => CustomSingleChildLayout(
                    delegate: _CustomBottomSheetLayout(bounceAnimation.value),
                    child: Listener(
                      onPointerDown: (event) {
                        _verticalDragRecognizer.addPointer(event);
                      },
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _handleScrollNotification,
                        child: KeyedSubtree(
                          key: _contentKey,
                          child: child!,
                        ),
                      ),
                    ),
                  ),
                ),
              );
        return ClipRect(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              physics: widget.scrollPhysicsBuilder
                  ?.call(_canScroll, ScrollConfiguration.of(context).getScrollPhysics(context))
                ?? widget.scrollPhysics,
            ),
            child: CustomSingleChildLayout(
              delegate: _ModalBottomSheetLayout(
                animationValue,
                widget.expanded,
              ),
              child: draggableChild,
            ),
          ),
        );
      },
      child: RepaintBoundary(child: child),
    );

    return StatusBarGestureDetector(
      child: child,
      onTap: (context) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCirc,
        );
      },
    );
  }
}

class _ModalBottomSheetLayout extends SingleChildLayoutDelegate {
  _ModalBottomSheetLayout(this.progress, this.expand);

  final double progress;
  final bool expand;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: expand ? constraints.maxHeight : 0,
      maxHeight: expand ? constraints.maxHeight : constraints.minHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_ModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _CustomBottomSheetLayout extends SingleChildLayoutDelegate {
  _CustomBottomSheetLayout(this.progress);

  final double progress;
  double? childHeight;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: constraints.minHeight,
      maxHeight: constraints.maxHeight + progress * 8,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    childHeight ??= childSize.height;
    return Offset(0.0, size.height - childSize.height);
  }

  @override
  bool shouldRelayout(_CustomBottomSheetLayout oldDelegate) {
    if (progress != oldDelegate.progress) {
      childHeight = oldDelegate.childHeight;
      return true;
    }
    return false;
  }
}

// Checks the device input type as per the OS installed in it
// Mobile platforms will be default to `touch` while desktop will do to `mouse`
// Used with VelocityTracker
// https://github.com/flutter/flutter/pull/64267#issuecomment-694196304
PointerDeviceKind defaultPointerDeviceKind(BuildContext context) {
  final platform = Theme.of(context).platform; // ?? defaultTargetPlatform;
  switch (platform) {
    case TargetPlatform.iOS:
    case TargetPlatform.android:
      return PointerDeviceKind.touch;
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
      return PointerDeviceKind.mouse;
    case TargetPlatform.fuchsia:
      return PointerDeviceKind.unknown;
  }
}


class _AllowMultipleVerticalDragGestureRecognizer extends VerticalDragGestureRecognizer{

  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}