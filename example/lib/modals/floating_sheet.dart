import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
          builder: (context) => FloatingModal(
            child: Builder(
              builder: builder,
            ),
          ),
          expanded: false,
        );
}
