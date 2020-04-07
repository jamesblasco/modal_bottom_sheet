<img src="https://github.com/jamesblasco/modal_bottom_sheet/blob/master/screenshots/preview.png?raw=true">

# Flutter Modal Bottom Sheet

Create awesome and powerful modal bottom sheets
 
|  Cupertino Modal |  Multiple Modals |  Material Modal | Bar Modal  |  Create your own |
|---|---|---|---|---|
|<img height="300" src="https://github.com/jamesblasco/modal_bottom_sheet/blob/master/screenshots/cupertino_shared_view.gif?raw=true">| <img  height="300" src="https://github.com/jamesblasco/modal_bottom_sheet/blob/master/screenshots/modal_inside_modal.gif?raw=true">| <img   height="300" src="https://github.com/jamesblasco/modal_bottom_sheet/blob/master/screenshots/material_fit.png?raw=true">|<img   height="300" src="https://github.com/jamesblasco/modal_bottom_sheet/blob/master/screenshots/bar_modal.png?raw=true">| <img height="300" src="https://github.com/jamesblasco/modal_bottom_sheet/blob/master/screenshots/avatar_modal.png?raw=true">|

## First Steps

How to install it? [Follow Instructions](
https://pub.dev/packages/modal_bottom_sheet#-installing-tab-)

## Material Modal BottomSheet

```dart
showMaterialModalBottomSheet(
  context: context,
  builder: (context, scrollController) => Container(),
})
```
What to use this over flutter `showModalBottomSheet`?
`showMaterialModalBottomSheet` supports closing bottoms sheets by dragging down even if there is a scrollview inside.
`showModalBottomSheet` won't work correctly with scrollviews

#### Generic params for all modal bottom sheets

| Param | Description |
|---|---|
|bool expand = false| The `expand` parameter specifies id the modal bottom sheet will be full screen size or will fit the content child|
|bool useRootNavigator = false| The `useRootNavigator` parameter ensures that the root navigator is used to display the bottom sheet when set to `true`. This is useful in the case that a modal bottom sheet needs to be displayed above all other content but the caller is inside another `Navigator`. |
|bool isDismissible = true| The `isDismissible` parameter specifies whether the bottom sheet will be dismissed when user taps on the scrim. |
|Color barrierColor | The `barrierColor` parameter controls the color of the scrim for this route |
|bool enableDrag = true| The `enableDrag` parameter specifies whether the bottom sheet can be dragged up and down and dismissed by swiping downwards. |
|AnimationController secondAnimation| The `secondAnimation` parameter allows you to provide an animation controller that will be used to animate  push/pop of the modal route. Using this param is advised against and will be probably removed in future versions |
|bool bounce = false| The `enableDrag` parameter specifies if the bottom sheet can go beyond the top boundary while dragging |


#### Material params
The optional `backgroundColor`, `elevation`, `shape`, and `clipBehavior` parameters can be passed in to customize the appearance and behavior of material bottom sheets.


## Cupertino Modal BottomSheet

iOS 13 came with an amazing new modal navigation and now it is available to use with Flutter.

### OPTION 1. Recommended.
1. use `showCupertinoModalBottomSheet` 
2. `MaterialPageRoute` does not allow animated translation for routes that are not `MaterialPageRoute` or `CupertinoPageRoute`.
For this we created `MaterialWithModalsPageRoute` that needs to replace the route you are using now. 
Notice this route type works the same as `MaterialPageRoute` and will support custom `PageTransitionsTheme`.


### OPTION 2. 
1. Wrap previous page inside a `CupertinoScaffold`. 
2. Call `CupertinoScaffold.showCupertinoModalBottomSheet(context:context, builder: ...)`

These two options won't work correctly together. 

It supports native features as bouncing, blurred background, dark mode, stacking modals and inside navigation.

For stacking modals call `showCupertinoModalBottomSheet` inside a modal;
For inside navigation use a CupertinoTabScaffold or a Navigator.

Also it support flutter features as WillPopScope.

## Build other BottomSheets 

Try `showBarModalBottomSheet` for a bottomSheet with the appearance used by Facebook or Slack

Check in the example project `showAvatarModalBottomSheet` for how to create your own ModalBottomSheet

## Roadmap
- [ ] Support closing by dragging fast on a modal with a scroll view.

- [ ] Improve animation curves when user is not dragging.

- [ ] Allow to set the initial size of the bottom sheet

- [ ] Support hero animations [Pull Request #2](https://github.com/jamesblasco/modal_bottom_sheet/pull/2)

<img height="400" src="https://user-images.githubusercontent.com/19904063/78669024-e8600800-78db-11ea-81ab-338398728de8.gif">
       
