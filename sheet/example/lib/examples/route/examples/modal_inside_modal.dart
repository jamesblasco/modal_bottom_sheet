import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sheet/route.dart';

class ModalInsideModal extends StatelessWidget {
  const ModalInsideModal({super.key, this.reverse = false});
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        leading: Container(),
        middle: const Text('Modal Page'),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          reverse: reverse,
          // shrinkWrap: true,
          controller: PrimaryScrollController.of(context),
          physics: const BouncingScrollPhysics(),
          children: ListTile.divideTiles(
              context: context,
              tiles: List<Widget>.generate(
                100,
                (int index) => ListTile(
                  title: Text('Item $index'),
                  onTap: () => Navigator.of(context).push(
                    CupertinoSheetRoute<void>(
                      builder: (BuildContext context) =>
                          ModalInsideModal(reverse: reverse),
                    ),
                  ),
                ),
              )).toList(),
        ),
      ),
    ));
  }
}
