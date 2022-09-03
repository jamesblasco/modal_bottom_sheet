import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalWithScroll extends StatelessWidget {
  const ModalWithScroll({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            leading: Container(), middle: Text('Modal Page')),
        child: SafeArea(
          bottom: false,
          child: ListView(
            shrinkWrap: true,
            primary: true,
            children: ListTile.divideTiles(
              context: context,
              tiles: List.generate(
                  100,
                  (index) => ListTile(
                        title: Text('Item'),
                      )),
            ).toList(),
          ),
        ),
      ),
    );
  }
}
