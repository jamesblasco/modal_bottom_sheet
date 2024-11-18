import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalWillScope extends StatelessWidget {
  const ModalWillScope({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
        child: PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final sheetNavigator = Navigator.of(context);
        showCupertinoDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('Should Close?'),
                actions: <Widget>[
                  CupertinoButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      sheetNavigator.pop();
                    },
                  ),
                  CupertinoButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            leading: Container(), middle: const Text('Modal Page')),
        child: const Center(),
      ),
    ));
  }
}
