import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';

import '../base_scaffold.dart';

class FloatingSheet extends StatefulWidget {
  @override
  _FitSheetState createState() => _FitSheetState();
}

class _FitSheetState extends State<FloatingSheet> {
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
    return BaseScaffold(
      showBottomBar: false,
      title: const Text('Floating Sheet'),
      sheet: Sheet.raw(
        physics: const SnapSheetPhysics(
          parent: BouncingSheetPhysics(overflowViewport: false),
          stops: <double>[0, 1],
        ),
        padding: const EdgeInsets.all(20),
        child: Container(
          height: 200,
          alignment: Alignment.topCenter,
          child: Container(
            height: 200,
            width: double.infinity,
            child: Material(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.grey[900],
            ),
          ),
        ),
        controller: controller,
      ),
    );
  }
}
