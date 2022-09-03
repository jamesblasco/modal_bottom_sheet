import 'dart:async';

import 'package:example/base_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sheet/sheet.dart';

class FitSheet extends StatefulWidget {
  @override
  _FitSheetState createState() => _FitSheetState();
}

class _FitSheetState extends State<FitSheet> {
  final SheetController controller = SheetController();

  @override
  void initState() {
    Future<void>.delayed(const Duration(milliseconds: 400), animateSheet);

    super.initState();
  }

  void animateSheet() {
    controller.relativeAnimateTo(1,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Sheet(
        elevation: 4,
        child: Container(
          height: 400,
          child: const Text('hello'),
        ),
        controller: controller,
   
    );
  }
}
