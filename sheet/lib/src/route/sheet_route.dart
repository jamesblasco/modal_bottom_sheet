// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sheet/route.dart';
import 'package:sheet/sheet.dart';

// TODO(jaime): Arbitrary values, keep them or make SheetRoute abstract
const double _kWillPopThreshold = 0.8;
const Duration _kSheetTransitionDuration = Duration(milliseconds: 400);
const Color _kBarrierColor = Color(0x59000000);

/// A modal route that overlays a widget over the current route and animates
/// it from the bottom
///
/// By default, when a modal route is replaced by another, the previous route
/// remains in memory. To free all the resources when this is not necessary, set
/// [maintainState] to false.
///
///
/// The type `T` specifies the return type of the route which can be supplied as
/// the route is popped from the stack via [Navigator.pop] by providing the
/// optional `result` argument.
///
/// See also:
///
///  * [SheetPage], which is a [Page] of this class.
///  * [CupertinoSheetRoute], which is has an iOS appareance
class SheetRoute<T> extends PageRoute<T> with DelegatedTransitionsRoute<T> {
  SheetRoute({
    required this.builder,
    this.initialExtent = 1,
    this.stops,
    this.draggable = true,
    this.fit = SheetFit.expand,
    this.physics,
    this.animationCurve,
    Duration? duration,
    this.sheetLabel,
    this.barrierLabel,
    this.barrierColor = _kBarrierColor,
    this.barrierDismissible = true,
    this.maintainState = true,
    this.willPopThreshold = _kWillPopThreshold,
    this.decorationBuilder,
    RouteSettings? settings,
  })  : transitionDuration = duration ?? _kSheetTransitionDuration,
        super(settings: settings, fullscreenDialog: true);

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  /// Relative extent up to where the sheet is animated when pushed for
  /// the first time.
  /// Values can't only be between
  ///    - 0: hidden
  ///    - 1: fully animated to the top
  /// By default it is 1
  final double initialExtent;

  /// Possible stops where the sheet can be snapped when dragged
  /// Values can only be between 0 and 1
  /// By default it is null
  final List<double>? stops;

  /// How to size the builder content in the sheet route.
  ///
  /// The constraints passed into the [Sheet] child are either
  /// loosened ([SheetFit.loose]) or tightened to their biggest size
  /// ([SheetFit.expand]).
  final SheetFit fit;

  /// {@macro flutter.widgets.sheet.physics}
  final SheetPhysics? physics;

  /// Defines if the sheet can be translated by user dragging.
  /// If false the route can still be closed by tapping the barrier if
  /// barrierDismissible is true or by [Navigator.pop]
  final bool draggable;

  /// Curve for the transition animation
  final Curve? animationCurve;

  /// Drag threshold to block any interaction if [Route.willPop] returns false
  /// See also:
  ///   * [WillPopScope], that allow to block an attemp to close a [ModalRoute]
  final double willPopThreshold;

  /// {@macro flutter.widgets.TransitionRoute.transitionDuration}
  @override
  final Duration transitionDuration;

  /// The semantic label used for a sheet modal route.
  final String? sheetLabel;

  /// Wraps the child in a custom sheet decoration appareance
  ///
  /// The default value is null.
  final SheetDecorationBuilder? decorationBuilder;

  @override
  final bool barrierDismissible;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  AnimationController? _routeAnimationController;

  late final SheetController _sheetController;
  SheetController get sheetController => _sheetController;

  @override
  void install() {
    _sheetController = createSheetController();
    super.install();
  }

  /// Called to create the sheet controller that will drive the
  /// sheet transitions
  SheetController createSheetController() {
    return SheetController();
  }

