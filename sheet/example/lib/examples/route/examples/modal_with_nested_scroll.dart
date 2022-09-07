import 'package:flutter/material.dart';

class NestedScrollModal extends StatelessWidget {
  const NestedScrollModal({super.key});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      physics: const ClampingScrollPhysics(),
      controller: PrimaryScrollController.of(context),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Container(height: 300, color: Colors.blue),
              ],
            ),
          ),
        ];
      },
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
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
