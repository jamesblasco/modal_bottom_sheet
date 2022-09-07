import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/sheet.dart';

const Key _key = Key('_sheet_builder');

Finder findSheet() => find.byKey(_key);

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
    final Offset offset = getTopLeft(find.byKey(_key));
    return offset.dy;
  }

  SheetController getSheetController() {
    final Element context = element(find.byKey(_key));
    return Sheet.of(context)!.controller;
  }

  double getSheetHeight() {
    final Size rect = getSize(find.byKey(_key));
    return rect.height;
  }

  Size getSheetSize() {
    return getSize(find.byKey(_key));
  }

  Future<void> dragSheet(double offset) {
    return drag(find.byKey(_key), Offset(0, offset));
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
