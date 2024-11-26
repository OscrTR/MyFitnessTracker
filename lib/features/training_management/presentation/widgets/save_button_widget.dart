import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/bloc/training_management_bloc.dart';
import '../../../../assets/app_colors.dart';

class SaveButtonWidget extends StatelessWidget {
  final VoidCallback onSave;

  const SaveButtonWidget({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final bool isNewTraining = (context.read<TrainingManagementBloc>().state
                as TrainingManagementLoaded)
            .selectedTraining!
            .id ==
        null;

    bool isActive = false;

    if (isNewTraining &&
        (context.read<TrainingManagementBloc>().state
                as TrainingManagementLoaded)
            .hasExercisesOrMultisets) {
      isActive = true;
    }

    if (!isNewTraining) {
      isActive = true;
    }

    return GestureDetector(
      onTap: isActive ? onSave : null,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? AppColors.black : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr(isNewTraining ? 'global_create' : 'global_save'),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: isActive ? AppColors.white : AppColors.lightBlack,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
