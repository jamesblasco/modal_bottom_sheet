import 'package:flutter/material.dart';
import 'package:sheet/route.dart';
import 'package:sheet/sheet.dart';

class MaterialSheetRoute<T> extends SheetRoute<T> {
  MaterialSheetRoute({
    required WidgetBuilder builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color barrierColor = Colors.black87,
    SheetFit fit = SheetFit.expand,
    Curve? animationCurve,
    bool barrierDismissible = true,
    bool enableDrag = true,
    List<double>? stops,
    double initialStop = 1,
    Duration? duration,
  }) : super(
          builder: (BuildContext context) => Material(
            child: Builder(
              builder: builder,
            ),
            color: backgroundColor,
            clipBehavior: clipBehavior ?? Clip.none,
            shape: shape,
            elevation: elevation ?? 1,
          ),
          stops: stops,
          initialExtent: initialStop,
          fit: fit,
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          draggable: enableDrag,
          animationCurve: animationCurve,
          duration: duration,
        );
}
