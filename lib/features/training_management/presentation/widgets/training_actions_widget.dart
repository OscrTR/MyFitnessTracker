import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../assets/app_colors.dart';
import '../bloc/training_management_bloc.dart';

class TrainingActionsWidget extends StatelessWidget {
  const TrainingActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context
                      .read<TrainingManagementBloc>()
                      .add(AddExerciseToSelectedTrainingEvent());
                },
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightBlack),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child:
                        Text(context.tr('training_detail_page_add_exercise')),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context
                      .read<TrainingManagementBloc>()
                      .add(AddRunToSelectedTrainingEvent());
                },
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightBlack),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(context.tr('training_detail_page_add_run')),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            context
                .read<TrainingManagementBloc>()
                .add(AddMultisetToSelectedTrainingEvent());
          },
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightBlack),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(context.tr('training_detail_page_add_multiset')),
            ),
          ),
        )
      ],
    );
  }
}