  @override
  AnimationController createAnimationController() {
    assert(_routeAnimationController == null);
    _routeAnimationController = AnimationController(
      vsync: navigator!,
      duration: transitionDuration,
    );
    return _routeAnimationController!;
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

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
  bool canDriveSecondaryTransitionForPreviousRoute(
      Route<dynamic> previousRoute) {
    return true;
  }

  @override
  Widget buildSecondaryTransitionForPreviousRoute(BuildContext context,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  /// Returns true if the controller should prevent popping for a given extent
  @protected
  bool shouldPreventPopForExtent(double extent) {
    return extent < willPopThreshold &&
        hasScopedWillPopCallback &&
        controller!.velocity <= 0;
  }

  Widget buildSheet(BuildContext context, Widget child) {
    SheetPhysics? effectivePhysics = SnapSheetPhysics(
      stops: stops ?? <double>[0, 1],
      parent: physics,
    );
    if (!draggable) {
      effectivePhysics = const NeverDraggableSheetPhysics();
    }
    return Sheet.raw(
      initialExtent: initialExtent,
      decorationBuilder: decorationBuilder,
      fit: fit,
      physics: effectivePhysics,
      controller: sheetController,
      child: child,
    );
  }
}

/// A page that creates a material style [SheetRoute].
///
/// By default, when a modal route is replaced by another, the previous route
/// remains in memory. To free all the resources when this is not necessary, set
/// [maintainState] to false.
///
/// The `fullscreenDialog` property specifies whether the incoming route is a
/// fullscreen modal dialog. On iOS, those routes animate from the bottom to the
/// top rather than horizontally.
///
/// The type `T` specifies the return type of the route which can be supplied as
/// the route is popped from the stack via [Navigator.pop] by providing the
/// optional `result` argument.
///
/// See also:
///
///
///  * [SheetPageRoute], which is the [PageRoute] version of this class
class SheetPage<T> extends Page<T> {
  /// Creates a material page.
  const SheetPage(
      {required this.child,
      this.maintainState = true,
      LocalKey? key,
      String? name,
      Object? arguments,
      this.initialExtent = 1,
      this.stops,
      this.draggable = true,
      this.fit = SheetFit.expand,
      this.physics,
      this.animationCurve,
      Duration? duration,
      this.sheetLabel,
      this.barrierLabel,
      this.barrierColor = _kBarrierColor,
      this.barrierDismissible = true,
      this.willPopThreshold = _kWillPopThreshold,
      this.decorationBuilder})
      : transitionDuration = duration ?? _kSheetTransitionDuration,
        super(
          key: key,
          name: name,
          arguments: arguments,
        );

  /// Relative extent up to where the sheet is animated when pushed for
  /// the first time.
  /// Values can't only be between
  ///    - 0: hidden
  ///    - 1: fully animated to the top
  /// By default it is 1
  final double initialExtent;

  /// Possible stops where the sheet can be snapped when dragged
  /// Values can only be between 0 and 1
  /// By default it is null
  final List<double>? stops;

  /// How to size the builder content in the sheet route.
  ///
  /// The constraints passed into the [Sheet] child are either
  /// loosened ([SheetFit.loose]) or tightened to their biggest size
  /// ([SheetFit.expand]).
  final SheetFit fit;

  /// {@macro flutter.widgets.sheet.physics}
  final SheetPhysics? physics;

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.modalRoute.maintainState}
  final bool maintainState;

  /// Defines if the sheet can be translated by user dragging.
  /// If false the route can still be closed by tapping the barrier if
  /// barrierDismissible is true or by [Navigator.pop]
  final bool draggable;

  /// Curve for the transition animation
  final Curve? animationCurve;

  /// Drag threshold to block any interaction if [Route.willPop] returns false
  /// See also:
  ///   * [WillPopScope], that allow to block an attemp to close a [ModalRoute]
  final double willPopThreshold;

  /// {@macro flutter.widgets.TransitionRoute.transitionDuration}
  final Duration transitionDuration;

  /// The semantic label used for a sheet modal route.
  final String? sheetLabel;

  final bool barrierDismissible;

  final Color? barrierColor;

  final String? barrierLabel;

  /// Wraps the child in a custom sheet decoration appareance
  ///
  /// The default value is null.
  final SheetDecorationBuilder? decorationBuilder;

  @override
  Route<T> createRoute(BuildContext context) {
    return _PageBasedSheetRoute<T>(
      page: this,
      physics: physics,
      fit: fit,
      stops: stops,
      initialExtent: initialExtent,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      draggable: draggable,
      animationCurve: animationCurve,
      duration: transitionDuration,
      decorationBuilder: decorationBuilder,
    );
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
    SheetPhysics? physics,
    SheetFit fit = SheetFit.expand,
    Curve? animationCurve,
    bool barrierDismissible = true,
    bool draggable = true,
    Duration? duration,
    List<double>? stops,
    double initialExtent = 1,
    SheetDecorationBuilder? decorationBuilder,
  }) : super(
          settings: page,
          builder: (BuildContext context) => page.child,
          physics: physics,
          fit: fit,
          stops: stops,
          initialExtent: initialExtent,
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          draggable: draggable,
          animationCurve: animationCurve,
          duration: duration,
          decorationBuilder: decorationBuilder,
        );

