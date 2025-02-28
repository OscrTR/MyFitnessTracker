import 'package:flutter/material.dart';

import '../../app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Color borderColor;
  final Color backgroundColor;

  const CustomTextField(
      {required this.controller,
      required this.hintText,
      this.backgroundColor = AppColors.white,
      this.borderColor = AppColors.timberwolf,
      super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      maxLines: null,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        filled: true,
        fillColor: backgroundColor,
        labelText: hintText,
        labelStyle: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(color: AppColors.taupeGray),
        border: InputBorder.none,
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(
            color: borderColor,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(
            color: borderColor,
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
