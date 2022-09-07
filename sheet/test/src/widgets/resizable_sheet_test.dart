import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheet/src/widgets/resizable_sheet.dart';

import '../../screen_size_test.dart';

void main() {
  group('ResizableSheetChild', () {
    testWidgets('if resizable is false, constraints are ignored',
        (WidgetTester tester) async {
      final ViewportOffset offset = ViewportOffset.fixed(100);

      await tester.pumpWidget(
        ResizableSheetChild(
          offset: offset,
          child: Container(),
          resizable: false,
        ),
      );

      expect(tester.getSize(find.byType(Container)), kScreenSize);
    });

    testWidgets('if resizable is true, child height depends on pixels offset',
        (WidgetTester tester) async {
      final ViewportOffset offset = ViewportOffset.fixed(100);

      await tester.pumpWidget(
        ResizableSheetChild(
          offset: offset,
          child: Container(),
          resizable: true,
        ),
      );

      expect(tester.getSize(find.byType(Container)).height, 100);
    });

    testWidgets('minExtent is Zero By default', (WidgetTester tester) async {
      final ViewportOffset offset = ViewportOffset.fixed(100);
      expect(
        ResizableSheetChild(
          offset: offset,
          child: Container(),
          resizable: true,
        ).minExtent,
        isZero,
      );
    });
    testWidgets('minExtent works', (WidgetTester tester) async {
      final ViewportOffset offset = ViewportOffset.fixed(100);

      await tester.pumpWidget(
        ResizableSheetChild(
          offset: offset,
          child: Container(),
          minExtent: 200,
          resizable: true,
        ),
      );

      expect(tester.getSize(find.byType(Container)).height, 200);
    });
  });

  group('Updates render object values', () {
    testWidgets('ViewportOffset', (WidgetTester tester) async {
      late StateSetter setState;
      ViewportOffset offset = ViewportOffset.fixed(100);
      await tester.pumpWidget(
        StatefulBuilder(
            builder: (BuildContext context, StateSetter stateSetter) {
          setState = stateSetter;
          return ResizableSheetChild(
            offset: offset,
            child: Container(),
            resizable: true,
          );
        }),
      );
      final RenderResizableSheetChildBox renderObject =
          tester.renderObject<RenderResizableSheetChildBox>(
              find.byType(ResizableSheetChild));

      expect(renderObject.offset, offset);
      expect(tester.getSize(find.byType(Container)).height, offset.pixels);

      offset = ViewportOffset.fixed(200);
      setState(() {});
      await tester.pump();
      expect(renderObject.offset, offset);
      expect(renderObject.offset.pixels, 200);
      expect(tester.getSize(find.byType(Container)).height, offset.pixels);
    });

    testWidgets('resizable', (WidgetTester tester) async {
      late StateSetter setState;
      final ViewportOffset offset = ViewportOffset.fixed(100);
      bool resizable = true;
      await tester.pumpWidget(
        StatefulBuilder(
            builder: (BuildContext context, StateSetter stateSetter) {
          setState = stateSetter;
          return ResizableSheetChild(
            offset: offset,
            child: Container(),
            resizable: resizable,
          );
        }),
      );
      final RenderResizableSheetChildBox renderObject =
          tester.renderObject<RenderResizableSheetChildBox>(
              find.byType(ResizableSheetChild));

      expect(renderObject.resizable, resizable);
      expect(tester.getSize(find.byType(Container)).height, offset.pixels);

      resizable = false;
      setState(() {});
      await tester.pump();
      expect(renderObject.resizable, resizable);
      expect(renderObject.resizable, isFalse);
      expect(tester.getSize(find.byType(Container)), kScreenSize);
    });

    testWidgets('minExtent', (WidgetTester tester) async {
      late StateSetter setState;
      final ViewportOffset offset = ViewportOffset.fixed(100);
      double minExtent = 200;
      await tester.pumpWidget(
        StatefulBuilder(
            builder: (BuildContext context, StateSetter stateSetter) {
          setState = stateSetter;
          return ResizableSheetChild(
            offset: offset,
            child: Container(),
            minExtent: minExtent,
            resizable: true,
          );
        }),
      );
      final RenderResizableSheetChildBox renderObject =
          tester.renderObject<RenderResizableSheetChildBox>(
              find.byType(ResizableSheetChild));

      expect(renderObject.minExtent, minExtent);
      expect(tester.getSize(find.byType(Container)).height, 200);

      minExtent = 300;
      setState(() {});
      await tester.pump();
      expect(renderObject.minExtent, minExtent);
      expect(tester.getSize(find.byType(Container)).height, 300);
    });
  });
}
