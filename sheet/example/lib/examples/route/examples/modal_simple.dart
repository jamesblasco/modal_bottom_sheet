import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleModal extends StatelessWidget {
  const SimpleModal({Key? key, required this.scrollController})
      : super(key: key);
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          leading: Container(), middle: const Text('Modal Page')),
      child: const Center(),
    ));
  }
}
