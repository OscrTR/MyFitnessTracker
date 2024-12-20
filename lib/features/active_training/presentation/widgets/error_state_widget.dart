import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ErrorStateWidget extends StatefulWidget {
  const ErrorStateWidget({super.key});

  @override
  State<ErrorStateWidget> createState() => _ErrorStateWidgetState();
}

class _ErrorStateWidgetState extends State<ErrorStateWidget> {
  bool _showSpinner = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _showSpinner = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Center(
            child: _showSpinner
                ? const CircularProgressIndicator()
                : Text(context.tr('error_state'))));
  }
}
