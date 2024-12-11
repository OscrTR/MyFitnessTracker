import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app_colors.dart';
import '../bloc/training_management_bloc.dart';
import '../../domain/entities/training.dart';
import 'trainings_list_page.dart';

class TrainingsPage extends StatelessWidget {
  const TrainingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('trainings_page_title'),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                FilledButton.icon(
                  onPressed: () {
                    _showNewDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: Text(context.tr('trainings_page_new'),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: AppColors.white)),
                )
              ],
            ),
            const SizedBox(height: 20),
            const Expanded(child: TrainingsListPage()),
          ],
        ),
      ),
    );
  }
}

void _showNewDialog(BuildContext context) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: AppColors.lightGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(context.tr('trainings_page_add_new')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              GoRouter.of(context).go('/exercise_detail');
              Navigator.pop(context, 'New exercise');
            },
            child: SizedBox(
              child: Text(context.tr('trainings_page_exercise')),
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<TrainingManagementBloc>().add(
                    const UpdateSelectedTrainingProperty(
                        type: TrainingType.yoga),
                  );
              GoRouter.of(context).go(
                '/training_detail',
                extra: TrainingType.yoga,
              );
              Navigator.pop(context, 'New yoga training');
            },
            child: SizedBox(
              child: Text(context.tr('trainings_page_yoga')),
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<TrainingManagementBloc>().add(
                    const UpdateSelectedTrainingProperty(
                        type: TrainingType.run),
                  );
              GoRouter.of(context).go(
                '/training_detail',
                extra: TrainingType.run,
              );
              Navigator.pop(context, 'New run training');
            },
            child: SizedBox(
              child: Text(context.tr('trainings_page_run')),
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<TrainingManagementBloc>().add(
                    const UpdateSelectedTrainingProperty(
                        type: TrainingType.workout),
                  );
              GoRouter.of(context).go(
                '/training_detail',
                extra: TrainingType.workout,
              );
              Navigator.pop(context, 'New workout training');
            },
            child: SizedBox(
              child: Text(context.tr('trainings_page_workout')),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: Text(context.tr('global_cancel')),
        ),
      ],
    ),
  );
}
