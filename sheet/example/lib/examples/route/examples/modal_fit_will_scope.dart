import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalFitWillScope extends StatelessWidget {
  const ModalFitWillScope({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
        child: PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        final sheetNavigator = Navigator.of(context);
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
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text('Edit'),
            leading: const Icon(Icons.edit),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            title: const Text('Copy'),
            leading: const Icon(Icons.content_copy),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            title: const Text('Cut'),
            leading: const Icon(Icons.content_cut),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            title: const Text('Move'),
            leading: const Icon(Icons.folder_open),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            title: const Text('Delete'),
            leading: const Icon(Icons.delete),
            onTap: () => Navigator.of(context).pop(),
          )
        ],
      ),
    ));
  }
}
