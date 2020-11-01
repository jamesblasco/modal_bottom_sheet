import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class CupertinoModalInsideModal extends StatelessWidget {
  final ScrollController scrollController;
  final bool reverse;

  const CupertinoModalInsideModal({
    Key key,
    this.scrollController,
    this.reverse = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Container(),
        middle: Text('Modal Page'),
      ),
      child: SafeArea(
        bottom: false,
        child: Theme(
          data: ThemeData(brightness: CupertinoTheme.of(context).brightness),
          child: Material(
            color: Colors.transparent,
            child: ListView(
              reverse: reverse,
              shrinkWrap: true,
              controller: scrollController,
              physics: ClampingScrollPhysics(),
              children: ListTile.divideTiles(
                context: context,
                tiles: List.generate(
                  100,
                  (index) => ListTile(
                    title: Text('Item $index'),
                    onTap: () => showCupertinoModalBottomSheet(
                      expand: true,
                      isDismissible: false,
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => CupertinoModalInsideModal(
                        reverse: reverse,
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
