<img src="https://github.com/jamesblasco/modal_bottom_sheet/blob/main/docs/assets/sheet.gif?raw=true">


# Sheet Package

[![Pub](https://img.shields.io/pub/v/sheet.svg?logo=flutter&color=blue&style=flat-square)](https://pub.dev/packages/sheet)

A fully customizable draggable bottom sheet for Flutter

Sheet is a new package that intends to replace [modal_bottom_sheet](https://pub.dev/packages/modal_bottom_sheet) in a near future 

It allows to add a [Sheet] widget to any page or push a new [SheetRoute] to your navigator.

## Getting Started

Add the sheet package to your pubspec 

```sh
flutter pub add sheet 
```

Learn more about:
  - Using [Sheet](modal_bottom_sheet/tree/main/sheet#sheet) to create bottom sheets inside your page
  - Using [SheetRoute](modal_bottom_sheet/tree/main/sheet#sheetroute) or `SheetPage` to push a new modal bottom sheet route

## Sheet

```dart
Sheet(
 initialExtent: 200,
 child: Container(color: Colors.blue[100]),
)
```

You can add it above any other widget. Usually you might want to use a Stack for that

```dart
Stack(
 children: [
  body,   
  Sheet(
    initialExtent: 200,
    child: Container(color: Colors.blue[100]),
  ),
 ],
)
```


The widget has several parameters that allow fully costumization of the sheet

#### Add an initial position

Use `initialExtent` to set a initial offset from the bottom

```dart
Sheet(
 initialExtent: 200,
 child: Container(color: Colors.blue[100]),
)
```

#### Clamp the sheet between a min and maximun values

You can set a `minExtent` and `maxExtent` to limit the position of the Sheet between those values

```dart
Sheet(
 initialExtent: 200,
 minExtent: 100,
 maxExtent: 400,
 child: Container(color: Colors.blue[100]),
)
```


#### Allow to open the sheet when is fully hidden

When the sheet is hidden you might wanna allow the user to drag up the bottom sheet even if this one is no visible. You can define an area where the interaction can be detected

```dart
Sheet(
 initialExtent: 0,
 minInteractionExtent: 20,
 child: Container(color: Colors.blue[100]),
)
```


#### Fit modes

By default the sheet height will be the minimun between the max available height and the one recommended by the child.

It is possible to force the sheet child to be the maxium size available by setting  `SheetFit.expand`

```dart
Sheet(
 initialExtent: 200,
 fit: SheetFit.expand,
 child: Container(color: Colors.blue[100]),
)
```

#### Resizable

By default the sheet has a fixed sized and it is vertically translated according to the user drag.
It is posible to make the sheet change the height of the child by setting `resize: true`
This will force the child to fit the available visual space.

```dart
Sheet(
 initialExtent: 200,
 resizable:true
 child: Container(color: Colors.blue[100]),
)
```

#### Resizable with min size extent

It is possible to set a min height for a resizable sheet. When the height reaches that min value, the sheet 
will start vertically translating instead of shrinking

```dart
Sheet(
 initialExtent: 200,
 resizable: true
 child: Container(color: Colors.blue[100]),
)
```


#### Control the position of the sheet

It is possible to pass a `SheetController` to control programatically the position of the sheet.

```dart
SheetController controller = SheetController();

Sheet(
 controller: controller,
 initialExtent: 200,
child: Container(color: Colors.blue[100]),
)

controller.jumpTo(400); 
controller.relativeJumpTo(1); // Value between 0 and 1


controller.animateTo(400, ...); 
controller.relativeAnimateTo(1, ...); // Value between 0 and 1
```

The sheet controller also contains an animation value that can be used to animate other parts of the ui in sync

```dart
AnimatedBuilder(
 animation: controller.animation,
 builder: (context, child) {
     return ...;
 }
);
```


## Sheet Route

You can push a new modal bottom sheet route above your current page using `SheetRoute`


```dart
SheetRoute<void>(
  builder: (BuildContext) => Container(),
)
```

Or you can also use `SheetPage` with the Navigator 2.0

```dart
Navigator(
  pages: <Page<dynamic>>[
    MaterialPage<bool>(
      key: const ValueKey<String>('BooksListPage'),
      child: BooksListScreen(
        books: books,
        onTapped: _handleBookTapped,
      ),
    ),
    if (_selectedBook != null)
      SheetPage<void>(
          key: ValueKey<Book?>(_selectedBook),
          child: BookDetailsScreen(book_selectedBook!),
          barrierColor: Colors.black26,
      )
  ],
)
```

An example using [GoRouter](https://pub.dev/packages/go_router) is available [here](https://github.com/jamesblasco/modal_bottom_sheet/blob/main/sheet/example/lib/examples/route/navigation/go_router.dart)



#### Set the initial position

Use `initialExtent` to set the initial position the bottom sheet will be dragged to:

```dart
SheetRoute(
 initialExtent: 200,
 builder: (BuildContext) => Container(color: Colors.blue[100]),
)
```

TBD