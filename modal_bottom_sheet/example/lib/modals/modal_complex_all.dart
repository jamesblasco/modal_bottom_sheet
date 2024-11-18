import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ComplexModal extends StatelessWidget {
  const ComplexModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            final sheetNavigator = Navigator.of(context);

            showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                      title: Text('Should Close?'),
                      actions: <Widget>[
                        CupertinoButton(
                          child: Text('Yes'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            sheetNavigator.pop();
                          },
                        ),
                        CupertinoButton(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ));
          }
        },
        child: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (context) => Builder(
              builder: (context) => CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                    leading: Container(), middle: Text('Modal Page')),
                child: SafeArea(
                  bottom: false,
                  child: ListView(
                    shrinkWrap: true,
                    controller: ModalScrollController.of(context),
                    children: ListTile.divideTiles(
                      context: context,
                      tiles: List.generate(
                          100,
                          (index) => ListTile(
                                title: Text('Item'),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          CupertinoPageScaffold(
                                              navigationBar:
                                                  CupertinoNavigationBar(
                                                middle: Text('New Page'),
                                              ),
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: <Widget>[],
                                              ))));
                                },
                              )),
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
