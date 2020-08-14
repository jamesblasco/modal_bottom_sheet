import 'package:flutter/material.dart';

class ModalWithPageView extends StatelessWidget {
  final ScrollController scrollController;

  const ModalWithPageView({Key key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
            leading: Container(), title: Text('Modal With Page View')),
        body: SafeArea(
          bottom: false,
          child: PageView(
            children: List.generate(2, (index) => ListView(
              shrinkWrap: true,
              controller: scrollController,
              children: ListTile.divideTiles(
                context: context,
                tiles: List.generate(
                    100,
                        (index) => ListTile(
                      title: Text('Item'),
                    )),
              ).toList(),
            )),
          ),
        ),
      ),
    );
  }
}
