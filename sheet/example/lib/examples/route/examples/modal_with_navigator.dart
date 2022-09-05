import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalWithNavigator extends StatelessWidget {
  const ModalWithNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (BuildContext newContext) => CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                leading: Container(), middle: const Text('Modal Page')),
            child: SafeArea(
              bottom: false,
              child: ListView(
                shrinkWrap: true,
                controller: PrimaryScrollController.of(context),
                children: ListTile.divideTiles(
                  context: newContext,
                  tiles: List<Widget>.generate(
                      100,
                      (int index) => ListTile(
                            title: const Text('Item'),
                            onTap: () {
                              pushRoute(newContext, context);
                            },
                          )),
                ).toList(),
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
        builder: (BuildContext context) => CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('New Page'),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              MaterialButton(
                onPressed: () => Navigator.of(modalContext).pop(),
                child: const Text('touch here'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
