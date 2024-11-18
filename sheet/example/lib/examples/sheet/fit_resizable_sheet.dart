import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';

class FitResizableSheet extends StatefulWidget {
  @override
  State<FitResizableSheet> createState() => _FitSheetState();
}

class _FitSheetState extends State<FitResizableSheet> {
  final SheetController controller = SheetController();

  @override
  void initState() {
    Future<void>.delayed(const Duration(milliseconds: 400), animateSheet);

    super.initState();
  }

  void animateSheet() {
    controller.animateTo(
      200,
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
      resizable: true,
      minResizableExtent: 200,
      physics: const SnapSheetPhysics(
        stops: <double>[0, 200, double.infinity],
        relative: false,
        parent: BouncingSheetPhysics(),
      ),
      child: Container(
        height: 500,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: const Center(
            child: Text('Hello'),
          ),
          bottomNavigationBar: BottomAppBar(
            elevation: 4,
            child: Row(
              children: <Widget>[
                IconButton(
                    icon: const Icon(Icons.access_alarm), onPressed: () {})
              ],
            ),
          ),
        ),
      ),
      controller: controller,
    );
  }
}
