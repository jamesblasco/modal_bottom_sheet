import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sheet/route.dart';

class Book {
  const Book(this.id, this.title, this.author);
  final String id;
  final String title;
  final String author;
}

class AdvancedGoRouterBooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GoRouterBooksAppState();
}

class _GoRouterBooksAppState extends State<AdvancedGoRouterBooksApp> {
  List<Book> books = <Book>[
    const Book('1', 'Stranger in a Strange Land', 'Robert A. Heinlein'),
    const Book('2', 'Foundation', 'Isaac Asimov'),
    const Book('3', 'Fahrenheit 451', 'Ray Bradbury'),
  ];

  @override
  void initState() {
    super.initState();
  }

  Brightness brightness = Brightness.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      debugShowCheckedModeBanner: false,
      theme:
          brightness == Brightness.light ? ThemeData.light() : ThemeData.dark(),
      title: 'Books App',
      builder: (BuildContext context, Widget? child) {
        return CupertinoTheme(
          data: CupertinoThemeData(brightness: brightness),
          child: child!,
        );
      },
    );
  }

  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final nestedNavigationKey = GlobalKey<NavigatorState>();
  late final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: rootNavigatorKey,
    routes: <GoRoute>[
      GoRoute(
          path: '/',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return MaterialExtendedPage<void>(
              key: state.pageKey,
              child: BooksListScreen(
                books: books,
                onBrigthnessChanged: (Brightness brightness) {
                  setState(() {
                    this.brightness = brightness;
                  });
                },
              ),
            );
          },
          routes: <RouteBase>[
            ShellRoute(
                navigatorKey: nestedNavigationKey,
                parentNavigatorKey: rootNavigatorKey,
                pageBuilder: (context, state, child) {
                  return CupertinoSheetPage<void>(child: child);
                },
                routes: [
                  GoRoute(
                      name: 'book',
                      path: 'book/:bid',
                      parentNavigatorKey: nestedNavigationKey,
                      pageBuilder: (BuildContext context, GoRouterState state) {
                        final String id = state.pathParameters['bid']!;
                        final Book? book =
                            books.firstWhereOrNull((Book b) => b.id == id);
                        return MaterialPage<void>(
                          key: state.pageKey,
                          child: BookDetailsScreen(
                            book: book!,
                          ),
                        );
                      },
                      redirect: (context, state) {
                        final String id = state.pathParameters['bid']!;
                        final Book? book =
                            books.firstWhereOrNull((Book b) => b.id == id);
                        if (book == null) {
                          return '/404';
                        }
                        // no need to redirect at all
                        return null;
                      },
                      routes: [
                        GoRoute(
                          name: 'Reviews',
                          path: 'reviews',
                          parentNavigatorKey: nestedNavigationKey,
                          pageBuilder: (context, state) {
                            return MaterialPage<void>(
                              key: state.pageKey,
                              child: Scaffold(
                                appBar: AppBar(
                                  title: const Text('Reviews'),
                                ),
                              ),
                            );
                          },
                        ),
                      ]),
                ]),
            GoRoute(
              name: 'new',
              path: 'new',
              parentNavigatorKey: rootNavigatorKey,
              pageBuilder: (BuildContext context, GoRouterState state) {
                return CupertinoSheetPage<void>(
                  key: state.pageKey,
                  child: Scaffold(
                    backgroundColor: Colors.grey[200],
                    appBar: AppBar(
                      title: const Text('New'),
                    ),
                  ),
                );
              },
            ),
          ]),
    ],
  );
}

class BooksListScreen extends StatelessWidget {
  const BooksListScreen({
    required this.books,
    required this.onBrigthnessChanged,
  });
  final List<Book> books;

  final void Function(Brightness) onBrigthnessChanged;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: CupertinoNavigationBar(
        leading: BackButton(onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        }),
        middle: const Text('Book'),
        trailing: IconButton(
          icon: Icon(brightness == Brightness.light
              ? Icons.nightlight_round
              : Icons.wb_sunny),
          onPressed: () {
            onBrigthnessChanged(
              brightness == Brightness.light
                  ? Brightness.dark
                  : Brightness.light,
            );
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            for (Book book in books)
              ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  onTap: () {
                    context.go('/book/${book.id}');
                  },
                  trailing: TextButton(
                    onPressed: () {
                      context.go('/book/${book.id}');
                      context.go('/book/${book.id}/reviews');
                    },
                    child: const Text('Reviews'),
                  ))
          ],
        ),
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({
    required this.book,
  });
  final Book book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        middle: Text('Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0) + const EdgeInsets.only(top: 52.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(book.title, style: Theme.of(context).textTheme.titleLarge),
            Text(book.author, style: Theme.of(context).textTheme.titleMedium),
            TextButton(
              onPressed: () {
                context.go('/book/${book.id}/reviews');
              },
              child: Text('Reviews'),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          context.push('/new');
        },
      ),
    );
  }
}