  SheetPage<T> get _page => settings as SheetPage<T>;

  @override
  bool get maintainState => _page.maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}

class _SheetRouteContainer extends StatefulWidget {
  const _SheetRouteContainer({Key? key, required this.sheetRoute})
      : super(key: key);

  final SheetRoute<dynamic> sheetRoute;
  @override
  __SheetRouteContainerState createState() => __SheetRouteContainerState();
}

class __SheetRouteContainerState extends State<_SheetRouteContainer>
    with TickerProviderStateMixin {
  SheetRoute<dynamic> get route => widget.sheetRoute;
  SheetController get _sheetController => widget.sheetRoute._sheetController;
  AnimationController get _routeController =>
      widget.sheetRoute._routeAnimationController!;
  @override
  void initState() {
    _routeController.addListener(onRouteAnimationUpdate);
    _sheetController.addListener(onSheetExtentUpdate);
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      _sheetController.relativeAnimateTo(
        route.initialExtent,
        duration: route.transitionDuration,
        curve: route.animationCurve ?? Curves.easeOut,
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    _routeController.addListener(onRouteAnimationUpdate);
    _sheetController.removeListener(onSheetExtentUpdate);
    super.dispose();
  }

  void onSheetExtentUpdate() {
    if (_routeController.value != _sheetController.animation.value) {
      if (route.isCurrent &&
          !_sheetController.position.preventingDrag &&
          route.shouldPreventPopForExtent(_sheetController.animation.value)) {
        preventPop();
        return;
      }
      if (!_routeController.isAnimating) {
        final double animationValue =
            _sheetController.animation.value.mapDistance(
          fromLow: 0,
          fromHigh: route.initialExtent,
          toLow: 0,
          toHigh: 1,
        );
        _routeController.value = animationValue;

        if (_sheetController.animation.value == 0) {
          widget.sheetRoute.navigator?.pop();
        }
      }
    }
  }

  bool _firstAnimation = true;
  void onRouteAnimationUpdate() {
    if (_routeController.isCompleted) {
      _firstAnimation = false;
    }
    if (!_routeController.isAnimating) {
      return;
    }
    if (!_firstAnimation &&
        _routeController.value != _sheetController.animation.value) {
      if (_routeController.status == AnimationStatus.forward) {
        final double animationValue = _routeController.value.mapDistance(
          fromLow: 0,
          fromHigh: 1,
          toLow: _sheetController.animation.value,
          toHigh: 1,
        );
        _sheetController.relativeJumpTo(animationValue);
      } else {
        final double animationValue = _routeController.value.mapDistance(
          fromLow: 0,
          fromHigh: 1,
          toLow: 0,
          toHigh: _sheetController.animation.value,
        );
        _sheetController.relativeJumpTo(animationValue);
      }
    }
  }

  /// Stop current sheet transition and call willPop to confirm/cancel the pop
  @protected
  void preventPop() {
    _sheetController.position.preventDrag();
    _sheetController.relativeAnimateTo(
      1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    route.willPop().then(
      (RoutePopDisposition disposition) {
        if (disposition == RoutePopDisposition.pop) {
          _sheetController.relativeAnimateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        } else {
          _sheetController.position.stopPreventingDrag();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final SheetRoute<dynamic> route = widget.sheetRoute;

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: route.sheetLabel,
      explicitChildNodes: true,
      child: route.buildSheet(
        context,
        Builder(builder: widget.sheetRoute.builder),
      ),
    );
  }
}

extension on double {
  /// Re-maps a number from one range to another.
  ///
  /// A value of fromLow would get mapped to toLow, a value of
  /// fromHigh to toHigh, values in-between to values in-between, etc
  double mapDistance({
    required double fromLow,
    required double fromHigh,
    required double toLow,
    required double toHigh,
  }) {
    final double offset = toLow;
    final double ratio = (toHigh - toLow) / (fromHigh - fromLow);
    return ratio * (this - fromLow) + offset;
  }
}
