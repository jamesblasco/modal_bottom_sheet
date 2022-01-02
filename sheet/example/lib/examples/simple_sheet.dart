import 'package:flutter/material.dart';
import 'package:sheet/sheet.dart';

import '../base_scaffold.dart';

class SimpleSheetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: const Text('SimpleSheet'),
      sheet: Sheet(
        elevation: 12,
        initialExtent: 200,
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.blue[100],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20),
              Text('Title', style: Theme.of(context).textTheme.headline3),
              Text('Subtitle', style: Theme.of(context).textTheme.headline6),
            ],
          ),
        ),
      ),
    );
  }
}
