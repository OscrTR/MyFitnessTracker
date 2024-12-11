import 'package:flutter/material.dart';

import '../../../../app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const CustomTextField(
      {required this.controller, required this.hintText, super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: hintText,
        labelStyle: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(color: AppColors.lightBlack),
        border: InputBorder.none,
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(
            color: AppColors.lightBlack,
            width: 1.0,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(
            color: AppColors.lightBlack,
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
