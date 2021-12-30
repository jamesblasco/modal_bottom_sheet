import 'package:example/base_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';

class ScrollableSheet extends StatefulWidget {
  @override
  _SnapSheetPageExampleState createState() => _SnapSheetPageExampleState();
}

class _SnapSheetPageExampleState extends State<ScrollableSheet>
    with TickerProviderStateMixin {
  late SheetController controller = SheetController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      showBottomBar: false,
      title: const Text('Floating Sheet'),
      sheet: Sheet(
        physics: const BouncingSheetPhysics(overflow: true),
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
            body: ListView(
              shrinkWrap: true,
              primary: true,
              physics: const BouncingScrollPhysics(),
              children: ListTile.divideTiles(
                context: context,
                tiles: List <Widget>.generate(100, (int index) {
                  if (index == 0) {
                    return Container(
                      child: Text(
                        'Location',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                    );
                  }
                  return ListTile(
                    title: Text('Item $index'),
                  );
                }),
              ).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
