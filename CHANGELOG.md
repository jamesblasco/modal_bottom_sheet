## [1.0.0-dev] - Improved performance and breaking change
- The `builder` param has changed from:
```dart
showMaterialModalBottomSheet(
  context: context,
  builder: (context, scrollController) {
       return SingleChildScrollView(
        controller: scrollController,
        child: Container()
      )
  },
)
```
to 

```dart
showMaterialModalBottomSheet(
  context: context,
  builder: (context) {
      return SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Container()
      )
  },
)
```
- Appart from the visual change, with this changes you can access the controller from every inner widget without having to pass it to every constructor. Also now the builder method will be called only once as before it was calling multiple times while the modal was being animated.

## [0.2.1+2] - Reverse fix Flutter 22 beta breaking change
- https://github.com/jamesblasco/modal_bottom_sheet/issues/69

## [0.2.1+1-dev] - Fix Flutter 22 beta breaking change
- https://github.com/jamesblasco/modal_bottom_sheet/issues/69

## [0.2.0+1] - ScrollView bug fix
- Fix bug when scrollview was not used 

## [0.2.0] - New Cool Features
- Added support for scroll-to-top by tapping the status bar on iOS devices.
- Use `curveAnimation` to define a custom curve animation for the modal transition
- Bug fixes releated to horizontal scroll, clamping physics and othes.


## [0.1.6] - New custom params
- Use `duration` to define the opening duration of the modal
- Change the top radius of the cupertino bottom sheet 
Thanks to @bierbaumtim @troyanskiy @rodineijf for the contributions

## [0.1.5] - Scroll improvements and bug fixes
- Support for closing a modal with a scroll view by dragging down fast.
- Fix assertion in CupertinoBottomSheet and BottomSheetRoute when using the CupetinoApp or WidgetsApp as root
- Fix assertion when scrollController isn't used by the builder 


## [0.1.4] - Clean code and fix small bugs

## [0.1.0] - Package Release.

## [0.0.1] - Pre Release.

