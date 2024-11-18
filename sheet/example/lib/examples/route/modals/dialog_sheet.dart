import 'package:flutter/material.dart';
import 'package:sheet/route.dart';
import 'package:sheet/sheet.dart';

class DialogSheet extends StatelessWidget {
  const DialogSheet({super.key, required this.child, this.backgroundColor});
  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(
          padding: mediaQuery.padding + const EdgeInsets.only(top: 40)),
      child: SafeArea(
        bottom: false,
        left: false,
        right: false,
        child: SizedBox.expand(
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 800,
              ),
              child: Material(
                color: backgroundColor,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(12),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DialogSheetRoute<T> extends SheetRoute<T> {
  DialogSheetRoute({
    required WidgetBuilder builder,
  }) : super(
          builder: (BuildContext context) => DialogSheet(
            child: Builder(builder: builder),
          ),
          fit: SheetFit.loose,
        );
}
