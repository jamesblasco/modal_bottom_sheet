import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoModalWithScroll extends StatelessWidget {
  final ScrollController scrollController;

  const CupertinoModalWithScroll({Key key, this.scrollController})
      : super(key: key);

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
              shrinkWrap: true,
              controller: scrollController,
              children: ListTile.divideTiles(
                context: context,
                tiles: List.generate(
                  100,
                  (index) => ListTile(
                    title: Text('Item'),
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
