import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ComplexModal extends StatelessWidget {
  const ComplexModal({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController primaryScrollController =
        PrimaryScrollController.maybeOf(context)!;
    return Material(
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          final sheetNavigator = Navigator.of(context);
          if (!didPop) {
            showCupertinoDialog<void>(
                context: context,
                builder: (BuildContext context) => CupertinoAlertDialog(
                      title: const Text('Should Close?'),
                      actions: <Widget>[
                        CupertinoButton(
                          child: const Text('Yes'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            sheetNavigator.pop();
                          },
                        ),
                        CupertinoButton(
                          child: const Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ));
          }
        },
        child: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (BuildContext context) => Builder(
              builder: (BuildContext context) => CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                    leading: Container(), middle: const Text('Modal Page')),
                child: SafeArea(
                  bottom: false,
                  child: ListView(
                    shrinkWrap: true,
                    controller: primaryScrollController,
                    children: ListTile.divideTiles(
                      context: context,
                      tiles: List<Widget>.generate(
                        100,
                        (int index) => ListTile(
                          title: const Text('Item'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    CupertinoPageScaffold(
                                  navigationBar: const CupertinoNavigationBar(
                                    middle: Text('New Page'),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: const <Widget>[],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
