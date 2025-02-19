import 'package:flutter/material.dart';

import '../../../app_colors.dart';
import 'exercise_list_item_option_menu_widget.dart';

class ExerciseListItem extends StatelessWidget {
  final int exerciseId;
  final String exerciseName;
  final String? exerciseImagePath;
  final String? exerciseDescription;

  const ExerciseListItem({
    super.key,
    required this.exerciseName,
    required this.exerciseId,
    required this.exerciseImagePath,
    required this.exerciseDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.whiteSmoke),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 10, right: 0),
        title: Text(
          exerciseName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: ExerciseListItemOptionsMenu(exerciseId: exerciseId),
      ),
    );
  }
}
