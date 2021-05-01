import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'examples/cupertino_share.dart';
import 'modals/circular_modal.dart';
import 'modals/cupertino/cupertino_modal_complex_all.dart';
import 'modals/cupertino/cupertino_modal_inside_modal.dart';
import 'modals/cupertino/cupertino_modal_will_scope.dart';
import 'modals/cupertino/cupertino_modal_with_navigator.dart';
import 'modals/cupertino/cupertino_modal_with_scroll.dart';
import 'modals/floating_modal.dart';
import 'modals/modal_fit.dart';
import 'modals/modal_with_nested_scroll.dart';

void main() => runApp(MyCApp());

class MyCApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        // scaffoldBackgroundColor: CupertinoColors.activeOrange,
      ),
      title: 'BottomSheet Modals',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialWithModalsPageRoute(
            builder: (context) => MyCupertinoHomePage(),
            settings: settings,
          );
        } else {
          return CupertinoPageRoute(
            builder: (context) => CupertinoScaffold(
              body: CupertinoPageScaffold(
                child: Builder(
                  builder: (context) => CupertinoPageScaffold(
                    navigationBar: CupertinoNavigationBar(
                      transitionBetweenRoutes: false,
                      middle: Text('Normal Navigation Presentation'),
                      trailing: GestureDetector(
                        child: Icon(CupertinoIcons.up_arrow),
                        onTap: () =>
                            CupertinoScaffold.showCupertinoModalBottomSheet(
                          expand: true,
                          context: context,
                          backgroundColor: Color(0x00000000),
                          builder: (context) => Stack(
                            children: <Widget>[
                              CupertinoModalWithScroll(),
                              Positioned(
                                left: 40,
                                right: 40,
                                bottom: 20,
                                child: CupertinoButton(
                                  onPressed: () =>
                                      Navigator.of(context).popUntil(
                                    (route) => route.settings.name == '/',
                                  ),
                                  child: Text('Pop back home'),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    child: Container(),
                  ),
                ),
              ),
            ),
            settings: settings,
          );
        }
      },
    );
  }
}

class MyCupertinoHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        middle: Text('iOS13 Modal Presentation'),
        trailing: GestureDetector(
          child: Icon(CupertinoIcons.forward),
          onTap: () => Navigator.of(context).pushNamed('modal_and_navigation'),
        ),
      ),
      child: SingleChildScrollView(
        primary: true,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CupertinoListTile(
                title: Text('Cupertino Photo Share Example'),
                onTap: () => Navigator.of(context).push(
                  MaterialWithModalsPageRoute(
                    builder: (context) => CupertinoSharePage(),
                  ),
                ),
              ),
              section('STYLES'),
              CupertinoListTile(
                title: Text('Bar Modal'),
                onTap: () => showBarModalBottomSheet(
                  expand: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CupertinoUserInterfaceLevel(
                    data: CupertinoUserInterfaceLevelData.elevated,
                    child: CupertinoModalInsideModal(),
                  ),
                ),
              ),
              CupertinoListTile(
                title: Text('Avatar Modal'),
                onTap: () => showAvatarModalBottomSheet(
                  expand: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CupertinoUserInterfaceLevel(
                    data: CupertinoUserInterfaceLevelData.elevated,
                    child: CupertinoModalInsideModal(),
                  ),
                ),
              ),
              CupertinoListTile(
                title: Text('Float Modal'),
                onTap: () => showFloatingModalBottomSheet(
                  context: context,
                  builder: (
                    context,
                  ) =>
                      ModalFit(),
                ),
              ),
              CupertinoListTile(
                title: Text('Cupertino Modal fit'),
                onTap: () => showCupertinoModalBottomSheet(
                  expand: false,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (
                    context,
                  ) =>
                      ModalFit(),
                ),
              ),
              section('COMPLEX CASES'),
              CupertinoListTile(
                title: Text('Cupertino Small Modal forced to expand'),
                onTap: () => showCupertinoModalBottomSheet(
                  expand: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ModalFit(),
                ),
              ),
              CupertinoListTile(
                title: Text('Reverse list'),
                onTap: () => showBarModalBottomSheet(
                  expand: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CupertinoUserInterfaceLevel(
                    data: CupertinoUserInterfaceLevelData.elevated,
                    child: CupertinoModalInsideModal(
                      reverse: true,
                    ),
                  ),
                ),
              ),
              CupertinoListTile(
                title: Text('Cupertino Modal inside modal'),
                onTap: () => showCupertinoModalBottomSheet(
                  expand: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CupertinoModalInsideModal(),
                ),
              ),
              CupertinoListTile(
                title: Text('Cupertino Modal with inside navigation'),
                onTap: () => showCupertinoModalBottomSheet(
                  expand: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CupertinoModalWithNavigator(),
                ),
              ),
              CupertinoListTile(
                title: Text('Cupertino Navigator + Scroll + WillPopScope'),
                onTap: () => showCupertinoModalBottomSheet(
                  expand: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CupertinoComplexModal(),
                ),
              ),
              CupertinoListTile(
                title: Text('Modal with WillPopScope'),
                onTap: () => showCupertinoModalBottomSheet(
                  expand: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CupertinoModalWillScope(),
                ),
              ),
              CupertinoListTile(
                title: Text('Modal with Nested Scroll'),
                onTap: () => showCupertinoModalBottomSheet(
                  expand: true,
                  context: context,
                  builder: (context) => NestedScrollModal(),
                ),
              ),
              SizedBox(
                height: 60,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget section(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
      ),
    );
  }
}

class CupertinoListTile extends StatelessWidget {
  final Widget? title;
  final VoidCallback? onTap;

  const CupertinoListTile({
    Key? key,
    this.title,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Theme(
      data: isDark
          ? ThemeData.dark().copyWith(backgroundColor: Colors.black)
          : ThemeData.light(),
      child: Builder(
        builder: (context) => Material(
          color: Color(0x00000000),
          child: Builder(
            builder: (context) => ListTile(
              title: title,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}
