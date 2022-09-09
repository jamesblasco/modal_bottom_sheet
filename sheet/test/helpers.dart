import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

const Key _childKey = Key('_sheet_child');

Finder findSheet() => find.byKey(_childKey);

extension BuildContextWidgetTester on WidgetTester {
  /// Gets context that can be used to push a new route into the root navigator
  /// Useful when we need to test bottom sheets or alerts
  BuildContext get contextForRootNavigator =>
      firstElement(find.byType(Navigator));
}

extension SheetTester on WidgetTester {
  Future<void> pumpApp(Widget sheet, {VoidCallback? onButtonPressed}) async {
    await pumpWidget(
      MaterialApp(
          home: Stack(
        children: <Widget>[
          TextButton(
            child: const Text('TapHere'),
            onPressed: onButtonPressed,
          ),
          sheet,
        ],
      )),
    );
  }

  Future<void> pumpSheet({VoidCallback? onButtonPressed}) async {
    await pumpWidget(
      MaterialApp(
          home: Stack(
        children: <Widget>[
          TextButton(
            child: const Text('TapHere'),
            onPressed: onButtonPressed,
          ),
          Sheet(
            fit: fitVariants.currentValue ?? SheetFit.loose,
            child: childVariants.currentValue ?? Container(),
          ),
        ],
      )),
    );
  }

  double getSheetTop() {
    final Offset offset = getTopLeft(findSheet());
    return offset.dy;
  }

  double getSheetExtent() {
    final Rect rootRect = getRect(find.byType(Sheet));
    final Offset offset = getTopLeft(findSheet());
    return rootRect.bottom - offset.dy;
  }

  SheetController getSheetController() {
    final BuildContext context = element(findSheet());
    return Sheet.of(context)!.controller;
  }

  SheetPosition getSheetPosition() {
    final BuildContext context = element(findSheet());
    return Sheet.of(context)!.position;
  }

  double getSheetHeight() {
    final Size rect = getSize(findSheet());
    return rect.height;
  }

  Size getSheetSize() {
    return getSize(find.byKey(_childKey));
  }

  Future<void> dragSheet(double offset) {
    return drag(find.byKey(_childKey), Offset(0, offset));
  }
}

final FitSheetVariant fitVariants = FitSheetVariant();

class FitSheetVariant extends ValueVariant<SheetFit> {
  FitSheetVariant() : super(SheetFit.values.toSet());
}

final SheetChildVariant childVariants = SheetChildVariant();

class SheetChildVariant extends ValueVariant<Widget> {
  SheetChildVariant()
      : super(<Widget>{Container(), const SingleChildScrollView()});
}
