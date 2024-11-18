import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalWillScope extends StatelessWidget {
  const ModalWillScope({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
        child: PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        final sheetNavigator = Navigator.of(context);
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Should Close?'),
            actions: <Widget>[
              CupertinoButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                  sheetNavigator.pop();
                },
              ),
            ],
          ),
        );
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            leading: Container(), middle: Text('Modal Page')),
        child: Center(),
      ),
    ));
  }
}
