// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sheet/sheet.dart';

// TODO: Arbitrary values, keep them or make SheetRoute abstract
const double _kWillPopThreshold = 0.8;
const Duration _kSheetTransitionDuration = Duration(milliseconds: 400);
const Color _kBarrierColor = Color(0x59000000);

///
class SheetRoute<T> extends PageRoute<T> with DelegatedTransitionsRoute<T> {
  SheetRoute({
    required this.builder,
    this.initialExtent = 1,
    this.stops,
    this.draggable = true,
    this.expanded = true,
    this.bounceAtTop = false,
    this.animationCurve,
    this.duration,
    this.sheetLabel,
    this.barrierLabel,
    this.barrierColor = _kBarrierColor,
    this.barrierDismissible = true,
    this.maintainState = true,
    this.willPopThreshold = _kWillPopThreshold,
    RouteSettings? settings,
  }) : super(settings: settings, fullscreenDialog: true);

  final WidgetBuilder builder;

  final double initialExtent;

  final List<double>? stops;

  final bool expanded;

  final bool bounceAtTop;

  final bool draggable;

  final Duration? duration;

  final Curve? animationCurve;

  final double willPopThreshold;

  @override
  Duration get transitionDuration => duration ?? _kSheetTransitionDuration;

  final String? sheetLabel;

  @override
  final bool barrierDismissible;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  AnimationController? _routeAnimationController;

  late final SheetController sheetController = SheetController();

  //SheetRouteController<T>? _sheetController;

  // Animation<double>? get sheetAnimation => _sheetController?.animation;

  @override
  AnimationController createAnimationController() {
    assert(_routeAnimationController == null);
    assert(navigator?.overlay != null);
    _routeAnimationController = AnimationController(
      vsync: navigator!.overlay!,
      duration: duration ?? _kSheetTransitionDuration,
    );
    return _routeAnimationController!;
  }

  @override
  void dispose() {
    sheetController.dispose();
    super.dispose();
  }

  bool get _hasScopedWillPopCallback => hasScopedWillPopCallback;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _SheetRouteContainer(sheetRoute: this);
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
      nextRoute is SheetRoute;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
      previousRoute is PageRoute;

  /// {@macro flutter.widgets.modalRoute.maintainState}
  @override
  final bool maintainState;

  @override
  bool get opaque => false;

  @override
  bool canDriveSecondaryTransitionForPreviousRoute(Route previousRoute) {
    return true;
  }

  @override
  Widget buildSecondaryTransitionForPreviousRoute(BuildContext context,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}

/// A page that creates a material style [PageRoute].
///
/// {@macro flutter.material.materialRouteTransitionMixin}
///
/// By default, when the created route is replaced by another, the previous
/// route remains in memory. To free all the resources when this is not
/// necessary, set [maintainState] to false.
///
/// The `fullscreenDialog` property specifies whether the created route is a
/// fullscreen modal dialog. On iOS, those routes animate from the bottom to the
/// top rather than horizontally.
///
/// The type `T` specifies the return type of the route which can be supplied as
/// the route is popped from the stack via [Navigator.transitionDelegate] by
/// providing the optional `result` argument to the
/// [RouteTransitionRecord.markForPop] in the [TransitionDelegate.resolve].
///
/// See also:
///
///  * [MaterialPageRoute], which is the [PageRoute] version of this class
class SheetPage<T> extends Page<T> {
  /// Creates a material page.
  const SheetPage({
    required this.child,
    this.maintainState = true,
    LocalKey? key,
    String? name,
    Object? arguments,
  })  : assert(child != null),
        assert(maintainState != null),
        super(key: key, name: name, arguments: arguments);

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.modalRoute.maintainState}
  final bool maintainState;

  @override
  Route<T> createRoute(BuildContext context) {
    return _PageBasedSheetRoute<T>(page: this);
  }
}

// A page-based version of SheetRoute.
//
// This route uses the builder from the page to build its content. This ensures
// the content is up to date after page updates.
class _PageBasedSheetRoute<T> extends SheetRoute<T> {
  _PageBasedSheetRoute({
    required SheetPage<T> page,
    Color? barrierColor,
    bool bounceAtTop = false,
    bool expanded = false,
    Curve? animationCurve,
    bool barrierDismissible = true,
    bool enableDrag = true,
    Duration? duration,
    List<double>? stops,
    double initialStop = 1,
  })  : assert(page != null),
        super(
          settings: page,
          builder: (BuildContext context) => page.child,
          bounceAtTop: bounceAtTop,
          expanded: expanded,
          stops: stops,
          initialExtent: initialStop,
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          draggable: enableDrag,
          animationCurve: animationCurve,
          duration: duration,
        );

