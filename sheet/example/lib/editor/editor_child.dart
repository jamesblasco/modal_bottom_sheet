import 'package:example/editor/editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum SheetChildType { empty, column, scroll }

extension SheetChild on SheetChildType {
  Widget child() {
    switch (this) {
      case SheetChildType.empty:
        return const EmptyWidget();
      case SheetChildType.column:
        return const ColumnWidget();
      case SheetChildType.scroll:
        return const ListWidget();
    }
  }
}

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      alignment: Alignment.topCenter,
    );
  }
}

class ColumnWidget extends StatelessWidget {
  const ColumnWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          title: const Text('Edit'),
          leading: const Icon(Icons.edit),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Copy'),
          leading: const Icon(Icons.content_copy),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Cut'),
          leading: const Icon(Icons.content_cut),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Move'),
          leading: const Icon(Icons.folder_open),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Delete'),
          leading: const Icon(Icons.delete),
          onTap: () {},
        )
      ],
    );
  }
}

class ListWidget extends StatelessWidget {
  const ListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final int count = context.select(
            (SheetConfigurationController? controller) =>
                controller?.value.childrenCount) ??
        100;
    return ListView(
      shrinkWrap: true,
      primary: true,
      physics: const BouncingScrollPhysics(),
      children: ListTile.divideTiles(
        context: context,
        tiles: List<Widget>.generate(count, (int index) {
          if (index == 0) {
            return Container(
              child: Text(
                'Location',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
            );
          }
          return ListTile(
            title: Text('Item $index'),
          );
        }),
      ).toList(),
    );
  }
}
