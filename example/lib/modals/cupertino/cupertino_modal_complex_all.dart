import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoComplexModal extends StatelessWidget {
  final ScrollController scrollController;

  const CupertinoComplexModal({
    Key key,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldClose = true;
        shouldClose = await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Should Close?'),
            actions: <Widget>[
              CupertinoButton(
                child: Text('Yes'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
              CupertinoButton(
                child: Text('No'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        );
        print('hello');
        return shouldClose ?? true;
      },
      child: Navigator(
        onGenerateRoute: (_) => CupertinoPageRoute(
          builder: (context) => Builder(
            builder: (context) => CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                leading: Container(),
                middle: Text('Modal Page'),
              ),
              child: SafeArea(
                bottom: false,
                child: Theme(
                  data: ThemeData.dark(),
                  child: Material(
                    color: Colors.transparent,
                    child: ListView(
                      shrinkWrap: true,
                      controller: scrollController,
                      children: ListTile.divideTiles(
                        context: context,
                        tiles: List.generate(
                          100,
                          (index) => ListTile(
                            title: Text('Item'),
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => CupertinoPageScaffold(
                                    navigationBar: CupertinoNavigationBar(
                                      middle: Text('New Page'),
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: <Widget>[],
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
      ),
    );
  }
}
