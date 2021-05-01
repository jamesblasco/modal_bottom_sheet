import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoModalWithNavigator extends StatelessWidget {
  final ScrollController? scrollController;

  const CupertinoModalWithNavigator({
    Key? key,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => CupertinoPageRoute(
        builder: (context) => Builder(
          builder: (context) => CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              leading: const SizedBox(),
              middle: Text('Modal Page'),
            ),
            child: SafeArea(
              bottom: false,
              child: Theme(
                data: ThemeData(
                    brightness: CupertinoTheme.of(context).brightness),
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
    );
  }
}
