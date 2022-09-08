import 'package:flutter/widgets.dart';
import 'package:sheet/sheet.dart';
import 'dart:math' as math;

/// A widget that updates the top safe area proportionally to the position
/// of the sheet
///
/// If the sheet is below the top safe area the inner top padding will be 0.
/// Once the sheet enters the top safe area the inner top padding will increase
///   proportionally to the sheet offset.
/// If the sheet is fully expanded to the top of the screen the top padding
///   will be the same as the parent top safe area.
class SheetMediaQuery extends StatelessWidget {
  const SheetMediaQuery({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = Sheet.of(context)!.controller;
    final MediaQueryData data = MediaQuery.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      return AnimatedBuilder(
        animation: controller.animation,
        builder: (BuildContext context, Widget? child) {
          final position = controller.position;
          final viewportDimension = position.hasViewportDimension
              ? position.viewportDimension
              : double.infinity;
          final pixels = position.hasPixels ? position.pixels : 0;
          final offset = viewportDimension - pixels;
          final topPadding = math.max(0.0, data.padding.top - offset);
          return MediaQuery(
            data: data.copyWith(
              padding: data.padding.copyWith(
                top: topPadding,
              ),
            ),
            child: child!,
          );
        },
        child: child,
      );
    });
  }
}
