import 'package:example/route_example_page.dart';
import 'package:example/sheet_example_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sheet/route.dart';

void main() => runApp(MyApp());

final goRouter = GoRouter(routes: [
  GoRoute(
    path: '/',
    pageBuilder: (context, state) =>
        MaterialExtendedPage<void>(child: const BottomNavigationScaffold()),
  ),
]);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(platform: TargetPlatform.iOS),
      debugShowCheckedModeBanner: false,
      title: 'BottomSheet Modals',
      routerConfig: goRouter,
    );
  }
}

class BottomNavigationScaffold extends StatefulWidget {
  const BottomNavigationScaffold({super.key});

  @override
  State<BottomNavigationScaffold> createState() =>
      _BottomNavigationScaffoldState();
}

class _BottomNavigationScaffoldState extends State<BottomNavigationScaffold> {
  int _currentNavitagionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: IndexedStack(
            index: _currentNavitagionIndex,
            children: const <Widget>[
              SheetExamplesPage(),
              RouteExamplePage(),
            ],
          ),
        ),
        BottomNavigationBar(
            currentIndex: _currentNavitagionIndex,
            onTap: (int value) {
              setState(() {
                _currentNavitagionIndex = value;
              });
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.pages), label: 'Sheet'),
              BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Route'),
            ])
      ],
    );
  }
}
