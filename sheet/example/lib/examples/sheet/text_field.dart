import 'package:flutter/material.dart';

import 'package:sheet/sheet.dart';

class TextFieldSheet extends StatefulWidget {
  @override
   State<TextFieldSheet> createState() => _TextFieldSheetState();
}

class _TextFieldSheetState extends State<TextFieldSheet>
    with TickerProviderStateMixin {
  late SheetController controller = SheetController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Sheet(
      minExtent: 100,
      physics: const SnapSheetPhysics(
        stops: <double>[0.4, 1],
        relative: true,
      ),
      initialExtent: 500,
      controller: controller,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.black12, blurRadius: 12),
          ],
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Inside AppBar'),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            primary: true,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: const <Widget>[
                SizedBox(height: 400),
                TextField(
                  scrollPadding: EdgeInsets.all(200),
                ),
                SizedBox(height: 400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
