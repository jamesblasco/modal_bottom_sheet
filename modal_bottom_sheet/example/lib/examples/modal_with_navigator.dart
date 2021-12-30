import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalWithNavigator extends StatelessWidget {
  const ModalWithNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context1) {
    return Material(
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (context) => Builder(
            builder: (context) => CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                  leading: Container(), middle: Text('Modal Page')),
              child: SafeArea(
                bottom: false,
                child: ListView(
                  shrinkWrap: true,
                  controller: PrimaryScrollController.of(context1),
                  children: ListTile.divideTiles(
                    context: context,
                    tiles: List.generate(
                        100,
                        (index) => ListTile(
                              title: Text('Item'),
                              onTap: () {
                                pushRoute(context, context1);
                              },
                            )),
                  ).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void pushRoute(BuildContext context, BuildContext modalContext) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('New Page'),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              MaterialButton(
                onPressed: () => Navigator.of(modalContext).pop(),
                child: Text('touch here'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
