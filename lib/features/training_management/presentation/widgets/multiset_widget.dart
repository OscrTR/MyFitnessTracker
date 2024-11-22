import 'package:flutter/material.dart';

class MultisetWidget extends StatefulWidget {
  final int widgetId;
  const MultisetWidget({super.key, required this.widgetId});

  @override
  State<MultisetWidget> createState() => _MultisetWidgetState();
}

class _MultisetWidgetState extends State<MultisetWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('Placeholder for multiset ${widget.widgetId}');
  }
}
