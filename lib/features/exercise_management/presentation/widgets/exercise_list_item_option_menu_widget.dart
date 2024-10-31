import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_colors.dart';
import '../bloc/exercise_management_bloc.dart';

class ExerciseListItemOptionsMenu extends StatelessWidget {
  final int exerciseId;

  const ExerciseListItemOptionsMenu({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) {
        final bloc = BlocProvider.of<ExerciseManagementBloc>(context);
        if (value == 'edit') {
          bloc.add(GetExerciseEvent(exerciseId));
          GoRouter.of(context).go('/exercise_detail');
        } else if (value == 'delete') {
          bloc.add(DeleteExerciseEvent(exerciseId));
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [Text(context.tr('global_edit'))],
          ),
        ),
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
