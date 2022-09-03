import 'package:flutter/material.dart';
import 'package:sheet/route.dart';
import 'package:sheet/sheet.dart';

class FloatingModal extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const FloatingModal({Key? key, required this.child, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Material(
        color: backgroundColor,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

class FloatingSheetRoute<T> extends SheetRoute<T> {
  FloatingSheetRoute({
    required WidgetBuilder builder,
  }) : super(
          decorationBuilder: (context, child) {
            return FloatingModal(child: child);
          },
          builder: builder,
          fit: SheetFit.loose,
        );
}
