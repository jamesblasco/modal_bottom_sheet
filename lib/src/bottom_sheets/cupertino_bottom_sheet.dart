// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../modal_bottom_sheet.dart';
import '../bottom_sheet_route.dart';

const double _behind_widget_visible_height = 10;

/// Cupertino Bottom Sheet Container
///
/// Clip the child widget to rectangle with top rounded corners and adds
/// top padding(+safe area padding). This padding [_behind_widget_visible_height]
/// is the height that will be displayed from previous route.
class _CupertinoBottomSheetContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const _CupertinoBottomSheetContainer(
      {Key key, this.child, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topSafeAreaPadding = MediaQuery.of(context).padding.top;
    final topPadding = _behind_widget_visible_height + topSafeAreaPadding;
    final radius = Radius.circular(12);
    final shadow =
        BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 5);
    final _backgroundColor =
        backgroundColor ?? CupertinoTheme.of(context).scaffoldBackgroundColor;
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
        child: Container(
          decoration:
              BoxDecoration(color: _backgroundColor, boxShadow: [shadow]),
          width: double.infinity,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true, //Remove top Safe Area
            child: child,
          ),
        ),
      ),
    );
  }
}

Future<T> showCupertinoModalBottomSheet<T>({
  @required BuildContext context,
  @required ScrollWidgetBuilder builder,
  Color backgroundColor,
  double elevation,
  ShapeBorder shape,
  Clip clipBehavior,
  Color barrierColor,
  bool expand = false,
  AnimationController secondAnimation,
  bool useRootNavigator = false,
  bool bounce = true,
  bool isDismissible,
  bool enableDrag = true,
}) async {
  assert(context != null);
  assert(builder != null);
  assert(expand != null);
  assert(useRootNavigator != null);
  assert(enableDrag != null);
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));
  final result = await Navigator.of(context, rootNavigator: useRootNavigator)
      .push(CupertinoModalBottomSheetRoute<T>(
    builder: builder,
    containerBuilder: (context, _, child) => _CupertinoBottomSheetContainer(
      child: child,
      backgroundColor: backgroundColor,
    ),
    secondAnimationController: secondAnimation,
    expanded: expand,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    elevation: elevation,
    bounce: bounce,
    shape: shape,
    clipBehavior: clipBehavior,
    isDismissible: isDismissible ?? expand == false ? true : false,
    modalBarrierColor: barrierColor ?? Colors.black12,
    enableDrag: enableDrag,
  ));
  return result;
}

class CupertinoModalBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  CupertinoModalBottomSheetRoute({
    ScrollWidgetBuilder builder,
    WidgetWithChildBuilder containerBuilder,
    String barrierLabel,
    double elevation,
    ShapeBorder shape,
    Clip clipBehavior,
    AnimationController secondAnimationController,
    Color modalBarrierColor,
    bool bounce = true,
    bool isDismissible = true,
    bool enableDrag = true,
    @required bool expanded,
    RouteSettings settings,
  })  : assert(expanded != null),
        assert(isDismissible != null),
        assert(enableDrag != null),
        super(
          containerBuilder: containerBuilder,
          builder: builder,
          bounce: bounce,
          barrierLabel: barrierLabel,
          secondAnimationController: secondAnimationController,
          modalBarrierColor: modalBarrierColor,
          isDismissible: isDismissible,
          enableDrag: enableDrag,
          expanded: expanded,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final paddingTop = MediaQuery.of(context).padding.top;
    final distanceWithScale =
        (paddingTop + _behind_widget_visible_height) * 0.9;
    final offsetY = secondaryAnimation.value * (paddingTop - distanceWithScale);
    final scale = 1 - secondaryAnimation.value / 10;
    return AnimatedBuilder(
      builder: (context, child) => Transform.translate(
        offset: Offset(0, offsetY),
        child: Transform.scale(
          scale: scale,
          child: child,
          alignment: Alignment.topCenter,
        ),
      ),
      child: child,
      animation: secondaryAnimation,
    );
  }

  @override
  Widget getPreviousRouteTransition(BuildContext context,
      Animation<double> secondaryAnimation, Widget child) {
    return _CupertinoModalTransition(
        secondaryAnimation: secondaryAnimation, body: child);
  }
}

class _CupertinoModalTransition extends StatelessWidget {
  final Animation<double> secondaryAnimation;

  final Widget body;

  const _CupertinoModalTransition(
      {Key key, @required this.secondaryAnimation, @required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double startRoundCorner = 0;
    final paddingTop = MediaQuery.of(context).padding.top;
    if (defaultTargetPlatform == TargetPlatform.iOS && paddingTop > 20) {
      startRoundCorner = 38.5;
      //https://kylebashour.com/posts/finding-the-real-iphone-x-corner-radius
    }

    final curvedAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOut,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: AnimatedBuilder(
          animation: curvedAnimation,
          child: body,
          builder: (context, child) {
            Widget result = child;

            final progress = curvedAnimation.value;
            final yOffset = progress * paddingTop;
            final scale = 1 - progress / 10;
            final radius = progress == 0
                ? 0.0
                : (1 - progress) * startRoundCorner + progress * 12;
            return Stack(
              children: <Widget>[
                Container(color: Colors.black),
                Transform.translate(
                  offset: Offset(0, yOffset),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(radius),
                        child: result),
                  ),
                )
              ],
            );
          },
        ));
  }
}

class _CupertinoScaffold extends InheritedWidget {
  final AnimationController animation;

  final Widget child;

  const _CupertinoScaffold({Key key, this.animation, this.child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}

// Support
class CupertinoScaffold extends StatefulWidget {
  static _CupertinoScaffold of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_CupertinoScaffold>();

  final Widget body;

  const CupertinoScaffold({Key key, this.body}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CupertinoScaffoldState();

  static Future<T> showCupertinoModalBottomSheet<T>({
    @required BuildContext context,
    @required ScrollWidgetBuilder builder,
    Color backgroundColor,
    Color barrierColor,
    bool expand = false,
    bool useRootNavigator = false,
    bool bounce = true,
    bool isDismissible,
    bool enableDrag = true,
  }) async {
    assert(context != null);
    assert(builder != null);
    assert(expand != null);
    assert(useRootNavigator != null);
    assert(enableDrag != null);
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final result = await Navigator.of(context, rootNavigator: useRootNavigator)
        .push(CupertinoModalBottomSheetRoute<T>(
      builder: builder,
      secondAnimationController: CupertinoScaffold.of(context).animation,
      containerBuilder: (context, _, child) => _CupertinoBottomSheetContainer(
        child: child,
        backgroundColor: backgroundColor,
      ),
      expanded: expand,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      bounce: bounce,
      isDismissible: isDismissible ?? expand == false ? true : false,
      modalBarrierColor: barrierColor ?? Colors.black12,
      enableDrag: enableDrag,
    ));
    return result;
  }
}

class _CupertinoScaffoldState extends State<CupertinoScaffold>
    with TickerProviderStateMixin {
  AnimationController animationController;

  SystemUiOverlayStyle lastStyle;

  @override
  void initState() {
    animationController =
        AnimationController(duration: Duration(milliseconds: 350), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CupertinoScaffold(
      animation: animationController,
      child: _CupertinoModalTransition(
        secondaryAnimation: animationController,
        body: widget.body,
      ),
    );
  }
}
