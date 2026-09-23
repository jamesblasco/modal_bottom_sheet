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
        ThemeData,
        debugCheckHasMaterialLocalizations;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../modal_bottom_sheet.dart';

const double _kPreviousPageVisibleOffset = 10;

const Radius _kDefaultTopRadius = Radius.circular(12);
const BoxShadow _kDefaultBoxShadow =
    BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 5);

SystemUiOverlayStyle overlayStyleFromColor(Color color) {
  final brightness = ThemeData.estimateBrightnessForColor(color);
  return brightness == Brightness.dark
      ? SystemUiOverlayStyle.light
      : SystemUiOverlayStyle.dark;
}

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
  final SystemUiOverlayStyle? overlayStyle;

  const _CupertinoBottomSheetContainer({
    required this.child,
    this.backgroundColor,
    required this.topRadius,
    this.overlayStyle,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final scopedOverlayStyle = overlayStyle;
    final topSafeAreaPadding = MediaQuery.paddingOf(context).top;
    final topPadding = _kPreviousPageVisibleOffset + topSafeAreaPadding;

    final shadow = this.shadow ?? _kDefaultBoxShadow;
    final backgroundColor = this.backgroundColor ??
        CupertinoTheme.of(context).scaffoldBackgroundColor;
    Widget bottomSheetContainer = Padding(
      padding: EdgeInsets.only(top: topPadding),
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
    if (scopedOverlayStyle != null) {
      bottomSheetContainer = AnnotatedRegion<SystemUiOverlayStyle>(
        value: scopedOverlayStyle,
        child: bottomSheetContainer,
      );
    }
    return bottomSheetContainer;
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
              overlayStyle: overlayStyle,
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
  @Deprecated(
    'Will be ignored. OverlayStyle is computed from luminance of transitionBackgroundColor',
  )
  final SystemUiOverlayStyle? overlayStyle;

  CupertinoModalBottomSheetRoute({
    required super.builder,
    super.containerBuilder,
    super.closeProgressThreshold,
    super.barrierLabel,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    super.secondAnimationController,
    super.animationCurve,
    super.modalBarrierColor,
    super.bounce = true,
    super.isDismissible,
    super.enableDrag,
    required super.expanded,
    super.duration,
    super.settings,
    super.scrollController,
    this.boxShadow = _kDefaultBoxShadow,
    this.transitionBackgroundColor,
    this.topRadius = _kDefaultTopRadius,
    this.previousRouteAnimationCurve,
    this.overlayStyle,
  });

  // ModalRoute.animation jumps to 1 during Hero's offstage layout pass.
  // The visible background must follow the real transition instead.
  Animation<double>? get _backgroundAnimation => controller?.view;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final paddingTop = MediaQuery.paddingOf(context).top;
    final distanceWithScale = (paddingTop + _kPreviousPageVisibleOffset) * 0.9;
    return _CupertinoSheetTransform(
      animation: secondaryAnimation,
      verticalOffset: paddingTop - distanceWithScale,
      child: child,
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
    );
  }
}

class _CupertinoModalTransition extends StatelessWidget {
  final Animation<double> secondaryAnimation;
  final Radius topRadius;
  final Curve? animationCurve;
  final Color backgroundColor;

  final Widget body;

  const _CupertinoModalTransition({
    required this.secondaryAnimation,
    required this.body,
    required this.topRadius,
    this.backgroundColor = Colors.black,
    this.animationCurve,
  });

  @override
  Widget build(BuildContext context) {
    var startRoundCorner = 0.0;
    final paddingTop = MediaQuery.paddingOf(context).top;
    if (Theme.of(context).platform == TargetPlatform.iOS && paddingTop > 20) {
      startRoundCorner = 38.5;
      //https://kylebashour.com/posts/finding-the-real-iphone-x-corner-radius
    }

    final curvedAnimation = secondaryAnimation.drive(
      CurveTween(curve: animationCurve ?? Curves.easeOut),
    );

    return AnnotatedRegion(
      // Make sure to match the system UI overlay style to the background color
      // we insert below. Since all other content is pushed down, the background
      // color will always be the one visible behind the status bar.
      value: overlayStyleFromColor(backgroundColor),
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: backgroundColor)),
          _CupertinoSheetTransform(
            animation: curvedAnimation,
            verticalOffset: paddingTop,
            child: ClipRRect(
              clipper: _CupertinoSheetClipper(
                animation: curvedAnimation,
                startRadius: startRoundCorner,
                endRadius: topRadius.x,
              ),
              child: CupertinoUserInterfaceLevel(
                data: CupertinoUserInterfaceLevelData.elevated,
                child: _CupertinoPreviousRouteTheme(
                  animation: curvedAnimation,
                  child: CupertinoUserInterfaceLevel(
                    data: CupertinoUserInterfaceLevelData.base,
                    child: RepaintBoundary(child: body),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CupertinoPreviousRouteTheme extends StatefulWidget {
  const _CupertinoPreviousRouteTheme({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  State<_CupertinoPreviousRouteTheme> createState() =>
      _CupertinoPreviousRouteThemeState();
}

class _CupertinoPreviousRouteThemeState
    extends State<_CupertinoPreviousRouteTheme> {
  late CupertinoThemeData _startTheme;
  late CupertinoThemeData _endTheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startTheme = createPreviousRouteTheme(context, kAlwaysDismissedAnimation);
    _endTheme = createPreviousRouteTheme(context, kAlwaysCompleteAnimation);
  }

  @override
  Widget build(BuildContext context) {
    if (_startTheme.scaffoldBackgroundColor ==
            _endTheme.scaffoldBackgroundColor &&
        _startTheme.barBackgroundColor == _endTheme.barBackgroundColor) {
      return CupertinoTheme(data: _startTheme, child: widget.child);
    }
    return AnimatedBuilder(
      animation: widget.animation,
      child: widget.child,
      builder: (context, child) => CupertinoTheme(
        data: createPreviousRouteTheme(context, widget.animation),
        child: child!,
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
  final Color transitionBackgroundColor;

  const CupertinoScaffoldInheirted({
    this.animation,
    required super.child,
    this.topRadius,
    required this.transitionBackgroundColor,
  });

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
    super.key,
    required this.body,
    this.topRadius = _kDefaultTopRadius,
    this.transitionBackgroundColor = Colors.black,
    this.overlayStyle,
  });

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
    @Deprecated(
      'Will be ignored. OverlayStyle is computed from luminance of transitionBackgroundColor',
    )
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
    final scaffold = CupertinoScaffold.of(context)!;
    final scaffoldState =
        context.findAncestorStateOfType<_CupertinoScaffoldState>();
    final topRadius = scaffold.topRadius;
    final transitionBackgroundColor = scaffold.transitionBackgroundColor;
    final overlayStyle = overlayStyleFromColor(transitionBackgroundColor);
    final route = CupertinoModalBottomSheetRoute<T>(
      closeProgressThreshold: closeProgressThreshold,
      builder: builder,
      secondAnimationController:
          scaffoldState == null ? scaffold.animation : null,
      containerBuilder: (context, _, child) => _CupertinoBottomSheetContainer(
        child: child,
        backgroundColor: backgroundColor,
        topRadius: topRadius ?? _kDefaultTopRadius,
        shadow: shadow,
        overlayStyle: overlayStyle,
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
    );
    final result =
        Navigator.of(context, rootNavigator: useRootNavigator).push<T>(route);
    scaffoldState?._trackRoute(route);
    return result;
  }
}

class _CupertinoScaffoldState extends State<CupertinoScaffold>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  final Set<Animation<double>> _routeAnimations = {};

  void _trackRoute(CupertinoModalBottomSheetRoute<dynamic> route) {
    final animation = route._backgroundAnimation!;
    _routeAnimations.add(animation);
    animation.addListener(_updateProgress);
    _updateProgress();
    route.completed.then((_) {
      if (!_routeAnimations.remove(animation)) return;
      animation.removeListener(_updateProgress);
      _updateProgress();
    });
  }

  void _updateProgress() {
    var progress = 0.0;
    for (final animation in _routeAnimations) {
      if (animation.value > progress) progress = animation.value;
    }
    if (animationController.value != progress) {
      animationController.value = progress;
    }
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: Duration(milliseconds: 350), vsync: this);
  }

  @override
  void dispose() {
    for (final animation in _routeAnimations) {
      animation.removeListener(_updateProgress);
    }
    _routeAnimations.clear();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoScaffoldInheirted(
      animation: animationController,
      topRadius: widget.topRadius,
      transitionBackgroundColor: widget.transitionBackgroundColor,
      child: _CupertinoModalTransition(
        secondaryAnimation: animationController,
        body: widget.body,
        topRadius: widget.topRadius,
        backgroundColor: widget.transitionBackgroundColor,
      ),
    );
  }
}

class _CupertinoSheetTransform extends SingleChildRenderObjectWidget {
  const _CupertinoSheetTransform({
    required this.animation,
    required this.verticalOffset,
    required super.child,
  });

  final Animation<double> animation;
  final double verticalOffset;

  @override
  _RenderCupertinoSheetTransform createRenderObject(BuildContext context) =>
      _RenderCupertinoSheetTransform(animation, verticalOffset);

  @override
  void updateRenderObject(
      BuildContext context, _RenderCupertinoSheetTransform renderObject) {
    renderObject.update(animation, verticalOffset);
  }
}

// Keep transition ticks in the paint phase; RenderTransform also handles hit
// testing and accessibility coordinates using the same matrix.
class _RenderCupertinoSheetTransform extends RenderTransform {
  _RenderCupertinoSheetTransform(this._animation, this._verticalOffset)
      : super(transform: Matrix4.identity(), alignment: Alignment.topCenter) {
    _updateTransform();
  }

  Animation<double> _animation;
  double _verticalOffset;

  void update(Animation<double> animation, double verticalOffset) {
    if (_animation != animation) {
      if (attached) _animation.removeListener(_updateTransform);
      _animation = animation;
      if (attached) _animation.addListener(_updateTransform);
    }
    _verticalOffset = verticalOffset;
    _updateTransform();
  }

  void _updateTransform() {
    final progress = _animation.value;
    final scale = 1 - progress / 10;
    transform = Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(0, progress * _verticalOffset, 0);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(_updateTransform);
    _updateTransform();
  }

  @override
  void detach() {
    _animation.removeListener(_updateTransform);
    super.detach();
  }
}

class _CupertinoSheetClipper extends CustomClipper<RRect> {
  _CupertinoSheetClipper({
    required this.animation,
    required this.startRadius,
    required this.endRadius,
  }) : super(reclip: animation);

  final Animation<double> animation;
  final double startRadius;
  final double endRadius;

  @override
  RRect getClip(Size size) {
    final progress = animation.value;
    final radius = progress == 0
        ? 0.0
        : (1 - progress) * startRadius + progress * endRadius;
    return RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
  }

  @override
  bool shouldReclip(_CupertinoSheetClipper oldClipper) =>
      animation != oldClipper.animation ||
      startRadius != oldClipper.startRadius ||
      endRadius != oldClipper.endRadius;
}
