import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';

import '../base_scaffold.dart';

class ResizableSheetExample extends StatefulWidget {
  @override
  _ResizableSheetExampleState createState() => _ResizableSheetExampleState();
}

class _ResizableSheetExampleState extends State<ResizableSheetExample>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      showBottomBar: false,
      title: const Text('Resizable Sheet'),
      sheet: Sheet(
        initialExtent: 300,
        fit: SheetFit.expand,
        elevation: 20,
        minInteractionExtent: 100,
        resizable: true,
        minResizableExtent: 300,
        physics: const SnapSheetPhysics(
          stops: <double>[0, 300, double.infinity],
          relative: false,
        ),
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
                  icon: const Icon(Icons.access_alarm),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
