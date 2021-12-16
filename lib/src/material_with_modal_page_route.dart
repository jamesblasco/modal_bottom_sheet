import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../modal_bottom_sheet.dart';
import 'bottom_sheet_route.dart';

class MaterialWithModalsPageRoute<T> extends MaterialPageRoute<T> {
  /// Construct a MaterialPageRoute whose contents are defined by [builder].
  ///
  /// The values of [builder], [maintainState], and [fullScreenDialog] must not
  /// be null.
  MaterialWithModalsPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  })  : super(
            settings: settings,
            fullscreenDialog: fullscreenDialog,
            builder: builder,
            maintainState: maintainState);

  ModalBottomSheetRoute? _nextModalRoute;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    return (nextRoute is MaterialPageRoute && !nextRoute.fullscreenDialog) ||
        (nextRoute is CupertinoPageRoute && !nextRoute.fullscreenDialog) ||
        (nextRoute is MaterialWithModalsPageRoute &&
            !nextRoute.fullscreenDialog) ||
        (nextRoute is ModalBottomSheetRoute);
  }

  @override
  void didChangeNext(Route? nextRoute) {
    if (nextRoute is ModalBottomSheetRoute) {
      _nextModalRoute = nextRoute;
    }

    super.didChangeNext(nextRoute);
  }

  @override
  void didPopNext(Route nextRoute) {
    super.didPopNext(nextRoute);
  }

  @override
  bool didPop(T? result) {
    _nextModalRoute = null;
    return super.didPop(result);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final theme = Theme.of(context).pageTransitionsTheme;
    final nextRoute = _nextModalRoute;
    if (nextRoute != null) {
      if (!secondaryAnimation.isDismissed) {
        // Avoid default transition theme to animate when a new modal view is pushed
        final fakeSecondaryAnimation =
            Tween<double>(begin: 0, end: 0).animate(secondaryAnimation);

        final defaultTransition = theme.buildTransitions<T>(
            this, context, animation, fakeSecondaryAnimation, child);
        return nextRoute.getPreviousRouteTransition(
            context, secondaryAnimation, defaultTransition);
      } else {
        _nextModalRoute = null;
      }
    }

    return theme.buildTransitions<T>(
        this, context, animation, secondaryAnimation, child);
  }
}
