// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheet/route.dart';
import 'package:sheet/sheet.dart';

/// Value extracted from the official sketch iOS UI kit
/// It is the top offset that will be displayed from the bottom route
const double _kPreviousRouteVisibleOffset = 10.0;

/// Value extracted from the official sketch iOS UI kit
const Radius _kCupertinoSheetTopRadius = Radius.circular(10.0);

/// Estimated Round corners for iPhone X, XR, 11, 11 Pro
/// https://kylebashour.com/posts/finding-the-real-iphone-x-corner-radius
/// It used to animate the bottom route with a top radius that matches
/// the frame radius. If the device doesn't have round corners it will use
/// Radius.zero
const Radius _kRoundedDeviceRadius = Radius.circular(38.5);

/// Minimal distance from the top of the screen to the top of the previous route
/// It will be used ff the top safearea is less than this value.
/// In iPhones the top SafeArea is more or equal to this distance.
const double _kSheetMinimalOffset = 10;

/// Value extracted from the official sketch iOS UI kit for iPhone X, XR, 11, 11 Pro
/// The status bar height is bigger for devices with rounded corners, this is
/// used to detect if an iPhone has round corners or not
const double _kRoundedDeviceStatusBarHeight = 20;

const Curve _kCupertinoSheetCurve = Curves.easeOutExpo;
const Curve _kCupertinoTransitionCurve = Curves.linear;

/// Wraps the child into a cupertino modal sheet appareance. This is used to
/// create a [SheetRoute].
///
/// Clip the child widget to rectangle with top rounded corners and adds
/// top padding and top safe area.
class _CupertinoSheetDecorationBuilder extends StatelessWidget {
  const _CupertinoSheetDecorationBuilder({
    Key? key,
    required this.child,
    required this.topRadius,
    this.backgroundColor,
  }) : super(key: key);

  /// The child contained by the modal sheet
  final Widget child;

  /// The color to paint behind the child
  final Color? backgroundColor;

  /// The top corners of this modal sheet are rounded by this Radius
  final Radius topRadius;

