import 'dart:math';

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AvatarBottomSheet extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final SystemUiOverlayStyle? overlayStyle;

  const AvatarBottomSheet(
      {Key? key,
      required this.child,
      required this.animation,
      this.overlayStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle ?? SystemUiOverlayStyle.light,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),
          SafeArea(
            bottom: false,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) => Transform.translate(
                  offset: Offset(0, (1 - animation.value) * 100),
                  child: Opacity(
                      child: child, opacity: max(0, animation.value * 2 - 1))),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 20),
                  CircleAvatar(
                    child: Text(
                      'JB',
                      style: TextStyle(color: Colors.black),
                    ),
                    radius: 32,
                    backgroundColor: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black12,
                      spreadRadius: 5,
                    ),
                  ],
                ),
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

Future<T?> showAvatarModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  Color barrierColor = Colors.black87,
  bool bounce = true,
  bool expand = false,
  AnimationController? secondAnimation,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  Duration? duration,
  SystemUiOverlayStyle? overlayStyle,
}) async {
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));
  final result = await Navigator.of(context, rootNavigator: useRootNavigator)
      .push(ModalBottomSheetRoute<T>(
    builder: builder,
    containerBuilder: (_, animation, child) => AvatarBottomSheet(
      child: child,
      animation: animation,
      overlayStyle: overlayStyle,
    ),
    bounce: bounce,
    secondAnimationController: secondAnimation,
    expanded: expand,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    isDismissible: isDismissible,
    modalBarrierColor: barrierColor,
    enableDrag: enableDrag,
    duration: duration,
  ));
  return result;
}