  SheetPage<T> get _page => settings as SheetPage<T>;

  @override
  bool get maintainState => _page.maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}

class _SheetRouteContainer extends StatefulWidget {
  final SheetRoute sheetRoute;

  const _SheetRouteContainer({Key? key, required this.sheetRoute})
      : super(key: key);
  @override
  __SheetRouteContainerState createState() => __SheetRouteContainerState();
}

class __SheetRouteContainerState extends State<_SheetRouteContainer>
    with TickerProviderStateMixin {
  SheetRoute get route => widget.sheetRoute;
  SheetController get _sheetController => widget.sheetRoute.sheetController;
  AnimationController get _routeController =>
      widget.sheetRoute._routeAnimationController!;
  @override
  void initState() {
    _routeController.addListener(onRouteAnimationUpdate);
    _sheetController.addListener(onSheetExtentUpdate);
    super.initState();
  }

  @override
  void dispose() {
    _routeController.addListener(onRouteAnimationUpdate);
    _sheetController.removeListener(onSheetExtentUpdate);
    super.dispose();
  }

  bool _prevented = false;
  void onSheetExtentUpdate() {
    if (_routeController.value != _sheetController.animation.value) {
      if (shouldPreventPopForExtent(_sheetController.animation.value)) {
        preventPop();
        return;
      }
      if (!_routeController.isAnimating) {
        _routeController.value = _sheetController.animation.value;

        if (_sheetController.animation.value == 0) {
          widget.sheetRoute.navigator?.pop();
        }
      }
    }
  }

  bool _firstAnimation = true;
  void onRouteAnimationUpdate() {
    if (_firstAnimation) {
      if (_routeController.isCompleted) {
        _firstAnimation = false;
      } else {
        final animationValue = _mapDoubleInRange(
            _routeController.value, 0, 1, 0, route.initialExtent);
        _sheetController
            .jumpTo(animationValue * _sheetController.position.maxScrollExtent);
      }
    } else if (_routeController.value != _sheetController.animation.value) {
      _sheetController.jumpTo(
          _routeController.value * _sheetController.position.maxScrollExtent);
    }
  }

  /// Returns true if the controller should prevent popping for a given extent
  @protected
  bool shouldPreventPopForExtent(double extent) {
    final bool shouldPreventClose = route._hasScopedWillPopCallback;
    return !_prevented &&
        extent < route.willPopThreshold &&
        shouldPreventClose &&
        _routeController.velocity <= 0;
  }

  /// Stop current sheet transition and call willPop to confirm/cancel the pop
  @protected
  void preventPop() {
    _prevented = true;
    _sheetController.animateTo(
      1,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    route.willPop.call().then((RoutePopDisposition disposition) {
      if (disposition == RoutePopDisposition.pop) {
        _prevented = true;
        _sheetController
            .animateTo(
          0,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        )
            .whenComplete(() {
          _prevented = false;
        });
      } else {
        _prevented = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.sheetRoute;
    SheetPhysics? physics =
        route.bounceAtTop ? BouncingSheetPhysics(overflow: true) : null;
    physics = SnapSheetPhysics(stops: route.stops ?? [0, 1], parent: physics);
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: route.sheetLabel,
      explicitChildNodes: true,
      child: Sheet(
        initialExtent: route.initialExtent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        fit: route.expanded ? SheetFit.expand : SheetFit.loose,
        physics: physics,
        clipBehavior: Clip.none,
        controller: _sheetController,
        child: Builder(builder: route.builder),
      ),
    );
  }
}

/// Re-maps a number from one range to another.
///
/// A value of fromLow would get mapped to toLow, a value of
/// fromHigh to toHigh, values in-between to values in-between, etc
double _mapDoubleInRange(double value, double fromLow, double fromHigh,
    double toLow, double toHigh) {
  final double offset = toLow;
  final double ratio = (toHigh - toLow) / (fromHigh - fromLow);
  return ratio * (value - fromLow) + offset;
}

/* 
/// A [SheetController] that also implements the behaviour for
/// willPop inside the sheet
///
/// If the sheet reaches the [willPopThreshold] and [shouldPreventPop] returns
/// true, the sheet will stop animating and will animate back to the top.
/// If willPop returns true, the sheet will close.
class SheetRouteController<T> extends SheetController {
  // TODO(jamesblasco): Do we want this to be private?
  SheetRouteController({
    required this.route,
    required TickerProvider vsync,
    Duration? duration,
    Curve? curve,
    List<double>? stops,
    double? initialExtent,
    bool snap = true,
    this.onPop,
    this.willPop,
    this.hasScopedWillPopCallback,
    this.willPopThreshold = _kWillPopThreshold,
  }) : super(
          vsync: vsync,
          curve: curve,
          stops: stops,
          snap: snap,
          duration: duration,
          initialExtent: initialExtent ?? 1.0,
        ) {
    animationController.value = 0;
    routeAnimationController.addListener(onRouteAnimationUpdate);
    animationController.addListener(onSheetAnimationUpdate);
  }

  final SheetRoute<T> route;

  /// The extent limit that will call willPop
  final double willPopThreshold;

  /// Return true if the sheet should prevent pop and call willPop
  final bool Function()? hasScopedWillPopCallback;

  /// If returns true, the sheet will close, otherwise the sheet will stay open
  /// Notice that if willPop is not null, the dialog will go back to the
  /// previous position until the function is solved
  final Future<bool> Function()? willPop;

  /// Callback called when the route that wraps the sheet should pop
  final VoidCallback? onPop;

  /// Once is confirmed by willPop that the sheet can pop, force it to pop.
  bool _forcePop = false;

  /// Returns true if the controller should prevent popping for a given extent
  @protected
  bool shouldPreventPopForExtent(double extent) {
    final bool shouldPreventClose = hasScopedWillPopCallback?.call() ?? false;
    return !_forcePop &&
        extent < willPopThreshold &&
        shouldPreventClose &&
        animationController.velocity <= 0;
  }

  /// Stop current sheet transition and call willPop to confirm/cancel the pop
  @protected
  void preventPop() {
    animationController.stop();
    animationController.animateTo(1);
    willPop?.call().then((bool close) {
      if (close) {
        _forcePop = true;
        onPop?.call();
      }
    });
  }

  @override
  void addPixelDelta(double delta, {VoidCallback? onDragCancel}) {
    if (availablePixels == 0) {
      return;
    }
    final double newExtent =
        currentExtent + delta / availablePixels * maxExtent;

    /// Check if the newExtent needs to call willPop
    if (shouldPreventPopForExtent(newExtent)) {
      preventPop();
      // Cancel drag if pop is prevented
      onDragCancel?.call();
      return;
    }
    super.addPixelDelta(delta, onDragCancel: onDragCancel);
  }

  AnimationController get routeAnimationController =>
      route._routeAnimationController!;

  bool get sheetDismissUnderway => animationController.velocity < 0;
  bool get routeDismissUnderway => routeAnimationController.velocity < 0;
  double? lastPositionBeforeDismiss;

  void onRouteAnimationUpdate() {
    /// Prevent pop if sheet is being dismissed and [_shouldPreventPopForExtent] is true
    if (sheetDismissUnderway && shouldPreventPopForExtent(currentExtent)) {
      preventPop();
      return;
    }

    // If dismiss is underway we animate the sheet from the last known position
    // Otherwise we will animate to the initialStop
    double value;
    if (routeDismissUnderway) {
      lastPositionBeforeDismiss ??= animationController.value;
      value = _mapDoubleInRange(
          routeAnimationController.value, 0, 1, 0, lastPositionBeforeDismiss!);
    } else if (routeAnimationController.isAnimating ||
        routeAnimationController.isCompleted ||
        routeAnimationController.isDismissed) {
      value = _mapDoubleInRange(
          routeAnimationController.value, 0, 1, 0, initialExtent);
    } else {
      return;
    }

    if (animationController.value != value) {
      animationController.value = value;
    }
  }

  void onSheetAnimationUpdate() {
    /// If sheet reaches the bottom call onPop
    if (animationController.value == 0 && animationController.isCompleted) {
      _forcePop = false;
      animationController.stop();
      onPop?.call();
    }

    if (routeAnimationController.isAnimating) {
      return;
    }
    final double clampedValue =
        animationController.value.clamp(0, initialExtent);
    final double value =
        _mapDoubleInRange(clampedValue, 0, initialExtent, 0, 1);
    if (routeAnimationController.value != value) {
      routeAnimationController.value = value;
    }
  }

  @override
  void dispose() {
    routeAnimationController.removeListener(onRouteAnimationUpdate);
    animationController.removeListener(onSheetAnimationUpdate);
    super.dispose();
  }
}


 */
