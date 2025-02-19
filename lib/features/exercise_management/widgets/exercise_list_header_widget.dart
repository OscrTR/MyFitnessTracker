import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../app_colors.dart';

class ExerciseListHeader extends StatelessWidget {
  const ExerciseListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.whiteSmoke,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(
            Icons.list,
            color: AppColors.licorice,
            size: 30,
          ),
          const SizedBox(width: 10),
          Text(
            context.tr('exercise_page_exercises'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
