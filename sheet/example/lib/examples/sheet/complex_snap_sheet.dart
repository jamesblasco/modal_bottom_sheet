// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sheet/sheet.dart';

class AdvancedSnapSheetPage extends StatefulWidget {
  @override
  _AdvancedSnapSheetPageState createState() => _AdvancedSnapSheetPageState();
}

class _AdvancedSnapSheetPageState extends State<AdvancedSnapSheetPage>
    with TickerProviderStateMixin {
  late SheetController controller;

  @override
  void initState() {
    controller = SheetController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey[200],
      appBar: MapAppBar(controller: controller),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        unselectedItemColor: Colors.grey[400],
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: (int index) {
          controller.relativeAnimateTo(0.3,
              duration: Duration(milliseconds: 200), curve: Curves.easeIn);
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              label: 'Explore', icon: Icon(Icons.place_outlined)),
          BottomNavigationBarItem(label: 'Go', icon: Icon(Icons.bus_alert)),
          BottomNavigationBarItem(
              label: 'Saved', icon: Icon(Icons.bookmark_border)),
          BottomNavigationBarItem(
              label: 'Updates', icon: Icon(Icons.add_alert_outlined)),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/map.png',
              fit: BoxFit.cover,
            ),
          ),
          FloatingButtons(controller: controller),
          Positioned.fill(
            top: kToolbarHeight + MediaQuery.of(context).padding.top - 18,
            child: MapSheet(controller: controller),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class MapAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MapAppBar({Key? key, required this.controller}) : super(key: key);
  final SheetController controller;
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  @override
  State<MapAppBar> createState() => _MapAppBarState();
}

class _MapAppBarState extends State<MapAppBar> {
  bool scrolled = false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      widget.controller.position.scrollController.addListener(() {
        if (widget.controller.position.scrollController.position.pixels > 60) {
          setState(() {
            scrolled = true;
          });
        } else {
          setState(() {
            scrolled = false;
          });
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !scrolled
        ? AnimatedBuilder(
            animation: widget.controller.animation,
            builder: (BuildContext context, Widget? child) {
              final bool sheetBar = widget.controller.animation.value > 0.98;
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: sheetBar ? 1 : 0),
                duration: Duration(milliseconds: 200),
                builder: (BuildContext context, double t, Widget? child) {
                  final double elevation =
                      Tween<double>(begin: 4.0, end: 0.0).transform(t);
                  final Color? color = ColorTween(
                          begin: Colors.white.withOpacity(0), end: Colors.white)
                      .transform(t);
                  final Color? borderColor = ColorTween(
                          begin: Colors.grey[200]!.withOpacity(0),
                          end: Colors.grey[200])
                      .transform(t);
                  return AppBar(
                    elevation: 0,
                    systemOverlayStyle: SystemUiOverlayStyle.dark,
                    backgroundColor: color,
                    automaticallyImplyLeading: false,
                    title: Material(
                      borderRadius: BorderRadius.circular(24),
                      elevation: elevation,
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.place),
                          hintText: 'Search here',
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: borderColor!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: borderColor),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            })
        : AppBar(
            elevation: 1,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            automaticallyImplyLeading: false,
            title: Text('Latest near you'),
            leading: IconButton(
              onPressed: () async {
                await widget.controller.position.scrollController.animateTo(0,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeIn);
                await widget.controller.relativeAnimateTo(0.3,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeOut);
              },
              icon: Icon(Icons.arrow_downward),
            ),
          );
  }
}

class FloatingButtons extends StatelessWidget {
  const FloatingButtons({Key? key, required this.controller}) : super(key: key);
  final SheetController controller;
  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double height =
        mediaQuery.size.height - mediaQuery.padding.top - kToolbarHeight;
    return AnimatedBuilder(
        animation: controller.animation,
        builder: (BuildContext context, Widget? child) {
          return Positioned(
              right: 0,
              bottom: height * min(0.3, controller.animation.value),
              child: Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    FloatingActionButton(
                      child: Icon(Icons.location_searching),
                      foregroundColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.white,
                      key: Key('value'),
                      heroTag: 'ggg',
                      onPressed: () {
                        controller.relativeAnimateTo(
                          0.1,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeIn,
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    FloatingActionButton(
                      child: Icon(Icons.directions),
                      onPressed: () {
                        controller.relativeAnimateTo(
                          0.1,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeIn,
                        );
                      },
                    ),
                  ],
                ),
              ));
        });
  }
}

class MapSheet extends StatelessWidget {
  const MapSheet({Key? key, required this.controller}) : super(key: key);
  final SheetController controller;
  @override
  Widget build(BuildContext context) {
    return Sheet(
      backgroundColor: Colors.transparent,
      initialExtent: 120,
      controller: controller,
      physics: SnapSheetPhysics(
        stops: const <double>[0, 0.1, 0.3, 1],
      ),
      /*   snap: true,
                stops: [0, 0.1, 0.3, 0.5, 1], */
      child: AnimatedBuilder(
        animation: controller.animation,
        builder: (BuildContext context, Widget? child) {
          final bool sheetBar = controller.animation.value > 0.95;
          return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: sheetBar ? 1 : 0),
              duration: Duration(milliseconds: 200),
              builder: (BuildContext context, double t, Widget? child) {
                final double radius =
                    Tween<double>(begin: 16.0, end: 0.0).transform(t);

                final Color? shadow = ColorTween(
                        begin: Colors.black26,
                        end: Colors.black26.withOpacity(0))
                    .transform(t);
                final Color? barColor = ColorTween(
                        begin: Colors.grey[200],
                        end: Colors.grey[200]?.withOpacity(0))
                    .transform(t);
                return MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(radius),
                          topRight: Radius.circular(radius),
                        ),
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(color: shadow!, blurRadius: 12),
                        ]),
                    child: Column(children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8),
                        width: 36,
                        height: 4,
                        color: barColor,
                        alignment: Alignment.center,
                      ),
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          primary: true,
                          physics: BouncingScrollPhysics(),
                          children: ListTile.divideTiles(
                            context: context,
                            tiles: List<Widget>.generate(100, (int index) {
                              if (index == 0) {
                                return Container(
                                  child: Text(
                                    'Latest near you',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  padding: EdgeInsets.all(20),
                                  alignment: Alignment.centerLeft,
                                );
                              }
                              return ListTile(
                                title: Text('Item $index'),
                              );
                            }),
                          ).toList(),
                        ),
                      ),
                    ]),
                  ),
                );
              });
        },
      ),
    );
  }
}
