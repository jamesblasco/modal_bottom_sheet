import 'package:example/base_scaffold.dart';
import 'package:example/examples/bouncing_sheet.dart';
import 'package:example/examples/fit_resizable_sheet.dart';
import 'package:example/examples/fit_sheet.dart';
import 'package:example/examples/floating_sheet.dart';
import 'package:example/examples/resizable_sheet.dart';
import 'package:example/examples/simple_sheet.dart';
import 'package:example/examples/snap_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'editor/editor_page.dart';
import 'examples/clamped_sheet.dart';
import 'examples/complex_snap_sheet.dart';
import 'examples/fit_sheet_snap.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(platform: TargetPlatform.iOS),
      title: 'BottomSheet Modals',
      home: const SheetExamplesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SheetExamplesPage extends StatelessWidget {
  const SheetExamplesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        middle: Text('Sheets'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        primary: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SectionTitle('SHEET'),
            const ExampleTile(
              title: 'Customizable sheet',
              sheet: SheetConfigurationPage(),
            ),
            const SectionTitle('EXAMPLES'),
            ExampleTile(
              title: 'Simple sheet',
              sheet: SimpleSheetPage(),
            ),
            ExampleTile(
              title: 'Snap sheet',
              sheet: SnapSheet(),
            ),
            ExampleTile(
              title: 'Fit sheet',
              sheet: FitSheet(),
            ),
            ExampleTile(
              title: 'Floating sheet',
              sheet: FloatingSheet(),
            ),
            ExampleTile(
              title: 'Clamped sheet (min and max extent',
              sheet: ClampedSheetPage(),
            ),
            ExampleTile(
              title: 'Sheet with Bouncing at top',
              sheet: BouncingSheetPage(),
            ),
            ExampleTile(
              title: 'Fit and Snap sheet',
              sheet: FitSnapSheet(),
            ),
            ExampleTile(
              title: 'Resizable sheet',
              sheet: ResizableSheetExample(),
            ),
            ListTile(
              title: const Text('Fit, Resizable and Bouncing sheet'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => FitResizableSheet(),
                ),
              ),
            ),
            ListTile(
              title: const Text('Scrollabe sheet'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => FitResizableSheet(),
                ),
              ),
            ),
            ListTile(
              title: const Text('Advanced SnapSheet '),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      AdvancedSnapSheetPageExample(),
                ),
              ),
            ),
            const SizedBox(height: 60)
          ].addItemInBetween(const Divider(height: 1)),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  // ignore: sort_constructors_first
  const SectionTitle(
    this.title, {
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.caption,
      ),
    );
  }
}

extension ListUtils<T> on List<T> {
  List<T> addItemInBetween(T item) => length <= 1
      ? this
      : sublist(1).fold(
          <T>[first],
          (List<T> r, T element) => <T>[...r, item, element],
        );
}
