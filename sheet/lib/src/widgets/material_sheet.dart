import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';

class MaterialSheet extends Sheet {
  const MaterialSheet({
    super.key,
    required super.child,
    super.controller,
    super.physics,
    super.initialExtent,
    super.minExtent,
    super.maxExtent,
    super.minInteractionExtent = 20.0,
    super.backgroundColor,
    super.clipBehavior,
    super.shape,
    super.elevation,
    super.fit = SheetFit.loose,
    super.resizable = false,
    super.padding = EdgeInsets.zero,
    super.minResizableExtent,
  });

  @override
  Widget decorationBuild(BuildContext context, Widget child) {
    final BottomSheetThemeData bottomSheetTheme =
        Theme.of(context).bottomSheetTheme;
    final Color? color = backgroundColor ?? bottomSheetTheme.backgroundColor;
    final double elevation = this.elevation ?? bottomSheetTheme.elevation ?? 0;
    final ShapeBorder? shape = this.shape ?? bottomSheetTheme.shape;
    final Clip clipBehavior =
        this.clipBehavior ?? bottomSheetTheme.clipBehavior ?? Clip.none;

    return Material(
      color: color,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}
