import 'package:flutter/material.dart';

class ModalWithPageView extends StatelessWidget {
  const ModalWithPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar:
            AppBar(leading: Container(), title: Text('Modal With Page View')),
        body: SafeArea(
          bottom: false,
          child: PageView(
            children: List.generate(
                2,
                (index) => ListView(
                      shrinkWrap: true,
                      primary: true,
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
