import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../modal_bottom_sheet.dart';
import '../bottom_sheet_route.dart';

const Radius _default_bar_top_radius = Radius.circular(15);

class BarBottomSheet extends StatelessWidget {
  final Widget child;
  final Widget topControl;
  final Radius topRadius;

  const BarBottomSheet(
      {Key key, this.child, this.topControl, @required this.topRadius})
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
              child: topControl ??
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
              child: ClipRRect(
                borderRadius:
                    BorderRadius.only(topLeft: topRadius, topRight: topRadius),
                child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 10,
                              color: Colors.black12,
                              spreadRadius: 5)
                        ]),
                    width: double.infinity,
                    child: MediaQuery.removePadding(
                        context: context, removeTop: true, child: child)),
              ),
            ),
          ]),
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
  Radius topRadius = _default_bar_top_radius,
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
  assert(debugCheckHasMaterialLocalizations(context));
  final result = await Navigator.of(context, rootNavigator: useRootNavigator)
      .push(ModalBottomSheetRoute<T>(
    builder: builder,
    bounce: bounce,
    containerBuilder: (_, __, child) => BarBottomSheet(
      child: child,
      topRadius: topRadius,
      topControl: topControl,
    ),
    secondAnimationController: secondAnimation,
    expanded: expand,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    isDismissible: isDismissible,
    modalBarrierColor: barrierColor,
    enableDrag: enableDrag,
    animationCurve: animationCurve,
    duration: duration,
  ));
  return result;
}
