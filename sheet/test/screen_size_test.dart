// Default test screen size defined by Flutter
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const double kScreenWidth = 800;
const double kScreenHeight = 600;
const Size kScreenSize = Size(kScreenWidth, kScreenHeight);
const Rect kScreenRect = Rect.fromLTRB(0, 0, kScreenWidth, kScreenHeight);

void main() {
  testWidgets('defaultTestSize', (WidgetTester tester) async {
    final Size testSize =
        tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(testSize, equals(kScreenSize));
  });
}
