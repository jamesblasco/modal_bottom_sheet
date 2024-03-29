import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleModal extends StatelessWidget {
  const SimpleModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
        child: CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          leading: Container(), middle: Text('Modal Page')),
      child: Center(),
    ));
  }
}
