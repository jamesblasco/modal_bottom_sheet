import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:async';

/// Shows a modal material design bottom sheet.
Future<T> showMaterialModalBottomSheet<T>({
  @required BuildContext context,
  @required ScrollWidgetBuilder builder,
  Color backgroundColor,
  double elevation,
  ShapeBorder shape,
  Clip clipBehavior,
  Color barrierColor,
  bool bounce = false,
  bool expand = false,
  AnimationController secondAnimation,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
}) async {
  assert(context != null);
  assert(builder != null);
  assert(expand != null);
  assert(useRootNavigator != null);
  assert(isDismissible != null);
  assert(enableDrag != null);
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));
  final result = await Navigator.of(context, rootNavigator: useRootNavigator)
      .push(ModalBottomSheetRoute<T>(
    builder: builder,
    containerBuilder: _materialContainerBuilder(
      context,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      theme: Theme.of(context, shadowThemeOnly: true),
    ),
    secondAnimationController: secondAnimation,
    bounce: bounce,
    expanded: expand,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    isDismissible: isDismissible,
    modalBarrierColor: barrierColor,
    enableDrag: enableDrag,
  ));
  return result;
}

//Default container builder is the Material Appearance
WidgetWithChildBuilder _materialContainerBuilder(BuildContext context,
    {Color backgroundColor,
    double elevation,
    ThemeData theme,
    Clip clipBehavior,
    ShapeBorder shape}) {
  final BottomSheetThemeData bottomSheetTheme =
      Theme.of(context).bottomSheetTheme;
  final Color color = backgroundColor ??
      bottomSheetTheme?.modalBackgroundColor ??
      bottomSheetTheme?.backgroundColor;
  final double _elevation = elevation ?? bottomSheetTheme.elevation ?? 0;
  final ShapeBorder _shape = shape ?? bottomSheetTheme.shape;
  final Clip _clipBehavior =
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
