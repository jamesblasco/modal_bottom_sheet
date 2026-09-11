import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sheet/route.dart';

class GoRouterPopScopeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PopScope Example',
      routerConfig: _router,
      theme: ThemeData.light(),
    );
  }

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => HomeScreen(),
        routes: [
          GoRoute(
            path: 'detail',
            pageBuilder: (_, __) => SheetPage(child: DetailScreen()),
          ),
        ],
      ),
    ],
  );
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        leading: BackButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop()),
        middle: Text('Home')
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/detail'),
          child: Text('Open Sheet'),
        ),
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool canPop = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmExit(context)) Navigator.pop(context, result);
      },
      child: Scaffold(
        appBar: CupertinoNavigationBar(middle: Text('Detail')),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("canPop"),
              Switch(value: canPop, onChanged: (value) => setState(() => canPop = value)),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmExit(BuildContext context) async {
    return await showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoActionSheet(
            title: Text('Should Close?'),
            actions: [
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context, true),
                child: Text('OK'),
              ),
              CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
