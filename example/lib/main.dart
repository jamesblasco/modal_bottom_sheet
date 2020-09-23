import 'package:example/modals/circular_modal.dart';
import 'package:example/web_frame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'modals/floating_modal.dart';
import 'modals/modal_complex_all.dart';
import 'modals/modal_fit.dart';
import 'modals/modal_inside_modal.dart';
import 'modals/modal_will_scope.dart';
import 'modals/modal_with_navigator.dart';
import 'modals/modal_with_nested_scroll.dart';
import 'modals/modal_with_scroll.dart';
import 'modals/modal_with_page_view.dart';

import 'examples/cupertino_share.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(platform: TargetPlatform.iOS),
      title: 'BottomSheet Modals',
      builder: (context, child) => WebFrame(
        child: child,
      ),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialWithModalsPageRoute(
                builder: (_) => MyHomePage(title: 'Flutter Demo Home Page'),
                settings: settings);
        }
        return MaterialPageRoute(
            builder: (context) => Scaffold(
                  body: CupertinoScaffold(
                    body: Builder(
                      builder: (context) => CupertinoPageScaffold(
                        backgroundColor: Colors.white,
                        navigationBar: CupertinoNavigationBar(
                          transitionBetweenRoutes: false,
                          middle: Text('Normal Navigation Presentation'),
                          trailing: GestureDetector(
                              child: Icon(Icons.arrow_upward),
                              onTap: () => CupertinoScaffold
                                      .showCupertinoModalBottomSheet(
                                    expand: true,
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => Stack(
                                      children: <Widget>[
                                        ModalWithScroll(),
                                        Positioned(
                                          height: 40,
                                          left: 40,
                                          right: 40,
                                          bottom: 20,
                                          child: MaterialButton(
                                            onPressed: () => Navigator.of(
                                                    context)
                                                .popUntil((route) =>
                                                    route.settings.name == '/'),
                                            child: Text('Pop back home'),
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                        ),
                        child: Center(child: Container()),
                      ),
                    ),
                  ),
                ),
            settings: settings);
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.height);
    return Material(
      child: Scaffold(
        body: CupertinoPageScaffold(
          backgroundColor: Colors.white,
          navigationBar: CupertinoNavigationBar(
            transitionBetweenRoutes: false,
            middle: Text('iOS13 Modal Presentation'),
            trailing: GestureDetector(
              child: Icon(Icons.arrow_forward),
              onTap: () => Navigator.of(context).pushNamed('ss'),
            ),
          ),
          child: SizedBox.expand(
            child: SingleChildScrollView(
              primary: true,
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                        title: Text('Cupertino Photo Share Example'),
                        onTap: () => Navigator.of(context).push(
                            MaterialWithModalsPageRoute(
                                builder: (context) => CupertinoSharePage()))),
                    section('STYLES'),
                    ListTile(
                        title: Text('Material fit'),
                        onTap: () => showMaterialModalBottomSheet(
                              expand: false,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ModalFit(),
                            )),
                    ListTile(
                        title: Text('Bar Modal'),
                        onTap: () => showBarModalBottomSheet(
                              expand: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ModalInsideModal(),
                            )),
                    ListTile(
                        title: Text('Avatar Modal'),
                        onTap: () => showAvatarModalBottomSheet(
                              expand: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ModalInsideModal(),
                            )),
                    ListTile(
                        title: Text('Float Modal'),
                        onTap: () => showFloatingModalBottomSheet(
                              context: context,
                              builder: (context) => ModalFit(),
                            )),
                    ListTile(
                        title: Text('Cupertino Modal fit'),
                        onTap: () => showCupertinoModalBottomSheet(
                              expand: false,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ModalFit(),
                            )),
                    section('COMPLEX CASES'),
                    ListTile(
                        title: Text('Cupertino Small Modal forced to expand'),
                        onTap: () => showCupertinoModalBottomSheet(
                              expand: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ModalFit(),
                            )),
                    ListTile(
                        title: Text('Reverse list'),
                        onTap: () => showBarModalBottomSheet(
                              expand: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  ModalInsideModal(reverse: true),
                            )),
                    ListTile(
                        title: Text('Cupertino Modal inside modal'),
                        onTap: () => showCupertinoModalBottomSheet(
                              expand: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ModalInsideModal(),
                            )),
                    ListTile(
                        title: Text('Cupertino Modal with inside navigation'),
                        onTap: () => showCupertinoModalBottomSheet(
                              expand: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ModalWithNavigator(),
                            )),
                    ListTile(
                        title:
                            Text('Cupertino Navigator + Scroll + WillPopScope'),
                        onTap: () => showCupertinoModalBottomSheet(
                              expand: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  ComplexModal(),
                            )),
                    ListTile(
                        title: Text('Modal with WillPopScope'),
                        onTap: () => showCupertinoModalBottomSheet(
                              expand: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  ModalWillScope(),
                            )),
                    ListTile(
                        title: Text('Modal with Nested Scroll'),
                        onTap: () => showCupertinoModalBottomSheet(
                              expand: true,
                              context: context,
                              builder: (context) =>
                                  NestedScrollModal(),
                            )),
                    ListTile(
                        title: Text('Modal with PageView'),
                        onTap: () => showBarModalBottomSheet(
                          expand: true,
                          context: context,
                          builder: (context, scrollController) =>
                              ModalWithPageView(
                                  scrollController: scrollController),
                        )),
                    SizedBox(
                      height: 60,
                    )
                  ],
                ),
              ),
            ),
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
          style: Theme.of(context).textTheme.caption,
        ));
  }
}
