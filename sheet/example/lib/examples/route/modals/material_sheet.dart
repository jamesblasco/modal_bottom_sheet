import 'package:flutter/material.dart';
import 'package:sheet/route.dart';

class MaterialSheetRoute<T> extends SheetRoute<T> {
  MaterialSheetRoute({
    required WidgetBuilder builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color super.barrierColor = Colors.black87,
    super.fit,
    super.animationCurve,
    super.barrierDismissible,
    bool enableDrag = true,
    super.stops,
    double initialStop = 1,
    super.duration,
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
          initialExtent: initialStop,
          draggable: enableDrag,
        );
}
