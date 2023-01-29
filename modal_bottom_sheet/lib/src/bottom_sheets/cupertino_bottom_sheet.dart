// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart'
    show
        CupertinoApp,
        CupertinoColors,
        CupertinoDynamicColor,
        CupertinoTheme,
        CupertinoThemeData,
        CupertinoUserInterfaceLevel,
        CupertinoUserInterfaceLevelData;
import 'package:flutter/material.dart'
    show
        Colors,
        MaterialLocalizations,
        Theme,
        debugCheckHasMaterialLocalizations;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../modal_bottom_sheet.dart';

const double _kPreviousPageVisibleOffset = 10;

const Radius _kDefaultTopRadius = Radius.circular(12);
const BoxShadow _kDefaultBoxShadow =
    BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 5);

/// Cupertino Bottom Sheet Container
///
/// Clip the child widget to rectangle with top rounded corners and adds
/// top padding(+safe area padding). This padding [_kPreviousPageVisibleOffset]
/// is the height that will be displayed from previous route.
class _CupertinoBottomSheetContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Radius topRadius;
  final BoxShadow? shadow;
  final bool? expand;

  const _CupertinoBottomSheetContainer({
    Key? key,
    required this.child,
    this.backgroundColor,
    required this.topRadius,
    this.shadow,
    this.expand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topSafeAreaPadding = MediaQuery.of(context).padding.top;
    final topPadding = _kPreviousPageVisibleOffset + topSafeAreaPadding;

    final shadow = this.shadow ?? _kDefaultBoxShadow;
    BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 5);
    final backgroundColor = this.backgroundColor ??
        CupertinoTheme.of(context).scaffoldBackgroundColor;
    return Padding(
      padding: EdgeInsets.only(top: expand ?? false ? 0.0 : topPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: topRadius),
        child: Container(
          decoration:
              BoxDecoration(color: backgroundColor, boxShadow: [shadow]),
          width: double.infinity,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true, //Remove top Safe Area
            child: CupertinoUserInterfaceLevel(
              data: CupertinoUserInterfaceLevelData.elevated,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> showCupertinoModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  Color? barrierColor,
  bool expand = false,
  AnimationController? secondAnimation,
  Curve? animationCurve,
  Curve? previousRouteAnimationCurve,
  bool useRootNavigator = false,
  bool bounce = true,
  bool? isDismissible,
  bool enableDrag = true,
  Radius topRadius = _kDefaultTopRadius,
  Duration? duration,
  RouteSettings? settings,
  Color? transitionBackgroundColor,
  BoxShadow? shadow,
  SystemUiOverlayStyle? overlayStyle,
  double? closeProgressThreshold,
}) async {
  assert(debugCheckHasMediaQuery(context));
  final hasMaterialLocalizations =
      Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) !=
          null;
  final barrierLabel = hasMaterialLocalizations
      ? MaterialLocalizations.of(context).modalBarrierDismissLabel
      : '';

  final result =
      await Navigator.of(context, rootNavigator: useRootNavigator).push(
    CupertinoModalBottomSheetRoute<T>(
        builder: builder,
        containerBuilder: (context, _, child) => _CupertinoBottomSheetContainer(
              child: child,
              backgroundColor: backgroundColor,
              topRadius: topRadius,
              shadow: shadow,
              expand: expand,
            ),
        secondAnimationController: secondAnimation,
        expanded: expand,
        closeProgressThreshold: closeProgressThreshold,
        barrierLabel: barrierLabel,
        elevation: elevation,
        bounce: bounce,
        shape: shape,
        clipBehavior: clipBehavior,
        isDismissible: isDismissible ?? expand == false ? true : false,
        modalBarrierColor: barrierColor ?? Colors.black12,
        enableDrag: enableDrag,
        topRadius: topRadius,
        animationCurve: animationCurve,
        previousRouteAnimationCurve: previousRouteAnimationCurve,
        duration: duration,
        settings: settings,
        transitionBackgroundColor: transitionBackgroundColor ?? Colors.black,
        overlayStyle: overlayStyle),
  );
  return result;
}

class CupertinoModalBottomSheetRoute<T> extends ModalSheetRoute<T> {
  final Radius topRadius;

  final Curve? previousRouteAnimationCurve;

  final BoxShadow? boxShadow;

  // Background color behind all routes
  // Black by default
  final Color? transitionBackgroundColor;
  final SystemUiOverlayStyle? overlayStyle;

  CupertinoModalBottomSheetRoute({
    required WidgetBuilder builder,
    WidgetWithChildBuilder? containerBuilder,
    double? closeProgressThreshold,
    String? barrierLabel,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    AnimationController? secondAnimationController,
    Curve? animationCurve,
    Color? modalBarrierColor,
    bool bounce = true,
    bool isDismissible = true,
    bool enableDrag = true,
    required bool expanded,
    Duration? duration,
    RouteSettings? settings,
    ScrollController? scrollController,
    this.boxShadow = _kDefaultBoxShadow,
    this.transitionBackgroundColor,
    this.topRadius = _kDefaultTopRadius,
    this.previousRouteAnimationCurve,
    this.overlayStyle,
  }) : super(
          closeProgressThreshold: closeProgressThreshold,
          scrollController: scrollController,
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
          animationCurve: animationCurve,
          duration: duration,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final paddingTop = MediaQuery.of(context).padding.top;
    final distanceWithScale = (paddingTop + _kPreviousPageVisibleOffset) * 0.9;
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
  Widget getPreviousRouteTransition(
      BuildContext context, Animation<double> secondAnimation, Widget child) {
    return _CupertinoModalTransition(
      secondaryAnimation: secondAnimation,
      body: child,
      animationCurve: previousRouteAnimationCurve,
      topRadius: topRadius,
      backgroundColor: transitionBackgroundColor ?? Colors.black,
      overlayStyle: overlayStyle,
    );
  }
}

class _CupertinoModalTransition extends StatelessWidget {
  final Animation<double> secondaryAnimation;
  final Radius topRadius;
  final Curve? animationCurve;
  final Color backgroundColor;
  final SystemUiOverlayStyle? overlayStyle;

  final Widget body;

  const _CupertinoModalTransition({
    Key? key,
    required this.secondaryAnimation,
    required this.body,
    required this.topRadius,
    this.backgroundColor = Colors.black,
    this.animationCurve,
    this.overlayStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var startRoundCorner = 0.0;
    final paddingTop = MediaQuery.of(context).padding.top;
    if (Theme.of(context).platform == TargetPlatform.iOS && paddingTop > 20) {
      startRoundCorner = 38.5;
      //https://kylebashour.com/posts/finding-the-real-iphone-x-corner-radius
    }

    final curvedAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: animationCurve ?? Curves.easeOut,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle ?? SystemUiOverlayStyle.light,
      child: AnimatedBuilder(
        animation: curvedAnimation,
        child: body,
        builder: (context, child) {
          final progress = curvedAnimation.value;
          final yOffset = progress * paddingTop;
          final scale = 1 - progress / 10;
          final radius = progress == 0
              ? 0.0
              : (1 - progress) * startRoundCorner + progress * topRadius.x;
          return Stack(
            children: <Widget>[
              Container(color: backgroundColor),
              Transform.translate(
                offset: Offset(0, yOffset),
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topCenter,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: CupertinoUserInterfaceLevel(
                      data: CupertinoUserInterfaceLevelData.elevated,
                      child: Builder(
                        builder: (context) => CupertinoTheme(
                          data: createPreviousRouteTheme(
                            context,
                            curvedAnimation,
                          ),
                          child: CupertinoUserInterfaceLevel(
                            data: CupertinoUserInterfaceLevelData.base,
                            child: child!,
                          ),
                        ),
                      ),
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

  CupertinoThemeData createPreviousRouteTheme(
    BuildContext context,
    Animation<double> animation,
  ) {
    final cTheme = CupertinoTheme.of(context);

    final systemBackground = CupertinoDynamicColor.resolve(
      cTheme.scaffoldBackgroundColor,
      context,
    );

    final barBackgroundColor = CupertinoDynamicColor.resolve(
      cTheme.barBackgroundColor,
      context,
    );

    var previousRouteTheme = cTheme;

    if (cTheme.scaffoldBackgroundColor is CupertinoDynamicColor) {
      final dynamicScaffoldBackgroundColor =
          cTheme.scaffoldBackgroundColor as CupertinoDynamicColor;

      /// BackgroundColor for the previous route with forced using
      /// of the elevated colors
      final elevatedScaffoldBackgroundColor =
          CupertinoDynamicColor.withBrightnessAndContrast(
        color: dynamicScaffoldBackgroundColor.elevatedColor,
        darkColor: dynamicScaffoldBackgroundColor.darkElevatedColor,
        highContrastColor:
            dynamicScaffoldBackgroundColor.highContrastElevatedColor,
        darkHighContrastColor:
            dynamicScaffoldBackgroundColor.darkHighContrastElevatedColor,
      );

      previousRouteTheme = previousRouteTheme.copyWith(
        scaffoldBackgroundColor: ColorTween(
          begin: systemBackground,
          end: elevatedScaffoldBackgroundColor.resolveFrom(context),
        ).evaluate(animation),
        primaryColor: CupertinoColors.placeholderText.resolveFrom(context),
      );
    }

    if (cTheme.barBackgroundColor is CupertinoDynamicColor) {
      final dynamicBarBackgroundColor =
          cTheme.barBackgroundColor as CupertinoDynamicColor;

      /// NavigationBarColor for the previous route with forced using
      /// of the elevated colors
      final elevatedBarBackgroundColor =
          CupertinoDynamicColor.withBrightnessAndContrast(
        color: dynamicBarBackgroundColor.elevatedColor,
        darkColor: dynamicBarBackgroundColor.darkElevatedColor,
        highContrastColor: dynamicBarBackgroundColor.highContrastElevatedColor,
        darkHighContrastColor:
            dynamicBarBackgroundColor.darkHighContrastElevatedColor,
      );

      previousRouteTheme = previousRouteTheme.copyWith(
        barBackgroundColor: ColorTween(
          begin: barBackgroundColor,
          end: elevatedBarBackgroundColor.resolveFrom(context),
        ).evaluate(animation),
        primaryColor: CupertinoColors.placeholderText.resolveFrom(context),
      );
    }

    return previousRouteTheme;
  }
}

class CupertinoScaffoldInheirted extends InheritedWidget {
  final AnimationController? animation;

  final Radius? topRadius;

  const CupertinoScaffoldInheirted({
    this.animation,
    required super.child,
    this.topRadius,
  }) : super();

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}

// Support
class CupertinoScaffold extends StatefulWidget {
  static CupertinoScaffoldInheirted? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CupertinoScaffoldInheirted>();

  final Widget body;
  final Radius topRadius;
  final Color transitionBackgroundColor;
  final SystemUiOverlayStyle? overlayStyle;

  const CupertinoScaffold({
    Key? key,
    required this.body,
    this.topRadius = _kDefaultTopRadius,
    this.transitionBackgroundColor = Colors.black,
    this.overlayStyle,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CupertinoScaffoldState();

  static Future<T?> showCupertinoModalBottomSheet<T>({
    required BuildContext context,
    double? closeProgressThreshold,
    required WidgetBuilder builder,
    Curve? animationCurve,
    Curve? previousRouteAnimationCurve,
    Color? backgroundColor,
    Color? barrierColor,
    bool expand = false,
    bool useRootNavigator = false,
    bool bounce = true,
    bool? isDismissible,
    bool enableDrag = true,
    Duration? duration,
    RouteSettings? settings,
    BoxShadow? shadow,
    SystemUiOverlayStyle? overlayStyle,
  }) async {
    assert(debugCheckHasMediaQuery(context));
    final isCupertinoApp =
        context.findAncestorWidgetOfExactType<CupertinoApp>() != null;
    var barrierLabel = '';
    if (!isCupertinoApp) {
      assert(debugCheckHasMaterialLocalizations(context));
      barrierLabel = MaterialLocalizations.of(context).modalBarrierDismissLabel;
    }
    final topRadius = CupertinoScaffold.of(context)!.topRadius;
    final result = await Navigator.of(context, rootNavigator: useRootNavigator)
        .push(CupertinoModalBottomSheetRoute<T>(
      closeProgressThreshold: closeProgressThreshold,
      builder: builder,
      secondAnimationController: CupertinoScaffold.of(context)!.animation,
      containerBuilder: (context, _, child) => _CupertinoBottomSheetContainer(
        child: child,
        backgroundColor: backgroundColor,
        topRadius: topRadius ?? _kDefaultTopRadius,
        shadow: shadow,
        expand: expand,
      ),
      expanded: expand,
      barrierLabel: barrierLabel,
      bounce: bounce,
      isDismissible: isDismissible ?? expand == false ? true : false,
      modalBarrierColor: barrierColor ?? Colors.black12,
      enableDrag: enableDrag,
      topRadius: topRadius ?? _kDefaultTopRadius,
      animationCurve: animationCurve,
      previousRouteAnimationCurve: previousRouteAnimationCurve,
      duration: duration,
      settings: settings,
      overlayStyle: overlayStyle,
    ));
    return result;
  }
}

class _CupertinoScaffoldState extends State<CupertinoScaffold>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController =
        AnimationController(duration: Duration(milliseconds: 350), vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoScaffoldInheirted(
      animation: animationController,
      topRadius: widget.topRadius,
      child: _CupertinoModalTransition(
        secondaryAnimation: animationController,
        body: widget.body,
        topRadius: widget.topRadius,
        backgroundColor: widget.transitionBackgroundColor,
        overlayStyle: widget.overlayStyle,
      ),
    );
  }
}
