import 'package:flutter/material.dart';

/// A mixin used by routes to allow the top route define how the bottom route
/// will animate when the top route enters and exits.
///
/// When a [Navigator] is instructed to pop/push, the bottom route will check if the
/// top route should define the secondary animation transition for this bottom route
/// and in that case it will delegate that transition
mixin DelegatedTransitionsRoute<T> on ModalRoute<T> {
  /// Override this method to wrap the [child] with one or more transition
  /// widgets that define how the previous route will hides/shows when this route
  /// is pushed on top of it or when then this route is popped off of it.
  ///
  /// This method is called only when `handleSecondaryAnimationTransitionForPreviousRoute`
  /// returns true and it will override the transition defined by `secondaryAnimation`
  /// inside [buildTransitions]. In this case, then the previous route's
  /// [ModalRoute.buildTransitions]  `secondaryAnimation` value will be kAlwaysDismissedAnimation.
  ///
  /// By default, the child (which contains the widget returned by previous
  /// route's [ModalRoute.buildPage]) is not wrapped in any transition widgets.
  ///
  /// When the [Navigator] pushes this route on the top of its stack, this
  /// method together with [secondaryAnimation] can be used to define how the
  /// previous route that was on the top of the stack leaves the screen.
  /// Similarly when the topmost route is popped, the secondaryAnimation
  /// can be used to define how the previous route below it reappears on the screen.
  ///
  /// When the Navigator pushes this new route on the top of its stack,
  /// the old topmost route's secondaryAnimation runs from 0.0 to 1.0.
  /// When the Navigator pops the topmost route, the
  /// secondaryAnimation for the route below it runs from 1.0 to 0.0.
  ///
  /// The example below adds a transition that's driven by the
  /// [secondaryAnimation]. When the previous route disappears because this route has
  /// been pushed on top of it, it translates to right. And the opposite when
  /// the route is exposed because this topmost route has been popped off.
  ///
  /// ```dart
  /// return SlideTransition(
  ///   position: TweenOffset(
  ///     begin: Offset.zero,
  ///     end: const Offset(0.0, 1.0),
  ///   ).animate(secondaryAnimation),
  ///   child: child,
  /// );
  ///
  ///  * `context`: The context in which the route is being built.
  ///  * [secondaryAnimation]: When the Navigator pushes this route
  ///    on the top of its stack, the previous topmost route's [secondaryAnimation]
  ///    runs from 0.0 to 1.0. When the [Navigator] pops the topmost route, the
  ///    [secondaryAnimation] for the route below it runs from 1.0 to 0.0.
  ///  * `child`, the page contents from the previous route by
  ///     previous route's [buildPage].
  Widget buildSecondaryTransitionForPreviousRoute(
    BuildContext context,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }

  /// Returns true if the [previousRoute] bottom route should delegate the
  /// `secondaryAnimation` transition when this route is pushed on top of it
  /// or when then this route is popped off of it.
  ///
  /// Subclasses can override this method to restrict the set of routes they
  /// need to coordinate transitions with.
  ///
  /// If true, and `previousRoute.canTransitionTo()` is true, then the route
  /// [previousRoute] will delegate its `secondaryAnimation` transition to
  /// this route's [buildSecondaryTransitionForPreviousRoute] method
  ///
  /// If false, [previousRoute]'s `secondaryAnimation` transition will be
  /// handled by default by [buildTransitions]
  ///
  /// Returns false by default.
  ///
  /// See also:
  ///  * [canTransitionTo], which must be true for [previousRoute] for the
  ///    [buildSecondaryTransitionForPreviousRoute] `secondaryAnimation` to run.
  ///
  ///  * [buildSecondaryTransitionForPreviousRoute], to define
  ///    [previousRoute]'s `secondaryAnimation` transition when this is true
  bool canDriveSecondaryTransitionForPreviousRoute(
          Route<dynamic> previousRoute) =>
      false;

  List<DelegatedTransitionsRoute<dynamic>>? _nextRoutes;

  @override
  void didChangeNext(Route<dynamic>? nextRoute) {
    if (nextRoute is DelegatedTransitionsRoute &&
        nextRoute.canDriveSecondaryTransitionForPreviousRoute(this)) {
      _nextRoutes ??= <DelegatedTransitionsRoute<dynamic>>[];
      _nextRoutes!.add(nextRoute);

      nextRoute.completed.then((dynamic value) {
        _nextRoutes!.remove(nextRoute);
      });
    }
    super.didChangeNext(nextRoute);
  }

  @override
  void didReplace(Route<dynamic>? oldRoute) {
    if (oldRoute is DelegatedTransitionsRoute && oldRoute._nextRoutes != null) {
      _nextRoutes =
          List<DelegatedTransitionsRoute<dynamic>>.from(oldRoute._nextRoutes!);
    }
    super.didReplace(oldRoute);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (_nextRoutes != null && _nextRoutes!.isNotEmpty) {
      Widget proxyChild = child;
      for (final DelegatedTransitionsRoute<dynamic> nextRoute in _nextRoutes!) {
        final ProxyAnimation secondaryAnimation =
            ProxyAnimation(nextRoute.animation!);
        // assert(!nextRoute._transitionCompleter.isCompleted,  'Cannot reuse a ${nextRoute.runtimeType} after disposing it.');
        proxyChild = nextRoute.buildSecondaryTransitionForPreviousRoute(
            context, secondaryAnimation, child);
      }

      final ProxyAnimation proxySecondaryAnimation =
          ProxyAnimation(kAlwaysDismissedAnimation);
      return super.buildTransitions(
          context, animation, proxySecondaryAnimation, proxyChild);
    } else {
      return super
          .buildTransitions(context, animation, secondaryAnimation, child);
    }
  }
}
