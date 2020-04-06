import 'dart:ui';

import 'package:example/examples/sliver_container.dart';
import 'package:example/modals/modal_fit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class CupertinoSharePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(context),
        body: CupertinoPageScaffold(
          child: Center(
            child: Hero(
                tag: 'image',
                child: Image.network(
                    'https://images.unsplash.com/photo-1586042062881-03688ce69774')),
          ),
        ),
        bottomNavigationBar: bottomAppBar(context));
  }

  PreferredSizeWidget appBar(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Column(
        children: <Widget>[
          Text('New York', style: TextStyle(fontWeight: FontWeight.normal)),
          Text('1 February 11:45',
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12))
        ],
      ),
      trailing: Text(
        'Edit',
        style: TextStyle(
          color: CupertinoTheme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget bottomAppBar(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CupertinoButton(
            child: Icon(
              CupertinoIcons.share,
              size: 28,
            ),
            onPressed: () {
              showCupertinoModalBottomSheet(
                expand: true,
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context, scrollController) =>
                    PhotoShareBottomSheet(scrollController: scrollController),
              );
            },
          ),
          CupertinoButton(
            child: Icon(CupertinoIcons.heart, size: 28),
            onPressed: null,
          ),
          CupertinoButton(
            child: Icon(CupertinoIcons.delete, size: 28),
            onPressed: null,
          )
        ],
      ),
    );
  }
}

class PhotoShareBottomSheet extends StatelessWidget {
  final ScrollController scrollController;

