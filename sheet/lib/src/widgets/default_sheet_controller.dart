import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';

typedef SheetControllerCallback = void Function(SheetController controller);

/// A widget that injects a [SheetController] that can be used by
/// any [Sheet] children
///
/// It is useful for creating initial animations
/// ```dart
/// DefaultSheetController(
///   onCreated: (controller) => controller.play
/// )
///
///
class DefaultSheetController extends StatefulWidget {
  const DefaultSheetController({super.key, required this.child, this.onCreated});

  final Widget child;

  /// A callback called when the controller is created
  final SheetControllerCallback? onCreated;

  static SheetController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedSheetController>()
        ?.controller;
  }

  @override
  State<DefaultSheetController> createState() => _DefaultSheetControllerState();
}

class _DefaultSheetControllerState extends State<DefaultSheetController> {
  late final SheetController controller = SheetController();

  @override
  void initState() {
    widget.onCreated?.call(controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedSheetController(
        child: widget.child, controller: controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _InheritedSheetController extends InheritedWidget {
  const _InheritedSheetController(
      {required super.child, required this.controller});

  final SheetController controller;

  @override
  bool updateShouldNotify(_InheritedSheetController oldWidget) {
    return false;
  }
}
