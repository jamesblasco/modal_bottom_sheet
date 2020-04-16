import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalFitResizable extends StatefulWidget {
  final ScrollController scrollController;

  const ModalFitResizable({Key key, this.scrollController}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ModalFitResizableState();
}

class _ModalFitResizableState extends State<ModalFitResizable> {
  int length = 4;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          controller:  widget.scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ...List.generate(
                length,
                (index) => ListTile(
                  title: Text('Item $index'),
                ),
              ),
              ListTile(
                onTap: () => setState(() {
                  length += 1;
                }),
                leading: Icon(Icons.add),
                title: Text('Add new row'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
