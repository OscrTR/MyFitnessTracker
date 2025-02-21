import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/base_exercise_management_bloc.dart';
import 'base_exercise_list_item_widget.dart';

class BaseExercisesList extends StatelessWidget {
  const BaseExercisesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BaseExerciseManagementBloc, BaseExerciseManagementState>(
      builder: (context, state) {
        if (state is BaseExerciseManagementLoaded) {
          return ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 10.0),
            itemCount: state.baseExercises.length,
            itemBuilder: (context, index) {
              final exercise = state.baseExercises[index];
              return BaseExercisesListItem(
                exerciseId: exercise.id!,
                exerciseName: exercise.name,
                exerciseImagePath: exercise.imagePath,
                exerciseDescription: exercise.description,
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
