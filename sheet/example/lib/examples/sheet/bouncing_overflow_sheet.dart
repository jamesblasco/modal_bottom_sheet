import 'package:flutter/material.dart';

import 'package:sheet/sheet.dart';

class BounceOverflowSheet extends StatelessWidget {
  const BounceOverflowSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sheet(
      physics: const BouncingSheetPhysics(overflowViewport: false),
      child: Scaffold(
        appBar: AppBar(title: const Text('Example')),
      ),
      minExtent: 100,
    );
  }
}