  @override
  Widget build(BuildContext context) {
    return CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: Builder(
        builder: (BuildContext context) {
          return Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: topRadius),
              color: backgroundColor ??
                  CupertinoColors.systemBackground.resolveFrom(context),
            ),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// A modal route that overlays a widget over the current route and animates
/// it from the bottom with a cupertino modal sheet appareance
///
/// Clip the child widget to rectangle with top rounded corners and adds
/// top padding and top safe area.
///
/// * [CupertinoSheetPage], which is the [Page] version of this class
class CupertinoSheetRoute<T> extends SheetRoute<T> {
  CupertinoSheetRoute(
      {required WidgetBuilder builder,
      List<double>? stops,
      double initialStop = 1,
      RouteSettings? settings,
      Color? backgroundColor,
      bool maintainState = true,
      super.fit})
      : super(
          builder: (BuildContext context) {
            return _CupertinoSheetDecorationBuilder(
              child: Builder(builder: builder),
              backgroundColor: backgroundColor,
              topRadius: _kCupertinoSheetTopRadius,
            );
          },
          settings: settings,
          animationCurve: _kCupertinoSheetCurve,
          stops: stops,
          initialExtent: initialStop,
          maintainState: maintainState,
        );

  @override
  bool get draggable => true;

  final SheetController _sheetController = SheetController();

  @override
  SheetController createSheetController() {
    return _sheetController;
  }

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  Widget buildSheet(BuildContext context, Widget child) {
    SheetPhysics? effectivePhysics = BouncingSheetPhysics(
        parent: SnapSheetPhysics(
      stops: stops ?? <double>[0, 1],
      parent: physics,
    ));
    if (!draggable) {
      effectivePhysics = const NeverDraggableSheetPhysics();
    }
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double topMargin =
        math.max(_kSheetMinimalOffset, mediaQuery.padding.top) +
            _kPreviousRouteVisibleOffset;
    return Sheet.raw(
      initialExtent: initialExtent,
      decorationBuilder: decorationBuilder,
      fit: fit,
      maxExtent: mediaQuery.size.height - topMargin,
      physics: effectivePhysics,
      controller: sheetController,
      child: child,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double topOffset = math.max(_kSheetMinimalOffset, topPadding);
    return AnimatedBuilder(
      animation: secondaryAnimation,
      child: CupertinoUserInterfaceLevel(
        data: CupertinoUserInterfaceLevelData.elevated,
        child: child,
      ),
      builder: (BuildContext context, Widget? child) {
        final double progress = secondaryAnimation.value;
        final double scale = 1 - progress / 10;
        final double distanceWithScale =
            (topOffset + _kPreviousRouteVisibleOffset) * 0.9;
        final Offset offset =
            Offset(0, progress * (topOffset - distanceWithScale));
        return Transform.translate(
          offset: offset,
          child: Transform.scale(
            scale: scale,
            child: child,
            alignment: Alignment.topCenter,
          ),
        );
      },
    );
  }

  @override
  bool canDriveSecondaryTransitionForPreviousRoute(
      Route<dynamic> previousRoute) {
    return previousRoute is! CupertinoSheetRoute;
  }

  @override
  Widget buildSecondaryTransitionForPreviousRoute(BuildContext context,
      Animation<double> secondaryAnimation, Widget child) {
    final Animation<double> delayAnimation = CurvedAnimation(
      parent: _sheetController.animation,
      curve: Interval(
        initialExtent == 1 ? 0 : initialExtent,
        1,
        curve: Curves.linear,
      ),
    );

    final Animation<double> secondaryAnimation = CurvedAnimation(
      parent: _sheetController.animation,
      curve: Interval(0, initialExtent, curve: Curves.linear),
    );

    return CupertinoSheetBottomRouteTransition(
      body: child,
      sheetAnimation: delayAnimation,
      secondaryAnimation: secondaryAnimation,
    );
  }
}

/// Animation for previous route when a [CupertinoSheetRoute] enters/exits
@visibleForTesting
class CupertinoSheetBottomRouteTransition extends StatelessWidget {
  const CupertinoSheetBottomRouteTransition({
    Key? key,
    required this.sheetAnimation,
    required this.secondaryAnimation,
    required this.body,
  }) : super(key: key);

  final Widget body;

  final Animation<double> sheetAnimation;
  final Animation<double> secondaryAnimation;

  // Currently iOS does not provide any way to detect the radius of the
  // screen device. Right not we detect if the safe area has the size
  // for the device that contain a notch as they are the ones rigth
  // now that has corners with radius
  Radius _getRadiusForDevice(MediaQueryData mediaQuery) {
    final double topPadding = mediaQuery.padding.top;
    // Round corners for iPhone devices from X to the newest version
    final bool isRoundedDevice = defaultTargetPlatform == TargetPlatform.iOS &&
        topPadding > _kRoundedDeviceStatusBarHeight;
    return isRoundedDevice ? _kRoundedDeviceRadius : Radius.zero;
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double topOffset = math.max(_kSheetMinimalOffset, topPadding);
    final Radius deviceCorner = _getRadiusForDevice(MediaQuery.of(context));

    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: sheetAnimation,
      curve: _kCupertinoTransitionCurve,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: AnimatedBuilder(
        animation: secondaryAnimation,
        child: body,
        builder: (BuildContext context, Widget? child) {
          final double progress = curvedAnimation.value;
          final double scale = 1 - progress / 10;
          final Radius radius = progress == 0
              ? Radius.zero
              : Radius.lerp(deviceCorner, _kCupertinoSheetTopRadius, progress)!;
          return Stack(
            children: <Widget>[
              Container(color: CupertinoColors.black),
              // TODO(jaime): Add ColorFilter based on CupertinoUserInterfaceLevelData
              // https://github.com/jamesblasco/modal_bottom_sheet/pull/44/files
              Transform.translate(
                offset: Offset(0, progress * topOffset),
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topCenter,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: radius),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        (CupertinoTheme.brightnessOf(context) == Brightness.dark
                                ? CupertinoColors.inactiveGray
                                : Colors.black)
                            .withOpacity(secondaryAnimation.value * 0.1),
                        BlendMode.srcOver,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A modal page that overlays a widget over the current route and animates
/// it from the bottom with a cupertino modal sheet appareance
///
/// Clip the child widget to rectangle with top rounded corners and adds
/// top padding and top safe area.
///
/// The type `T` specifies the return type of the route which can be supplied as
/// the route is popped from the stack via [Navigator.pop] by providing the
/// optional `result` argument.
///
/// See also:
///
///
///  * [CupertinoSheetRoute], which is the [PageRoute] version of this class
class CupertinoSheetPage<T> extends Page<T> {
  /// Creates a material page.
  const CupertinoSheetPage({
    required this.child,
    this.maintainState = true,
    LocalKey? key,
    String? name,
    Object? arguments,
  }) : super(key: key, name: name, arguments: arguments);

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.modalRoute.maintainState}
  final bool maintainState;

  @override
  Route<T> createRoute(BuildContext context) {
    return _PageBasedCupertinoSheetRoute<T>(page: this);
  }
}

// A page-based version of SheetRoute.
//
// This route uses the builder from the page to build its content. This ensures
// the content is up to date after page updates.
class _PageBasedCupertinoSheetRoute<T> extends CupertinoSheetRoute<T> {
  _PageBasedCupertinoSheetRoute({
    required CupertinoSheetPage<T> page,
    List<double>? stops,
    double initialStop = 1,
    Color? backgroundColor,
    bool maintainState = true,
  }) : super(
          settings: page,
          builder: (BuildContext context) => page.child,
          initialStop: initialStop,
          backgroundColor: backgroundColor,
          stops: stops,
          maintainState: maintainState,
        );

  CupertinoSheetPage<T> get _page => settings as CupertinoSheetPage<T>;

  @override
  bool get maintainState => _page.maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}
