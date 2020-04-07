import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleModal extends StatelessWidget {
  final ScrollController scrollController;

  const SimpleModal({Key key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: false,
          leading: Container(), middle: Text('Modal Page')),
      child: Center(),
    ));
  }
}
