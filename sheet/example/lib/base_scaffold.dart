import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExampleTile extends StatelessWidget {
  const ExampleTile({Key? key, required this.title, required this.sheet})
      : super(key: key);

  final String title;
  final Widget sheet;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => sheet,
        ),
      ),
    );
  }
}

class BaseScaffold extends StatelessWidget {
  const BaseScaffold({
    Key? key,
    this.sheet,
    this.title,
    this.showBottomBar = true,
  }) : super(key: key);

  final Widget? sheet;
  final Widget? title;
  final bool showBottomBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        middle: title ?? const Text('Example'),
      ),
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: <Widget>[
          Container(
            //    color: Colors.,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
            child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
              return ListTile(title: Text('Item $index'));
            }),
          ),
          if (sheet != null) sheet!
        ],
      ),
    );
  }
}
