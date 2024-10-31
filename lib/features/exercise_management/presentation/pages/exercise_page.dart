import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_fitness_tracker/core/app_colors.dart';
import '../bloc/exercise_management_bloc.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.lightGrey),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.list,
                  color: AppColors.black,
                ),
                const SizedBox(width: 10),
                Text(
                  context.tr('exercise_page_exercises'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Expanded(child: ExerciseList()),
        ],
      ),
    );
  }
}

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
              return Container(
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightGrey),
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 10, right: 0),
                  title: Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        BlocProvider.of<ExerciseManagementBloc>(context)
                            .add(GetExerciseEvent(exercise.id!));
                        GoRouter.of(context).go('/exercise_detail');
                      } else if (value == 'delete') {
                        BlocProvider.of<ExerciseManagementBloc>(context)
                            .add(DeleteExerciseEvent(exercise.id!));
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Text(
                              context.tr('global_edit'),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Text(
                              context.tr('global_delete'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppColors.lightBlack,
                    ),
                  ),
                ),
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
