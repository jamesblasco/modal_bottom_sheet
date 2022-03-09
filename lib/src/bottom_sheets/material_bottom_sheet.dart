import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:async';

/// Shows a modal material design bottom sheet.
Future<T?> showMaterialModalBottomSheet<T>({
  required BuildContext context,
  double? closeProgressThreshold,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  Color? barrierColor,
  bool bounce = false,
  bool expand = false,
  AnimationController? secondAnimation,
  Curve? animationCurve,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  Duration? duration,
  RouteSettings? settings,
}) async {
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));
  final result = await Navigator.of(context, rootNavigator: useRootNavigator)
      .push(ModalBottomSheetRoute<T>(
    builder: builder,
    closeProgressThreshold: closeProgressThreshold,
    containerBuilder: _materialContainerBuilder(
      context,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      theme: Theme.of(context),
    ),
    secondAnimationController: secondAnimation,
    bounce: bounce,
    expanded: expand,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    isDismissible: isDismissible,
    modalBarrierColor: barrierColor,
    enableDrag: enableDrag,
    animationCurve: animationCurve,
    duration: duration,
    settings: settings,
  ));
  return result;
}

//Default container builder is the Material Appearance
WidgetWithChildBuilder _materialContainerBuilder(BuildContext context,
    {Color? backgroundColor,
    double? elevation,
    ThemeData? theme,
    Clip? clipBehavior,
    ShapeBorder? shape}) {
  final bottomSheetTheme = Theme.of(context).bottomSheetTheme;
  final color = backgroundColor ??
      bottomSheetTheme.modalBackgroundColor ??
      bottomSheetTheme.backgroundColor;
  final _elevation = elevation ?? bottomSheetTheme.elevation ?? 0.0;
  final _shape = shape ?? bottomSheetTheme.shape;
  final _clipBehavior =
      clipBehavior ?? bottomSheetTheme.clipBehavior ?? Clip.none;

  final result = (context, animation, child) => Material(
      color: color,
      elevation: _elevation,
      shape: _shape,
      clipBehavior: _clipBehavior,
      child: child);
  if (theme != null) {
    return (context, animation, child) =>
        Theme(data: theme, child: result(context, animation, child));
  } else {
    return result;
  }
}
