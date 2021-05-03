import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NestedScrollModal extends StatelessWidget {
  const NestedScrollModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      physics: ClampingScrollPhysics(),
      controller: PrimaryScrollController.of(context),
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
