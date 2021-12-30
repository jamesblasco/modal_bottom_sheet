import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ModalFit extends StatelessWidget {
  const ModalFit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SheetMediaQuery(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Edit'),
                leading: Icon(Icons.edit),
                onTap: () => Navigator.of(context).pop(),
              ),
              ListTile(
                title: Text('Copy'),
                leading: Icon(Icons.content_copy),
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
                title: Text('Delete'),
                leading: Icon(Icons.delete),
                onTap: () => Navigator.of(context).pop(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
