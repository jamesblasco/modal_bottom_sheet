// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../sheet_route.dart';

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
    // TODO(jamesblasco): Implement landscape mode
    final double paddingTop = math.max(10, MediaQuery.of(context).padding.top);
    return CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: Builder(
        builder: (BuildContext context) => Padding(
          padding:
              EdgeInsets.only(top: _kPreviousRouteVisibleOffset + paddingTop),
          child: Container(
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
          ),
        ),
      ),
    );
  }
}

class CupertinoSheetRoute<T> extends SheetRoute<T>  {
  CupertinoSheetRoute({
    required WidgetBuilder builder,
    List<double>? stops,
    double initialStop = 1,
    RouteSettings? settings,
    Color? backgroundColor,
    bool maintainState = true,
  }) : super(
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
  bool get bounceAtTop => true;

  @override
  bool get draggable => true;

  @override
  bool get expanded => true;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

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
      parent: sheetController.animation,
      curve: Interval(initialExtent == 1 ? 0 : initialExtent, 1,
          curve: Curves.linear),
    );

    final Animation<double> secondaryAnimation = CurvedAnimation(
      parent: sheetController.animation,
      curve: Interval(0, initialExtent, curve: Curves.linear),
    );

    return _CupertinoSheetBottomRouteTransition(
      body: child,
      sheetAnimation: delayAnimation,
      secondaryAnimation: secondaryAnimation,
    );
  }
}

/// Animation for previous route when a [CupertinoSheetRoute] enters/exits
class _CupertinoSheetBottomRouteTransition extends StatelessWidget {
  const _CupertinoSheetBottomRouteTransition({
    Key? key,
    required this.sheetAnimation,
    required this.secondaryAnimation,
    required this.body,
  }) : super(key: key);

  final Widget body;

  final Animation<double> sheetAnimation;
  final Animation<double> secondaryAnimation;

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double topOffset = math.max(_kSheetMinimalOffset, topPadding);

    // Round corners for iPhone devices from X to the newest version
    final bool isRoundedDevice = defaultTargetPlatform == TargetPlatform.iOS &&
        topPadding > _kRoundedDeviceStatusBarHeight;
    final Radius deviceCorner =
        isRoundedDevice ? _kRoundedDeviceRadius : Radius.zero;

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
              // TODO(jamesblasco): Add ColorFilter based on CupertinoUserInterfaceLevelData
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