  const PhotoShareBottomSheet({Key key, this.scrollController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
            color: Colors.transparent,
            child: Scaffold(
              backgroundColor: CupertinoTheme.of(context)
                  .scaffoldBackgroundColor
                  .withOpacity(0.95),
              extendBodyBehindAppBar: true,
              appBar: appBar(context),
              body: CustomScrollView(
                physics: ClampingScrollPhysics(),
                controller: scrollController,
                slivers: <Widget>[
                  SliverSafeArea(
                    bottom: false,
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        height: 318,
                        child: ListView(
                          padding: EdgeInsets.all(12).copyWith(
                              right:
                                  MediaQuery.of(context).size.width / 2 - 100),
                          reverse: true,
                          scrollDirection: Axis.horizontal,
                          physics: PageScrollPhysics(),
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Hero(
                                      tag: 'image',
                                      child: Image.network(
                                          'https://images.unsplash.com/photo-1586042062881-03688ce69774'),
                                    ))),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                      'https://images.unsplash.com/photo-1586042062881-03688ce69774'),
                                )),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                      'https://images.unsplash.com/photo-1586042062881-03688ce69774'),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Divider(height: 1),
                  ),
                  sliverContactsSection(context),
                  SliverToBoxAdapter(
                    child: Divider(height: 1),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      height: 120,
                      padding: EdgeInsets.only(top: 12),
                      child: ListView.builder(
                        padding: EdgeInsets.all(10),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final app = apps[index];
                          return Container(
                              width: 72,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                children: <Widget>[
                                  Material(
                                    child: ClipRRect(
                                      child: Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image:
                                                    NetworkImage(app.imageUrl),
                                                fit: BoxFit.cover),
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    elevation: 12,
                                    shadowColor: Colors.black12,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    app.title,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 11),
                                  )
                                ],
                              ));
                        },
                        itemCount: apps.length,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    sliver: SliverContainer(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate.fixed(
                              List<Widget>.from(actions.map(
                            (action) => Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                child: Text(
                                  action.title,
                                  style: CupertinoTheme.of(context)
                                      .textTheme
                                      .textStyle,
                                )),
                          )).addItemInBetween(Divider(
                            height: 1,
                          ))),
                        )),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    sliver: SliverContainer(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate.fixed(
                              List<Widget>.from(actions1.map(
                            (action) => Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                child: Text(
                                  action.title,
                                  style: CupertinoTheme.of(context)
                                      .textTheme
                                      .textStyle,
                                )),
                          )).addItemInBetween(Divider(
                            height: 1,
                          ))),
                        )),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    sliver: SliverContainer(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate.fixed(
                              List<Widget>.from(actions2.map(
                            (action) => Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                child: Text(
                                  action.title,
                                  style: CupertinoTheme.of(context)
                                      .textTheme
                                      .textStyle,
                                )),
                          )).addItemInBetween(Divider(
                            height: 1,
                          ))),
                        )),
                  ),
                  SliverSafeArea(
                    top: false,
                    sliver: SliverPadding(
                        padding: EdgeInsets.only(
                      bottom: 20,
                    )),
                  )
                ],
              ),
            )));
  }

  Widget sliverContactsSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 132,
        padding: EdgeInsets.only(top: 12),
        child: ListView.builder(
          padding: EdgeInsets.all(10),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final person = people[index];
            return Container(
              width: 72,
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: <Widget>[
                  Material(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        person.imageUrl,
                      ),
                      radius: 30,
                      backgroundColor: Colors.white,
                    ),
                    shape: CircleBorder(),
                    elevation: 12,
                    shadowColor: Colors.black12,
                  ),
                  SizedBox(height: 8),
                  Text(
                    person.title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11),
                  )
                ],
              ),
            );
          },
          itemCount: people.length,
        ),
      ),
    );
  }

  PreferredSizeWidget appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(double.infinity, 74),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: CupertinoTheme.of(context)
                .scaffoldBackgroundColor
                .withOpacity(0.8),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 18),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1586042062881-03688ce69774',
                            fit: BoxFit.cover,
                            height: 40,
                            width: 40,
                          )),
                      SizedBox(width: 12),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            '1 Photo selected',
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 4),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: <Widget>[
                                Text(
                                  'Options',
                                  style: CupertinoTheme.of(context)
                                      .textTheme
                                      .actionTextStyle
                                      .copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal),
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  CupertinoIcons.right_chevron,
                                  size: 14,
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                )
                              ]),
                        ],
                      )),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: EdgeInsets.only(top: 14),
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 24,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 14),
                    ],
                  ),
                ),
                Divider(height: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Item {
  final String title;
  final String imageUrl;

  Item(this.title, this.imageUrl);
}

final people = [
  Item('MacBook Pro',
      'https://www.uoduckstore.com/TDS%20Product%20Images/Apple%20MacBook%20Pro%2016%20w%20T%20Bar%20Late%202019_1.jpg'),
  Item('Jaime Blasco',
      'https://media-exp1.licdn.com/dms/image/C5603AQGfIMBxWBRMSg/profile-displayphoto-shrink_200_200/0?e=1591833600&v=beta&t=r6xnd4oBDfb3A3IcsgliyrT_avYaeBEwRr9XtlizWq8'),
  Item('Mya Johnston',
      'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7'),
  Item('Maxime Nicholls',
      'https://images.unsplash.com/photo-1520719627573-5e2c1a6610f0'),
  Item('Susanna Thorne',
      'https://images.unsplash.com/photo-1568707043650-eb03f2536825'),
  Item('Jarod Aguilar',
      'https://images.unsplash.com/photo-1547106634-56dcd53ae883')
];

final apps = [
  Item('Messages',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/IMessage_logo.svg/1200px-IMessage_logo.svg.png'),
  Item('Github',
      'https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png'),
  Item('Slack',
      'https://is3-ssl.mzstatic.com/image/thumb/Purple113/v4/6e/80/06/6e80063f-e5c8-3f20-d8d5-22dd0740f5ba/AppIcon-0-0-1x_U007emarketing-0-0-0-7-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/246x0w.png'),
  Item('Twitter',
      'https://cfcdnpull-creativefreedoml.netdna-ssl.com/wp-content/uploads/2015/06/Twitter-bird-white-blue2.png'),
  Item('Mail',
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Mail_%28iOS%29.svg/1200px-Mail_%28iOS%29.svg.png'),
];

final actions = [
  Item('Copy Photo', null),
];
final actions1 = [
  Item('Add to Shared Album', null),
  Item('Add to Album', null),
  Item('Duplicate', null),
  Item('Hide', null),
  Item('Slideshow', null),
  Item('AirPlay', null),
  Item('Use as Wallpaper', null),
];

final actions2 = [
  Item('Create Watch', null),
  Item('Save to Files', null),
  Item('Asign to Contact', null),
  Item('Print', null),
];

extension ListUtils<T> on List<T> {
  List<T> addItemInBetween<T>(T item) => this.length == 0
      ? this
      : (this.fold([], (r, element) => [...r, element as T, item])
        ..removeLast());
}

class SimpleSliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  SimpleSliverDelegate({
    this.child,
    this.height,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(height: height, child: child);
  }

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
