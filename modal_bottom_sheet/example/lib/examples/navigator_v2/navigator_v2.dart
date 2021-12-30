import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  Book? _selectedBook;

  List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  Brightness brightness = Brightness.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          brightness == Brightness.light ? ThemeData.light() : ThemeData.dark(),
      title: 'Books App',
      builder: (context, child) {
        return CupertinoTheme(
          data: CupertinoThemeData(brightness: brightness),
          child: child!,
        );
      },
      home: Navigator(
        pages: [
          MaterialPage<bool>(
            key: ValueKey('BooksListPage'),
            child: BooksListScreen(
              books: books,
              onTapped: _handleBookTapped,
              onBrigthnessChanged: (brightness) {
                setState(() {
                  this.brightness = brightness;
                });
              },
            ),
          ),
          if (_selectedBook != null)
            SheetPage<void>(
                key: ValueKey(_selectedBook),
                child: BookDetailsScreen(book: _selectedBook!),
                barrierColor: Colors.black26)
        ],
        onPopPage: (route, dynamic result) {
          if (!route.didPop(result)) {
            return false;
          }

          // Update the list of pages by setting _selectedBook to null
          setState(() {
            _selectedBook = null;
          });

          return true;
        },
      ),
    );
  }

  void _handleBookTapped(Book book) {
    setState(() {
      _selectedBook = book;
    });
  }
}

class BookDetailsPage<T> extends Page<T> {
  final Book? book;

  BookDetailsPage({
    this.book,
  }) : super(key: ValueKey(book));

  Route<T> createRoute(BuildContext context) {
    return CupertinoSheetRoute<T>(
      settings: this,
      builder: (BuildContext context) {
        return BookDetailsScreen(book: book!);
      },
    );
  }
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<Book> onTapped;
  final void Function(Brightness) onBrigthnessChanged;

  BooksListScreen({
    required this.books,
    required this.onTapped,
    required this.onBrigthnessChanged,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: CupertinoNavigationBar(
        leading: BackButton(onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        }),
        middle: Text('Book'),
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
          children: [
            for (var book in books)
              ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
                onTap: () => onTapped(book),
              )
          ],
        ),
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  BookDetailsScreen({
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text('Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0) + EdgeInsets.only(top: 52.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(book.title, style: Theme.of(context).textTheme.headline6),
            Text(book.author, style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Invalid'),
              ),
            );
          }));
        },
      ),
    );
  }
}
