import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheet/route.dart';
import 'package:sheet/sheet.dart';

class AvatarSheetRoute<T> extends SheetRoute<T> {
  AvatarSheetRoute({
    required WidgetBuilder builder,
    super.barrierColor = Colors.black87,
    super.fit = SheetFit.expand,
    super.barrierDismissible = true,
    super.draggable = true,
    super.duration,
  }) : super(
          builder: (BuildContext context) {
            return _AvatarSheet(
              child: Builder(builder: builder),
              animation: Sheet.of(context)!.controller.animation,
            );
          },
        );
}

class _AvatarSheet extends StatelessWidget {
  const _AvatarSheet({required this.child, required this.animation});
  final Widget child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 12),
            SafeArea(
                bottom: false,
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget? child) =>
                      Transform.translate(
                          offset: Offset(0, (1 - animation.value) * 100),
                          child: Opacity(
                              child: child,
                              opacity: max(0, animation.value * 2 - 1))),
                  child: Row(
                    children: const <Widget>[
                      SizedBox(width: 20),
                      CircleAvatar(
                        child: Text('JB'),
                        radius: 32,
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
            Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black12,
                        spreadRadius: 5,
                      )
                    ],
                  ),
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
