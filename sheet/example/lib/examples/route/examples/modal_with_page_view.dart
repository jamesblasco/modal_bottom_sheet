import 'package:flutter/material.dart';

class ModalWithPageView extends StatelessWidget {
  const ModalWithPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          title: const Text('Modal With Page View'),
        ),
        body: SafeArea(
          bottom: false,
          child: PageView(
            children: List<Widget>.generate(
              2,
              (int index) => ListView(
                shrinkWrap: true,
                primary: true,
                children: ListTile.divideTiles(
                  context: context,
                  tiles: List<Widget>.generate(
                    100,
                    (int index) => const ListTile(
                      title: Text('Item'),
                    ),
                  ),
                ).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
