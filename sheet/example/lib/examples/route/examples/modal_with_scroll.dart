import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalWithScroll extends StatelessWidget {
  const ModalWithScroll({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            leading: Container(), middle: const Text('Modal Page')),
        child: SafeArea(
          bottom: false,
          child: ListView(
            shrinkWrap: true,
            primary: true,
            children: ListTile.divideTiles(
              context: context,
              tiles: List<Widget>.generate(
                  100,
                  (int index) => const ListTile(
                        title: Text('Item'),
                      )),
            ).toList(),
          ),
        ),
      ),
    );
  }
}
