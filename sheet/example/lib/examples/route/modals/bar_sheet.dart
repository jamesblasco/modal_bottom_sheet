import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheet/route.dart';

const Radius _defaultBarTopRadius = Radius.circular(15);

class BarBottomSheet extends StatelessWidget {
  const BarBottomSheet(
      {super.key,
      required this.child,
      this.control,
      this.clipBehavior,
      this.shape,
      this.elevation});
  final Widget child;
  final Widget? control;
  final Clip? clipBehavior;
  final double? elevation;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 12),
            SafeArea(
              bottom: false,
              child: control ??
                  Container(
                    height: 6,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6)),
                  ),
            ),
            const SizedBox(height: 8),
            Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: Material(
                shape: shape ??
                    const RoundedRectangleBorder(
                      side: BorderSide(),
                      borderRadius: BorderRadius.only(
                          topLeft: _defaultBarTopRadius,
                          topRight: _defaultBarTopRadius),
                    ),
                clipBehavior: clipBehavior ?? Clip.hardEdge,
                elevation: elevation ?? 2,
                child: SizedBox(
                  width: double.infinity,
                  child: MediaQuery.removePadding(
                      context: context, removeTop: true, child: child),
                ),
              ),
            ),
          ]),
    );
  }
}

class BarSheetRoute<T> extends SheetRoute<T> {
  BarSheetRoute({
    required WidgetBuilder builder,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color super.barrierColor = Colors.black87,
    super.fit,
    super.animationCurve,
    bool isDismissible = true,
    bool enableDrag = true,
    Widget? topControl,
    super.duration,
  }) : super(
          builder: (BuildContext context) {
            return BarBottomSheet(
              child: Builder(builder: builder),
              control: topControl,
              clipBehavior: clipBehavior,
              shape: shape,
              elevation: elevation,
            );
          },
          barrierDismissible: isDismissible,
          draggable: enableDrag,
        );
}
