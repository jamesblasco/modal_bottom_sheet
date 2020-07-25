import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoModalWillScope extends StatelessWidget {
  final ScrollController scrollController;

  const CupertinoModalWillScope({Key key, this.scrollController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldClose = true;
        shouldClose = await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Should Close?'),
            actions: <Widget>[
              CupertinoButton(
                child: Text('Yes'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
              CupertinoButton(
                child: Text('No'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        );
        print('hello');
        return shouldClose ?? true;
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: const SizedBox(),
          middle: Text('Modal Page'),
        ),
        child: const SizedBox(),
      ),
    );
  }
}
