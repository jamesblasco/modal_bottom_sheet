import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../modal_bottom_sheet.dart';
import '../bottom_sheet_route.dart';

const Radius _default_bar_top_radius = Radius.circular(15);

class BarBottomSheet extends StatelessWidget {
  final Widget child;
  final Widget control;
  final Clip clipBehavior;
  final double elevation;
  final ShapeBorder shape;

  const BarBottomSheet(
      {Key key,
      this.child,
      this.control,
      this.clipBehavior,
      this.shape,
      this.elevation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 12),
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
          SizedBox(height: 8),
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Material(
              shape: RoundedRectangleBorder(
                side: BorderSide(),
                borderRadius: BorderRadius.only(
                    topLeft: _default_bar_top_radius,
                    topRight: _default_bar_top_radius),
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
        ],
      ),
    );
  }
}

Future<T> showBarModalBottomSheet<T>({
  @required BuildContext context,
  @required ScrollWidgetBuilder builder,
  Color backgroundColor,
  double elevation,
  ShapeBorder shape,
  Clip clipBehavior,
  Color barrierColor = Colors.black87,
  bool bounce = true,
  bool expand = false,
  AnimationController secondAnimation,
  Curve animationCurve,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  Widget topControl,
  Duration duration,
}) async {
  assert(context != null);
  assert(builder != null);
  assert(expand != null);
  assert(useRootNavigator != null);
  assert(isDismissible != null);
  assert(enableDrag != null);
  assert(debugCheckHasMediaQuery(context));

  final isCupertinoApp = Theme.of(context, shadowThemeOnly: true) == null;
  var barrierLabel = '';
  if (!isCupertinoApp) {
    assert(debugCheckHasMaterialLocalizations(context));
    barrierLabel = MaterialLocalizations.of(context).modalBarrierDismissLabel;
  }

  final result = await Navigator.of(context, rootNavigator: useRootNavigator)
      .push(ModalBottomSheetRoute<T>(
    builder: builder,
    bounce: bounce,
    containerBuilder: (_, __, child) => BarBottomSheet(
      child: child,
      control: topControl,
      clipBehavior: clipBehavior,
      shape: shape,
      elevation: elevation,
    ),
    secondAnimationController: secondAnimation,
    expanded: expand,
    barrierLabel: barrierLabel,
    isDismissible: isDismissible,
    modalBarrierColor: barrierColor,
    enableDrag: enableDrag,
    animationCurve: animationCurve,
    duration: duration,
  ));
  return result;
}
