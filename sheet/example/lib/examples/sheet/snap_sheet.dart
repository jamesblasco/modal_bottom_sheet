import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sheet/sheet.dart';

class SnapSheet extends StatefulWidget {
  @override
   State<SnapSheet> createState() => _SnapSheetState();
}

class _SnapSheetState extends State<SnapSheet> {
  final SheetController controller = SheetController();

  @override
  void initState() {
    Future<void>.delayed(const Duration(milliseconds: 400), animateSheet);

    super.initState();
  }

  void animateSheet() {
    controller.relativeAnimateTo(
      0.5,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sheet(
      elevation: 4,
      physics: const SnapSheetPhysics(
        stops: <double>[0.1, 0.5, 1],
        parent: BouncingSheetPhysics(),
      ),
      child: Container(),
      controller: controller,
    );
  }
}
