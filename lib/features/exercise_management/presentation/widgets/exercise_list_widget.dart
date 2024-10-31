import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/exercise_management_bloc.dart';
import 'exercise_list_item_widget.dart';

class ExerciseList extends StatelessWidget {
  const ExerciseList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseManagementBloc, ExerciseManagementState>(
      builder: (context, state) {
        if (state is ExerciseManagementLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ExerciseManagementLoaded) {
          return ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 10.0),
            itemCount: state.exercises.length,
            itemBuilder: (context, index) {
              final exercise = state.exercises[index];
              return ExerciseListItem(
                exerciseId: exercise.id!,
                exerciseName: exercise.name,
                exerciseImagePath: exercise.imagePath,
                exerciseDescription: exercise.description,
              );
            },
          );
        } else if (state is ExerciseManagementFailure) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
