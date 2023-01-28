import 'package:flutter/widgets.dart';

/// Widget that that will make the [scrollController] to scroll the top
/// when tapped on the status bar
///
/// Extracted from [Scaffold] and used in [Sheet]
class ScrollToTopStatusBarHandler extends StatefulWidget {
  const ScrollToTopStatusBarHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  ScrollToTopStatusBarState createState() => ScrollToTopStatusBarState();
}

class ScrollToTopStatusBarState extends State<ScrollToTopStatusBarHandler> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.maybeOf(context)?.padding.top ?? 0,
          child: Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _handleStatusBarTap(context),
                // iOS accessibility automatically adds scroll-to-top to the clock in the status bar
                excludeFromSemantics: true,
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleStatusBarTap(BuildContext context) {
    final ScrollController? controller =
        PrimaryScrollController.maybeOf(context);
    if (controller != null && controller.hasClients) {
      controller.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear, // TODO(ianh): Use a more appropriate curve.
      );
    }
  }
}
