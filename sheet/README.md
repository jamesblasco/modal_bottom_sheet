# Sheet

A fully customizable draggable bottom sheet for Flutter

## Getting Started

```dart
Sheet(
 initialExtent: 200,
 child: Container(color: Colors.blue[100]),
)
```

You can add it above any widget 

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

# Add an initial position
Sheet(
 initialExtent: 200,
 child: Container(color: Colors.blue[100]),
)


# Clamp the sheet between a min and maximun values
Sheet(
 initialExtent: 200,
 minExtent: 100,
 maxExtent: 400,
 child: Container(color: Colors.blue[100]),
)


# Set a space value of interaction

When the sheet is hidden you might wanna allow the user to drag up the
bottom sheet even if this one is no visible. You can define an area where
the interaction can be detected

Sheet(
 initialExtent: 0,
 minInteractionExtent: 20,
 child: Container(color: Colors.blue[100]),
)


# Fit modes

By default the sheet height will be the minimun between the max available height and the 
one recommended by the child.

It is possible to force the sheet child to be the maxium size available by setting  `SheetFit.expand`

Sheet(
 initialExtent: 200,
 fit: SheetFit.expand,
 child: Container(color: Colors.blue[100]),
)

# Resizable

By default the sheet has a fixed sized and it is translated according to the user scroll.
It is posible to make the sheet change the height of the child by setting `resize: true`
This will force the child to fit the available visual space.

Sheet(
 initialExtent: 200,
 resizable:true
 child: Container(color: Colors.blue[100]),
)

# Resizable with min size extent

It is possible to set a min height for a resizable sheet. When the height reaches that min value, the sheet 
will start translating instead of shrinking

```dart
Sheet(
 initialExtent: 200,
 resizable: true
 child: Container(color: Colors.blue[100]),
)
```


# Control the position of the sheet

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

The sheet controller also contains an animation value that can be used
to animate other parts of the ui in sync

```dart
AnimatedBuilder(
 animation: controller.animation,
 builder: (context, child) {
     return ...;
 }
);
```

The sheet controller also contains an animation value that can be used
to animate other parts of the ui in sync
