import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sheet/sheet.dart';

class NoMomentumSheet extends StatefulWidget {
  @override
  State<NoMomentumSheet>  createState() => _NoMomentumSheetState();
}

class _NoMomentumSheetState extends State<NoMomentumSheet> {
  final SheetController controller = SheetController();

  @override
  void initState() {
    Future<void>.delayed(const Duration(milliseconds: 400), animateSheet);

    super.initState();
  }

  void animateSheet() {
    controller.relativeAnimateTo(0.2,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sheet(
      minExtent: 100,
      maxExtent: 400,
      elevation: 4,
      physics: const NoMomentumSheetPhysics(),
      child: Container(),
      controller: controller,
    );
  }
}
