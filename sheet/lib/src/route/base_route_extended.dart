import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'delegated_transitions_route.dart';
import 'sheet_route.dart';

mixin PreviousSheetRouteMixin<T> on PageRoute<T> {
  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return nextRoute is SheetRoute || super.canTransitionTo(nextRoute);
  }
}

class MaterialExtendedPageRoute<T> extends MaterialPageRoute<T>
    with PreviousSheetRouteMixin<T>, DelegatedTransitionsRoute<T> {
  MaterialExtendedPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
          builder: builder,
          maintainState: maintainState,
          settings: settings,
          fullscreenDialog: fullscreenDialog,
        );
}

class MaterialExtendedPage<T> extends Page<T> {
  /// Creates a material page.
  const MaterialExtendedPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
            key: key,
            name: name,
            arguments: arguments,
            restorationId: restorationId);

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) {
    return _PageBasedMaterialPageRoute<T>(page: this);
  }
}

// A page-based version of MaterialPageRoute.
//
// This route uses the builder from the page to build its content. This ensures
// the content is up to date after page updates.
class _PageBasedMaterialPageRoute<T> extends MaterialExtendedPageRoute<T> {
  _PageBasedMaterialPageRoute({
    required MaterialExtendedPage<T> page,
  }) : super(
          settings: page,
          builder: (BuildContext context) => page.child,
        );

  MaterialExtendedPage<T> get _page => settings as MaterialExtendedPage<T>;

  @override
  Widget buildContent(BuildContext context) {
    return _page.child;
  }

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}

class CupertinoExtendedPageRoute<T> extends CupertinoPageRoute<T>
    with PreviousSheetRouteMixin<T>, DelegatedTransitionsRoute<T> {
  CupertinoExtendedPageRoute({
    required WidgetBuilder builder,
    String? title,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
          builder: builder,
          title: title,
          maintainState: maintainState,
          settings: settings,
          fullscreenDialog: fullscreenDialog,
        );
}

class CupertinoExtendedPage<T> extends Page<T> {
  /// Creates a cupertino page.
  const CupertinoExtendedPage({
    required this.child,
    this.maintainState = true,
    this.title,
    this.fullscreenDialog = false,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
            key: key,
            name: name,
            arguments: arguments,
            restorationId: restorationId);

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.cupertino.CupertinoRouteTransitionMixin.title}
  final String? title;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) {
    return _PageBasedCupertinoPageRoute<T>(page: this);
  }
}

class _PageBasedCupertinoPageRoute<T> extends CupertinoExtendedPageRoute<T> {
  _PageBasedCupertinoPageRoute({
    required CupertinoExtendedPage<T> page,
  }) : super(
          settings: page,
          builder: (BuildContext context) => page.child,
        );

  CupertinoExtendedPage<T> get _page => settings as CupertinoExtendedPage<T>;

  @override
  Widget buildContent(BuildContext context) {
    return _page.child;
  }

  @override
  String? get title => _page.title;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}
