import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_fitness_tracker/features/training_management/presentation/bloc/training_management_bloc.dart';

import '../../../../assets/app_colors.dart';

class MoreWidget extends StatelessWidget {
  final String trainingExerciseKey;

  const MoreWidget({super.key, required this.trainingExerciseKey});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) {
        final bloc = BlocProvider.of<TrainingManagementBloc>(context);
        if (value == 'delete') {
          bloc.add(
              RemoveExerciseFromSelectedTrainingEvent(trainingExerciseKey));
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
