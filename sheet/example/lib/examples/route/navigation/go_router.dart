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

class GoRouterBooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GoRouterBooksAppState();
}

class _GoRouterBooksAppState extends State<GoRouterBooksApp> {
  List<Book> books = <Book>[
    const Book('1', 'Stranger in a Strange Land', 'Robert A. Heinlein'),
    const Book('2', 'Foundation', 'Isaac Asimov'),
    const Book('3', 'Fahrenheit 451', 'Ray Bradbury'),
  ];

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

  late final GoRouter _router = GoRouter(
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
          routes: <GoRoute>[
            GoRoute(
              name: 'book',
              path: 'book/:bid',
              pageBuilder: (BuildContext context, GoRouterState state) {
                final String id = state.pathParameters['bid']!;
                final Book? book =
                    books.firstWhereOrNull((Book b) => b.id == id);
                return CupertinoSheetPage<void>(
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
              )
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Invalid'),
              ),
            );
          }));
        },
      ),
    );
  }
}
