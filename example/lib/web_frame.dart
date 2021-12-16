import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebFrame extends StatelessWidget {
  final Widget child;

  const WebFrame({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && MediaQuery.of(context).size.width > 600) {
      final date = DateTime.now();
      final MediaQueryData mediaQuery = MediaQueryData(
        size: Size(414, 896),
        padding: EdgeInsets.only(
          top: 44,
          bottom: 34,
        ),
        devicePixelRatio: 2,
      );
      return Material(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                flex: 2,
                key: Key('Preview'),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Builder(builder: (context) {
                    final device = MediaQuery(
                      data: mediaQuery,
                      child: Container(
                          width: mediaQuery.size.width,
                          height: mediaQuery.size.height,
                          alignment: Alignment.center,
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              child,
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: 44,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                        padding:
                                            EdgeInsets.only(left: 30, top: 4),
                                        child: Text(
                                          '${date.hour}:${date.minute}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Padding(
                                        padding: EdgeInsets.only(right: 18),
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.signal_cellular_4_bar,
                                              size: 14,
                                            ),
                                            SizedBox(width: 4),
                                            Icon(Icons.wifi, size: 16),
                                            SizedBox(width: 4),
                                            Icon(
                                                CupertinoIcons.battery_charging,
                                                size: 20)
                                          ],
                                        ))
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  height: 4,
                                  width: 140,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                              )
                            ],
                          )),
                    );

                    return Container(
                      child: ClipRRect(
                          clipBehavior: Clip.antiAlias,
                          borderRadius: BorderRadius.circular(38.5),
                          child: device),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.black, width: 12)),
                    );
                  }),
                ),
              ),
              SizedBox(width: 80),
              Flexible(
                  flex: 1,
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                          padding: EdgeInsets.only(bottom: 40),
                          width: mediaQuery.size.width,
                          height: mediaQuery.size.height,
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                  child: Text(
                                'Modal\nBottom\nSheet',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 80,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.clip,
                              )),
                              Spacer(),
                              Row(
                                children: <Widget>[
                                  InkWell(
                                    onTap: () => launch(
                                        'https://pub.dev/packages/modal_bottom_sheet'),
                                    child: Image.asset('assets/flutter.png',
                                        height: 60),
                                  ),
                                  Spacer(),
                                  InkWell(
                                    onTap: () => launch(
                                        'https://github.com/jamesblasco/modal_bottom_sheet'),
                                    child: Image.asset('assets/github.png',
                                        height: 60),
                                  ),
                                ],
                              )
                            ],
                          ))))
            ],
          ),
        ),
      );
    } else {
      return child;
    }
  }
}
