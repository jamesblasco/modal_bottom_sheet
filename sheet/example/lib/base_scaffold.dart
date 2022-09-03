import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExampleTile extends StatelessWidget {
  const ExampleTile({
    Key? key,
    required this.title,
    required this.page,
    this.leading,
  }) : super(key: key);

  ExampleTile.sheet(this.title, Widget sheet, {this.leading})
      : page = BaseScaffold(title: Text(title), sheet: sheet),
        super();

  final String title;
  final Widget page;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => page,
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
    this.appBarTrailingButton,
  }) : super(key: key);

  final Widget? sheet;
  final Widget? title;
  final Widget? appBarTrailingButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        middle: title ?? const Text('Example'),
        trailing: appBarTrailingButton,
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
              return ListTile(
                title: Text('Item $index'),
                onTap: () {},
              );
            }),
          ),
          if (sheet != null) sheet!
        ],
      ),
    );
  }
}
