import 'package:flutter/material.dart';
import '../../../../assets/app_colors.dart';

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
          color: AppColors.lightBlack,
          width: 1.0,
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor ?? AppColors.black),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: const EdgeInsets.only(top: 5, bottom: 5, left: 2),
            labelStyle: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: AppColors.lightBlack),
            border: InputBorder.none,
            // enabledBorder: const OutlineInputBorder(
            //   borderRadius: BorderRadius.all(Radius.circular(10)),
            //   borderSide: BorderSide(
            //     color: AppColors.lightBlack,
            //     width: 1.0,
            //   ),
            // ),
            // focusedBorder: const OutlineInputBorder(
            //   borderRadius: BorderRadius.all(Radius.circular(10)),
            //   borderSide: BorderSide(
            //     color: AppColors.lightBlack,
            //     width: 1.0,
            //   ),
            // ),
          ),
        ),
      ),
    );
  }
}
