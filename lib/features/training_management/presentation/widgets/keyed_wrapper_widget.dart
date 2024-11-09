import 'package:flutter/material.dart';

class KeyedWrapperWidget extends StatelessWidget {
  final Widget widget;
  final int uniqueId;

  KeyedWrapperWidget({
    Key? key,
    required this.widget,
    required this.uniqueId,
  }) : super(
            key: ValueKey(uniqueId)); // Assign a unique key based on `uniqueId`

  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.only(bottom: 10), child: widget);
  }
}
