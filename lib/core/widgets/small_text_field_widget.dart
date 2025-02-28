import 'package:flutter/material.dart';

import '../../app_colors.dart';

class SmallTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final Color? textColor;
  final Color? backgroungColor;

  const SmallTextFieldWidget(
      {super.key,
      required this.controller,
      this.textColor,
      this.backgroungColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 36,
      decoration: BoxDecoration(
        color: backgroungColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.frenchGray,
          width: 1.0,
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor ?? AppColors.licorice),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: const EdgeInsets.only(top: 5, bottom: 5, left: 2),
            labelStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: AppColors.frenchGray),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
