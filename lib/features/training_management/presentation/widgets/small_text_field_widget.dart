import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/assets/app_colors.dart';

class SmallTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;

  const SmallTextFieldWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 40,
      child: Center(
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 5),
            labelStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: AppColors.lightBlack),
            border: InputBorder.none,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                color: AppColors.lightBlack,
                width: 1.0,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                color: AppColors.lightBlack,
                width: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
