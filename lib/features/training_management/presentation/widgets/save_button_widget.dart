import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../assets/app_colors.dart';
import '../../domain/entities/training.dart';

class SaveButtonWidget extends StatelessWidget {
  final Training? training;
  final VoidCallback onSave;

  const SaveButtonWidget({super.key, this.training, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSave,
      child: Container(
        decoration: BoxDecoration(
          color: training == null ? AppColors.lightGrey : AppColors.black,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr(training == null ? 'global_create' : 'global_save'),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: training == null
                        ? AppColors.lightBlack
                        : AppColors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
