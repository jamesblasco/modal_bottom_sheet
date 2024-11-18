import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleModal extends StatelessWidget {
  const SimpleModal({super.key, required this.scrollController});
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
