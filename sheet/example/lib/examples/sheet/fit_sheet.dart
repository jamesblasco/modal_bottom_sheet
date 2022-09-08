import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sheet/sheet.dart';

class FitSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultSheetController(
      onCreated: (controller) async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        controller.relativeAnimateTo(
          1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      },
      child: Sheet(
        elevation: 4,
        child: Container(
          height: 400,
          child: const Text('hello'),
        ),
      ),
    );
  }
}
