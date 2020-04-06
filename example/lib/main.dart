import 'package:example/modals/circular_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'modals/modal_complex_all.dart';
import 'modals/modal_fit.dart';
import 'modals/modal_inside_modal.dart';
import 'modals/modal_inside_modal.dart';
import 'modals/modal_simple.dart';
import 'modals/modal_will_scope.dart';
import 'modals/modal_with_navigator.dart';
import 'modals/modal_with_scroll.dart';

import 'examples/cupertino_share.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                          middle: Text('Normal Navigation Presentation'),
                          trailing: GestureDetector(
                              child: Icon(Icons.arrow_upward),
                              onTap: () => CupertinoScaffold
                                      .showCupertinoModalBottomSheet(
                                    expand: true,
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (context, scrollController) =>
                                        Stack(
                                      children: <Widget>[
                                        ModalWithScroll(
                                            scrollController: scrollController),
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
      child: CupertinoPageScaffold(
        backgroundColor: Colors.white,
        navigationBar: CupertinoNavigationBar(
          middle: Text('iOS13 Modal Presentation'),
          trailing: GestureDetector(
            child: Icon(Icons.arrow_forward),
            onTap: () => Navigator.of(context).pushNamed('ss'),
          ),
        ),
        child: SizedBox.expand(
          child: SingleChildScrollView(
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                      title: Text('Cupertino Photo Share Example'),
                      onTap: () => Navigator.of(context).push(
                          MaterialWithModalsPageRoute(
                              builder: (context) => CupertinoSharePage()))),
                  ListTile(
                      title: Text('Material fit'),
                      onTap: () => showMaterialModalBottomSheet(
                            expand: false,
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context, scrollController) =>
                                ModalFit(scrollController: scrollController),
                          )),
                  ListTile(
                      title: Text('Bar Modal'),
                      onTap: () => showBarModalBottomSheet(
                            expand: true,
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context, scrollController) =>
                                ModalInsideModal(
                                    scrollController: scrollController),
                          )),
                  ListTile(
                      title: Text('Avatar Modal'),
                      onTap: () => showAvatarModalBottomSheet(
                            expand: true,
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context, scrollController) =>
                                ModalInsideModal(
                                    scrollController: scrollController),
                          )),
                  ListTile(
                      title: Text('Cupertino Modal fit'),
                      onTap: () => showCupertinoModalBottomSheet(
                            expand: false,
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context, scrollController) =>
                                ModalFit(scrollController: scrollController),
                          )),
                  ListTile(
                      title: Text('Cupertino Small Modal forzed to expand'),
                      onTap: () => showCupertinoModalBottomSheet(
                            expand: true,
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context, scrollController) =>
                                ModalFit(scrollController: scrollController),
                          )),
                  ListTile(
                      title: Text('Cupertino Modal inside modal'),
                      onTap: () => showCupertinoModalBottomSheet(
                            expand: true,
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context, scrollController) =>
                                ModalInsideModal(
                                    scrollController: scrollController),
                          )),
                  ListTile(
                      title: Text('Cupertino Navigator + Scroll + WillScope'),
                      onTap: () => showCupertinoModalBottomSheet(
                            expand: true,
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context, scrollController) =>
                                ComplexModal(
                                    scrollController: scrollController),
                          )),
                  ListTile(
                      title: Text('Cupertino Modal with WillScope'),
                      onTap: () => showCupertinoModalBottomSheet(
                            expand: true,
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context, scrollController) =>
                                ModalWillScope(
                                    scrollController: scrollController),
                          )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
