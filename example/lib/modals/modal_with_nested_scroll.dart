import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NestedScrollModal extends StatelessWidget {
  const NestedScrollModal({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final scrollController = PrimaryScrollController.of(context);
    return NestedScrollView(
      controller: ScrollController(),
      physics: ScrollPhysics(parent: PageScrollPhysics()),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(height: 300, color: Colors.blue),
              ],
            ),
          ),
        ];
      },
      body: ListView.builder(
        controller: scrollController,
        itemBuilder: (context, index) {
          return Container(
            height: 100,
            color: index.isOdd ? Colors.green : Colors.orange,
          );
        },
        itemCount: 12,
      ),
    );
  }
}
