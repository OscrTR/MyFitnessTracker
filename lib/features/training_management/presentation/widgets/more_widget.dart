import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/bloc/training_management_bloc.dart';

import '../../../../assets/app_colors.dart';

class MoreWidget extends StatelessWidget {
  final String? multisetKey;
  final String? exerciseKey;

  const MoreWidget({super.key, this.exerciseKey, this.multisetKey});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) {
        final bloc = BlocProvider.of<TrainingManagementBloc>(context);
        if (value == 'delete') {
          // Delete multiset
          if (multisetKey != null && exerciseKey == null) {
            bloc.add(RemoveExerciseFromSelectedTrainingEvent(multisetKey!));
          }
          // Delete exercise multiset
          else if (multisetKey != null && exerciseKey != null) {
            bloc.add(RemoveExerciseFromSelectedTrainingMultisetEvent(
                multisetKey!, exerciseKey!));
          }
          // Delete exercise
          else if (multisetKey == null && exerciseKey != null) {
            bloc.add(RemoveExerciseFromSelectedTrainingEvent(exerciseKey!));
          }
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [Text(context.tr('global_delete'))],
          ),
        ),
      ],
      icon: const Icon(
        Icons.more_horiz,
        color: AppColors.lightBlack,
      ),
    );
  }
}
