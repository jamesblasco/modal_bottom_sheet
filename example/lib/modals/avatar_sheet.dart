import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class _AvatarSheet extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const _AvatarSheet({Key? key, required this.child, required this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
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
                          child: child,
                          opacity: max(0, animation.value * 2 - 1))),
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 20),
                      CircleAvatar(
                        child: Text('JB'),
                        radius: 32,
                      ),
                    ],
                  ),
                )),
            SizedBox(height: 12),
            Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
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

// ignore: always_specify_types
class AvatarSheetRoute<T> extends SheetRoute<T> {
  AvatarSheetRoute({
    required WidgetBuilder builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color barrierColor = Colors.black87,
    bool expand = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    Duration? duration,
  }) : super(
          builder: (context) {
            return _AvatarSheet(
              child: Builder(builder: builder),
              animation: Sheet.of(context)!.animation,
            );
          },
          expanded: expand,
          barrierDismissible: isDismissible,
          barrierColor: barrierColor,
          draggable: enableDrag,
          duration: duration,
        );
}
