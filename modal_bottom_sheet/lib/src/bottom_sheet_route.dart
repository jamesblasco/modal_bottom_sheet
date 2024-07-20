import 'dart:async';

import 'package:flutter/material.dart';

import '../modal_bottom_sheet.dart';

const Duration _bottomSheetDuration = Duration(milliseconds: 400);

class _ModalBottomSheet<T> extends StatefulWidget {
  const _ModalBottomSheet({
    super.key,
    this.closeProgressThreshold,
    required this.route,
    this.secondAnimationController,
    this.bounce = false,
    this.expanded = false,
    this.enableDrag = true,
    this.animationCurve,
    this.secondAnimationCurve,
  });

  final double? closeProgressThreshold;
  final ModalSheetRoute<T> route;
  final bool expanded;
  final bool bounce;
  final bool enableDrag;
  final AnimationController? secondAnimationController;
  final Curve? animationCurve;
  final Curve? secondAnimationCurve;

  @override
  _ModalBottomSheetState<T> createState() => _ModalBottomSheetState<T>();
}

class _ModalBottomSheetState<T> extends State<_ModalBottomSheet<T>> {
  String _getRouteLabel() {
    final platform = Theme.of(context).platform; //?? defaultTargetPlatform;
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return '';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        if (Localizations.of(context, MaterialLocalizations) != null) {
          return MaterialLocalizations.of(context).dialogLabel;
        } else {
          return DefaultMaterialLocalizations().dialogLabel;
        }
    }
  }

  ScrollController? _scrollController;

  @override
  void initState() {
    widget.route.animation?.addListener(updateController);
    super.initState();
  }

  @override
  void dispose() {
    widget.route.animation?.removeListener(updateController);
    _scrollController?.dispose();
    super.dispose();
  }

  void updateController() {
    final animation = widget.route.animation;
    if (animation != null) {
      widget.secondAnimationController?.value = animation.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(widget.route._animationController != null);
    final scrollController = PrimaryScrollController.maybeOf(context) ??
        (_scrollController ??= ScrollController());
    return ModalScrollController(
      controller: scrollController,
      child: Builder(
        builder: (context) => AnimatedBuilder(
          animation: widget.route._animationController!,
          builder: (BuildContext context, final Widget? child) {
            assert(child != null);
            // Disable the initial animation when accessible navigation is on so
            // that the semantics are added to the tree at the correct time.
            return Semantics(
              scopesRoute: true,
              namesRoute: true,
              label: _getRouteLabel(),
              explicitChildNodes: true,
              child: ModalBottomSheet(
                closeProgressThreshold: widget.closeProgressThreshold,
                expanded: widget.route.expanded,
                containerBuilder: widget.route.containerBuilder,
                animationController: widget.route._animationController!,
                shouldClose: widget.route._hasScopedWillPopCallback
                    ? () async {
                        final willPop = await widget.route.willPop();
                        return willPop != RoutePopDisposition.doNotPop;
                      }
                    : null,
                onClosing: () {
                  if (widget.route.isCurrent) {
                    Navigator.of(context).pop();
                  }
                },
                child: child!,
                enableDrag: widget.enableDrag,
                bounce: widget.bounce,
                scrollController: scrollController,
                animationCurve: widget.animationCurve,
                secondAnimationCurve: widget.secondAnimationCurve,
              ),
            );
          },
          child: widget.route.builder(context),
        ),
      ),
    );
  }
}

class ModalSheetRoute<T> extends PageRoute<T> {
  ModalSheetRoute({
    this.closeProgressThreshold,
    this.containerBuilder,
    required this.builder,
    this.scrollController,
    this.barrierLabel,
    this.secondAnimationController,
    this.modalBarrierColor,
    this.isDismissible = true,
    this.enableDrag = true,
    required this.expanded,
    this.bounce = false,
    this.animationCurve,
    this.secondAnimationCurve,
    Duration? duration,
    super.settings,
  })  : duration = duration ?? _bottomSheetDuration;

  final double? closeProgressThreshold;
  final WidgetWithChildBuilder? containerBuilder;
  final WidgetBuilder builder;
  final bool expanded;
  final bool bounce;
  final Color? modalBarrierColor;
  final bool isDismissible;
  final bool enableDrag;
  final ScrollController? scrollController;

  final Duration duration;

  final AnimationController? secondAnimationController;
  final Curve? animationCurve;
  final Curve? secondAnimationCurve;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  bool get maintainState => true; // keep in memory when not active (#252)

  @override
  bool get opaque => false; //transparency

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => modalBarrierColor ?? Colors.black.withOpacity(0.35);

  AnimationController? _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController = ModalBottomSheet.createAnimationController(
      navigator!,
      duration: transitionDuration,
    );
    return _animationController!;
  }

  // ignore: deprecated_member_use
  bool get _hasScopedWillPopCallback => hasScopedWillPopCallback;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    // By definition, the bottom sheet is aligned to the bottom of the page
    // and isn't exposed to the top padding of the MediaQuery.
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      // removeTop: true,
      child: _ModalBottomSheet<T>(
        closeProgressThreshold: closeProgressThreshold,
        route: this,
        secondAnimationController: secondAnimationController,
        expanded: expanded,
        bounce: bounce,
        enableDrag: enableDrag,
        animationCurve: animationCurve,
        secondAnimationCurve: secondAnimationCurve,
      ),
    );
    return bottomSheet;
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
      nextRoute is ModalSheetRoute;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
      previousRoute is ModalSheetRoute || previousRoute is PageRoute;

  Widget getPreviousRouteTransition(
    BuildContext context,
    Animation<double> secondAnimation,
    Widget child,
  ) {
    return child;
  }
}

/// Shows a modal material design bottom sheet.
Future<T?> showCustomModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required WidgetWithChildBuilder containerWidget,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  Color? barrierColor,
  bool bounce = false,
  bool expand = false,
  AnimationController? secondAnimation,
  Curve? animationCurve,
  Curve? secondAnimationCurve,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  Duration? duration,
  RouteSettings? settings,
  double? closeProgressThreshold,
}) async {
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));
  final hasMaterialLocalizations =
      Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) !=
          null;
  final barrierLabel = hasMaterialLocalizations
      ? MaterialLocalizations.of(context).modalBarrierDismissLabel
      : '';

  final result = await Navigator.of(context, rootNavigator: useRootNavigator)
      .push(ModalSheetRoute<T>(
    builder: builder,
    bounce: bounce,
    containerBuilder: containerWidget,
    secondAnimationController: secondAnimation,
    expanded: expand,
    barrierLabel: barrierLabel,
    isDismissible: isDismissible,
    modalBarrierColor: barrierColor,
    enableDrag: enableDrag,
    animationCurve: animationCurve,
    secondAnimationCurve: secondAnimationCurve,
    duration: duration,
    settings: settings,
    closeProgressThreshold: closeProgressThreshold,
  ));
  return result;
}
