import 'package:example/base_scaffold.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'editor/editor_page.dart';
import 'examples/sheet/bouncing_overflow_sheet.dart';
import 'examples/sheet/bouncing_sheet.dart';
import 'examples/sheet/clamped_sheet.dart';
import 'examples/sheet/complex_snap_sheet.dart';
import 'examples/sheet/fit_resizable_sheet.dart';
import 'examples/sheet/fit_sheet.dart';
import 'examples/sheet/fit_sheet_snap.dart';
import 'examples/sheet/floating_sheet.dart';
import 'examples/sheet/fold_screen_sheet.dart';
import 'examples/sheet/resizable_sheet.dart';
import 'examples/sheet/scrollable_sheet.dart';
import 'examples/sheet/scrollable_snap_sheet.dart';
import 'examples/sheet/simple_sheet.dart';
import 'examples/sheet/snap_sheet.dart';
import 'examples/sheet/text_field.dart';

class SheetExamplesPage extends StatelessWidget {
  const SheetExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        middle: Text('Sheets'),
        transitionBetweenRoutes: false,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        primary: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SectionTitle('SIZING'),
            ExampleTile.sheet('Expanded sheet', SimpleSheet()),
            ExampleTile.sheet('Fit sheet', FitSheet()),
            ExampleTile.sheet('Resizable sheet', ResizableSheet()),
            const SectionTitle('DRAG PHYSICS'),
            ExampleTile.sheet('Snap', SnapSheet()),
            ExampleTile.sheet('Bouncing', const BounceTopSheet()),
            ExampleTile.sheet('Bouncing overflow', const BounceOverflowSheet()),
            ExampleTile.sheet(
                'Clamped sheet (min and max extent)', ClampedSheet()),
            const SectionTitle('SCROLLING'),
            ExampleTile.sheet('Scrollabe sheet', ScrollableSheet()),
            ExampleTile.sheet('Scrollabe snap sheet', ScrollableSnapSheet()),
            const SectionTitle('Others'),
            ExampleTile.sheet('Floating sheet', FloatingSheet()),
            ExampleTile.sheet('Fit and Snap sheet', FitSnapSheet()),
            ExampleTile.sheet(
                'Fit, Resizable and Bouncing sheet', FitResizableSheet()),
            ExampleTile.sheet('Textfield sheet', TextFieldSheet()),
            ExampleTile.sheet('Foldable screen', FoldableScreenFloatingSheet()),
            const ExampleTile(
                title: 'Customizable sheet', page: SheetConfigurationPage()),
            const SectionTitle('SHOWCASE'),
            ExampleTile(
                leading: const Icon(Icons.map),
                title: 'Map BottomSheet Example',
                page: AdvancedSnapSheetPage()),
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
        style: Theme.of(context).textTheme.bodySmall,
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
